/// 数値の識別子を抽出するユーティリティ関数
String extractIdentifier(int value) {
  final digits = value.abs().toString();
  final splitIndex = digits.isNotEmpty ? digits.length - 1 : 0;
  final basePart = digits.substring(0, splitIndex);
  if (basePart.isEmpty) {
    return ''.padLeft(5, '0');
  }
  return basePart.padLeft(5, '0');
}

/// 数値のサフィックスを抽出するユーティリティ関数
int extractSuffix(int value) {
  final digits = value.abs().toString();
  if (digits.isEmpty) {
    return 0;
  }
  return int.parse(digits.substring(digits.length - 1));
}

/// 数値をフォーマットするユーティリティ関数
String formatNumber(num? value) {
  if (value == null) {
    return '-';
  }
  final doubleValue = value.toDouble();
  if (doubleValue == doubleValue.roundToDouble()) {
    return doubleValue.toInt().toString();
  }
  return doubleValue.toString();
}

/// 付加値リストをフォーマットするユーティリティ関数
String formatAppendValues(List<String> values) {
  if (values.isEmpty) {
    return 'なし';
  }
  return values.join(' + ');
}
