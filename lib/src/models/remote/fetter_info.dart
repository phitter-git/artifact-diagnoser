/// フェッター（好感度）情報
class FetterInfo {
  const FetterInfo({required this.expLevel});

  final int expLevel;

  factory FetterInfo.fromJson(Map<String, dynamic> json) {
    return FetterInfo(expLevel: (json['expLevel'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() => {'expLevel': expLevel};
}
