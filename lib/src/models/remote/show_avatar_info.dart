/// 表示用アバター情報
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
