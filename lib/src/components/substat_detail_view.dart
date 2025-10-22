import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// サブステータスの詳細を表示するコンポーネント
///
/// 強化マーカー(●/○)、ステータス名、数値、増加値を表示します。
class SubstatDetailView extends StatelessWidget {
  const SubstatDetailView({
    super.key,
    required this.substat,
    required this.currentLevel,
    required this.isInitial,
    required this.statAppendResolver,
  });

  /// サブステータスの情報
  final SubstatSummary substat;

  /// 現在表示している強化レベル（0, 4, 8, 12, 16, 20）
  final int currentLevel;

  /// 初期サブステータスかどうか
  final bool isInitial;

  /// ステータス付加値リゾルバー
  final StatAppendResolver statAppendResolver;

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
    return percentageStats.contains(substat.propId);
  }

  /// 現在値をフォーマット
  String _formatCurrentValue(double value) {
    if (_isPercentageStat()) {
      return '${value.toStringAsFixed(1)}%';
    }
    return formatNumber(value);
  }

  /// 増加値をフォーマット
  String _formatIncrement(double increment) {
    if (_isPercentageStat()) {
      return '${increment.toStringAsFixed(1)}%';
    }
    return formatNumber(increment);
  }

  /// 抽選値のティアを判定（0=最小, 1=中低, 2=中高, 3=最大）
  /// stats_append.jsonから正確な抽選値を取得して判定
  int? _getRollTier(double increment) {
    // stats_append.jsonから全ティアの値を取得
    final tierValues = statAppendResolver.valuesFor(substat.propId, [
      1,
      2,
      3,
      4,
    ]);

    if (tierValues.length != 4) return null;

    // 増加値を文字列に変換（パーセント表示の場合は小数点1桁）
    final incrementStr = _isPercentageStat()
        ? increment.toStringAsFixed(1)
        : formatNumber(increment);

    // 各ティアと比較して一致するものを探す
    for (int i = 0; i < tierValues.length; i++) {
      if (tierValues[i] == incrementStr) {
        return i; // tier 1-4 → 0-3に変換（配列インデックス）
      }
    }

    // 完全一致しない場合は、最も近いティアを推定
    try {
      final numericValues = tierValues.map((v) => double.parse(v)).toList();
      final diff = numericValues.map((v) => (v - increment).abs()).toList();
      final minDiffIndex = diff.indexOf(diff.reduce((a, b) => a < b ? a : b));
      return minDiffIndex;
    } catch (e) {
      return null;
    }
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

  /// ティアからランクを取得（Tier 4→S, 3→A, 2→B, 1→C）
  String? _getTierRank(int? tier) {
    if (tier == null) return null;
    switch (tier) {
      case 3:
        return 'S';
      case 2:
        return 'A';
      case 1:
        return 'B';
      case 0:
        return 'C';
      default:
        return null;
    }
  }

  /// ランクに応じた色を取得
  Color _getRankColor(String rank) {
    switch (rank) {
      case 'S':
        return const Color(0xFFFF8C00); // ダークオレンジ
      case 'A':
        return const Color(0xFFA256E1); // パープル
      case 'B':
        return const Color(0xFF4A90E2); // ブルー
      case 'C':
        return const Color(0xFF73C990); // グリーン
      default:
        return Colors.grey;
    }
  }

  /// 加算履歴を構築（例: "2.7 + 3.9 + 3.9"）
  String _buildRollHistory(int level) {
    final rollsUpToLevel = <String>[];

    for (int i = 0; i < substat.enhancementLevels.length; i++) {
      if (substat.enhancementLevels[i] <= level &&
          i < substat.rollValues.length) {
        final rollValue = substat.rollValues[i];
        final formatted = _formatIncrement(rollValue);
        // "+"記号を除去して数値のみ
        rollsUpToLevel.add(formatted);
      }
    }

    return rollsUpToLevel.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = _getValueAtLevel(currentLevel);
    final increment = _getIncrementValue();

    // +0で初期値の場合は初期ロール値を使用、それ以外は通常の増加値
    double? displayIncrement;
    if (currentLevel == 0 && isInitial && substat.rollValues.isNotEmpty) {
      displayIncrement = substat.rollValues[0];
    } else if (currentLevel > 0 && increment != null) {
      displayIncrement = increment;
    }

    final showIncrement = displayIncrement != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1行目: マーカー、ステータス名、現在値、増加値
          Row(
            children: [
              // サブステータスマーカー
              Text(
                '○',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 20),
              ),
              const SizedBox(width: 10),
              // ステータス名
              Expanded(
                flex: 3,
                child: Text(
                  substat.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 現在値
              SizedBox(
                width: 80,
                child: Text(
                  _formatCurrentValue(currentValue),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              // 増加値表示用の固定幅スペース
              SizedBox(
                width: 120,
                child: showIncrement
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 増加値表示
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRollTier(displayIncrement) != null
                                  ? _getRollTierColor(
                                      _getRollTier(displayIncrement)!,
                                    ).withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getRollTier(displayIncrement) != null
                                    ? _getRollTierColor(
                                        _getRollTier(displayIncrement)!,
                                      ).withValues(alpha: 0.5)
                                    : Colors.grey.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 15,
                                  color: _getRollTier(displayIncrement) != null
                                      ? _getRollTierColor(
                                          _getRollTier(displayIncrement)!,
                                        )
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+${_formatIncrement(displayIncrement)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        _getRollTier(displayIncrement) != null
                                        ? _getRollTierColor(
                                            _getRollTier(displayIncrement)!,
                                          )
                                        : Colors.grey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ランクバッジ
                          if (_getTierRank(_getRollTier(displayIncrement)) !=
                              null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRankColor(
                                  _getTierRank(_getRollTier(displayIncrement))!,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getTierRank(_getRollTier(displayIncrement))!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : null,
              ),
            ],
          ),
          // 2行目: 追加回数表示と加算履歴（インデント付き）
          if (substat.getUpgradesAtLevel(currentLevel) > 0) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 30), // マーカー分のインデント
              child: Row(
                children: [
                  // 追加回数バッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5DEB3).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '×${substat.getUpgradesAtLevel(currentLevel)}',
                      style: const TextStyle(
                        color: Color(0xFF8B6914),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 加算履歴表示
                  Expanded(
                    child: Text(
                      _buildRollHistory(currentLevel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
