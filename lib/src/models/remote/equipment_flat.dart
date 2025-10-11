import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment_substat.dart';
import 'package:artifact_diagnoser/src/models/remote/reliquary_mainstat.dart';
import 'package:artifact_diagnoser/src/models/remote/weapon_stat.dart';

/// 装備の詳細情報（Flat: APIから取得できる全詳細データ）
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

  /// 名前のテキストマップハッシュ（ローカライズ用）
  final String nameTextMapHash;

  /// レアリティ（1-5星）
  final int rankLevel;

  /// アイテムタイプ（ITEM_RELIQUARY, ITEM_WEAPONなど）
  final String itemType;

  /// アイコンのファイル名
  final String icon;

  /// 装備タイプ（EQUIP_BRACER=花、EQUIP_NECKLACE=羽、など）
  final String? equipType;

  /// セットID（聖遺物セットの識別子）
  final int? setId;

  /// セット名のテキストマップハッシュ
  final String? setNameTextMapHash;

  /// サブステータス一覧（現在の最終値）
  final List<EquipmentSubstat>? reliquarySubstats;

  /// メインステータス（現在の値）
  final ReliquaryMainstat? reliquaryMainstat;

  /// 武器のステータス一覧
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
