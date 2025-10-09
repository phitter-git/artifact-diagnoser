import 'dart:convert';
import 'package:flutter/services.dart';

/// ステータスのローカライゼーションを提供するサービス
class StatLocalizer {
  StatLocalizer(this._labels);

  final Map<String, String> _labels;

  static StatLocalizer? _cache;

  /// ステータスローカライザーを読み込む
  static Future<StatLocalizer> load() async {
    if (_cache != null) {
      return _cache!;
    }
    
    final content = await rootBundle.loadString('assets/json/stats_l18n.json');
    final Map<String, dynamic> data = jsonDecode(content) as Map<String, dynamic>;
    final labels = data.map((key, value) => MapEntry(key, value.toString()));
    _cache = StatLocalizer(labels);
    return _cache!;
  }

  /// 指定されたキーに対応するラベルを取得する
  String labelFor(String? key) {
    if (key == null || key.isEmpty) {
      return '';
    }
    return _labels[key] ?? key;
  }
}