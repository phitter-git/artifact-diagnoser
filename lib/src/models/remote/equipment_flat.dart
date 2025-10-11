import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment_substat.dart';
import 'package:artifact_diagnoser/src/models/remote/reliquary_mainstat.dart';
import 'package:artifact_diagnoser/src/models/remote/weapon_stat.dart';

/// 装備の詳細情報（Flat）
class EquipmentFlat {
  const EquipmentFlat({
    required this.nameTextMapHash,
    required this.rankLevel,
    required this.itemType,
    required this.icon,
    this.equipType,
    this.setId,
    this.setNameTextMapHash,
    this.reliquarySubstats,
    this.reliquaryMainstat,
    this.weaponStats,
  });

  final String nameTextMapHash;
  final int rankLevel;
  final String itemType;
  final String icon;
  final String? equipType;
  final int? setId;
  final String? setNameTextMapHash;
  final List<EquipmentSubstat>? reliquarySubstats;
  final ReliquaryMainstat? reliquaryMainstat;
  final List<WeaponStat>? weaponStats;

  factory EquipmentFlat.fromJson(Map<String, dynamic> json) {
    return EquipmentFlat(
      nameTextMapHash: json['nameTextMapHash']?.toString() ?? '',
      rankLevel: (json['rankLevel'] as num?)?.toInt() ?? 0,
      itemType: json['itemType']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      equipType: json['equipType']?.toString(),
      setId: (json['setId'] as num?)?.toInt(),
      setNameTextMapHash: json['setNameTextMapHash']?.toString(),
      reliquarySubstats: json['reliquarySubstats'] == null
          ? null
          : readList(json['reliquarySubstats'])
                .map(
                  (entry) =>
                      EquipmentSubstat.fromJson(entry as Map<String, dynamic>),
                )
                .toList(),
      reliquaryMainstat: json['reliquaryMainstat'] == null
          ? null
          : ReliquaryMainstat.fromJson(
              json['reliquaryMainstat'] as Map<String, dynamic>,
            ),
      weaponStats: json['weaponStats'] == null
          ? null
          : readList(json['weaponStats'])
                .map(
                  (entry) => WeaponStat.fromJson(entry as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameTextMapHash': nameTextMapHash,
      'rankLevel': rankLevel,
      'itemType': itemType,
      'icon': icon,
      if (equipType != null) 'equipType': equipType,
      if (setId != null) 'setId': setId,
      if (setNameTextMapHash != null) 'setNameTextMapHash': setNameTextMapHash,
      if (reliquarySubstats != null)
        'reliquarySubstats': reliquarySubstats!
            .map((sub) => sub.toJson())
            .toList(),
      if (reliquaryMainstat != null)
        'reliquaryMainstat': reliquaryMainstat!.toJson(),
      if (weaponStats != null)
        'weaponStats': weaponStats!.map((stat) => stat.toJson()).toList(),
    };
  }
}
