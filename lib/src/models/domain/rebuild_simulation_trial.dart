import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';

/// 再構築シミュレーションの試行結果
///
/// 仮想的に再構築を実行した結果を保持します。
class RebuildSimulationTrial {
  const RebuildSimulationTrial({
    required this.newSubstats,
    required this.newScore,
    required this.scoreDiff,
    required this.isImproved,
  });

  /// 新しいサブステータス一覧（4つ）
  final List<SubstatSummary> newSubstats;

  /// シミュレーション後のスコア
  final double newScore;

  /// スコア差分（新 - 旧）
  final double scoreDiff;

  /// 改善されたか（新スコア > 旧スコア）
  final bool isImproved;
}
