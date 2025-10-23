import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマモード管理サービス
///
/// ダークモード/ライトモードの設定を管理します。
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// ダークモードが有効か（ThemeMode.systemの場合はシステム設定を参照）
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // ThemeMode.systemの場合、実際にUI上ではダークモードになっている可能性がある
    // ここでは単純にfalseを返す（ユーザーが明示的に設定していないため）
    return false;
  }

  /// 初期化（保存されたテーマモードを読み込み）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    } else {
      // 初回訪問時はシステム設定に従う（デフォルトはThemeMode.system）
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// テーマモードを変更
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// ダークモードのON/OFF切り替え
  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
