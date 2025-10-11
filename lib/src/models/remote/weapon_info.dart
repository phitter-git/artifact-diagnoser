import 'package:artifact_diagnoser/src/utils/json_utils.dart';

/// 武器情報
class WeaponInfo {
  const WeaponInfo({
    required this.level,
    this.promoteLevel,
    required this.affixMap,
  });

  final int level;
  final int? promoteLevel;
  final Map<String, int> affixMap;

  factory WeaponInfo.fromJson(Map<String, dynamic> json) {
    return WeaponInfo(
      level: (json['level'] as num?)?.toInt() ?? 0,
      promoteLevel: (json['promoteLevel'] as num?)?.toInt(),
      affixMap: readMap(
        json['affixMap'],
      ).map((key, value) => MapEntry(key, (value as num).toInt())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      if (promoteLevel != null) 'promoteLevel': promoteLevel,
      'affixMap': affixMap,
    };
  }
}
