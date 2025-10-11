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

  /// プレイヤー名
  final String nickname;

  /// 冒険ランク
  final int level;

  /// 一言コメント
  final String signature;

  /// 世界ランク
  final int worldLevel;

  /// 名刺ID
  final int nameCardId;

  /// 達成済み実績数
  final int finishAchievementNum;

  /// 深境螺旋：到達階層
  final int towerFloorIndex;

  /// 深境螺旋：到達間
  final int towerLevelIndex;

  /// 展示中のキャラクター情報
  final List<ShowAvatarInfo> showAvatarInfoList;

  /// 展示中の名刺IDリスト
  final List<int> showNameCardIdList;

  /// プロフィール画像
  final ProfilePicture profilePicture;

  /// 幻想シアター：幕
  final int theaterActIndex;

  /// 幻想シアター：難易度
  final int theaterModeIndex;

  /// 幻想シアター：星数
  final int theaterStarIndex;

  /// キャラクター天賦表示フラグ
  final bool isShowAvatarTalent;

  /// 好感度レベルが最大のキャラクター数
  final int fetterCount;

  /// 深境螺旋：獲得星数
  final int towerStarIndex;

  /// ステュギアの夜：階層
  final int stygianIndex;

  /// ステュギアの夜：クリア秒数
  final int stygianSeconds;

  /// ステュギアの夜：ID
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
