import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/property_value.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment.dart';
import 'package:artifact_diagnoser/src/models/remote/fetter_info.dart';

/// アバター情報
class AvatarInfo {
  const AvatarInfo({
    required this.avatarId,
    required this.propMap,
    required this.talentIdList,
    required this.fightPropMap,
    required this.equipList,
    this.fetterInfo,
    this.costumeId,
  });

  final int avatarId;
  final Map<String, PropertyValue> propMap;
  final List<int> talentIdList;
  final Map<String, double> fightPropMap;
  final List<Equipment> equipList;
  final FetterInfo? fetterInfo;
  final int? costumeId;

  factory AvatarInfo.fromJson(Map<String, dynamic> json) {
    return AvatarInfo(
      avatarId: (json['avatarId'] as num?)?.toInt() ?? 0,
      propMap: readMap(json['propMap']).map(
        (key, value) => MapEntry(
          key,
          PropertyValue.fromJson(value as Map<String, dynamic>),
        ),
      ),
      talentIdList: readList(
        json['talentIdList'],
      ).map((entry) => (entry as num).toInt()).toList(),
      fightPropMap: readMap(
        json['fightPropMap'],
      ).map((key, value) => MapEntry(key, (value as num).toDouble())),
      equipList: readList(json['equipList'])
          .map((entry) => Equipment.fromJson(entry as Map<String, dynamic>))
          .toList(),
      fetterInfo: json['fetterInfo'] == null
          ? null
          : FetterInfo.fromJson(json['fetterInfo'] as Map<String, dynamic>),
      costumeId: (json['costumeId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarId': avatarId,
      'propMap': propMap.map((key, value) => MapEntry(key, value.toJson())),
      'talentIdList': talentIdList,
      'fightPropMap': fightPropMap,
      'equipList': equipList.map((equip) => equip.toJson()).toList(),
      if (fetterInfo != null) 'fetterInfo': fetterInfo!.toJson(),
      if (costumeId != null) 'costumeId': costumeId,
    };
  }
}
