import 'package:artifact_diagnoser/src/models/domain/substat_summary.dart';

/// 内部で使用する可変サブステータス
class MutableSubstat {
  MutableSubstat({
    required this.appendPropId,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
  });

  final String appendPropId;
  final double statValue;
  final String identifier;
  final List<int> statAppendList;

  /// SubstatSummaryに変換する
  SubstatSummary toSubstatSummary({
    required String displayName,
    required List<String> appendValueStrings,
  }) {
    return SubstatSummary(
      appendPropId: appendPropId,
      displayName: displayName,
      statValue: statValue,
      identifier: identifier,
      statAppendList: List<int>.from(statAppendList),
      appendValueStrings: appendValueStrings,
    );
  }
}
