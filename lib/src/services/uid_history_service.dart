import 'package:shared_preferences/shared_preferences.dart';

/// UID入力履歴を管理するサービス
///
/// SharedPreferencesを使用して、最大3件のUID履歴をローカルに保存します。
/// 有効なUID（データ取得成功）のみを保存します。
class UidHistoryService {
  static const String _storageKey = 'uid_history';
  static const int _maxHistoryCount = 10;

  /// UID履歴を取得
  ///
  /// 保存されているUID履歴を新しい順に返します。
  /// 最大10件まで保存されます。
  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_storageKey) ?? [];
    return history;
  }

  /// UID履歴に追加
  ///
  /// 新しいUIDを履歴の先頭に追加します。
  /// - 既に存在する場合は、そのUIDを削除して先頭に追加
  /// - 最大10件を超える場合は、古いものから削除
  ///
  /// [uid] 追加するUID（有効なUIDのみ渡すこと）
  Future<void> addToHistory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // 既存の同じUIDを削除（重複防止）
    history.remove(uid);

    // 先頭に追加
    history.insert(0, uid);

    // 最大件数を超える場合は削除
    if (history.length > _maxHistoryCount) {
      history.removeRange(_maxHistoryCount, history.length);
    }

    // 保存
    await prefs.setStringList(_storageKey, history);
  }

  /// UID履歴をクリア
  ///
  /// すべての履歴を削除します。
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
