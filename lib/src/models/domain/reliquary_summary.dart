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

  /// スコアランクを計算（SS/S/A/B/C）
  ///
  /// サブステータスのロール品質平均に基づいて評価
  String get scoreRank {
    if (substats.isEmpty) return 'C';

    // 各サブステータスのロール品質平均を取得
    final qualities = substats.map((s) => s.averageRollQuality).toList();

    // 全体の平均品質を計算
    final avgQuality = qualities.reduce((a, b) => a + b) / qualities.length;

    // ランク判定
    // 1.20以上: SS（極めて高品質）
    // 1.10以上: S（最大値近い）
    // 1.00以上: A（平均以上）
    // 0.90以上: B（平均）
    // 0.90未満: C（平均以下）
    if (avgQuality >= 1.20) return 'SS';
    if (avgQuality >= 1.10) return 'S';
    if (avgQuality >= 1.00) return 'A';
    if (avgQuality >= 0.90) return 'B';
    return 'C';
  }

  /// 初期値の品質を計算（高/中高/中低/低）
  String get initialQuality {
    if (initialSubstats.isEmpty) return '低';

    // 初期サブステータスのTier平均を計算
    final tiers = initialSubstats.map((s) {
      // 初回のTierを取得
      if (s.rollTiers.isEmpty) return 1;
      return s.rollTiers.first;
    }).toList();

    final avgTier = tiers.reduce((a, b) => a + b) / tiers.length;

    // 品質判定（Tier平均: 1.0~4.0）
    // 3.5以上: 高（ほぼTier 4）
    // 2.5以上: 中高（Tier 3が中心）
    // 1.5以上: 中低（Tier 2が中心）
    // 1.5未満: 低（Tier 1が多い）
    if (avgTier >= 3.5) return '高';
    if (avgTier >= 2.5) return '中高';
    if (avgTier >= 1.5) return '中低';
    return '低';
  }
}
