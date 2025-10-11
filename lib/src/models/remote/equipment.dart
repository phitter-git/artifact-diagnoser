import 'package:artifact_diagnoser/src/models/remote/reliquary_info.dart';
import 'package:artifact_diagnoser/src/models/remote/weapon_info.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment_flat.dart';

/// 装備情報
class Equipment {
  const Equipment({
    required this.itemId,
    this.reliquary,
    this.weapon,
    required this.flat,
  });

  final int itemId;
  final ReliquaryInfo? reliquary;
  final WeaponInfo? weapon;
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
