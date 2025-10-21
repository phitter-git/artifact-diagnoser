# 技術仕様

このドキュメントでは、聖遺物診断器の技術的な実装仕様を定義します。

---

## 📖 目次

1. [技術スタック](#技術スタック)
2. [アーキテクチャ](#アーキテクチャ)
3. [API仕様](#api仕様)
4. [データモデル](#データモデル)
5. [データ保存戦略](#データ保存戦略)
6. [パフォーマンス最適化](#パフォーマンス最適化)
7. [セキュリティ](#セキュリティ)
8. [エラーハンドリング](#エラーハンドリング)

---

## 1. 技術スタック

### フロントエンド
- **Framework**: Flutter 3.9.2+
- **言語**: Dart
- **状態管理**: Provider / Riverpod（検討中）
- **パッケージ管理**: Melos（モノレポ構成）

### プラットフォーム
- **Phase 1**: Web（Chrome, Firefox, Edge, Safari）
- **Phase 2**: Android / iOS（将来拡張）

### 開発ツール
- **IDE**: VS Code / Android Studio
- **バージョン管理**: Git / GitHub
- **CI/CD**: GitHub Actions（予定）
- **ホスティング**: GitHub Pages / Firebase Hosting（検討中）

---

## 2. アーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────┐
│  UI Layer (screens, components) │
│  - StatefulWidget / StatelessWidget
│  - ユーザー入力の受付
│  - 表示ロジック
├─────────────────────────────────┤
│  Business Logic Layer (services)│
│  - スコアリング計算
│  - 分析ロジック
│  - データ変換
├─────────────────────────────────┤
│  Data Layer (models, utils)     │
│  - API通信 (remote models)
│  - ドメインモデル (domain models)
│  - データ永続化
└─────────────────────────────────┘
```

### ディレクトリ構成

```
lib/
├── main.dart
└── src/
    ├── models/
    │   ├── remote/          # API通信用モデル
    │   ├── domain/          # アプリ内部モデル
    │   ├── remote.dart      # remoteエクスポート
    │   └── domain.dart      # domainエクスポート
    ├── services/            # ビジネスロジック
    │   ├── reliquary_analysis_service.dart
    │   ├── reliquary_scoring_service.dart
    │   └── data_storage_service.dart
    ├── utils/               # ユーティリティ関数
    │   ├── json_utils.dart
    │   └── format_utils.dart
    ├── components/          # 再利用可能なUIコンポーネント
    │   └── reliquary_summary_view.dart
    ├── screens/             # 画面実装（独立パッケージ）
    │   └── demo_page/
    └── i18n/                # 多言語対応
```

---

## 3. API仕様

### 使用API

#### Enka Network API（予定）
- **Base URL**: `https://enka.network/api`
- **レート制限**: 1リクエスト/秒
- **認証**: 不要

#### エンドポイント

##### GET /uid/{uid}
ユーザーの聖遺物データを取得

**リクエスト:**
```http
GET https://enka.network/api/uid/123456789
```

**レスポンス:**
```json
{
  "uid": "123456789",
  "playerInfo": {
    "nickname": "Traveler",
    "level": 60,
    ...
  },
  "avatarInfoList": [
    {
      "avatarId": 10000002,
      "equipList": [
        {
          "itemId": 81324,
          "flat": {
            "nameTextMapHash": "炎魔女の燃え盛る炎",
            "equipType": "EQUIP_BRACER",
            "reliquaryMainstat": {...},
            "reliquarySubstats": [...]
          }
        }
      ]
    }
  ]
}
```

### HTTPクライアント設定

```dart
class ApiClient {
  static const String baseUrl = 'https://enka.network/api';
  static const Duration timeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  
  final http.Client _client;
  
  Future<UserData> fetchUserData(String uid) async {
    final uri = Uri.parse('$baseUrl/uid/$uid');
    
    try {
      final response = await _client
        .get(uri)
        .timeout(timeout);
        
      if (response.statusCode == 200) {
        return UserData.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      // リトライロジック
      // エラーハンドリング
    }
  }
}
```

---

## 4. データモデル

### モデルの分類

#### Remote Models（API通信用）
- `UserData`: APIレスポンス全体
- `PlayerInfo`: プレイヤー情報
- `AvatarInfo`: キャラクター情報
- `Equipment`: 装備情報（聖遺物含む）
- `ReliquaryInfo`: 聖遺物詳細

#### Domain Models（アプリ内部用）
- `ReliquarySummary`: 分析済み聖遺物データ
- `SubstatSummary`: サブオプション詳細
- `MutableSubstat`: 内部処理用可変データ

### データ変換フロー

```
API Response (JSON)
    ↓
Remote Model (UserData)
    ↓
Converter (remote_to_domain.dart)
    ↓
Domain Model (ReliquarySummary)
    ↓
UI Display
```

### 型定義例

```dart
// Remote Model
class Equipment {
  final int itemId;
  final EquipmentFlat flat;
  
  Equipment({required this.itemId, required this.flat});
  
  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      itemId: json['itemId'] as int,
      flat: EquipmentFlat.fromJson(json['flat']),
    );
  }
}

// Domain Model
class ReliquarySummary {
  final int itemId;
  final String equipTypeLabel;
  final double totalScore;
  final ScoreRank rank;
  final List<SubstatSummary> substats;
  
  const ReliquarySummary({...});
}
```

---

## 5. データ保存戦略

### Phase 1: LocalStorage

#### 保存データ
- ユーザーID
- 最終取得日時
- 聖遺物データ（JSON形式）
- スコアリング設定

#### 保存キー
```dart
class StorageKeys {
  static const String lastUid = 'last_uid';
  static const String lastFetchTime = 'last_fetch_time';
  static const String reliquaryData = 'reliquary_data';
  static const String scoringSettings = 'scoring_settings';
}
```

#### 実装例

```dart
class DataStorageService {
  final SharedPreferences _prefs;
  
  /// データを保存
  Future<void> saveReliquaryData(List<ReliquarySummary> data) async {
    final json = jsonEncode(data.map((e) => e.toJson()).toList());
    
    // データ圧縮（容量削減）
    final compressed = gzip.encode(utf8.encode(json));
    final base64 = base64Encode(compressed);
    
    await _prefs.setString(StorageKeys.reliquaryData, base64);
    await _prefs.setString(
      StorageKeys.lastFetchTime,
      DateTime.now().toIso8601String(),
    );
  }
  
  /// データを読み込み
  Future<List<ReliquarySummary>?> loadReliquaryData() async {
    final base64 = _prefs.getString(StorageKeys.reliquaryData);
    if (base64 == null) return null;
    
    try {
      final compressed = base64Decode(base64);
      final json = utf8.decode(gzip.decode(compressed));
      final list = jsonDecode(json) as List;
      
      return list.map((e) => ReliquarySummary.fromJson(e)).toList();
    } catch (e) {
      // データ破損時の処理
      return null;
    }
  }
}
```

### Phase 2: IndexedDB（将来拡張）

大量データ対応のため、IndexedDBへの移行を検討。

---

## 6. パフォーマンス最適化

### 6.1 レンダリング最適化

#### リスト表示の仮想化
```dart
// 大量の聖遺物を効率的に表示
ListView.builder(
  itemCount: reliquaries.length,
  itemBuilder: (context, index) {
    return ReliquaryCard(reliquary: reliquaries[index]);
  },
)
```

#### メモ化
```dart
// 計算結果のキャッシング
class ReliquaryScoringService {
  final _scoreCache = <int, ReliquaryScore>{};
  
  ReliquaryScore calculateScore(ReliquarySummary reliquary) {
    final cacheKey = reliquary.itemId;
    
    if (_scoreCache.containsKey(cacheKey)) {
      return _scoreCache[cacheKey]!;
    }
    
    final score = _computeScore(reliquary);
    _scoreCache[cacheKey] = score;
    return score;
  }
}
```

### 6.2 データ読み込み最適化

#### 遅延読み込み
```dart
// 初期表示時は最小限のデータのみ読み込み
Future<void> loadInitialData() async {
  // 最初の20件のみ読み込み
  final initial = await fetchReliquaries(limit: 20);
  setState(() => reliquaries = initial);
  
  // 残りはバックグラウンドで読み込み
  fetchRemainingReliquaries().then((remaining) {
    setState(() => reliquaries.addAll(remaining));
  });
}
```

### 6.3 計算の並列化

```dart
// スコア計算を並列実行
Future<List<ReliquaryScore>> calculateScoresParallel(
  List<ReliquarySummary> reliquaries,
) async {
  return await compute(_calculateScoresBatch, reliquaries);
}

// Isolateで実行される関数
List<ReliquaryScore> _calculateScoresBatch(
  List<ReliquarySummary> reliquaries,
) {
  return reliquaries.map((r) => _calculateScore(r)).toList();
}
```

---

## 7. セキュリティ

### 7.1 データ保護
- **ローカルストレージ**: 暗号化は不要（公開データのみ）
- **API通信**: HTTPS必須
- **XSS対策**: サニタイズ処理（ユーザー入力は数字のみ）

### 7.2 プライバシー
- **個人情報**: UIDのみ（個人特定不可）
- **Cookie**: 必要最小限（LocalStorageを優先）
- **アナリティクス**: オプトアウト可能（将来実装）

---

## 8. エラーハンドリング

### エラー分類

| エラータイプ | HTTPステータス | 対応 |
|-------------|--------------|------|
| ネットワークエラー | - | リトライ3回、タイムアウト10秒 |
| 不正なUID | 400 | バリデーションメッセージ表示 |
| UID不存在 | 404 | "UIDが見つかりません"表示 |
| レート制限 | 429 | 1秒待機後リトライ |
| サーバーエラー | 500 | エラーメッセージ + サポートリンク |

### 実装例

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
  
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'UIDの形式が正しくありません';
      case 404:
        return 'UIDが見つかりませんでした';
      case 429:
        return 'リクエストが多すぎます。しばらく待ってから再試行してください';
      case 500:
      case 502:
      case 503:
        return 'サーバーエラーが発生しました';
      default:
        return '不明なエラーが発生しました（$statusCode）';
    }
  }
}
```

---

## 📝 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-10-12 | 初版作成、技術スタックとアーキテクチャ定義 |
