/// サブステータスの解析結果を表すドメインモデル
class SubstatSummary {
  const SubstatSummary({
    required this.appendPropId,
    required this.displayName,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
    required this.appendValueStrings,
  });

  /// 付加プロパティID
  final String appendPropId;

  /// 表示名
  final String displayName;

  /// ステータス値
  final double statValue;

  /// 識別子
  final String identifier;

  /// ステータス付加リスト
  final List<int> statAppendList;

  /// 付加値文字列一覧
  final List<String> appendValueStrings;
}
