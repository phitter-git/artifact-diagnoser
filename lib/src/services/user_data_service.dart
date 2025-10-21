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

  /// CORSプロキシのURL（Web版でのCORSエラー回避用）
  static const String _corsProxy = 'https://corsproxy.io/?';

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
    // デバッグ用ログ
    if (kDebugMode) {
      print('fetchUserData called with UID: $uid');
      print('kIsWeb: $kIsWeb');
      if (kIsWeb) {
        print('Uri.base: ${Uri.base}');
        print('Uri.base.host: ${Uri.base.host}');
      }
      print('_isLocalhost: $_isLocalhost');
    }

    if (_isLocalhost) {
      if (kDebugMode) {
        print('Loading from local file');
      }
      return await _loadLocalUserData();
    } else {
      if (kDebugMode) {
        print('Fetching from Enka API');
      }
      return await _fetchFromEnkaApi(uid);
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
    // Web版ではCORSプロキシを使用
    final apiUrl = kIsWeb
        ? '$_corsProxy$_enkaApiBaseUrl/$uid'
        : '$_enkaApiBaseUrl/$uid';
    final url = Uri.parse(apiUrl);

    try {
      final response = await http
          .get(
            url,
            headers: {
              // ブラウザ標準のAcceptヘッダーに合わせる（Web版でのAPI互換性向上）
              'Accept':
                  'application/json, text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8',
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

        // デバッグ用ログ
        if (kDebugMode) {
          print('API Response received (${jsonString.length} bytes)');
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
          print('Response UID: ${jsonData['uid']}');
          print('Response TTL: ${jsonData['ttl']}');
          print(
            'Response playerInfo.nickname: ${(jsonData['playerInfo'] as Map?)?['nickname']}',
          );
        }

        try {
          final userData = UserData.fromJsonString(jsonString);
          if (kDebugMode) {
            print('UserData parsed successfully. UID: ${userData.uid}');
          }
          return userData;
        } catch (e, stackTrace) {
          // JSON解析エラーの詳細をログ出力（開発時のデバッグ用）
          if (kDebugMode) {
            print('JSON解析エラー: $e');
            print('スタックトレース: $stackTrace');
            print(
              'レスポンス（最初の500文字）: ${jsonString.substring(0, jsonString.length > 500 ? 500 : jsonString.length)}',
            );
          }
          throw UserDataServiceException('レスポンスの解析に失敗しました', originalError: e);
        }
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
    } on UserDataServiceException {
      // 既に UserDataServiceException の場合はそのまま再スロー
      rethrow;
    } on http.ClientException catch (e) {
      throw UserDataServiceException('ネットワークエラーが発生しました', originalError: e);
    } catch (e) {
      // その他の予期しない例外
      throw UserDataServiceException('予期しないエラーが発生しました', originalError: e);
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
