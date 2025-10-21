import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:artifact_diagnoser/src/models/remote.dart';

/// ユーザーデータ取得サービス
///
/// Enka Network APIからユーザーデータを取得します。
/// localhost環境では、assets/json/userdata.jsonを使用します。
class UserDataService {
  /// Enka Network API のベースURL
  static const String _enkaApiBaseUrl = 'https://enka.network/api/uid';

  /// ローカル開発用のユーザーデータファイルパス
  static const String _localUserDataPath = 'assets/json/userdata.json';

  /// localhost判定
  bool get _isLocalhost {
    if (kIsWeb) {
      // Web環境でのlocalhost判定
      final uri = Uri.base;
      return uri.host == 'localhost' || uri.host == '127.0.0.1';
    }
    return false;
  }

  /// ユーザーデータを取得
  ///
  /// [uid] ユーザーID（9桁の数字）
  ///
  /// localhost環境の場合は、ローカルのJSONファイルを読み込みます。
  /// それ以外の場合は、Enka Network APIにリクエストを送信します。
  ///
  /// throws [UserDataServiceException] データ取得に失敗した場合
  Future<UserData> fetchUserData(String uid) async {
    try {
      if (_isLocalhost) {
        return await _loadLocalUserData();
      } else {
        return await _fetchFromEnkaApi(uid);
      }
    } catch (e) {
      throw UserDataServiceException('ユーザーデータの取得に失敗しました: $e', originalError: e);
    }
  }

  /// ローカルのJSONファイルからユーザーデータを読み込み
  Future<UserData> _loadLocalUserData() async {
    try {
      final jsonString = await rootBundle.loadString(_localUserDataPath);
      return UserData.fromJsonString(jsonString);
    } catch (e) {
      throw UserDataServiceException('ローカルデータの読み込みに失敗しました', originalError: e);
    }
  }

  /// Enka Network APIからユーザーデータを取得
  Future<UserData> _fetchFromEnkaApi(String uid) async {
    final url = Uri.parse('$_enkaApiBaseUrl/$uid');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ArtifactDiagnoser/0.1.0',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw UserDataServiceException('リクエストがタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        // UTF-8でデコード
        final jsonString = utf8.decode(response.bodyBytes);
        return UserData.fromJsonString(jsonString);
      } else if (response.statusCode == 404) {
        throw UserDataServiceException('ユーザーが見つかりません。UIDを確認してください。');
      } else if (response.statusCode == 424) {
        throw UserDataServiceException('ゲーム内のプロフィール設定で「キャラクター詳細」を公開してください。');
      } else if (response.statusCode == 429) {
        throw UserDataServiceException('リクエストが多すぎます。しばらく待ってから再試行してください。');
      } else if (response.statusCode == 500) {
        throw UserDataServiceException('サーバーエラーが発生しました。しばらく待ってから再試行してください。');
      } else {
        throw UserDataServiceException(
          'データの取得に失敗しました（ステータスコード: ${response.statusCode}）',
        );
      }
    } on FormatException catch (e) {
      throw UserDataServiceException('レスポンスの解析に失敗しました', originalError: e);
    } on http.ClientException catch (e) {
      throw UserDataServiceException('ネットワークエラーが発生しました', originalError: e);
    }
  }
}

/// ユーザーデータサービスの例外
class UserDataServiceException implements Exception {
  const UserDataServiceException(this.message, {this.originalError});

  final String message;
  final Object? originalError;

  @override
  String toString() {
    if (originalError != null) {
      return '$message (詳細: $originalError)';
    }
    return message;
  }
}
