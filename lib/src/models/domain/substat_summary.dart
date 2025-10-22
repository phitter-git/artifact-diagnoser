/// サブステータスの解析結果を表すドメインモデル
class SubstatSummary {
  const SubstatSummary({
    required this.propId,
    required this.label,
    required this.statValue,
    required this.avgRollValue,
    required this.minRollValue,
    required this.maxRollValue,
    required this.totalUpgrades,
    required this.enhancementLevels,
    required this.rollValues,
    required this.rollTiers,
  });

  /// プロパティID
  final String propId;

  /// 表示ラベル
  final String label;

  /// 現在のステータス値（ゲーム内表示値）
  final double statValue;

  /// 平均ロール値（この聖遺物レアリティでの平均）
  final double avgRollValue;

  /// 最小ロール値
  final double minRollValue;

  /// 最大ロール値
  final double maxRollValue;

  /// 強化回数
  final int totalUpgrades;

  /// 強化レベル一覧（このサブステータスが強化されたレベルのリスト）
  /// 例: [0, 4, 12] → 初期値、+4、+12で強化された
  final List<int> enhancementLevels;

  /// 各強化時の実際のロール値（appendValueStringsから算出）
  final List<double> rollValues;

  /// 各強化時のTier（1-4の整数値）
  /// 1=最小値、2=中低値、3=中高値、4=最大値
  final List<int> rollTiers;

  /// 初期サブステータスかどうか
  bool get isInitial =>
      enhancementLevels.isNotEmpty && enhancementLevels[0] == 0;

  /// 指定レベルでの累積値を計算
  /// [level]: 聖遺物の強化レベル（+0~+20）
  double getValueAtLevel(int level) {
    if (level == 20) {
      return statValue; // +20では実際のゲーム内表示値を使用
    }

    double total = 0.0;
    for (int i = 0; i < enhancementLevels.length; i++) {
      if (enhancementLevels[i] <= level) {
        total += rollValues[i];
      } else {
        break;
      }
    }
    return total;
  }

  /// 指定レベルでの増加値を取得（そのレベルで強化された場合）
  /// [level]: 聖遺物の強化レベル（+0~+20）
  /// 返り値: そのレベルで強化されていれば増加値、されていなければnull
  double? getIncrementAtLevel(int level) {
    final index = enhancementLevels.indexOf(level);
    if (index == -1) return null;
    if (index >= rollValues.length) return null;
    return rollValues[index];
  }

  /// 指定レベルまでの強化回数を取得
  /// [level]: 聖遺物の強化レベル（+0~+20）
  /// 返り値: そのレベルまでに強化された回数
  int getUpgradesAtLevel(int level) {
    return enhancementLevels.where((l) => l <= level).length;
  }

  /// 理論最大値（最大ロール値 × 強化回数）
  double get theoreticalMaxValue => maxRollValue * totalUpgrades;

  /// 理論最小値（最小ロール値 × 強化回数）
  double get theoreticalMinValue => minRollValue * totalUpgrades;

  /// 現在値の理論値範囲内での位置（0.0~1.0）
  /// 0.0 = 最小値、1.0 = 最大値
  double get valueRatio {
    final range = theoreticalMaxValue - theoreticalMinValue;
    if (range == 0) return 1.0;
    return (statValue - theoreticalMinValue) / range;
  }

  /// ロール品質の平均（avgRollValueと実際の平均を比較）
  /// 1.0 = 平均ロール、> 1.0 = 平均以上、< 1.0 = 平均以下
  double get averageRollQuality {
    if (totalUpgrades == 0) return 1.0;
    return statValue / (avgRollValue * totalUpgrades);
  }

  /// 最高ロール品質（最も高い品質のロール）
  double get maxRollQuality {
    if (rollTiers.isEmpty) return 0.0;
    return rollTiers.reduce((a, b) => a > b ? a : b) / 4.0;
  }

  /// 最低ロール品質（最も低い品質のロール）
  double get minRollQuality {
    if (rollTiers.isEmpty) return 0.0;
    return rollTiers.reduce((a, b) => a < b ? a : b) / 4.0;
  }
}
