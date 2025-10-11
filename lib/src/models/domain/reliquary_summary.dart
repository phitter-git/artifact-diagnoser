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
    required this.level,
    required this.initialSubstatCount,
  });

  /// アバターID
  final int avatarId;

  /// アイテムID
  final int itemId;

  /// 装備種別（EQUIP_BRACER, EQUIP_NECKLACE, など）
  final String? equipType;

  /// 装備種別のラベル（花、羽、時計、杯、冠）
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

  /// 聖遺物の強化レベル (1-21, 実際の表示は+0~+20)
  final int level;

  /// 初期サブステータス数（3または4）
  final int initialSubstatCount;

  /// 初期レベル（初期サブステータス3個なら4、4個なら0）
  int get initialLevel => initialSubstatCount == 3 ? 4 : 0;

  /// 初期サブステータス一覧
  List<SubstatSummary> get initialSubstats =>
      substats.where((s) => s.isInitial).toList();

  /// 表示用の強化レベル（+0~+20）
  int get displayLevel => level - 1;

  /// 強化が完了しているか（+20まで）
  bool get isMaxLevel => level >= 21;

  /// 残りの強化回数
  int get remainingEnhancements {
    final remaining = (20 - displayLevel) ~/ 4;
    return remaining > 0 ? remaining : 0;
  }
}
