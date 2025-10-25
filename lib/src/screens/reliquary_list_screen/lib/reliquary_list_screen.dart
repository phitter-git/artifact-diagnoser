import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/remote/user_data.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/services/stat_localizer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/src/services/artifact_icon_resolver.dart';
import 'package:artifact_diagnoser/src/services/reliquary_analysis_service.dart';
import 'package:artifact_diagnoser/src/components/reliquary_card_view.dart';
import 'package:artifact_diagnoser/src/components/settings_drawer.dart';
import 'package:artifact_diagnoser/src/screens/reliquary_detail_screen/lib/reliquary_detail_screen.dart';
import 'package:artifact_diagnoser/main.dart';

/// 聖遺物一覧画面
///
/// ユーザーの聖遺物データを一覧表示します。
class ReliquaryListScreen extends StatefulWidget {
  const ReliquaryListScreen({super.key});

  @override
  State<ReliquaryListScreen> createState() => _ReliquaryListScreenState();
}

class _ReliquaryListScreenState extends State<ReliquaryListScreen> {
  List<ReliquarySummary> _summaries = const [];
  bool _isLoading = false;
  bool _showInitialValues = false; // 初期値表示フラグ
  String? _uid;
  StatAppendResolver? _statAppendResolver; // StatAppendResolverを保持

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

  // スコア計算対象の折り畳み状態
  bool _isScoreTargetCollapsed = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 画面遷移時の引数を取得
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _uid = args['uid'] as String?;
      final userData = args['userData'] as UserData?;
      if (_uid != null &&
          userData != null &&
          _summaries.isEmpty &&
          !_isLoading) {
        _loadData(userData);
      }
    }
  }

  /// 聖遺物データの読み込み
  Future<void> _loadData(UserData userData) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    setState(() {
      _isLoading = true;
    });

    try {
      // 各種サービスの読み込み
      final localizer = await StatLocalizer.load();
      final appendResolver = await StatAppendResolver.load();
      final iconResolver = await ArtifactIconResolver.load();

      // 聖遺物解析の実行
      final summaries = ReliquaryAnalysisService.buildReliquarySummaries(
        userData,
        localizer,
        appendResolver,
        iconResolver,
      );

      if (!mounted) return;

      setState(() {
        _summaries = summaries;
        _statAppendResolver = appendResolver; // StatAppendResolverを保存
        _isLoading = false;
      });

      debugPrint(
        'Loaded user UID: ${userData.uid} with ${summaries.length} reliquaries',
      );
    } catch (error, stackTrace) {
      if (!mounted) return;

      setState(() {
        _summaries = const [];
        _isLoading = false;
      });

      debugPrint('ユーザーデータの読み込みに失敗しました: $error');
      debugPrint('$stackTrace');
      messenger?.showSnackBar(
        const SnackBar(content: Text('ユーザーデータの読み込みに失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面幅に応じて列数を計算（カード幅340px + 間隔16px想定）
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = ((screenWidth - 32) / (340 + 16)).floor().clamp(
      1,
      10,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('聖遺物一覧'),
        actions: [
          // 初期値表示トグル（文字付き）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('初期値を表示', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Switch(
                  value: _showInitialValues,
                  onChanged: (value) {
                    setState(() {
                      _showInitialValues = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              tooltip: '設定',
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(themeService: ThemeServiceProvider.of(context)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '聖遺物データがありません。\nゲーム内からキャラクターラインナップを登録するか、キャラ詳細表示中にしてください。',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // スコア計算対象のステータス選択（折り畳み対応）
                _buildScoreTargetSelection(),
                // 聖遺物件数と一覧（スクロール可能）
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // 聖遺物件数表示
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Text(
                            'n個の聖遺物データが登録されています'.replaceFirst(
                              'n',
                              _summaries.length.toString(),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                          ),
                        ),
                      ),
                      // 聖遺物グリッド
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 360,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final summary = _summaries[index];
                            return ReliquaryCardView(
                              summary: summary,
                              showInitialValues: _showInitialValues,
                              selectedStats: _scoreTargetStats,
                              onTap: () async {
                                if (_statAppendResolver == null) return;
                                final result = await Navigator.of(context)
                                    .push<Map<String, bool>>(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReliquaryDetailScreen(
                                              summary: summary,
                                              statAppendResolver:
                                                  _statAppendResolver!,
                                              initialScoreTargetStats:
                                                  _scoreTargetStats,
                                            ),
                                      ),
                                    );
                                // 詳細画面から戻ってきた時にスコア計算対象を更新
                                if (result != null) {
                                  setState(() {
                                    _scoreTargetStats.clear();
                                    _scoreTargetStats.addAll(result);
                                  });
                                }
                              },
                            );
                          }, childCount: _summaries.length),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}
