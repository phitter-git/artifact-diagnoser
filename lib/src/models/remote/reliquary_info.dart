import 'package:artifact_diagnoser/src/utils/json_utils.dart';

/// 聖遺物情報
class ReliquaryInfo {
  const ReliquaryInfo({
    required this.level,
    this.mainPropId,
    this.appendPropIdList,
    this.promoteLevel,
  });

  final int level;
  final int? mainPropId;
  final List<int>? appendPropIdList;
  final int? promoteLevel;

  factory ReliquaryInfo.fromJson(Map<String, dynamic> json) {
    return ReliquaryInfo(
      level: (json['level'] as num?)?.toInt() ?? 0,
      mainPropId: (json['mainPropId'] as num?)?.toInt(),
      appendPropIdList: json['appendPropIdList'] == null
          ? null
          : readList(
              json['appendPropIdList'],
            ).map((entry) => (entry as num).toInt()).toList(),
      promoteLevel: (json['promoteLevel'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      if (mainPropId != null) 'mainPropId': mainPropId,
      if (appendPropIdList != null) 'appendPropIdList': appendPropIdList,
      if (promoteLevel != null) 'promoteLevel': promoteLevel,
    };
  }
}
