# 聖遺物一覧画面パッケージ

聖遺物データの一覧表示を提供するパッケージです。

## 機能

- **聖遺物一覧表示**: ユーザーの全聖遺物を一覧表示
- **データ読み込み**: Enka Network APIまたはローカルJSONからデータを取得
- **スコア表示**: 各聖遺物のスコアとランクを表示

## 使用方法

```dart
import 'package:reliquary_list_screen/reliquary_list_screen.dart';

// ルーティング設定
MaterialApp(
  routes: {
    '/reliquary-list': (context) => const ReliquaryListScreen(),
  },
)

// 画面遷移
Navigator.pushNamed(
  context,
  '/reliquary-list',
  arguments: {'uid': '123456789'},
);
```

## データフロー

1. HomeScreenから`uid`を受け取る
2. ローカルJSONまたはAPIからユーザーデータを読み込み
3. `ReliquaryAnalysisService`でデータを解析
4. `ReliquarySummaryView`で各聖遺物を表示

## UI設計

UI設計詳細は `/docs/requirements/ui_design.md` の「4.2 聖遺物一覧画面」を参照してください。
