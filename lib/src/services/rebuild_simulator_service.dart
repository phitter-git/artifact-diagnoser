import 'dart:math';

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

  /// 再構築シミュレーションを実行
  ///
  /// [currentSubstats] 現在のサブステータス一覧
  /// [currentScore] 現在のスコア
  /// [primarySubstat] 優先サブステータス（保持）
  /// [secondarySubstat] 非優先サブステータス（保持）
  /// [initialSubstatCount] 初期サブステータス数（3または4）
  /// [scoreTargetPropIds] スコア計算対象のpropIdセット
  /// [rebuildType] 再構築種別（最低保証回数の決定に使用）
  ///
  /// 返り値: 再構築シミュレーション結果
  RebuildSimulationTrial simulateRebuild({
    required List<SubstatSummary> currentSubstats,
    required double currentScore,
    required SubstatSummary primarySubstat,
    required SubstatSummary secondarySubstat,
    required int initialSubstatCount,
    required Set<String> scoreTargetPropIds,
    required RebuildType rebuildType,
  }) {
    final random = Random();

    // 1. 選択した2つのサブステを保持
    final preservedPropIds = {primarySubstat.propId, secondarySubstat.propId};

    // 2. 全体のサブステータスプールから、選択2つを除いた候補を取得
    final availablePropIds = currentSubstats
        .map((s) => s.propId)
        .where((propId) => !preservedPropIds.contains(propId))
        .toList();

    // 3. 残り2つをランダム抽選（重複なし）
    final newPropIds = <String>[];
    final tempPool = List<String>.from(availablePropIds);
    for (int i = 0; i < 2; i++) {
      if (tempPool.isEmpty) break;
      final index = random.nextInt(tempPool.length);
      newPropIds.add(tempPool[index]);
      tempPool.removeAt(index);
    }

    // 4. 新しいサブステータス一覧を構築（元の順序を保持）
    // 元のサブステータスの順序に従ってソート
    final allNewPropIds = <String>[];
    for (final substat in currentSubstats) {
      if (substat.propId == primarySubstat.propId ||
          substat.propId == secondarySubstat.propId ||
          newPropIds.contains(substat.propId)) {
        allNewPropIds.add(substat.propId);
      }
    }

    // 5. 各サブステの初期値を設定（既存の初期値を保持）
    final remainingEnhancements = initialSubstatCount == 4 ? 5 : 4;
    final substatsMap = <String, _SubstatSimulation>{};

    for (final propId in allNewPropIds) {
      // 元のサブステータスからtierValuesを取得
      final originalSubstat = currentSubstats.firstWhere(
        (s) => s.propId == propId,
      );

      // 初期値は元の値を保持（再構築しても初期値は変わらない）
      final initialValue = originalSubstat.rollValues.isNotEmpty
          ? originalSubstat.rollValues[0]
          : originalSubstat.tierValues[random.nextInt(4)];

      substatsMap[propId] = _SubstatSimulation(
        propId: propId,
        label: originalSubstat.label,
        tierValues: originalSubstat.tierValues,
        minRollValue: originalSubstat.minRollValue,
        maxRollValue: originalSubstat.maxRollValue,
        rollValues: [initialValue],
        rollTiers: [
          originalSubstat.tierValues.indexOf(initialValue) + 1,
        ], // 1-based
        enhancementLevels: [0],
      );
    }

    // 6. 最低保証回数を取得
    final forcedCount = _getForcedCount(rebuildType);

    // 7. 希望サブオプション（primary + secondary）に最低保証回数をランダムに割り当て
    // 注: ゲーム内の仕様では、保証回数内でもA/Bのどちらに偏るかはランダム
    final guaranteedEnhancements = <String>[];
    final guaranteedCandidates = [
      primarySubstat.propId,
      secondarySubstat.propId,
    ];
    for (int i = 0; i < forcedCount && i < remainingEnhancements; i++) {
      final selectedPropId = guaranteedCandidates[random.nextInt(2)];
      guaranteedEnhancements.add(selectedPropId);
    }

    // 8. 残りの強化回数をランダム割り当て
    final remainingRandomEnhancements =
        remainingEnhancements - guaranteedEnhancements.length;
    final randomEnhancements = <String>[];
    for (int i = 0; i < remainingRandomEnhancements; i++) {
      final selectedPropId =
          allNewPropIds[random.nextInt(allNewPropIds.length)];
      randomEnhancements.add(selectedPropId);
    }

    // 9. 保証回数とランダム回数を結合してシャッフル
    final allEnhancements = [...guaranteedEnhancements, ...randomEnhancements];
    allEnhancements.shuffle(random);

    // 10. 強化を実行
    for (int i = 0; i < allEnhancements.length; i++) {
      final selectedPropId = allEnhancements[i];
      final simulation = substatsMap[selectedPropId]!;

      // ランダムにTier値を抽選（Tier 1~4）
      final rollValue = simulation.tierValues[random.nextInt(4)];
      final rollTier = simulation.tierValues.indexOf(rollValue) + 1; // 1-based

      // 強化値を追加
      simulation.rollValues.add(rollValue);
      simulation.rollTiers.add(rollTier);
      simulation.enhancementLevels.add((i + 1) * 4); // 4, 8, 12, 16, 20
    }

    // 11. SubstatSummaryリストを作成（元の順序を保持）
    final newSubstats = <SubstatSummary>[];
    for (final propId in allNewPropIds) {
      final simulation = substatsMap[propId]!;
      final totalValue = simulation.rollValues.reduce((a, b) => a + b);

      newSubstats.add(
        SubstatSummary(
          propId: simulation.propId,
          label: simulation.label,
          statValue: _round(totalValue),
          tierValues: simulation.tierValues,
          minRollValue: simulation.minRollValue,
          maxRollValue: simulation.maxRollValue,
          totalUpgrades: simulation.rollValues.length,
          enhancementLevels: simulation.enhancementLevels,
          rollValues: simulation.rollValues,
          rollTiers: simulation.rollTiers,
        ),
      );
    }

    // 12. 新しいスコアを計算
    double newScore = 0.0;
    for (final substat in newSubstats) {
      if (scoreTargetPropIds.contains(substat.propId)) {
        final coefficient = _scoreCoefficients[substat.propId] ?? 1.0;
        newScore += substat.statValue * coefficient;
      }
    }
    newScore = _round(newScore);

    // 9. スコア差分と改善判定
    final scoreDiff = _round(newScore - currentScore);
    final isImproved = newScore > currentScore;

    return RebuildSimulationTrial(
      newSubstats: newSubstats,
      newScore: newScore,
      scoreDiff: scoreDiff,
      isImproved: isImproved,
    );
  }
}

/// シミュレーション用の一時データ構造
class _SubstatSimulation {
  _SubstatSimulation({
    required this.propId,
    required this.label,
    required this.tierValues,
    required this.minRollValue,
    required this.maxRollValue,
    required this.rollValues,
    required this.rollTiers,
    required this.enhancementLevels,
  });

  final String propId;
  final String label;
  final List<double> tierValues;
  final double minRollValue;
  final double maxRollValue;
  final List<double> rollValues;
  final List<int> rollTiers;
  final List<int> enhancementLevels;
}
