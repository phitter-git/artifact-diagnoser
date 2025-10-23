import 'package:artifact_diagnoser/src/models/domain.dart';
import 'package:artifact_diagnoser/src/utils/probability_calculator.dart';

/// 再構築シミュレーターサービス
///
/// 選択した2つのサブステータスと再構築種別に基づいて、
/// 理論最大値と更新率を計算します。
class RebuildSimulatorService {
  /// サブステータスの優先度マップ（高い方を優先的に強化）
  ///
  /// 優先度: 会心率 > 会心ダメージ > 防御力% > 元素チャージ効率 > 攻撃力% > HP% > 元素熟知
  static const _substatPriority = {
    'FIGHT_PROP_CRITICAL': 7, // 会心率
    'FIGHT_PROP_CRITICAL_HURT': 6, // 会心ダメージ
    'FIGHT_PROP_DEFENSE_PERCENT': 5, // 防御力%
    'FIGHT_PROP_CHARGE_EFFICIENCY': 4, // 元素チャージ効率
    'FIGHT_PROP_ATTACK_PERCENT': 3, // 攻撃力%
    'FIGHT_PROP_HP_PERCENT': 2, // HP%
    'FIGHT_PROP_ELEMENT_MASTERY': 1, // 元素熟知
  };

  /// スコア係数マップ
  ///
  /// 会心率×2、会心ダメージ×1、攻撃力%×1、その他×1、元素熟知×0.25
  static const _scoreCoefficients = {
    'FIGHT_PROP_CRITICAL': 2.0,
    'FIGHT_PROP_CRITICAL_HURT': 1.0,
    'FIGHT_PROP_ATTACK_PERCENT': 1.0,
    'FIGHT_PROP_DEFENSE_PERCENT': 1.0,
    'FIGHT_PROP_HP_PERCENT': 1.0,
    'FIGHT_PROP_CHARGE_EFFICIENCY': 1.0,
    'FIGHT_PROP_ELEMENT_MASTERY': 0.25,
  };

  /// 小数点第2位で四捨五入
  double _round(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  /// 基本情報を計算（再構築種別に依存しない）
  ///
  /// [substat1] 選択サブステータス1
  /// [substat2] 選択サブステータス2
  /// [initialSubstatCount] 初期サブステータス数（3または4）
  /// [scoreTargetPropIds] スコア計算対象のpropIdセット
  ///
  /// 計算内容:
  /// - 残り強化回数
  /// - 優先度に基づくプライマリ・セカンダリの決定
  /// - 現在スコア
  /// - 初期値スコア
  /// - 理論値
  /// - 理論スコア
  /// - 更新可能かどうか
  RebuildSimulationResult calculateBaseInfo({
    required SubstatSummary substat1,
    required SubstatSummary substat2,
    required List<SubstatSummary> allSubstats,
    required int initialSubstatCount,
    required Set<String> scoreTargetPropIds,
  }) {
    // 残り強化回数を計算（初期3なら4回、初期4なら5回）
    final remainingEnhancements = initialSubstatCount == 4 ? 5 : 4;

    // 優先度に基づいてプライマリ・セカンダリを決定
    final priority1 = _substatPriority[substat1.propId] ?? 0;
    final priority2 = _substatPriority[substat2.propId] ?? 0;
    final primarySubstat = priority1 >= priority2 ? substat1 : substat2;
    final secondarySubstat = priority1 >= priority2 ? substat2 : substat1;

    // 現在スコアを計算
    final currentScore = _calculateCurrentScore(
      allSubstats,
      scoreTargetPropIds,
    );

    // 初期値スコアを計算（×1状態）
    final initialScore = _calculateInitialScore(
      allSubstats,
      scoreTargetPropIds,
    );

    // 理論値を計算（優先サブステを最大回数強化、その他は×1）
    final theoreticalValues = _calculateTheoreticalValues(
      allSubstats: allSubstats,
      primarySubstat: primarySubstat,
      remainingEnhancements: remainingEnhancements,
    );

    // 理論スコアを計算
    final theoreticalMaxScore = _calculateTheoreticalScore(
      allSubstats,
      theoreticalValues,
      scoreTargetPropIds,
    );

    // 更新可能かチェック
    final isUpdatePossible = theoreticalMaxScore > currentScore;

    return RebuildSimulationResult(
      currentScore: _round(currentScore),
      initialScore: _round(initialScore),
      theoreticalMaxScore: _round(theoreticalMaxScore),
      updateRate: 0.0,
      successPatternCount: 0,
      totalPatternCount: 0,
      primarySubstat: primarySubstat,
      secondarySubstat: secondarySubstat,
      allSubstats: allSubstats,
      theoreticalValues: theoreticalValues,
      remainingEnhancements: remainingEnhancements,
      isUpdatePossible: isUpdatePossible,
      rebuildType: RebuildType.normal,
    );
  }

  /// 更新率を計算（再構築種別ごと）
  ///
  /// [baseInfo] 基本情報（calculateBaseInfo()の結果）
  /// [rebuildType] 再構築種別
  /// [scoreTargetPropIds] スコア計算対象のpropIdセット
  ///
  /// 返り値: 更新率（0.0～100.0のパーセント値）
  double calculateUpdateRate({
    required RebuildSimulationResult baseInfo,
    required RebuildType rebuildType,
    required Set<String> scoreTargetPropIds,
  }) {
    // valueSets構築（スコア係数適用）
    final valueSets = _buildValueSets(baseInfo.allSubstats, scoreTargetPropIds);

    // score（しきい値 = 現在スコア - 初期値スコア）
    final score = baseInfo.currentScore - baseInfo.initialScore;

    // selectCount（残り強化回数）
    final selectCount = baseInfo.remainingEnhancements;

    // forcedCount（再構築種別による保証回数）
    final forcedCount = _getForcedCount(rebuildType);

    // forcedTarget（希望サブオプション2個）
    final forcedTarget = [
      baseInfo.primarySubstat.propId,
      baseInfo.secondarySubstat.propId,
    ];

    // scoredTarget（スコア計算対象サブオプション）
    // この聖遺物のサブステータスに存在するものだけをフィルタリング
    final existingPropIds = baseInfo.allSubstats.map((s) => s.propId).toSet();
    final scoredTarget = scoreTargetPropIds
        .where((propId) => existingPropIds.contains(propId))
        .toList();

    // 厳密計算で確率を求める
    final probability = ProbabilityCalculator.calculateExceedingProbability(
      valueSets: valueSets,
      score: score,
      selectCount: selectCount,
      forcedCount: forcedCount,
      forcedTarget: forcedTarget,
      scoredTarget: scoredTarget,
    );

    // パーセント表示に変換
    return probability * 100.0;
  }

  /// valueSetsを構築（スコア係数適用）
  ///
  /// スコア計算対象のサブステータスには係数を適用し、
  /// それ以外はそのままの値を使用します。
  Map<String, List<double>> _buildValueSets(
    List<SubstatSummary> allSubstats,
    Set<String> scoreTargetPropIds,
  ) {
    final valueSets = <String, List<double>>{};
    for (final substat in allSubstats) {
      final coefficient = _scoreCoefficients[substat.propId] ?? 1.0;
      // スコア計算対象の場合のみ係数を適用
      if (scoreTargetPropIds.contains(substat.propId)) {
        valueSets[substat.propId] = substat.tierValues
            .map((v) => v * coefficient)
            .toList();
      } else {
        // スコア対象外は係数なし（でも計算には含める）
        valueSets[substat.propId] = substat.tierValues;
      }
    }
    return valueSets;
  }

  /// 再構築種別から保証回数を取得
  ///
  /// - 通常: 最低2回
  /// - 高級: 最低3回
  /// - 絶対: 最低4回
  int _getForcedCount(RebuildType rebuildType) {
    switch (rebuildType) {
      case RebuildType.normal:
        return 2;
      case RebuildType.advanced:
        return 3;
      case RebuildType.absolute:
        return 4;
    }
  }

  /// 現在スコアを計算
  double _calculateCurrentScore(
    List<SubstatSummary> allSubstats,
    Set<String> scoreTargetPropIds,
  ) {
    double score = 0.0;
    for (final substat in allSubstats) {
      if (scoreTargetPropIds.contains(substat.propId)) {
        final coefficient = _scoreCoefficients[substat.propId] ?? 1.0;
        score += substat.statValue * coefficient;
      }
    }
    return _round(score);
  }

  /// 初期値スコアを計算（×1状態）
  double _calculateInitialScore(
    List<SubstatSummary> allSubstats,
    Set<String> scoreTargetPropIds,
  ) {
    double score = 0.0;
    for (final substat in allSubstats) {
      if (scoreTargetPropIds.contains(substat.propId)) {
        final coefficient = _scoreCoefficients[substat.propId] ?? 1.0;
        score += substat.rollValues[0] * coefficient;
      }
    }
    return _round(score);
  }

  /// 理論値を計算（優先サブステを最大回数強化、その他は×1）
  Map<String, double> _calculateTheoreticalValues({
    required List<SubstatSummary> allSubstats,
    required SubstatSummary primarySubstat,
    required int remainingEnhancements,
  }) {
    final theoreticalValues = <String, double>{};

    for (final substat in allSubstats) {
      if (substat.propId == primarySubstat.propId) {
        // 優先サブステ: ×1 + (最大値 × 残り強化回数)
        final initialValue = substat.rollValues[0];
        final maxRollValue = substat.maxRollValue; // 最大値
        theoreticalValues[substat.propId] = _round(
          initialValue + (maxRollValue * remainingEnhancements),
        );
      } else {
        // その他: ×1のみ（初回値）
        theoreticalValues[substat.propId] = _round(substat.rollValues[0]);
      }
    }

    return theoreticalValues;
  }

  /// 理論スコアを計算
  double _calculateTheoreticalScore(
    List<SubstatSummary> allSubstats,
    Map<String, double> theoreticalValues,
    Set<String> scoreTargetPropIds,
  ) {
    double score = 0.0;
    for (final substat in allSubstats) {
      if (scoreTargetPropIds.contains(substat.propId)) {
        final coefficient = _scoreCoefficients[substat.propId] ?? 1.0;
        final value = theoreticalValues[substat.propId] ?? 0.0;
        score += value * coefficient;
      }
    }
    return _round(score);
  }
}
