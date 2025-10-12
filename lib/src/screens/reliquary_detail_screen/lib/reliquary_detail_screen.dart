import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/components/reliquary_summary_view.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// 聖遺物詳細画面
///
/// 選択された聖遺物の詳細情報を表示します。
/// 強化レベルごとの推移をタブで切り替えて確認できます。
class ReliquaryDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(summary.equipTypeLabel)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ReliquarySummaryView(
          summary: summary,
          statAppendResolver: statAppendResolver,
        ),
      ),
    );
  }
}
