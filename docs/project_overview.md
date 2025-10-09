# Project Overview

## 概要
Artifact Diagnoser は Flutter で作成された Genshin Impact の聖遺物解析ツールです。

## 主要機能
- ユーザーデータ（userdata.json）の読み込み
- 聖遺物のメイン・サブステータス解析
- 強化履歴の再構築と表示
- ローカライズ対応

## アーキテクチャ
- **Remote Models**: REST API から取得するデータ型
- **Domain Models**: アプリケーション内で使用するデータ型
- **Components**: 再利用可能なUI コンポーネント
- **Features**: 機能別のUI とロジック
- **Services**: データ取得・変換等のサービス層
- **Common**: 汎用的なユーティリティ

## 主要な解析ロジック
`appendPropIdList` の値を識別子（先頭5桁）とサフィックス（末尾1桁）に分割し、
聖遺物の強化履歴を再構築します。