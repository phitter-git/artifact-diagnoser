import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';

/// 聖遺物一覧用のコンパクトなカード表示
///
/// 部位、メインステータス、サブステータス、スコアランクを表示します。
class ReliquaryCardView extends StatelessWidget {
  const ReliquaryCardView({
    super.key,
    required this.summary,
    required this.showInitialValues,
    this.selectedStats = const {},
    this.onTap,
  });

  /// 聖遺物の情報
  final ReliquarySummary summary;

  /// 初期値を表示するか（初期3なら+4、初期4なら+0）
  final bool showInitialValues;

  /// スコア計算対象として選択されているステータス（ラベル名 -> 選択状態）
  final Map<String, bool> selectedStats;

  /// カードタップ時のコールバック
  final VoidCallback? onTap;

  /// パーセント表示が必要なステータスかどうか
  bool _isPercentageStat(String propId) {
    const percentageStats = [
      'FIGHT_PROP_HP_PERCENT',
      'FIGHT_PROP_ATTACK_PERCENT',
      'FIGHT_PROP_DEFENSE_PERCENT',
      'FIGHT_PROP_CRITICAL',
      'FIGHT_PROP_CRITICAL_HURT',
      'FIGHT_PROP_CHARGE_EFFICIENCY',
      'FIGHT_PROP_FIRE_ADD_HURT',
      'FIGHT_PROP_WATER_ADD_HURT',
      'FIGHT_PROP_GRASS_ADD_HURT',
      'FIGHT_PROP_ELEC_ADD_HURT',
      'FIGHT_PROP_WIND_ADD_HURT',
      'FIGHT_PROP_ICE_ADD_HURT',
      'FIGHT_PROP_ROCK_ADD_HURT',
      'FIGHT_PROP_PHYSICAL_ADD_HURT',
      'FIGHT_PROP_HEAL_ADD',
    ];
    return percentageStats.contains(propId);
  }

  /// サブステータスの表示値を取得
  String _getSubstatDisplayValue(substat) {
    final level = showInitialValues
        ? summary.initialLevel
        : summary.displayLevel;
    final value = substat.getValueAtLevel(level);

    if (_isPercentageStat(substat.propId)) {
      return '${value.toStringAsFixed(1)}%';
    }
    return formatNumber(value);
  }

  /// スコアランクの色を取得（scoring_logic.mdに基づく）
  Color _getScoreRankColor(String rank) {
    switch (rank) {
      case 'SS':
        return const Color(0xFFC0C0C0); // 銀色（プラチナ級の最高品質）
      case 'S':
        return const Color(0xFFFFD700); // 金色（☆5相当）
      case 'A':
        return const Color(0xFFA256E1); // 紫色（☆4相当）
      case 'B':
        return const Color(0xFF4A90E2); // 青色（☆3相当）
      default: // 'C'
        return const Color(0xFF73C990); // 緑色（☆2相当、再構築推奨）
    }
  }

  /// サブステータス個別のロール品質ランクを取得（Tierベース）
  /// 初期値表示時に各サブステータスのTierに基づいてランクを表示
  /// Tier: 1=C、2=B、3=A、4=S
  Widget _getSubstatRollQualityRank(int tier) {
    String rank;
    Color color;

    switch (tier) {
      case 4:
        // 最大値
        rank = 'S';
        color = const Color(0xFFFF8C00); // オレンジゴールド（背景色と区別しやすい）
        break;
      case 3:
        // 中高値
        rank = 'A';
        color = const Color(0xFFA256E1); // 紫色
        break;
      case 2:
        // 中低値
        rank = 'B';
        color = const Color(0xFF4A90E2); // 青色
        break;
      case 1:
      default:
        // 最小値
        rank = 'C';
        color = const Color(0xFF73C990); // 緑色
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        rank,
        style: TextStyle(fontSize: 16, color: color, height: 1.0),
      ),
    );
  }

  /// メインステータスの表示値を取得（%付き）
  String _getMainStatDisplayValue() {
    final value = summary.mainStatValue;
    if (value == null) return '';

    // メインステータスがパーセント表示が必要か判定
    if (summary.mainPropId != null && _isPercentageStat(summary.mainPropId!)) {
      return '${formatNumber(value)}%';
    }
    return formatNumber(value);
  }

  /// スコアを計算する
  /// - 会心率は×2
  /// - 元素熟知は÷4
  /// - その他は等倍
  double _calculateScore() {
    double score = 0.0;
    final level = showInitialValues
        ? summary.initialLevel
        : summary.displayLevel;

    for (final substat in summary.substats) {
      // このサブステータスが選択されているかチェック
      final isSelected = selectedStats[substat.label] ?? false;
      if (!isSelected) continue;

      final value = substat.getValueAtLevel(level);

      // ラベル名に応じて係数を適用
      if (substat.label == '会心率') {
        score += value * 2;
      } else if (substat.label == '元素熟知') {
        score += value / 4;
      } else {
        score += value;
      }
    }

    return score;
  }

  /// スコアに基づいてランクを計算（部位別基準）
  ///
  /// 基本基準（花・羽）:
  /// - SS: 50以上
  /// - S: 45以上
  /// - A: 40以上
  /// - B: 30以上
  /// - C: 30未満
  ///
  /// 杯・時計（砂）: -5.0寛容
  /// - SS: 45以上
  /// - S: 40以上
  /// - A: 35以上
  /// - B: 25以上
  /// - C: 25未満
  ///
  /// 冠: -10.0寛容
  /// - SS: 40以上
  /// - S: 35以上
  /// - A: 30以上
  /// - B: 20以上
  /// - C: 20未満
  String _getScoreBasedRank() {
    // 少なくとも1つのステータスが選択されている場合のみスコアベースのランクを計算
    if (selectedStats.values.any((selected) => selected)) {
      final score = _calculateScore();

      // 部位に応じて基準値を調整
      double ssThreshold, sThreshold, aThreshold, bThreshold;

      switch (summary.equipType) {
        case 'EQUIP_RING': // 杯: -5.0寛容
        case 'EQUIP_SHOES': // 時計（砂）: -5.0寛容
          ssThreshold = 45.0;
          sThreshold = 40.0;
          aThreshold = 35.0;
          bThreshold = 25.0;
          break;
        case 'EQUIP_DRESS': // 冠: -10.0寛容
          ssThreshold = 40.0;
          sThreshold = 35.0;
          aThreshold = 30.0;
          bThreshold = 20.0;
          break;
        case 'EQUIP_BRACER': // 花
        case 'EQUIP_NECKLACE': // 羽
        default: // 基本基準
          ssThreshold = 50.0;
          sThreshold = 45.0;
          aThreshold = 40.0;
          bThreshold = 30.0;
          break;
      }

      if (score >= ssThreshold) return 'SS';
      if (score >= sThreshold) return 'S';
      if (score >= aThreshold) return 'A';
      if (score >= bThreshold) return 'B';
      return 'C';
    }

    // 何も選択されていない場合は空文字を返す
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = _getScoreBasedRank(); // スコアベースのランクを使用

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero, // カード外側の余白を削除
      color: theme.cardColor,
      elevation: 2, // 軽い影を追加
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー：アイコン、部位+メインステータス（ランクを背後に重ねる）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // アイコン（左端）
                  if (summary.iconAssetPath != null)
                    Image.asset(
                      summary.iconAssetPath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),

                  const SizedBox(width: 12),

                  // 部位名+メインステータスのColumn（ランクを背後に配置）
                  Expanded(
                    child: SizedBox(
                      height: 80, // アイコンと同じ高さを確保
                      child: Stack(
                        clipBehavior: Clip.none, // はみ出しを許可
                        children: [
                          // 背後のスコアランク（半透明、縁取り付き）
                          // 初期値表示時、または何も選択されていない時は非表示
                          if (!showInitialValues &&
                              selectedStats.values.any((selected) => selected))
                            Positioned(
                              right: -10, // 少し右にずらす
                              top: -10, // 少し上にずらして中央に配置
                              child: Opacity(
                                opacity: 0.25, // 透明度をやや上げて見やすくする
                                child: Stack(
                                  children: [
                                    // 縁取り（黒）
                                    Text(
                                      rank,
                                      style: TextStyle(
                                        fontSize: 80,
                                        height: 1.0,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 4
                                          ..color = Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                      ),
                                    ),
                                    // 本体
                                    Text(
                                      rank,
                                      style: TextStyle(
                                        fontSize: 80,
                                        color: _getScoreRankColor(rank),
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // 前面のテキスト
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 部位名（少し小さめ、灰色）
                              Text(
                                summary.equipTypeLabel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // メインステータス（黒字、%付き）
                              Text(
                                '${summary.mainPropLabel} ${_getMainStatDisplayValue()}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // サブステータス一覧
              ...summary.substats.map((substat) {
                // 初期値表示時は初期レベルでの最初のTierを取得
                final showTierIcon =
                    showInitialValues && substat.rollTiers.isNotEmpty;
                final tier = showTierIcon ? substat.rollTiers[0] : 0;

                // このサブステータスがスコア計算対象として選択されているかチェック
                final isSelected = selectedStats[substat.label] ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.circle : Icons.circle_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    substat.label,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight:
                                              FontWeight.normal, // 太字を通常に
                                          fontSize: 18,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 追加回数表示
                                if (substat.totalUpgrades > 0) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF5DEB3,
                                      ).withValues(alpha: 0.3), // 薄い金色背景
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFD4AF37,
                                        ).withValues(alpha: 0.5), // 金色の枠
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '×${substat.totalUpgrades}',
                                      style: TextStyle(
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? const Color(0xFFE8C547)
                                            : const Color(0xFF8B6914),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getSubstatDisplayValue(substat),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal, // 太字を通常に
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 初期値表示時のみ、各サブステータスのTierランクを表示
                      if (showTierIcon) ...[
                        const SizedBox(width: 4),
                        _getSubstatRollQualityRank(tier),
                      ],
                    ],
                  ),
                );
              }),

              // スコア表示
              if (selectedStats.values.any((selected) => selected)) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'スコア',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    Text(
                      _calculateScore().toStringAsFixed(1),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
