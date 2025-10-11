import 'package:artifact_diagnoser/src/models/remote/user_data.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/models/domain/mutable_substat.dart';
import 'package:artifact_diagnoser/src/services/stat_localizer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/src/services/artifact_icon_resolver.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';

/// 聖遺物解析サービス
class ReliquaryAnalysisService {
  /// ユーザーデータから聖遺物解析結果を構築する
  static List<ReliquarySummary> buildReliquarySummaries(
    UserData data,
    StatLocalizer localizer,
    StatAppendResolver appendResolver,
    ArtifactIconResolver iconResolver,
  ) {
    final results = <ReliquarySummary>[];

    for (final avatar in data.avatarInfoList) {
      for (final equipment in avatar.equipList) {
        final reliquary = equipment.reliquary;
        final flat = equipment.flat;

        // 聖遺物データが不完全な場合はスキップ
        if (reliquary == null || flat.reliquarySubstats == null) {
          continue;
        }

        final substats = flat.reliquarySubstats!;
        final appendIds = reliquary.appendPropIdList ?? const <int>[];
        final entries = <MutableSubstat>[];
        final map = <String, MutableSubstat>{};

        // 初期サブステータス数を判定（appendIds長から逆算: 8個=初期3, 9個=初期4）
        final initialSubstatCount = appendIds.length == 8 ? 3 : 4;

        // 各サブステータスの強化レベルを追跡
        final enhancementLevelsMap = <String, List<int>>{};

        // 初期サブステータスの処理
        for (var i = 0; i < substats.length; i++) {
          final substat = substats[i];
          final identifier = i < appendIds.length
              ? extractIdentifier(appendIds[i])
              : substat.appendPropId;
          final initialList = <int>[];

          if (i < appendIds.length) {
            initialList.add(extractSuffix(appendIds[i]));
          }

          final entry = MutableSubstat(
            appendPropId: substat.appendPropId,
            statValue: substat.statValue,
            identifier: identifier,
            statAppendList: initialList,
          );
          entries.add(entry);
          map[identifier] = entry;

          // 初期サブステータスの強化レベルを記録
          if (i < initialSubstatCount) {
            // 初期サブステータス（+0で付与）
            enhancementLevelsMap[identifier] = [0];
          } else {
            // +4で追加されたサブステータス
            enhancementLevelsMap[identifier] = [4];
          }
        }

        // 追加強化の処理
        // 初期3個の場合 (appendPropIdList長=8):
        //   [0][1][2] = 初期3個 (+0時点)
        //   [3] = +4で追加される4つ目のサブステータス (追加のみ、強化なし)
        //   [4] = +8での強化
        //   [5] = +12での強化
        //   [6] = +16での強化
        //   [7] = +20での強化
        //
        // 初期4個の場合 (appendPropIdList長=9):
        //   [0][1][2][3] = 初期4個 (+0時点)
        //   [4] = +4での強化
        //   [5] = +8での強化
        //   [6] = +12での強化
        //   [7] = +16での強化
        //   [8] = +20での強化

        if (initialSubstatCount == 3) {
          // 初期3個の場合
          // インデックス3は+4で追加されるサブステータス（すでに処理済み）
          // インデックス4以降が+8, +12, +16, +20での強化
          final enhancementStages = [8, 12, 16, 20]; // +4での強化はなし
          for (var i = substats.length; i < appendIds.length; i++) {
            final identifier = extractIdentifier(appendIds[i]);
            final suffix = extractSuffix(appendIds[i]);
            final entry = map[identifier];
            entry?.statAppendList.add(suffix);

            // i=3: 4つ目のサブステータス（+4で追加）← すでにenhancementLevels[4]設定済み
            // i=4: +8での強化
            // i=5: +12での強化
            // i=6: +16での強化
            // i=7: +20での強化
            if (i >= 4) {
              final stageIndex = i - 4; // 4→0(+8), 5→1(+12), 6→2(+16), 7→3(+20)
              if (stageIndex < enhancementStages.length) {
                final enhancementLevel = enhancementStages[stageIndex];
                enhancementLevelsMap[identifier]?.add(enhancementLevel);
              }
            }
          }
        } else {
          // 初期4個の場合
          final enhancementStages = [4, 8, 12, 16, 20];
          for (var i = substats.length; i < appendIds.length; i++) {
            final identifier = extractIdentifier(appendIds[i]);
            final suffix = extractSuffix(appendIds[i]);
            final entry = map[identifier];
            entry?.statAppendList.add(suffix);

            // i=4: +4での強化
            // i=5: +8での強化
            // i=6: +12での強化
            // i=7: +16での強化
            // i=8: +20での強化
            final stageIndex = i - substats.length; // 4→0(+4), 5→1(+8), ...
            if (stageIndex < enhancementStages.length) {
              final enhancementLevel = enhancementStages[stageIndex];
              enhancementLevelsMap[identifier]?.add(enhancementLevel);
            }
          }
        }

        // 聖遺物解析結果を作成
        results.add(
          ReliquarySummary(
            avatarId: avatar.avatarId,
            itemId: equipment.itemId,
            equipType: flat.equipType,
            equipTypeLabel: localizer.labelFor(flat.equipType),
            mainPropId: flat.reliquaryMainstat?.mainPropId,
            mainPropLabel: localizer.labelFor(
              flat.reliquaryMainstat?.mainPropId,
            ),
            mainStatValue: flat.reliquaryMainstat?.statValue,
            iconAssetPath: iconResolver.pathFor(flat.icon, flat.equipType),
            level: equipment.reliquary?.level ?? 1,
            substats: entries.map((entry) {
              final appendValues = appendResolver.valuesFor(
                entry.appendPropId,
                entry.statAppendList,
              );
              final enhancementLevels =
                  enhancementLevelsMap[entry.identifier] ?? [];
              return entry.toSubstatSummary(
                displayName: localizer.labelFor(entry.appendPropId),
                appendValueStrings: appendValues,
                enhancementLevels: enhancementLevels,
              );
            }).toList(),
          ),
        );
      }
    }
    return results;
  }
}
