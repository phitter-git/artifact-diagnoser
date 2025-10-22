import 'package:artifact_diagnoser/src/models/domain.dart';

/// 再構築シミュレーション結果
///
/// 選択した2つのサブステータスと再構築種別に基づいて計算された、
/// 理論最大値と更新率の情報を保持します。
class RebuildSimulationResult {
  const RebuildSimulationResult({
    required this.currentScore,
    required this.initialScore,
    required this.theoreticalMaxScore,
    required this.updateRate,
    required this.successPatternCount,
    required this.totalPatternCount,
    required this.primarySubstat,
    required this.secondarySubstat,
    required this.allSubstats,
    required this.theoreticalValues,
    required this.remainingEnhancements,
    required this.isUpdatePossible,
    required this.rebuildType,
  });

  /// 現在のスコア（再構築前、スコア対象選択を反映）
  final double currentScore;

  /// 初期値スコア（×1状態、スコア対象選択を反映）
  final double initialScore;

  /// 理論最大スコア（優先サブステを最大回数強化、×1状態から）
  final double theoreticalMaxScore;

  /// 更新率（0.0～100.0）
  final double updateRate;

  /// 成功パターン数（現在スコアを超えるパターンの数）
  final int successPatternCount;

  /// 総パターン数
  final int totalPatternCount;

  /// 優先サブステータス（選択2つのうち優先度が高い方）
  final SubstatSummary primarySubstat;

  /// 非優先サブステータス（選択2つのうち優先度が低い方）
  final SubstatSummary secondarySubstat;

  /// 全サブステータス（4つ）
  final List<SubstatSummary> allSubstats;

  /// 各サブステの理論値（×1状態から計算、優先のみ最大回数強化）
  final Map<String, double> theoreticalValues;

  /// 残り強化回数（初期3なら4回、初期4なら5回）
  final int remainingEnhancements;

  /// 更新可能か（理論スコア > 現在スコア）
  final bool isUpdatePossible;

  /// 再構築種別
  final RebuildType rebuildType;

  /// 目標スコア（現在スコアを超えるために必要な最小スコア）
  double get targetScore => currentScore + 0.1 - initialScore;

  /// スコア増加量（理論スコア - 現在スコア）
  double get scoreIncrease => theoreticalMaxScore - currentScore;
}
