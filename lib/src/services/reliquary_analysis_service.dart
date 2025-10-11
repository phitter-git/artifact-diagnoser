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
        final rollValuesMap = <String, List<double>>{};

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
            propId: substat.appendPropId,
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
            // 初期値をrollValuesに追加
            final tierSuffix = extractSuffix(appendIds[i]);
            final initialValue = _getRollValue(
              appendResolver,
              substat.appendPropId,
              tierSuffix,
            );
            rollValuesMap[identifier] = [initialValue];
          } else {
            // +4で追加されたサブステータス
            enhancementLevelsMap[identifier] = [4];
            final tierSuffix = extractSuffix(appendIds[i]);
            final initialValue = _getRollValue(
              appendResolver,
              substat.appendPropId,
              tierSuffix,
            );
            rollValuesMap[identifier] = [initialValue];
          }
        }

        // 追加強化の処理
        if (initialSubstatCount == 3) {
          // 初期3個の場合: インデックス3は+4で追加、4-7は+8/+12/+16/+20
          final enhancementStages = [8, 12, 16, 20];
          for (var i = substats.length; i < appendIds.length; i++) {
            final identifier = extractIdentifier(appendIds[i]);
            final suffix = extractSuffix(appendIds[i]);
            final entry = map[identifier];
            entry?.statAppendList.add(suffix);

            if (i >= 4) {
              final stageIndex = i - 4;
              if (stageIndex < enhancementStages.length) {
                final enhancementLevel = enhancementStages[stageIndex];
                enhancementLevelsMap[identifier]?.add(enhancementLevel);

                final rollValue = _getRollValue(
                  appendResolver,
                  entry?.propId ?? '',
                  suffix,
                );
                rollValuesMap[identifier]?.add(rollValue);
              }
            }
          }
        } else {
          // 初期4個の場合: インデックス4-8は+4/+8/+12/+16/+20
          final enhancementStages = [4, 8, 12, 16, 20];
          for (var i = substats.length; i < appendIds.length; i++) {
            final identifier = extractIdentifier(appendIds[i]);
            final suffix = extractSuffix(appendIds[i]);
            final entry = map[identifier];
            entry?.statAppendList.add(suffix);

            final stageIndex = i - substats.length;
            if (stageIndex < enhancementStages.length) {
              final enhancementLevel = enhancementStages[stageIndex];
              enhancementLevelsMap[identifier]?.add(enhancementLevel);

              final rollValue = _getRollValue(
                appendResolver,
                entry?.propId ?? '',
                suffix,
              );
              rollValuesMap[identifier]?.add(rollValue);
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
            initialSubstatCount: initialSubstatCount,
            substats: entries.map((entry) {
              final enhancementLevels =
                  enhancementLevelsMap[entry.identifier] ?? [];
              final rollValues = rollValuesMap[entry.identifier] ?? [];

              // ロール値の統計を計算
              final rollStats = _calculateRollStats(
                appendResolver,
                entry.propId,
              );

              return entry.toSubstatSummary(
                label: localizer.labelFor(entry.propId),
                avgRollValue: rollStats.avgRollValue,
                minRollValue: rollStats.minRollValue,
                maxRollValue: rollStats.maxRollValue,
                totalUpgrades: entry.statAppendList.length,
                enhancementLevels: enhancementLevels,
                rollValues: rollValues,
              );
            }).toList(),
          ),
        );
      }
    }
    return results;
  }

  /// ロール値を取得
  static double _getRollValue(
    StatAppendResolver resolver,
    String propId,
    int tierSuffix,
  ) {
    final values = resolver.valuesFor(propId, [tierSuffix]);
    if (values.isEmpty) return 0.0;

    final valueStr = values[0].replaceAll('%', '').replaceAll('+', '');
    return double.tryParse(valueStr) ?? 0.0;
  }

  /// ロール値の統計情報を計算
  static _RollStats _calculateRollStats(
    StatAppendResolver resolver,
    String propId,
  ) {
    // ティア1-4の値を取得
    final tier1 = _getRollValue(resolver, propId, 1);
    final tier2 = _getRollValue(resolver, propId, 2);
    final tier3 = _getRollValue(resolver, propId, 3);
    final tier4 = _getRollValue(resolver, propId, 4);

    return _RollStats(
      minRollValue: tier1,
      avgRollValue: (tier1 + tier2 + tier3 + tier4) / 4,
      maxRollValue: tier4,
    );
  }
}

/// ロール値の統計情報
class _RollStats {
  const _RollStats({
    required this.minRollValue,
    required this.avgRollValue,
    required this.maxRollValue,
  });

  final double minRollValue;
  final double avgRollValue;
  final double maxRollValue;
}
