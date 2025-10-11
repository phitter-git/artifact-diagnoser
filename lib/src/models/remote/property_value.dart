/// プロパティ値
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
