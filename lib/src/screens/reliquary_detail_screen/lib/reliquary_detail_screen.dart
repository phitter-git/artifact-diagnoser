import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/components/reliquary_summary_view.dart';
import 'package:artifact_diagnoser/src/components/settings_drawer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
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
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ReliquarySummaryView(
                          summary: widget.summary,
                          statAppendResolver: widget.statAppendResolver,
                          selectedStats: _scoreTargetStats,
                        ),
                      );
                    },
                  ),
                  // 再構築シミュレータータブ
                  ValueListenableBuilder<int>(
                    valueListenable: _scoreTargetChangeNotifier,
                    builder: (context, _, __) {
                      return RebuildSimulatorView(
                        key: ValueKey(_scoreTargetChangeNotifier.value),
                        summary: widget.summary,
                        scoreTargetPropIds: _scoreTargetPropIds,
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

  /// スコア計算対象選択UI
  Widget _buildScoreTargetSelection() {
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
          Text('スコア計算対象', style: Theme.of(context).textTheme.titleSmall),
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
      ),
    );
  }
}
