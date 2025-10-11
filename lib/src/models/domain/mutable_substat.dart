import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';

/// 内部で使用する可変サブステータス
///
/// ReliquaryAnalysisService内でRemote → Domain変換時に使用される中間データ構造。
/// appendPropIdListの解析中に段階的にstatAppendListを構築していくため、可変性が必要。
class MutableSubstat {
  MutableSubstat({
    required this.propId,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
  });

  /// プロパティID（FIGHT_PROP_CRITICAL、FIGHT_PROP_ATTACKなど）
  final String propId;

  /// 現在のステータス値（最終累積値）
  final double statValue;

  /// サブステータスの識別子（プロパティIDから数値部分を除いたもの）
  /// 同じステータスの複数回強化を追跡するために使用
  final String identifier;

  /// ステータス抽選ティアのリスト
  /// 各要素は1-4の値で、stats_append.jsonのティアに対応
  /// 例: [2, 3, 1] = 中低値→中高値→最小値で強化
  final List<int> statAppendList;

  /// SubstatSummaryに変換する
  SubstatSummary toSubstatSummary({
    required String label,
    required double avgRollValue,
    required double minRollValue,
    required double maxRollValue,
    required int totalUpgrades,
    required List<int> enhancementLevels,
    required List<double> rollValues,
  }) {
    return SubstatSummary(
      propId: propId,
      label: label,
      statValue: statValue,
      avgRollValue: avgRollValue,
      minRollValue: minRollValue,
      maxRollValue: maxRollValue,
      totalUpgrades: totalUpgrades,
      enhancementLevels: enhancementLevels,
      rollValues: rollValues,
    );
  }
}
