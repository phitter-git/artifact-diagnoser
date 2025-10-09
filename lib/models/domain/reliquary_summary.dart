/// 聖遺物の解析結果を表すドメインモデル
class ReliquarySummary {
  const ReliquarySummary({
    required this.avatarId,
    required this.itemId,
    required this.equipType,
    required this.equipTypeLabel,
    required this.mainPropId,
    required this.mainPropLabel,
    required this.mainStatValue,
    required this.substats,
    required this.iconAssetPath,
  });

  /// アバターID
  final int avatarId;

  /// アイテムID
  final int itemId;

  /// 装備種別
  final String? equipType;

  /// 装備種別のラベル
  final String equipTypeLabel;

  /// メインプロパティID
  final String? mainPropId;

  /// メインプロパティのラベル
  final String mainPropLabel;

  /// メインステータス値
  final double? mainStatValue;

  /// サブステータス一覧
  final List<SubstatSummary> substats;

  /// アイコンアセットパス
  final String? iconAssetPath;
}

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