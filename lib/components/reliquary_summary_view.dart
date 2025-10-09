import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/common/format_utils.dart';

/// 聖遺物の解析結果を表示するコンポーネント
class ReliquarySummaryView extends StatelessWidget {
  const ReliquarySummaryView({super.key, required this.summary});

  final ReliquarySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アイコン表示
            if (summary.iconAssetPath != null)
              Center(
                child: Image.asset(
                  summary.iconAssetPath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
            if (summary.iconAssetPath != null) const SizedBox(height: 8),
            
            // メインステータス表示
            if (summary.mainPropId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'メインステータス: ${summary.mainPropLabel} '
                  '(${formatNumber(summary.mainStatValue)})',
                ),
              ),
            
            // 装備部位表示
            if (summary.equipType?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('装備部位: ${summary.equipTypeLabel}'),
              ),
            
            // サブステータス表示
            const Text('サブステータス:'),
            for (final substat in summary.substats)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '・${substat.displayName} : ${formatNumber(substat.statValue)} '
                  '(${formatAppendValues(substat.appendValueStrings)})',
                ),
              ),
          ],
        ),
      ),
    );
  }
}