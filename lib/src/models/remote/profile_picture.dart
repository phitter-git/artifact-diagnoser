/// プロフィール画像情報
class ProfilePicture {
  const ProfilePicture({required this.id});

  final int id;

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(id: (json['id'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
