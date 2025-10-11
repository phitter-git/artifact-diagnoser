import 'package:artifact_diagnoser/src/models/remote/reliquary_info.dart';
import 'package:artifact_diagnoser/src/models/remote/weapon_info.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment_flat.dart';

/// 装備情報（聖遺物または武器）
class Equipment {
  const Equipment({
    required this.itemId,
    this.reliquary,
    this.weapon,
    required this.flat,
  });

  /// アイテムID（装備の識別子）
  final int itemId;

  /// 聖遺物情報（聖遺物の場合のみ）
  final ReliquaryInfo? reliquary;

  /// 武器情報（武器の場合のみ）
  final WeaponInfo? weapon;

  /// 装備の詳細情報（名前、アイコン、ステータスなど）
  final EquipmentFlat flat;

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      reliquary: json['reliquary'] == null
          ? null
          : ReliquaryInfo.fromJson(json['reliquary'] as Map<String, dynamic>),
      weapon: json['weapon'] == null
          ? null
          : WeaponInfo.fromJson(json['weapon'] as Map<String, dynamic>),
      flat: EquipmentFlat.fromJson(
        json['flat'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      if (reliquary != null) 'reliquary': reliquary!.toJson(),
      if (weapon != null) 'weapon': weapon!.toJson(),
      'flat': flat.toJson(),
    };
  }
}
