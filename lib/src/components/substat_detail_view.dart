import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';

/// サブステータスの詳細を表示するコンポーネント
///
/// 強化マーカー(●/○)、ステータス名、数値、増加値を表示します。
class SubstatDetailView extends StatelessWidget {
  const SubstatDetailView({
    super.key,
    required this.substat,
    required this.currentLevel,
    required this.isInitial,
  });

  /// サブステータスの情報
  final SubstatSummary substat;

  /// 現在表示している強化レベル（0, 4, 8, 12, 16, 20）
  final int currentLevel;

  /// 初期サブステータスかどうか
  final bool isInitial;

  /// 指定された強化レベルでの数値を取得
  double _getValueAtLevel(int level) {
    return substat.getValueAtLevel(level);
  }

  /// 前回の強化レベルからの増加値を取得
  double? _getIncrementValue() {
    return substat.getIncrementAtLevel(currentLevel);
  }

  /// パーセント表示が必要なステータスかどうか
  bool _isPercentageStat() {
    // パーセント表示が必要なステータス
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
    return percentageStats.contains(substat.appendPropId);
  }

  /// 増加値をフォーマット
  String _formatIncrement(double increment) {
    if (_isPercentageStat()) {
      return increment.toStringAsFixed(1);
    }
    return formatNumber(increment);
  }

  /// 抽選値のティアを判定（0=最小, 1=中低, 2=中高, 3=最大）
  int _getRollTier(double increment) {
    // TODO: stats_append.jsonから正確な抽選値を取得する
    // 暫定的な判定ロジック
    final incrementPercentage = (increment / substat.statValue) * 100;

    if (incrementPercentage >= 0.85) return 3; // 最大値
    if (incrementPercentage >= 0.70) return 2; // 中高値
    if (incrementPercentage >= 0.55) return 1; // 中低値
    return 0; // 最小値
  }

  /// 抽選値ティアに応じた色を取得
  Color _getRollTierColor(int tier) {
    switch (tier) {
      case 3:
        return const Color(0xFFFF9800); // オレンジ（金色より見やすい）
      case 2:
        return const Color(0xFF9E9E9E); // グレー（銀色）
      case 1:
        return const Color(0xFF795548); // ブラウン（銅色）
      default:
        return const Color(0xFF757575); // ダークグレー
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = _getValueAtLevel(currentLevel);
    final increment = _getIncrementValue();
    final showIncrement = increment != null && currentLevel > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // サブステータスマーカー
          Text(
            '○',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(width: 8),

          // ステータス名
          Expanded(
            flex: 3,
            child: Text(
              substat.displayName,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 現在値
          SizedBox(
            width: 60,
            child: Text(
              formatNumber(currentValue),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // 増加値表示
          if (showIncrement)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRollTierColor(
                  _getRollTier(increment),
                ).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getRollTierColor(
                    _getRollTier(increment),
                  ).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 10,
                    color: _getRollTierColor(_getRollTier(increment)),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '+${_formatIncrement(increment)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getRollTierColor(_getRollTier(increment)),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 50),
        ],
      ),
    );
  }
}
