/// 聖遺物のメインステータス
class ReliquaryMainstat {
  const ReliquaryMainstat({required this.mainPropId, required this.statValue});

  final String mainPropId;
  final double statValue;

  factory ReliquaryMainstat.fromJson(Map<String, dynamic> json) {
    return ReliquaryMainstat(
      mainPropId: json['mainPropId']?.toString() ?? '',
      statValue: (json['statValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mainPropId': mainPropId, 'statValue': statValue};
  }
}
