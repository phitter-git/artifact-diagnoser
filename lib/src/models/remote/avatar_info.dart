import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/property_value.dart';
import 'package:artifact_diagnoser/src/models/remote/equipment.dart';
import 'package:artifact_diagnoser/src/models/remote/fetter_info.dart';

/// アバター（キャラクター）情報
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

  /// アバターID（キャラクター識別子）
  final int avatarId;

  /// プロパティマップ（レベル、経験値など）
  final Map<String, PropertyValue> propMap;

  /// 天賦IDリスト（解放済みの天賦）
  final List<int> talentIdList;

  /// 戦闘プロパティマップ（攻撃力、会心率など）
  final Map<String, double> fightPropMap;

  /// 装備リスト（聖遺物、武器）
  final List<Equipment> equipList;

  /// 好感度情報
  final FetterInfo? fetterInfo;

  /// 衣装ID（着用中の衣装）
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
