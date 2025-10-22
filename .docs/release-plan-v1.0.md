# Ver1.0 リリース計画

**目標リリース日**: 2025年10月末  
**現在のステータス**: GitHub Pages公開済み（v0.1.0）

---

## 📋 概要

Genshin Impact聖遺物診断ツールの初回正式版リリース。  
バグ修正、主要機能追加、UI/UX改善を実施し、安定版として公開する。

---

## 🎯 リリース目標

- **安定性**: バグ修正により正確なデータ表示を実現
- **ユーザビリティ**: スマホ対応、ダークモード、オフライン対応
- **機能性**: サブステータス詳細表示、再構築提案機能
- **完成度**: アイコン・タイトル設定、背景デザイン実装

---

## 📝 タスクリスト

### Phase 1: バグ修正・緊急対応 🔴

#### 1. UIDバリデーションを9桁→10桁に拡張
- **優先度**: 最高
- **理由**: ユーザー数増加により10桁UIDが存在
- **影響範囲**: `lib/src/screens/home_screen/lib/home_screen.dart`
- **作業内容**:
  - `_validateUid`メソッドの正規表現を`^\d{9,10}$`に変更
  - エラーメッセージを「UIDは9～10桁の数字です」に更新
  - `maxLength`を10に変更
- **テスト**: 9桁・10桁両方のUIDで動作確認

#### 2. 詳細画面のスマホ表示時のボタンはみ出し修正（Phase 4へ移動）
- 本タスクはPhase 4（UI/UX改善）へ移動し、優先度を「低」に変更しました。

#### 3. 初期3の+16など中途半端な値の表示精度修正
- **優先度**: 高
- **理由**: データ正確性の担保
- **影響範囲**: `lib/src/components/reliquary_summary_view.dart`
- **作業内容**:
  - 初期値・強化回数計算ロジックの検証
  - `StatAppendResolver`の値を正しく使用しているか確認
  - 小数点以下の表示フォーマットを修正（必要に応じて）
  - 丸め誤差の修正
- **テスト**: 初期値3、4での各強化レベルの表示確認

---

### Phase 2: 主要機能追加 🟡

#### 4. サブステータス追加回数の表示機能追加
- **優先度**: 中
- **理由**: ユーザー要望の高い機能
- **影響範囲**: 
  - `lib/src/models/domain/substat_summary.dart`
  - `lib/src/services/reliquary_analysis_service.dart`
  - `lib/src/components/reliquary_card_view.dart`
  - `lib/src/components/substat_detail_view.dart`
- **作業内容**:
  - `SubstatSummary`に`upgradeCount`プロパティを追加
  - `ReliquaryAnalysisService`で追加回数計算ロジックを実装
  - カードビューと詳細ビューに回数バッジを表示（例: `×3`）
- **テスト**: 各強化レベルでの追加回数表示確認

#### 5. 通常加算表示の追加
- **優先度**: 中
- **理由**: 強化履歴の可視化
- **影響範囲**:
  - `lib/src/models/domain/mutable_substat.dart`
  - `lib/src/services/reliquary_analysis_service.dart`
  - `lib/src/components/substat_detail_view.dart`
- **作業内容**:
  - `MutableSubstat`に`upgradeHistory`プロパティを追加（例: `[5.8, 5.3, 4.8, 5.3]`）
  - 強化履歴を逆算して計算するアルゴリズムを実装
  - UIに`(5.8 + 5.3 + 4.8 + 5.3)`形式で表示
  - 各値の評価（高/中/低）を色分け表示
- **テスト**: 各レア度での加算値パターン確認

#### 6. 再構築更新率の表示実装
- **優先度**: 中
- **理由**: 最適化支援の重要機能
- **影響範囲**:
  - `lib/src/services/reliquary_analysis_service.dart`
  - `lib/src/components/reliquary_card_view.dart`
  - `lib/src/screens/reliquary_detail_screen/lib/reliquary_detail_screen.dart`
- **作業内容**:
  - 現在値と理想値（最大値×強化回数）の比較計算
  - 更新率パーセンテージの算出
  - 「再構築推奨度」セクションの追加
  - 推奨度に応じた色分け表示（緑/黄/赤）
- **テスト**: 様々な聖遺物での推奨度計算確認

---

### Phase 3: データ永続化 🟡

#### 7. 所持データの随時保存実装（LocalStorage）
- **優先度**: 中
- **理由**: オフライン対応・UX向上
- **影響範囲**:
  - `pubspec.yaml`（shared_preferences追加）
  - `lib/src/services/user_data_service.dart`
- **作業内容**:
  - `shared_preferences: ^2.2.0`をpubspec.yamlに追加
  - `UserDataService`にキャッシュ保存・読み込み機能を実装
  - TTL（Time To Live）の実装（24時間など）
  - キャッシュ有効時はAPI呼び出しをスキップ
  - 「最終更新日時」の表示
  - 「データ更新」ボタンの追加
- **テスト**: 
  - オフライン時のデータ表示確認
  - TTL経過後の自動更新確認
  - 複数UIDの切り替え確認

---

### Phase 4: UI/UX改善 🟢

#### 8. サイトアイコン（favicon）の設定
- **優先度**: 低
- **理由**: ブランディング
- **影響範囲**:
  - `web/icons/`
  - `web/index.html`
  - `web/manifest.json`
- **作業内容**:
  - Genshin Impact風のアイコンデザイン作成
    - 聖遺物のシルエット
    - 診断器のモチーフ
    - ブランドカラー（青・金）
  - 各サイズの画像生成（16x16, 32x32, 192x192, 512x512）
  - web/icons/に配置
  - manifest.jsonとindex.htmlを更新
- **テスト**: 各デバイス・ブラウザでのアイコン表示確認

#### 9. サイトタイトルの更新
- **優先度**: 低
- **理由**: SEO・ブランディング
- **影響範囲**:
  - `web/index.html`
  - `web/manifest.json`
- **作業内容**:
  - `<title>`を「聖遺物診断器 - Artifact Diagnoser」に変更
  - manifest.jsonの`name`を「聖遺物診断器」に変更
  - manifest.jsonの`short_name`を「聖遺物診断」に変更
  - OGPタグの追加（description, image）
- **テスト**: Twitter/Discord等でのリンクプレビュー確認

#### 10. UID入力ページの背景デザイン追加
- **優先度**: 低
- **理由**: UI改善・世界観表現
- **影響範囲**:
  - `lib/src/screens/home_screen/lib/home_screen.dart`
  - `assets/images/`（新規）
- **作業内容**:
  - Genshin Impact風の背景画像作成
    - テイワットの風景
    - 聖遺物のパターン
    - グラデーション（青→紫→金）
  - assets/images/background.webpを配置
  - pubspec.yamlのassetsに追加
  - ScaffoldにBoxDecorationで背景設定
  - 半透明オーバーレイで可読性確保
- **テスト**: 各デバイスでの表示確認、読みやすさ確認

#### 11. 設定画面の実装（ダークモード対応）
- **優先度**: 低
- **理由**: ユーザビリティ向上
- **影響範囲**:
  - `lib/src/screens/settings_screen/`（新規作成）
  - `lib/main.dart`
  - `pubspec.yaml`（shared_preferences）
- **作業内容**:
  - `settings_screen`パッケージの作成
  - ThemeMode切り替え機能の実装（Light/Dark/System）
  - `main.dart`にThemeData定義
    - ライトテーマ: 白ベース、青アクセント
    - ダークテーマ: 黒ベース、金アクセント
  - shared_preferencesで設定永続化
  - AppBarの設定アイコンから遷移
  - その他設定項目の検討
    - 言語設定（日本語/英語）
    - スコア計算対象のデフォルト値
    - キャッシュクリア機能
- **テスト**: テーマ切り替え動作確認、設定永続化確認

#### 12. 詳細画面のスマホ表示時のボタンはみ出し修正（移動）
- **優先度**: 低
- **理由**: 現状はスクロールで操作可能なため致命的ではないが、視認性改善のため
- **影響範囲**: `lib/src/screens/reliquary_detail_screen/lib/reliquary_detail_screen.dart`
- **対応方針（案2）**: 画面幅に応じたレイアウト切替
  - `MediaQuery`で画面幅を取得し、閾値（例: 420px）以下では`Wrap`で2行表示へ切替
    - 1行目: +0 / +4 / +8
    - 2行目: +12 / +16 / +20
  - 閾値より広い場合は従来どおり1行`Row`表示
  - 余白・マージンを調整してアイコンやテキストと干渉しないようにする
- **テスト**: iPhone 15 Pro Max / iPhone SE / Pixel 5 / iPadの各幅で表示確認

---

### Phase 5: リリース準備 📦

#### 13. バージョン番号を1.0.0に更新
- **優先度**: リリース直前
- **影響範囲**:
  - `pubspec.yaml`
  - `CHANGELOG.md`（新規作成）
  - `README.md`
- **作業内容**:
  - pubspec.yamlのversionを1.0.0に変更
  - CHANGELOG.mdの作成
    ```markdown
    # Changelog
    
    ## [1.0.0] - 2025-10-XX
    
    ### Added
    - 10桁UID対応
    - サブステータス追加回数表示
    - 通常加算表示（強化履歴）
    - 再構築更新率表示
    - データ永続化（オフライン対応）
    - ダークモード対応
    - サイトアイコン・タイトル設定
    - UID入力ページ背景デザイン
    
    ### Fixed
    - スマホ表示時のボタンはみ出し
    - 初期値3の計算精度問題
    - CORSエラー対応（CORSプロキシ導入）
    
    ### Changed
    - パッケージ名を genshin_artifact_diagnoser に変更
    
    ## [0.1.0] - 2025-10-21
    
    ### Added
    - 初回リリース
    - Enka Network API連携
    - 聖遺物一覧表示
    - 聖遺物詳細表示
    - スコア計算機能
    ```
  - README.mdの更新（機能一覧、スクリーンショット追加）

#### 14. 最終テストとビルド
- **優先度**: 最終
- **チェックリスト**:
  - [ ] 全機能の動作確認
    - [ ] UID入力（9桁・10桁）
    - [ ] データ取得（API・ローカル・キャッシュ）
    - [ ] 聖遺物一覧表示
    - [ ] 聖遺物詳細表示
    - [ ] スコア計算
    - [ ] 設定画面（テーマ切り替え）
  - [ ] レスポンシブ表示確認
    - [ ] iPhone SE (375px)
    - [ ] iPhone 12 Pro (390px)
    - [ ] iPad (768px)
    - [ ] デスクトップ (1920px)
  - [ ] ブラウザ互換性確認
    - [ ] Chrome
    - [ ] Safari
    - [ ] Firefox
    - [ ] Edge
  - [ ] パフォーマンス確認
    - [ ] 初回ロード時間
    - [ ] API レスポンス時間
    - [ ] 画面遷移の滑らかさ
  - [ ] エラーハンドリング確認
    - [ ] 存在しないUID
    - [ ] ネットワークエラー
    - [ ] タイムアウト
- **ビルド手順**:
  ```bash
  # 1. クリーンビルド
  flutter clean
  
  # 2. 依存関係更新
  flutter pub get
  
  # 3. リリースビルド
  flutter build web --release
  
  # 4. docsフォルダクリア
  rm -rf docs/*
  
  # 5. ビルド成果物をコピー
  cp -r build/web/* docs/
  
  # 6. Git コミット
  git add .
  git commit -m "Release v1.0.0"
  git tag v1.0.0
  git push origin main --tags
  ```

---

## 🚀 リリース後の対応

### 監視項目
- GitHub Pagesのアクセスログ
- ユーザーからのフィードバック
- エラーレポート

### 次期バージョンの検討事項
- 聖遺物セット効果の表示
- キャラクター別の推奨聖遺物表示
- 複数UIDの管理機能
- データエクスポート機能
- 多言語対応（英語、中国語）

---

## 📊 進捗管理

| Phase | タスク数 | 完了 | 進捗率 |
|-------|---------|------|--------|
| Phase 1 | 2 | 0 | 0% |
| Phase 2 | 3 | 0 | 0% |
| Phase 3 | 1 | 0 | 0% |
| Phase 4 | 5 | 0 | 0% |
| Phase 5 | 2 | 0 | 0% |
| **合計** | **13** | **0** | **0%** |

---

## 📝 備考

- 各タスクは独立性が高いため、並行作業可能
- Phase 1（バグ修正）を最優先で完了させる
- Phase 4（UI/UX）は時間に応じて調整可
- リリース予定日の3日前までにPhase 5を開始

---

**最終更新**: 2025年10月22日  
**作成者**: GitHub Copilot  
**ステータス**: 計画策定完了
