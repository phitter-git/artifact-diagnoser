import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/components/reliquary_summary_view.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// 聖遺物詳細画面
///
/// 選択された聖遺物の詳細情報を表示します。
/// 強化レベルごとの推移をタブで切り替えて確認できます。
class ReliquaryDetailScreen extends StatefulWidget {
  const ReliquaryDetailScreen({
    super.key,
    required this.summary,
    required this.statAppendResolver,
  });

  /// 聖遺物の情報
  final ReliquarySummary summary;

  /// ステータス付加値リゾルバー
  final StatAppendResolver statAppendResolver;

  @override
  State<ReliquaryDetailScreen> createState() => _ReliquaryDetailScreenState();
}

class _ReliquaryDetailScreenState extends State<ReliquaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.summary.equipTypeLabel),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '詳細'),
            Tab(text: '再構築シミュレーター'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 詳細タブ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReliquarySummaryView(
              summary: widget.summary,
              statAppendResolver: widget.statAppendResolver,
            ),
          ),
          // 再構築シミュレータータブ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildRebuildSimulator(),
          ),
        ],
      ),
    );
  }

  /// 再構築シミュレータービュー
  Widget _buildRebuildSimulator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('再構築シミュレーター', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              '現在のサブステータスを最大値に再構築した場合の期待値を計算します。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            // TODO: 再構築シミュレーターの実装
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.construction, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '実装準備中',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
