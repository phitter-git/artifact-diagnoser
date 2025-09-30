import 'dart:convert';

// ユーザーデータのJSONをモデル化したクラス群
class UserData {
  const UserData({
    required this.playerInfo,
    required this.avatarInfoList,
    required this.ttl,
    required this.uid,
  });

  final PlayerInfo playerInfo;
  final List<AvatarInfo> avatarInfoList;
  final int ttl;
  final String uid;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      playerInfo: PlayerInfo.fromJson(
        json['playerInfo'] as Map<String, dynamic>? ?? const {},
      ),
      avatarInfoList: _readList(json['avatarInfoList'])
          .map((entry) => AvatarInfo.fromJson(entry as Map<String, dynamic>))
          .toList(),
      ttl: (json['ttl'] as num?)?.toInt() ?? 0,
      uid: json['uid'] as String? ?? '',
    );
  }

  factory UserData.fromJsonString(String source) {
    return UserData.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'playerInfo': playerInfo.toJson(),
      'avatarInfoList': avatarInfoList
          .map((avatar) => avatar.toJson())
          .toList(),
      'ttl': ttl,
      'uid': uid,
    };
  }
}

class PlayerInfo {
  const PlayerInfo({
    required this.nickname,
    required this.level,
    required this.signature,
    required this.worldLevel,
    required this.nameCardId,
    required this.finishAchievementNum,
    required this.towerFloorIndex,
    required this.towerLevelIndex,
    required this.showAvatarInfoList,
    required this.showNameCardIdList,
    required this.profilePicture,
    required this.theaterActIndex,
    required this.theaterModeIndex,
    required this.theaterStarIndex,
    required this.isShowAvatarTalent,
    required this.fetterCount,
    required this.towerStarIndex,
    required this.stygianIndex,
    required this.stygianSeconds,
    required this.stygianId,
  });

  final String nickname;
  final int level;
  final String signature;
  final int worldLevel;
  final int nameCardId;
  final int finishAchievementNum;
  final int towerFloorIndex;
  final int towerLevelIndex;
  final List<ShowAvatarInfo> showAvatarInfoList;
  final List<int> showNameCardIdList;
  final ProfilePicture profilePicture;
  final int theaterActIndex;
  final int theaterModeIndex;
  final int theaterStarIndex;
  final bool isShowAvatarTalent;
  final int fetterCount;
  final int towerStarIndex;
  final int stygianIndex;
  final int stygianSeconds;
  final int stygianId;

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      nickname: json['nickname'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 0,
      signature: json['signature'] as String? ?? '',
      worldLevel: (json['worldLevel'] as num?)?.toInt() ?? 0,
      nameCardId: (json['nameCardId'] as num?)?.toInt() ?? 0,
      finishAchievementNum:
          (json['finishAchievementNum'] as num?)?.toInt() ?? 0,
      towerFloorIndex: (json['towerFloorIndex'] as num?)?.toInt() ?? 0,
      towerLevelIndex: (json['towerLevelIndex'] as num?)?.toInt() ?? 0,
      showAvatarInfoList: _readList(json['showAvatarInfoList'])
          .map(
            (entry) => ShowAvatarInfo.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      showNameCardIdList: _readList(
        json['showNameCardIdList'],
      ).map((entry) => (entry as num).toInt()).toList(),
      profilePicture: ProfilePicture.fromJson(
        json['profilePicture'] as Map<String, dynamic>? ?? const {},
      ),
      theaterActIndex: (json['theaterActIndex'] as num?)?.toInt() ?? 0,
      theaterModeIndex: (json['theaterModeIndex'] as num?)?.toInt() ?? 0,
      theaterStarIndex: (json['theaterStarIndex'] as num?)?.toInt() ?? 0,
      isShowAvatarTalent: json['isShowAvatarTalent'] as bool? ?? false,
      fetterCount: (json['fetterCount'] as num?)?.toInt() ?? 0,
      towerStarIndex: (json['towerStarIndex'] as num?)?.toInt() ?? 0,
      stygianIndex: (json['stygianIndex'] as num?)?.toInt() ?? 0,
      stygianSeconds: (json['stygianSeconds'] as num?)?.toInt() ?? 0,
      stygianId: (json['stygianId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'level': level,
      'signature': signature,
      'worldLevel': worldLevel,
      'nameCardId': nameCardId,
      'finishAchievementNum': finishAchievementNum,
      'towerFloorIndex': towerFloorIndex,
      'towerLevelIndex': towerLevelIndex,
      'showAvatarInfoList': showAvatarInfoList
          .map((info) => info.toJson())
          .toList(),
      'showNameCardIdList': showNameCardIdList,
      'profilePicture': profilePicture.toJson(),
      'theaterActIndex': theaterActIndex,
      'theaterModeIndex': theaterModeIndex,
      'theaterStarIndex': theaterStarIndex,
      'isShowAvatarTalent': isShowAvatarTalent,
      'fetterCount': fetterCount,
      'towerStarIndex': towerStarIndex,
      'stygianIndex': stygianIndex,
      'stygianSeconds': stygianSeconds,
      'stygianId': stygianId,
    };
  }
}

class ShowAvatarInfo {
  const ShowAvatarInfo({
    required this.avatarId,
    required this.level,
    this.costumeId,
    required this.talentLevel,
    required this.energyType,
  });

  final int avatarId;
  final int level;
  final int? costumeId;
  final int talentLevel;
  final int energyType;

  factory ShowAvatarInfo.fromJson(Map<String, dynamic> json) {
    return ShowAvatarInfo(
      avatarId: (json['avatarId'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      costumeId: (json['costumeId'] as num?)?.toInt(),
      talentLevel: (json['talentLevel'] as num?)?.toInt() ?? 0,
      energyType: (json['energyType'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarId': avatarId,
      'level': level,
      if (costumeId != null) 'costumeId': costumeId,
      'talentLevel': talentLevel,
      'energyType': energyType,
    };
  }
}

class ProfilePicture {
  const ProfilePicture({required this.id});

  final int id;

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(id: (json['id'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

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
      propMap: _readMap(json['propMap']).map(
        (key, value) => MapEntry(
          key,
          PropertyValue.fromJson(value as Map<String, dynamic>),
        ),
      ),
      talentIdList: _readList(
        json['talentIdList'],
      ).map((entry) => (entry as num).toInt()).toList(),
      fightPropMap: _readMap(
        json['fightPropMap'],
      ).map((key, value) => MapEntry(key, (value as num).toDouble())),
      equipList: _readList(json['equipList'])
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

class PropertyValue {
  const PropertyValue({required this.type, required this.ival, this.val});

  final int type;
  final String ival;
  final String? val;

  factory PropertyValue.fromJson(Map<String, dynamic> json) {
    return PropertyValue(
      type: (json['type'] as num?)?.toInt() ?? 0,
      ival: json['ival']?.toString() ?? '0',
      val: json['val']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'ival': ival, if (val != null) 'val': val};
  }
}

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

class ReliquaryInfo {
  const ReliquaryInfo({
    required this.level,
    this.mainPropId,
    this.appendPropIdList,
    this.promoteLevel,
  });

  final int level;
  final int? mainPropId;
  final List<int>? appendPropIdList;
  final int? promoteLevel;

  factory ReliquaryInfo.fromJson(Map<String, dynamic> json) {
    return ReliquaryInfo(
      level: (json['level'] as num?)?.toInt() ?? 0,
      mainPropId: (json['mainPropId'] as num?)?.toInt(),
      appendPropIdList: json['appendPropIdList'] == null
          ? null
          : _readList(
              json['appendPropIdList'],
            ).map((entry) => (entry as num).toInt()).toList(),
      promoteLevel: (json['promoteLevel'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      if (mainPropId != null) 'mainPropId': mainPropId,
      if (appendPropIdList != null) 'appendPropIdList': appendPropIdList,
      if (promoteLevel != null) 'promoteLevel': promoteLevel,
    };
  }
}

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
      affixMap: _readMap(
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
          : _readList(json['reliquarySubstats'])
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
          : _readList(json['weaponStats'])
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

class ReliquaryMainstat {
  const ReliquaryMainstat({required this.mainPropId, required this.statValue});

  final String mainPropId;
  final double statValue;

  factory ReliquaryMainstat.fromJson(Map<String, dynamic> json) {
    return ReliquaryMainstat(
      mainPropId: json['mainPropId']?.toString() ?? '',
      statValue: (json['statValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mainPropId': mainPropId, 'statValue': statValue};
  }
}

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

class FetterInfo {
  const FetterInfo({required this.expLevel});

  final int expLevel;

  factory FetterInfo.fromJson(Map<String, dynamic> json) {
    return FetterInfo(expLevel: (json['expLevel'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() => {'expLevel': expLevel};
}

List<dynamic> _readList(Object? source) {
  if (source is List) {
    return source;
  }
  return const [];
}

Map<String, dynamic> _readMap(Object? source) {
  if (source is Map<String, dynamic>) {
    return source;
  }
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}
