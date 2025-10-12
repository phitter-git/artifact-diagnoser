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
            // アイコン表示
            if (widget.summary.iconAssetPath != null)
              Center(
                child: Image.asset(
                  widget.summary.iconAssetPath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
            if (widget.summary.iconAssetPath != null) const SizedBox(height: 8),

            // メインステータス表示
            if (widget.summary.mainPropId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'メインステータス: ${widget.summary.mainPropLabel} '
                  '(${formatNumber(widget.summary.mainStatValue)})',
                ),
              ),

            // 装備部位表示
            if (widget.summary.equipType?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('装備部位: ${widget.summary.equipTypeLabel}'),
              ),

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
