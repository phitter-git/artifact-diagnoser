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
    this.onTap,
  });

  /// 聖遺物の情報
  final ReliquarySummary summary;

  /// 初期値を表示するか（初期3なら+4、初期4なら+0）
  final bool showInitialValues;

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
      return '+${value.toStringAsFixed(1)}%';
    }
    return '+${formatNumber(value)}';
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

  /// 初期品質のアイコンを取得（全体評価用）
  Widget _getInitialQualityIcon(String quality) {
    IconData icon;
    Color color;

    switch (quality) {
      case '高':
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case '中高':
        icon = Icons.trending_up;
        color = Colors.lightGreen;
        break;
      case '中低':
        icon = Icons.trending_down;
        color = Colors.orange;
        break;
      default: // '低'
        icon = Icons.arrow_downward;
        color = Colors.red;
    }

    return Icon(icon, size: 24, color: color);
  }

  /// サブステータス個別のロール品質アイコンを取得
  /// 初期値表示時に各サブステータスのロール品質を表示
  Widget _getSubstatRollQualityIcon(double rollQuality) {
    IconData icon;
    Color color;

    // ロール品質の閾値（maxRollValueに対する割合）
    if (rollQuality >= 0.95) {
      // 最高値（95%以上）
      icon = Icons.star;
      color = Colors.amber;
    } else if (rollQuality >= 0.80) {
      // 高（80%以上）
      icon = Icons.arrow_upward;
      color = Colors.green;
    } else if (rollQuality >= 0.65) {
      // 中の上（65%以上）
      icon = Icons.trending_up;
      color = Colors.lightGreen;
    } else if (rollQuality >= 0.50) {
      // 中の下（50%以上）
      icon = Icons.trending_down;
      color = Colors.orange;
    } else {
      // 低（50%未満）
      icon = Icons.arrow_downward;
      color = Colors.red;
    }

    return Icon(icon, size: 18, color: color);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = summary.scoreRank;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero, // カード外側の余白を削除
      color: const Color(0xFFF5F0E8), // 背景色を薄いベージュに
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー：部位+メインステータス、アイコン、初期品質、ランク
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 部位名+メインステータスのColumn
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 部位名（少し小さめ、灰色）
                        Text(
                          summary.equipTypeLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // メインステータス（サブステータスと同じサイズ、黒字、%付き）
                        Text(
                          '${summary.mainPropLabel} ${_getMainStatDisplayValue()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18, // サブステータスと同じサイズ
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // アイコン（部位名+メインステータスと同じ高さ）
                  if (summary.iconAssetPath != null)
                    Image.asset(
                      summary.iconAssetPath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),

                  const SizedBox(width: 12),

                  // スコアランク
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreRankColor(rank).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getScoreRankColor(rank),
                        width: 2.5,
                      ),
                    ),
                    child: Text(
                      rank,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: _getScoreRankColor(rank),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // サブステータス一覧
              ...summary.substats.map((substat) {
                // 初期値表示時は初期レベルでの最初のロール品質を取得
                final showRollQuality =
                    showInitialValues && substat.rollQualities.isNotEmpty;
                final rollQuality = showRollQuality
                    ? substat.rollQualities[0]
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        '○',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          substat.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getSubstatDisplayValue(substat),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      // 初期値表示時のみ、各サブステータスのロール品質アイコンを表示
                      if (showRollQuality) ...[
                        const SizedBox(width: 8),
                        _getSubstatRollQualityIcon(rollQuality),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
