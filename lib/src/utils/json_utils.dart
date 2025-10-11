/// JSON解析用のヘルパー関数
///
/// JSONのリストを安全に読み取る
List<dynamic> readList(Object? source) {
  if (source is List) {
    return source;
  }
  return const [];
}

/// JSONのマップを安全に読み取る
Map<String, dynamic> readMap(Object? source) {
  if (source is Map<String, dynamic>) {
    return source;
  }
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}
