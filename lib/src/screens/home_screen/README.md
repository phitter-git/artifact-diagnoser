# ホーム画面パッケージ

UID入力画面を提供するパッケージです。

## 機能

- **UID入力**: 9桁のUIDを入力
- **バリデーション**: UID形式のチェック
- **画面遷移**: 聖遺物一覧画面への遷移

## 使用方法

```dart
import 'package:home_screen/home_screen.dart';

// ルーティング設定
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeScreen(),
  },
)
```

## UI設計

UI設計詳細は `/docs/requirements/ui_design.md` の「4.1 ホーム画面（UID入力）」を参照してください。
