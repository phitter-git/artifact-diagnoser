# サブステータス表示の修正計画

## 問題の分析

### 現在のデータ構造
```
appendPropIdList: [501054, 501202, 501233, 501224, 501202, 501204, 501223, 501203, 501224]
                   ↑初期4個↑           ↑+4  ↑+8  ↑+12 ↑+16 ↑+20

statValue: 13.6 (最終的な累積値)
```

### 問題点
1. `appendValueStrings`は`statAppendList`の抽選ティア番号から生成される文字列
2. 各強化段階での「増加値」を表すが、どのレベルで増加したかの情報が欠けている
3. `getValueAtLevel()`の計算ロジックが間違っている

### 正しいデータ解釈

**appendPropIdList の解釈:**
- インデックス0-3: 初期サブステータス（または0-2が初期3個）
- インデックス4-8: +4, +8, +12, +16, +20での強化

**各サブステータスの statAppendList:**
- そのサブステータスが強化された回数分の抽選ティア番号
- 例: [4, 2, 4] → 初期値ティア4、1回目強化ティア2、2回目強化ティア4

**appendValueStrings:**
- `statAppendList`の各ティアに対応する増加値の文字列
- 例: ["+3.9%", "+3.1%", "+3.9%"]

## 修正方針

### SubstatSummaryの拡張

各強化レベルでの値を正しく計算するために、以下の情報が必要:
1. 初期サブステータスかどうか
2. どのレベルで強化されたか

### 新しいアプローチ

**Option 1: ReliquaryAnalysisServiceで強化履歴を構築**
- `appendPropIdList`を解析して、各サブステータスがどのレベルで強化されたかを記録

**Option 2: SubstatSummaryに強化レベル情報を追加**
```dart
class SubstatSummary {
  final List<int> enhancementLevels; // [0, 4, 12] = +0, +4, +12で強化
  final List<String> appendValueStrings; // 対応する増加値
}
```

## 実装計画

### ステップ1: ReliquaryAnalysisServiceの修正
- `appendPropIdList`から各サブステータスの強化レベルを特定
- 初期サブステータス数を判定（3 or 4）

### ステップ2: SubstatSummaryの拡張
- `enhancementLevels`フィールドを追加
- `getValueAtLevel()`の計算ロジックを修正

### ステップ3: EnhancementLevelTabsの修正
- 初期サブステータス3個の場合、+0タブを非活性化
