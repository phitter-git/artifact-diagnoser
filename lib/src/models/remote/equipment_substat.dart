/// 装備のサブステータス
class EquipmentSubstat {
  const EquipmentSubstat({required this.appendPropId, required this.statValue});

  final String appendPropId;
  final double statValue;

  factory EquipmentSubstat.fromJson(Map<String, dynamic> json) {
    return EquipmentSubstat(
      appendPropId: json['appendPropId']?.toString() ?? '',
      statValue: (json['statValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'appendPropId': appendPropId, 'statValue': statValue};
  }
}
