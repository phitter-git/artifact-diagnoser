/// 装備のサブステータス（現在の最終値）
class EquipmentSubstat {
  const EquipmentSubstat({required this.appendPropId, required this.statValue});

  /// サブステータスのプロパティID（FIGHT_PROP_CRITICAL、FIGHT_PROP_ATTACKなど）
  final String appendPropId;

  /// サブステータスの現在値（全強化の累積値）
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
