/// サブステータスの解析結果を表すドメインモデル
class SubstatSummary {
  const SubstatSummary({
    required this.appendPropId,
    required this.displayName,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
    required this.appendValueStrings,
    required this.enhancementLevels,
  });

  /// 付加プロパティID
  final String appendPropId;

  /// 表示名
  final String displayName;

  /// ステータス値（最終的な累積値）
  final double statValue;

  /// 識別子
  final String identifier;

  /// ステータス付加リスト（抽選ティア番号のリスト）
  final List<int> statAppendList;

  /// 付加値文字列一覧（各強化時の増加値）
  final List<String> appendValueStrings;

  /// 強化レベル一覧（このサブステータスが強化されたレベル）
  /// 例: [0, 4, 12] = +0(初期), +4, +12で強化
  final List<int> enhancementLevels;

  /// 指定された強化レベルでの累積値を計算
  ///
  /// [level] 強化レベル（0, 4, 8, 12, 16, 20）
  /// 戻り値: その時点での累積値
  double getValueAtLevel(int level) {
    if (enhancementLevels.isEmpty || appendValueStrings.isEmpty) {
      return 0.0;
    }

    // +20（最大レベル）の場合は、ゲーム内の実際の表示値を使用
    // これにより、小数点以下の丸め誤差を回避
    final maxLevel = enhancementLevels.reduce((a, b) => a > b ? a : b);
    if (level >= 20 && maxLevel >= 20) {
      return statValue;
    }

    // 指定されたレベル以下で強化された値を累積
    double cumulativeValue = 0.0;
    for (int i = 0; i < enhancementLevels.length; i++) {
      if (enhancementLevels[i] <= level) {
        final valueStr = appendValueStrings[i];
        final cleanedStr = valueStr.replaceAll('%', '').replaceAll('+', '');
        final value = double.tryParse(cleanedStr) ?? 0.0;
        cumulativeValue += value;
      }
    }

    return cumulativeValue;
  }

  /// 指定された強化レベルでの増加値を取得
  ///
  /// [level] 強化レベル（4, 8, 12, 16, 20）
  /// 戻り値: その段階での増加値（その段階で強化されなかった場合はnull）
  double? getIncrementAtLevel(int level) {
    // その段階で強化されたかチェック
    final index = enhancementLevels.indexOf(level);
    if (index == -1) return null;

    // 対応する増加値を返す
    if (index < appendValueStrings.length) {
      final valueStr = appendValueStrings[index];
      final cleanedStr = valueStr.replaceAll('%', '').replaceAll('+', '');
      return double.tryParse(cleanedStr) ?? 0.0;
    }

    return null;
  }

  /// 初期サブステータスかどうか
  bool get isInitial =>
      enhancementLevels.isNotEmpty && enhancementLevels[0] == 0;
}
