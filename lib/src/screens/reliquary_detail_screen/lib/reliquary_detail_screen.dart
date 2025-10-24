import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/components/reliquary_summary_view.dart';
import 'package:artifact_diagnoser/src/components/settings_drawer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/src/services/rebuild_simulator_service.dart';
import 'package:artifact_diagnoser/main.dart';
import 'rebuild_simulator_view.dart';

/// 聖遺物詳細画面
///
/// 選択された聖遺物の詳細情報を表示します。
/// 強化レベルごとの推移をタブで切り替えて確認できます。
class ReliquaryDetailScreen extends StatefulWidget {
  const ReliquaryDetailScreen({
    super.key,
    required this.summary,
    required this.statAppendResolver,
    this.initialScoreTargetStats,
  });

  /// 聖遺物の情報
  final ReliquarySummary summary;

  /// ステータス付加値リゾルバー
  final StatAppendResolver statAppendResolver;

  /// 初期スコア計算対象（一覧画面から渡される）
  final Map<String, bool>? initialScoreTargetStats;

  @override
  State<ReliquaryDetailScreen> createState() => _ReliquaryDetailScreenState();
}

class _ReliquaryDetailScreenState extends State<ReliquaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // スコア計算対象のステータス（デフォルトで会心率・会心ダメージがON）
  final Map<String, bool> _scoreTargetStats = {
    '攻撃力%': false,
    '防御力%': false,
    'HP%': false,
    '元素熟知': false,
    '元素チャージ効率': false,
    '会心率': true,
    '会心ダメージ': true,
  };

  // スコア計算対象変更時のコールバック
  final _scoreTargetChangeNotifier = ValueNotifier<int>(0);

  // スコア計算対象の折り畳み状態
  bool _isScoreTargetCollapsed = true;

  // スコア計算対象のpropIdセット
  Set<String> get _scoreTargetPropIds {
    const statNameToPropId = {
      '会心率': 'FIGHT_PROP_CRITICAL',
      '会心ダメージ': 'FIGHT_PROP_CRITICAL_HURT',
      '攻撃力%': 'FIGHT_PROP_ATTACK_PERCENT',
      '防御力%': 'FIGHT_PROP_DEFENSE_PERCENT',
      'HP%': 'FIGHT_PROP_HP_PERCENT',
      '元素チャージ効率': 'FIGHT_PROP_CHARGE_EFFICIENCY',
      '元素熟知': 'FIGHT_PROP_ELEMENT_MASTERY',
    };

    return _scoreTargetStats.entries
        .where((entry) => entry.value)
        .map((entry) => statNameToPropId[entry.key])
        .whereType<String>()
        .toSet();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 一覧画面から初期値が渡された場合は反映
    if (widget.initialScoreTargetStats != null) {
      _scoreTargetStats.addAll(widget.initialScoreTargetStats!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scoreTargetChangeNotifier.dispose();
    super.dispose();
  }

  /// スコア計算対象が変更されたことを通知
  void _notifyScoreTargetChanged() {
    _scoreTargetChangeNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          // 画面を閉じる時にスコア計算対象の状態を返す
          Navigator.of(context).pop(_scoreTargetStats);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.summary.equipTypeLabel),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '詳細'),
              Tab(text: '再構築シミュレーター'),
            ],
          ),
        ),
        endDrawer: SettingsDrawer(
          themeService: ThemeServiceProvider.of(context),
        ),
        body: Column(
          children: [
            // スコア計算対象選択UI（全タブ共通）
            _buildScoreTargetSelection(),
            // タブコンテンツ
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 詳細タブ
                  ValueListenableBuilder<int>(
                    valueListenable: _scoreTargetChangeNotifier,
                    builder: (context, _, __) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ReliquarySummaryView(
                                  summary: widget.summary,
                                  statAppendResolver: widget.statAppendResolver,
                                  selectedStats: _scoreTargetStats,
                                ),
                                const SizedBox(height: 16),
                                // 理論最大値セクション
                                _buildTheoreticalMaxSection(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // 再構築シミュレータータブ
                  ValueListenableBuilder<int>(
                    valueListenable: _scoreTargetChangeNotifier,
                    builder: (context, _, __) {
                      return RebuildSimulatorView(
                        key: ObjectKey(widget.summary),
                        summary: widget.summary,
                        scoreTargetPropIds: _scoreTargetPropIds,
                        statAppendResolver: widget.statAppendResolver,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// スコア計算対象選択UI（折り畳み対応）
  Widget _buildScoreTargetSelection() {
    const statNameToPropId = {
      '会心率': 'FIGHT_PROP_CRITICAL',
      '会心ダメージ': 'FIGHT_PROP_CRITICAL_HURT',
      '攻撃力%': 'FIGHT_PROP_ATTACK_PERCENT',
      '防御力%': 'FIGHT_PROP_DEFENSE_PERCENT',
      'HP%': 'FIGHT_PROP_HP_PERCENT',
      '元素チャージ効率': 'FIGHT_PROP_CHARGE_EFFICIENCY',
      '元素熟知': 'FIGHT_PROP_ELEMENT_MASTERY',
    };

    // 選択中のステータスリストを取得
    final selectedStats = _scoreTargetStats.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー行（折り畳み・展開共通の高さ）
          InkWell(
            onTap: () {
              setState(() {
                _isScoreTargetCollapsed = !_isScoreTargetCollapsed;
              });
            },
            child: SizedBox(
              height: 40, // 固定高さでアイコンと同じ高さを維持
              child: Row(
                children: [
                  Text(
                    'スコア計算対象',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 12),
                  // 折り畳み時のみアイコン表示
                  if (_isScoreTargetCollapsed)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: selectedStats.map((statName) {
                            final propId = statNameToPropId[statName];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildStatIcon(statName, propId),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    // 展開時は空白スペースをタップ対象に
                    const Expanded(child: SizedBox()),
                  Icon(
                    _isScoreTargetCollapsed
                        ? Icons.expand_more
                        : Icons.expand_less,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ],
              ),
            ),
          ),
          // 展開時: Checkboxリスト
          if (!_isScoreTargetCollapsed) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _scoreTargetStats.keys.map((statName) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _scoreTargetStats[statName],
                      onChanged: (value) {
                        setState(() {
                          _scoreTargetStats[statName] = value ?? false;
                          _notifyScoreTargetChanged();
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _scoreTargetStats[statName] =
                              !_scoreTargetStats[statName]!;
                          _notifyScoreTargetChanged();
                        });
                      },
                      child: Text(
                        statName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// ステータスアイコンをビルド
  Widget _buildStatIcon(String statName, String? propId) {
    if (propId == null) return const SizedBox.shrink();

    return Tooltip(
      message: statName,
      child: Image.asset(
        'assets/image/$propId.webp',
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 理論最大値セクション（詳細タブ下部）
  Widget _buildTheoreticalMaxSection() {
    // RebuildSimulatorServiceで理論値を計算
    final simulatorService = RebuildSimulatorService();
    final result = simulatorService.calculateBaseInfo(
      allSubstats: widget.summary.substats,
      initialSubstatCount: widget.summary.initialSubstatCount,
      scoreTargetPropIds: _scoreTargetPropIds,
    );

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, size: 20),
                SizedBox(width: 8),
                Text('理論最大値（スコア計算対象）', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '優先: ${result.primarySubstat.label}（残り${result.remainingEnhancements}回強化）',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.allSubstats.map((substat) {
              final theoreticalValue =
                  result.theoreticalValues[substat.propId] ?? 0.0;
              final isTarget = _scoreTargetPropIds.contains(substat.propId);
              final isPrimary = substat.propId == result.primarySubstat.propId;

              // 実数値(攻撃力、防御力、HP、元素熟知)は%なし、その他は%あり
              final hasPercent =
                  substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
                  substat.propId != 'FIGHT_PROP_ATTACK' &&
                  substat.propId != 'FIGHT_PROP_DEFENSE' &&
                  substat.propId != 'FIGHT_PROP_HP';

              String explanation = '';
              if (isPrimary) {
                final initial = substat.rollValues[0];
                final max = substat.maxRollValue;
                if (hasPercent) {
                  explanation =
                      '(初期値 ${initial.toStringAsFixed(1)}% + 最大値${max.toStringAsFixed(1)}% × ${result.remainingEnhancements}回)';
                } else {
                  explanation =
                      '(初期値 ${initial.toStringAsFixed(0)} + 最大値${max.toStringAsFixed(0)} × ${result.remainingEnhancements}回)';
                }
              } else {
                explanation = '(初期値のみ)';
              }

              final valueText = hasPercent
                  ? '${theoreticalValue.toStringAsFixed(1)}%'
                  : theoreticalValue.toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '• ${substat.label}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: isTarget
                                ? null
                                : (Theme.of(context).textTheme.bodyLarge?.color
                                          ?.withValues(alpha: 0.65) ??
                                      Colors.black54),
                          ),
                        ),
                        Text(
                          valueText,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: isTarget
                                ? null
                                : (Theme.of(context).textTheme.bodyLarge?.color
                                          ?.withValues(alpha: 0.65) ??
                                      Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '  $explanation',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Text(
              '現在スコア: ${result.currentScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '理論スコア: ${result.theoreticalMaxScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (result.isUpdatePossible)
              Text(
                '(${result.scoreIncrease >= 0 ? '+' : ''}${result.scoreIncrease.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 14,
                  color: result.scoreIncrease > 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
