import 'package:artifact_diagnoser/src/models/remote/user_data.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/models/domain/mutable_substat.dart';
import 'package:artifact_diagnoser/src/services/stat_localizer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/src/services/artifact_icon_resolver.dart';
import 'package:artifact_diagnoser/src/common/format_utils.dart';

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
        }

        // 追加強化の処理
        for (var i = substats.length; i < appendIds.length; i++) {
          final identifier = extractIdentifier(appendIds[i]);
          final suffix = extractSuffix(appendIds[i]);
          final entry = map[identifier];
          entry?.statAppendList.add(suffix);
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
            substats: entries.map((entry) {
              final appendValues = appendResolver.valuesFor(
                entry.appendPropId,
                entry.statAppendList,
              );
              return entry.toSubstatSummary(
                displayName: localizer.labelFor(entry.appendPropId),
                appendValueStrings: appendValues,
              );
            }).toList(),
          ),
        );
      }
    }
    return results;
  }
}
