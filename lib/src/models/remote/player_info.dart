import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/show_avatar_info.dart';
import 'package:artifact_diagnoser/src/models/remote/profile_picture.dart';

/// プレイヤー情報
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
      showAvatarInfoList: readList(json['showAvatarInfoList'])
          .map(
            (entry) => ShowAvatarInfo.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      showNameCardIdList: readList(
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
