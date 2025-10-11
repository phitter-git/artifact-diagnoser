import 'dart:convert';
import 'package:artifact_diagnoser/src/utils/json_utils.dart';
import 'package:artifact_diagnoser/src/models/remote/player_info.dart';
import 'package:artifact_diagnoser/src/models/remote/avatar_info.dart';

/// ユーザーデータ
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
      avatarInfoList: readList(json['avatarInfoList'])
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
