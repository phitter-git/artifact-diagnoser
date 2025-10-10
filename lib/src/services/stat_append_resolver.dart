import 'dart:convert';
import 'package:flutter/services.dart';

/// ステータスの付加値を解決するサービス
class StatAppendResolver {
  StatAppendResolver(this._values);

  final Map<String, Map<String, String>> _values;

  static StatAppendResolver? _cache;

  /// ステータス付加値リゾルバーを読み込む
  static Future<StatAppendResolver> load() async {
    if (_cache != null) {
      return _cache!;
    }

    final content = await rootBundle.loadString(
      'assets/json/stats_append.json',
    );
    final Map<String, dynamic> raw =
        jsonDecode(content) as Map<String, dynamic>;
    final values = <String, Map<String, String>>{};

    raw.forEach((key, dynamic value) {
      final map = <String, String>{};
      (value as Map).forEach((innerKey, innerValue) {
        map[innerKey.toString()] = innerValue.toString();
      });
      values[key] = map;
    });

    _cache = StatAppendResolver(values);
    return _cache!;
  }

  /// 指定された付加プロパティIDとサフィックスリストに対応する値を取得する
  List<String> valuesFor(String appendPropId, List<int> suffixes) {
    final table = _values[appendPropId];
    if (table == null) {
      return suffixes.map((suffix) => suffix.toString()).toList();
    }

    final result = <String>[];
    for (final suffix in suffixes) {
      final key = suffix.toString();
      result.add(table[key] ?? key);
    }
    return result;
  }
}
