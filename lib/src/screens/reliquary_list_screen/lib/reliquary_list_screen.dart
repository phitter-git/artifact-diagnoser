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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 画面遷移時の引数を取得
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _uid = args['uid'] as String?;
      if (_uid != null && _summaries.isEmpty && !_isLoading) {
        _loadData();
      }
    }
  }

  /// 聖遺物データの読み込み
  Future<void> _loadData() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    setState(() {
      _isLoading = true;
    });

    try {
      // ユーザーデータの読み込み
      final jsonString = await rootBundle.loadString(
        'assets/json/userdata.json',
      );
      final userData = UserData.fromJsonString(jsonString);

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
    // 画面幅に応じて列数を計算（カード幅約350px想定）
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 350).floor().clamp(1, 5);

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
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2, // 0.75から1.1に変更（横:縦 = 11:10でより正方形に近く）
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _summaries.length,
              itemBuilder: (context, index) {
                final summary = _summaries[index];
                return ReliquaryCardView(
                  summary: summary,
                  showInitialValues: _showInitialValues,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ReliquaryDetailScreen(summary: summary),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
