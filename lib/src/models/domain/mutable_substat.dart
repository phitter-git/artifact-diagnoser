import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';

/// 内部で使用する可変サブステータス
class MutableSubstat {
  MutableSubstat({
    required this.propId,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
  });

  final String propId;
  final double statValue;
  final String identifier;
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
