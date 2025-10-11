import 'package:artifact_diagnoser/src/utils/json_utils.dart';

/// 聖遺物情報（強化レベルやサブステータスの抽選履歴）
class ReliquaryInfo {
  const ReliquaryInfo({
    required this.level,
    this.mainPropId,
    this.appendPropIdList,
    this.promoteLevel,
  });

  /// 強化レベル（1-21、表示上は+0~+20）
  final int level;

  /// メインステータスのプロパティID
  final int? mainPropId;

  /// サブステータスの抽選履歴
  /// - 各要素は「プロパティID * 10 + ティア（1-4）」の形式
  /// - 初期3個: 長さ8（初期3 + 追加1 + 強化4回）
  /// - 初期4個: 長さ9（初期4 + 強化5回）
  final List<int>? appendPropIdList;

  /// 昇格レベル（未使用？）
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
