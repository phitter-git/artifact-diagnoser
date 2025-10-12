import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';
import 'package:artifact_diagnoser/src/components/enhancement_level_tabs.dart';
import 'package:artifact_diagnoser/src/components/substat_detail_view.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// 聖遺物の解析結果を表示するコンポーネント
class ReliquarySummaryView extends StatefulWidget {
  const ReliquarySummaryView({
    super.key,
    required this.summary,
    required this.statAppendResolver,
  });

  final ReliquarySummary summary;
  final StatAppendResolver statAppendResolver;

  @override
  State<ReliquarySummaryView> createState() => _ReliquarySummaryViewState();
}

class _ReliquarySummaryViewState extends State<ReliquarySummaryView> {
  /// 現在選択されている強化レベル
  int _selectedLevel = 20;

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

  /// メインステータスの表示値を取得（%付き）
  String _getMainStatDisplayValue() {
    final value = widget.summary.mainStatValue;
    if (value == null) return '';

    // メインステータスがパーセント表示が必要か判定
    if (widget.summary.mainPropId != null &&
        _isPercentageStat(widget.summary.mainPropId!)) {
      return '${formatNumber(value)}%';
    }
    return formatNumber(value);
  }

  @override
  void initState() {
    super.initState();
    // 初期値として聖遺物の現在レベルを設定 (level: 1-21 → 表示: +0~+20)
    // 表示用レベルに変換: (level - 1)
    final displayLevel = widget.summary.displayLevel;

    // 初期サブステータス3個の場合は+4から開始
    final minLevel = widget.summary.initialLevel;

    _selectedLevel = displayLevel < minLevel ? minLevel : displayLevel;
  }

  @override
  Widget build(BuildContext context) {
    // maxLevel: API値 (1-21) を表示用 (+0~+20) に変換
    final maxLevel = widget.summary.displayLevel;

    // 初期サブステータス3個の場合、最小レベルは+4
    final minLevel = widget.summary.initialLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー：アイコン、部位名+メインステータス（一覧画面と同じレイアウト）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // アイコン（左端）
                if (widget.summary.iconAssetPath != null)
                  Image.asset(
                    widget.summary.iconAssetPath!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),

                const SizedBox(width: 12),

                // 部位名+メインステータスのColumn
                Expanded(
                  child: SizedBox(
                    height: 80, // アイコンと同じ高さを確保
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 部位名（少し小さめ、灰色）
                        Text(
                          widget.summary.equipTypeLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // メインステータス（黒字、%付き）
                        Text(
                          '${widget.summary.mainPropLabel} ${_getMainStatDisplayValue()}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 強化レベル切り替えタブ
            EnhancementLevelTabs(
              currentLevel: _selectedLevel,
              maxLevel: maxLevel,
              minLevel: minLevel,
              onLevelChanged: (newLevel) {
                setState(() {
                  _selectedLevel = newLevel;
                });
              },
            ),
            const SizedBox(height: 16),

            // サブステータス表示
            const Text('サブステータス:'),
            const SizedBox(height: 8),

            // 各サブステータスの詳細
            for (final substat in widget.summary.substats)
              SubstatDetailView(
                substat: substat,
                currentLevel: _selectedLevel,
                isInitial: substat.isInitial,
                statAppendResolver: widget.statAppendResolver,
              ),
          ],
        ),
      ),
    );
  }
}
