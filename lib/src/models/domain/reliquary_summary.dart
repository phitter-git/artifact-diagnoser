import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';

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
