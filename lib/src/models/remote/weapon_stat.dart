/// 武器のステータス
class WeaponStat {
  const WeaponStat({required this.appendPropId, required this.statValue});

  final String appendPropId;
  final double statValue;

  factory WeaponStat.fromJson(Map<String, dynamic> json) {
    return WeaponStat(
      appendPropId: json['appendPropId']?.toString() ?? '',
      statValue: (json['statValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'appendPropId': appendPropId, 'statValue': statValue};
  }
}
