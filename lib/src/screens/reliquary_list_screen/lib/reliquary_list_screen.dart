import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artifact_diagnoser/src/models/remote/user_data.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/services/stat_localizer.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/src/services/artifact_icon_resolver.dart';
import 'package:artifact_diagnoser/src/services/reliquary_analysis_service.dart';
import 'package:artifact_diagnoser/src/components/reliquary_card_view.dart';
import 'package:artifact_diagnoser/src/screens/reliquary_detail_screen/lib/reliquary_detail_screen.dart';

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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 設定画面への遷移
            },
          ),
        ],
      ),
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
                    '聖遺物データがありません',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 聖遺物件数表示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.grey[100],
                  child: Text(
                    'n個の聖遺物データが登録されています'.replaceFirst(
                      'n',
                      _summaries.length.toString(),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // スコア計算対象のステータス選択
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'スコア計算対象',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                                    _scoreTargetStats[statName] =
                                        value ?? false;
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
                  ),
                ),
                // 聖遺物グリッド
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 360, // カードの高さを400pxに拡大（スコア表示分を追加）
                    ),
                    itemCount: _summaries.length,
                    itemBuilder: (context, index) {
                      final summary = _summaries[index];
                      return ReliquaryCardView(
                        summary: summary,
                        showInitialValues: _showInitialValues,
                        selectedStats: _scoreTargetStats,
                        onTap: () {
                          if (_statAppendResolver == null) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReliquaryDetailScreen(
                                summary: summary,
                                statAppendResolver: _statAppendResolver!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
