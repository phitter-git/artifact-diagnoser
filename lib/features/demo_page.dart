import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artifact_diagnoser/models/remote/user_data.dart';
import 'package:artifact_diagnoser/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/services/stat_localizer.dart';
import 'package:artifact_diagnoser/services/stat_append_resolver.dart';
import 'package:artifact_diagnoser/services/artifact_icon_resolver.dart';
import 'package:artifact_diagnoser/services/reliquary_analysis_service.dart';
import 'package:artifact_diagnoser/components/reliquary_summary_view.dart';

/// 聖遺物解析のメイン画面
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  List<ReliquarySummary> _summaries = const [];
  bool _isLoading = false;

  /// 解析実行処理
  Future<void> _handleExecute() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    setState(() {
      _isLoading = true;
    });

    try {
      // ユーザーデータの読み込み
      final jsonString = await rootBundle.loadString('assets/json/userdata.json');
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

      if (!mounted) {
        return;
      }

      setState(() {
        _summaries = summaries;
        _isLoading = false;
      });

      debugPrint(
        'Loaded user UID: ${userData.uid} with ${summaries.length} reliquaries',
      );
      messenger?.showSnackBar(
        SnackBar(content: Text('ユーザーデータを読み込みました: UID ${userData.uid}')),
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Artifact Diagnoser')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 入力エリア
                  const Text('テキストを入力してください', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'サンプルテキスト...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 実行ボタン
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleExecute,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('実行'),
                  ),
                  const SizedBox(height: 24),
                  
                  // 結果表示エリア
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isLoading && _summaries.isEmpty)
                    const Text('実行結果はまだありません。'),
                  if (_summaries.isNotEmpty)
                    SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '装備解析結果 (${_summaries.length} 件)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          for (final summary in _summaries)
                            ReliquarySummaryView(summary: summary),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}