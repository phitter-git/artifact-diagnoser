# Artifact Diagnoser（聖遺物診断機）

Genshin Impact の聖遺物を詳細に分析し、最適化をサポートする Flutter アプリケーション。

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎯 プロジェクト概要

**Artifact Diagnoser** は、Genshin Impact プレイヤー向けの聖遺物分析ツールです。ユーザーの UID から聖遺物データを取得し、以下の機能を提供します：

- 📊 **スコアリング**: ユーザー選択可能なステータスに基づく聖遺物の評価
- 🔍 **詳細分析**: サブオプションの強化履歴と初期値の可視化
- 🎲 **再構築シミュレーション**: 再構築時の更新確率計算
- 🏆 **ランク付け**: 部位別の聖遺物ランキング
- 💾 **データ保存**: ローカルストレージによるデータ永続化

---

## 📚 ドキュメント

### 📖 プロジェクト管理
- **[ROADMAP.md](./docs/ROADMAP.md)** - 開発ロードマップとマイルストーン
- **[プロジェクト概要](./docs/project_overview.md)** - プロジェクトの背景と目的
- **[ディレクトリ構造](./docs/directory_structure.md)** - コードベースの構成

### 📋 要件定義
- **[機能詳細仕様](./docs/requirements/features.md)** - 各機能の詳細要件
- **[スコアリングロジック](./docs/requirements/scoring_logic.md)** - スコア計算の詳細仕様
- **[UI設計方針](./docs/requirements/ui_design.md)** - UI/UX とコンポーネント設計
- **[技術仕様](./docs/requirements/technical_specs.md)** - アーキテクチャとAPI仕様

---

## 🚀 クイックスタート

### 前提条件

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.9.2 以上
- [Dart SDK](https://dart.dev/get-dart) 3.0 以上
- [Melos](https://melos.invertase.dev/) (モノレポ管理)

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/phitter-git/artifact-diagnoser.git
cd artifact-diagnoser

# Melos のインストール
dart pub global activate melos

# 依存関係のインストール
melos bootstrap

# または
flutter pub get
```

### 実行

```bash
# Web で実行
flutter run -d chrome

# または Melos スクリプトで実行
melos run get
```

---

## 🏗️ プロジェクト構造

```
artifact_diagnoser/
├── lib/
│   ├── main.dart                 # エントリーポイント
│   └── src/
│       ├── models/               # データモデル
│       │   ├── remote/           # API通信用モデル（1クラス1ファイル）
│       │   ├── domain/           # アプリ内部モデル（1クラス1ファイル）
│       │   ├── remote.dart       # remoteモデルのエクスポート
│       │   └── domain.dart       # domainモデルのエクスポート
│       ├── services/             # ビジネスロジック
│       ├── utils/                # ユーティリティ関数
│       ├── components/           # 再利用可能なUIコンポーネント
│       ├── screens/              # 画面実装（独立パッケージ）
│       └── i18n/                 # 多言語対応
├── docs/                         # ドキュメント
│   ├── ROADMAP.md
│   └── requirements/
├── assets/                       # 静的リソース
└── melos.yaml                    # モノレポ設定
```

詳細は [ディレクトリ構造](./docs/directory_structure.md) を参照してください。

---

## 🎯 開発ロードマップ

### Phase 1: コア機能（必須）- ✅ 完了

- [x] UIDから聖遺物情報の読み込み
- [x] サブオプション詳細情報分析
- [x] 聖遺物の初期値表示
- [x] 聖遺物のスコアリング（基本版）

### Phase 2: 分析機能（重要）- 進行中

- [x] 部位別ランク付け
- [ ] 聖遺物の理論値計算
- [ ] 再構築更新率の計算

### Phase 3: 高度な機能（拡張）

- [ ] 再構築推奨機能
- [ ] データ保存機能

詳細は [ROADMAP.md](./docs/ROADMAP.md) を参照してください。

---

## 🛠️ 技術スタック

- **フレームワーク**: Flutter 3.9.2+
- **言語**: Dart
- **パッケージ管理**: Melos
- **アーキテクチャ**: レイヤードアーキテクチャ（UI / Business Logic / Data）
- **プラットフォーム**: Web（将来的に Android/iOS 対応）

詳細は [技術仕様](./docs/requirements/technical_specs.md) を参照してください。

---

## 🤝 コントリビューション

コントリビューションは大歓迎です！以下の手順でお願いします：

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

### コーディング規約

- [copilot-instructions.md](./.github/copilot-instructions.md) に従ってください
- Linter ルールを遵守してください
- コメントは日本語で記述してください
- 1クラス1ファイルの原則を守ってください

---

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) を参照してください。

---

## 🙏 謝辞

- [Enka Network](https://enka.network/) - Genshin Impact データ API
- [Flutter](https://flutter.dev/) - クロスプラットフォームフレームワーク
- Genshin Impact コミュニティの皆様

---

## 📞 お問い合わせ

- **GitHub Issues**: [Issues ページ](https://github.com/phitter-git/artifact-diagnoser/issues)
- **プロジェクトリンク**: [https://github.com/phitter-git/artifact-diagnoser](https://github.com/phitter-git/artifact-diagnoser)

---

**Made with ❤️ for Genshin Impact players**

