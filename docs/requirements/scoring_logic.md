# スコアリングロジック詳細仕様

このドキュメントでは、聖遺物のスコアリングシステムの詳細な計算ロジックを定義します。

---

## 📖 目次

1. [基本概念](#基本概念)
2. [スコア計算式](#スコア計算式)
3. [ステータス別の重み付け](#ステータス別の重み付け)
4. [ユーザー選択可能なステータス](#ユーザー選択可能なステータス)
5. [スコアの評価基準](#スコアの評価基準)
6. [実装例](#実装例)
7. [将来の拡張](#将来の拡張)

---

## 1. 基本概念

### スコアリングの目的
聖遺物のサブオプション値を統一的な指標で評価し、ユーザーが聖遺物の価値を客観的に判断できるようにします。

### 基本方針
- **ユーザー選択型**: ユーザーが評価したいステータスを自由に選択
- **透明性**: 計算式を明示し、どのように計算されたか理解できる
- **拡張性**: 将来的にキャラクター別、ビルド別のスコアリングに対応可能

---

## 2. スコア計算式

### 基本計算式

聖遺物のスコアは、選択されたサブステータスの重み付き合計として計算されます。

```
Total Score = Σ (Stat Value × Weight)
```

各ステータスについて：
```
Score_stat = Value_stat × Weight_stat
```

### 計算例

**聖遺物のサブオプション:**
- 会心率: 7.8%
- 会心ダメージ: 20.2%
- 攻撃力%: 9.9%
- 防御力%: 6.5%

**ユーザーの選択:**
- 会心率 ✓
- 会心ダメージ ✓
- 攻撃力% ✓

**計算:**
```
会心率スコア      = 7.8 × 2    = 15.6
会心ダメージスコア = 20.2 × 1   = 20.2
攻撃力%スコア     = 9.9 × 1    = 9.9
防御力%スコア     = 6.5 × 0    = 0 (選択されていない)
─────────────────────────────────
Total Score                    = 45.7
```

---

## 3. ステータス別の重み付け

### デフォルト重み（Ver 1.0）

| ステータス | 重み | 理由 |
|-----------|------|------|
| 会心率 | **2.0** | 会心ダメージの2倍の価値（1% = 2%会心ダメージ相当） |
| 会心ダメージ | **1.0** | 基準値 |
| 攻撃力% | **1.0** | 会心ダメージと同等の価値 |
| 防御力% | **1.0** | 防御特化ビルド向け |
| HP% | **1.0** | HP特化ビルド向け |
| 元素熟知 | **0.25** | 4ポイント = 1スコア相当 |
| 元素チャージ効率 | **1.0** | 効率特化ビルド向け |

### 重み付けの根拠

#### 会心率 × 2 の理由
Genshin Impactでは、会心率と会心ダメージの価値比は一般的に 1:2 とされています。
- 会心率 1% ≈ 会心ダメージ 2%
- スコア計算を統一するため、会心率には2倍の重みを付与

#### 元素熟知 ÷ 4 の理由
元素熟知は他のステータスより値が大きいため、正規化が必要です。
- 一般的に、元素熟知4ポイント ≈ 会心ダメージ1%の価値
- スコア計算では 0.25 の重みを適用

---

## 4. ユーザー選択可能なステータス

### ステータス選択UI

ユーザーは以下のステータスから、スコア計算に含めたいものを選択できます。

```
☑ 会心率
☑ 会心ダメージ
☑ 攻撃力%
☐ 防御力%
☐ HP%
☐ 元素熟知
☐ 元素チャージ効率
```

### 選択の保存
- ユーザーの選択は LocalStorage に保存
- 次回訪問時に前回の設定を復元
- ビルドごとのプリセット機能（将来拡張）

---

## 5. スコアの評価基準

### スコアランク（部位別基準）

計算されたスコアを以下の基準でランク付けします。

#### 基本基準（花・羽）

| ランク | スコア範囲 | 色 | HEX | 説明 |
|--------|-----------|-----|-----|------|
| **SS** | 50.0+ | ⚪ 銀色 | `#C0C0C0` | 超優秀 - プラチナ級の最高品質聖遺物 |
| **S** | 45.0 - 49.9 | 🟨 金色 | `#FFD700` | 優秀 - ☆5相当の非常に良い聖遺物 |
| **A** | 40.0 - 44.9 | 🟪 紫色 | `#A256E1` | 良好 - ☆4相当の使える聖遺物 |
| **B** | 30.0 - 39.9 | 🟦 青色 | `#4A90E2` | 普通 - ☆3相当のまあまあの聖遺物 |
| **C** | 0 - 29.9 | 🟩 緑色 | `#73C990` | 平凡 - ☆2相当、再構築推奨 |

#### 杯・時計（砂）の基準（-5.0寛容）

| ランク | スコア範囲 | 色 | HEX | 説明 |
|--------|-----------|-----|-----|------|
| **SS** | 45.0+ | ⚪ 銀色 | `#C0C0C0` | 超優秀 |
| **S** | 40.0 - 44.9 | 🟨 金色 | `#FFD700` | 優秀 |
| **A** | 35.0 - 39.9 | 🟪 紫色 | `#A256E1` | 良好 |
| **B** | 25.0 - 34.9 | 🟦 青色 | `#4A90E2` | 普通 |
| **C** | 0 - 24.9 | 🟩 緑色 | `#73C990` | 平凡 |

#### 冠の基準（-10.0寛容）

| ランク | スコア範囲 | 色 | HEX | 説明 |
|--------|-----------|-----|-----|------|
| **SS** | 40.0+ | ⚪ 銀色 | `#C0C0C0` | 超優秀 |
| **S** | 35.0 - 39.9 | 🟨 金色 | `#FFD700` | 優秀 |
| **A** | 30.0 - 34.9 | 🟪 紫色 | `#A256E1` | 良好 |
| **B** | 20.0 - 29.9 | 🟦 青色 | `#4A90E2` | 普通 |
| **C** | 0 - 19.9 | 🟩 緑色 | `#73C990` | 平凡 |

### 部位別基準の根拠

- **花(EQUIP_BRACER)・羽(EQUIP_NECKLACE)**: メインステータスが固定(HP/攻撃力)なので、サブオプションの質が最も重要
- **杯(EQUIP_RING)**: 必要な元素ダメージバフ/物理ダメージバフが出にくく、メインステータスの厳選が困難なため、-5.0寛容に評価
- **時計(EQUIP_SHOES)**: 攻撃力%/元素熟知/元素チャージ効率など選択肢が多く、メインステータスの自由度が高いため、-5.0寛容に評価
- **冠(EQUIP_DRESS)**: 会心率/会心ダメージの出現率が低く、メインステータスが最も重要な部位のため、-10.0寛容に評価

---

## 6. 実装例

### データモデル

```dart
/// スコアリング設定
class ScoringSettings {
  final bool critRate;           // 会心率を含める
  final bool critDamage;          // 会心ダメージを含める
  final bool atkPercent;          // 攻撃力%を含める
  final bool defPercent;          // 防御力%を含める
  final bool hpPercent;           // HP%を含める
  final bool elementalMastery;    // 元素熟知を含める
  final bool energyRecharge;      // 元素チャージ効率を含める

  const ScoringSettings({
    this.critRate = true,
    this.critDamage = true,
    this.atkPercent = true,
    this.defPercent = false,
    this.hpPercent = false,
    this.elementalMastery = false,
    this.energyRecharge = false,
  });
}

/// スコア計算結果
class ReliquaryScore {
  final double totalScore;        // 総合スコア
  final Map<String, double> breakdown; // ステータス別内訳
  final ScoreRank rank;           // ランク (SS/S/A/B/C)
  final double maxPossibleScore;  // 理論値スコア

  const ReliquaryScore({
    required this.totalScore,
    required this.breakdown,
    required this.rank,
    required this.maxPossibleScore,
  });
}

enum ScoreRank { ss, s, a, b, c }
```

### スコア計算サービス

```dart
/// 聖遺物スコア計算サービス
class ReliquaryScoringService {
  /// ステータス別の重み
  static const Map<String, double> _weights = {
    'FIGHT_PROP_CRITICAL': 2.0,        // 会心率
    'FIGHT_PROP_CRITICAL_HURT': 1.0,   // 会心ダメージ
    'FIGHT_PROP_ATTACK_PERCENT': 1.0,  // 攻撃力%
    'FIGHT_PROP_DEFENSE_PERCENT': 1.0, // 防御力%
    'FIGHT_PROP_HP_PERCENT': 1.0,      // HP%
    'FIGHT_PROP_ELEMENT_MASTERY': 0.25,// 元素熟知
    'FIGHT_PROP_CHARGE_EFFICIENCY': 1.0,// 元素チャージ効率
  };

  /// スコアを計算する
  ReliquaryScore calculateScore(
    ReliquarySummary reliquary,
    ScoringSettings settings,
  ) {
    double totalScore = 0.0;
    final breakdown = <String, double>{};

    for (final substat in reliquary.substats) {
      // ユーザーが選択していないステータスはスキップ
      if (!_isStatSelected(substat.appendPropId, settings)) {
        continue;
      }

      // 重みを取得
      final weight = _weights[substat.appendPropId] ?? 0.0;
      
      // スコアを計算
      final score = substat.statValue * weight;
      
      totalScore += score;
      breakdown[substat.displayName] = score;
    }

    // ランクを判定（部位別基準）
    final rank = _determineRank(totalScore, reliquary.equipType);

    // 理論値を計算
    final maxScore = _calculateMaxPossibleScore(reliquary, settings);

    return ReliquaryScore(
      totalScore: totalScore,
      breakdown: breakdown,
      rank: rank,
      maxPossibleScore: maxScore,
    );
  }

  /// ステータスが選択されているか判定
  bool _isStatSelected(String propId, ScoringSettings settings) {
    switch (propId) {
      case 'FIGHT_PROP_CRITICAL':
        return settings.critRate;
      case 'FIGHT_PROP_CRITICAL_HURT':
        return settings.critDamage;
      case 'FIGHT_PROP_ATTACK_PERCENT':
        return settings.atkPercent;
      case 'FIGHT_PROP_DEFENSE_PERCENT':
        return settings.defPercent;
      case 'FIGHT_PROP_HP_PERCENT':
        return settings.hpPercent;
      case 'FIGHT_PROP_ELEMENT_MASTERY':
        return settings.elementalMastery;
      case 'FIGHT_PROP_CHARGE_EFFICIENCY':
        return settings.energyRecharge;
      default:
        return false;
    }
  }

  /// ランクを判定（部位別基準）
  ScoreRank _determineRank(double score, String equipType) {
    // 部位に応じて基準値を調整
    double ssThreshold, sThreshold, aThreshold, bThreshold;
    
    switch (equipType) {
      case 'EQUIP_RING': // 杯: -5.0寛容
      case 'EQUIP_SHOES': // 時計（砂）: -5.0寛容
        ssThreshold = 45.0;
        sThreshold = 40.0;
        aThreshold = 35.0;
        bThreshold = 25.0;
        break;
      case 'EQUIP_DRESS': // 冠: -10.0寛容
        ssThreshold = 40.0;
        sThreshold = 35.0;
        aThreshold = 30.0;
        bThreshold = 20.0;
        break;
      case 'EQUIP_BRACER': // 花
      case 'EQUIP_NECKLACE': // 羽
      default: // 基本基準
        ssThreshold = 50.0;
        sThreshold = 45.0;
        aThreshold = 40.0;
        bThreshold = 30.0;
        break;
    }
    
    if (score >= ssThreshold) return ScoreRank.ss;
    if (score >= sThreshold) return ScoreRank.s;
    if (score >= aThreshold) return ScoreRank.a;
    if (score >= bThreshold) return ScoreRank.b;
    return ScoreRank.c;
  }

  /// 理論値スコアを計算
  double _calculateMaxPossibleScore(
    ReliquarySummary reliquary,
    ScoringSettings settings,
  ) {
    // 現在のレベルから残り強化回数を計算
    final remainingUpgrades = (20 - (reliquary.level ?? 0)) ~/ 4;
    
    // 選択されたステータスの最大強化値を取得
    final maxUpgradeValue = _getMaxUpgradeValue(settings);
    
    // 理論値 = 現在スコア + (最大強化値 × 残り回数)
    final currentScore = calculateScore(reliquary, settings).totalScore;
    return currentScore + (maxUpgradeValue * remainingUpgrades);
  }

  /// 選択されたステータスの最大強化値を取得
  double _getMaxUpgradeValue(ScoringSettings settings) {
    // 選択中の中で最も価値の高いステータスの最大値を返す
    // 例: 会心ダメージの最大値 7.8% × 重み 1.0 = 7.8
    double maxValue = 0.0;
    
    if (settings.critRate) {
      maxValue = max(maxValue, 3.9 * 2.0); // 会心率最大 3.9% × 重み2
    }
    if (settings.critDamage) {
      maxValue = max(maxValue, 7.8 * 1.0); // 会心ダメージ最大 7.8%
    }
    // ... 他のステータス
    
    return maxValue;
  }
}
```

### 使用例

```dart
void main() {
  final scoringService = ReliquaryScoringService();
  
  // スコアリング設定（会心特化）
  const settings = ScoringSettings(
    critRate: true,
    critDamage: true,
    atkPercent: true,
  );
  
  // スコア計算
  final score = scoringService.calculateScore(reliquary, settings);
  
  print('総合スコア: ${score.totalScore}');
  print('ランク: ${score.rank}');
  print('理論値: ${score.maxPossibleScore}');
  print('達成率: ${(score.totalScore / score.maxPossibleScore * 100).toStringAsFixed(1)}%');
  
  // 内訳表示
  score.breakdown.forEach((stat, value) {
    print('$stat: $value');
  });
}
```

---

## 7. 将来の拡張

### Phase 2以降の拡張予定

#### 7.1 キャラクター別評価オプション種別の定義
キャラクターごとに評価すべきステータスの組み合わせをプリセットとして定義：

```dart
class CharacterStatPreset {
  final String characterId;
  final String characterName;
  final Set<String> evaluatedStats; // 評価対象のステータス（ON/OFF）
  final String description;
}

// 例: 胡桃（HP特化）
final hutaoPreset = CharacterStatPreset(
  characterId: 'hutao',
  characterName: '胡桃',
  evaluatedStats: {
    'FIGHT_PROP_HP_PERCENT',        // HP%
    'FIGHT_PROP_CRITICAL',          // 会心率
    'FIGHT_PROP_CRITICAL_HURT',     // 会心ダメージ
    'FIGHT_PROP_ELEMENT_MASTERY',   // 元素熟知
  },
  description: 'HP依存アタッカー向けビルド',
);

// 例: 雷電将軍（元素チャージ特化）
final raidenPreset = CharacterStatPreset(
  characterId: 'raiden',
  characterName: '雷電将軍',
  evaluatedStats: {
    'FIGHT_PROP_CHARGE_EFFICIENCY',  // 元素チャージ効率
    'FIGHT_PROP_CRITICAL',           // 会心率
    'FIGHT_PROP_CRITICAL_HURT',      // 会心ダメージ
    'FIGHT_PROP_ATTACK_PERCENT',     // 攻撃力%
  },
  description: 'チャージ効率重視サポーター/アタッカービルド',
);
```

**特徴:**
- 重み付けは変更せず、評価対象のON/OFF（0か1）のみを定義
- ユーザーはプリセットを選択するだけで適切なスコアリング設定が適用される
- Phase 1では、システム側でプリセットを用意せず、ユーザー自身がステータスを選択

**実装方針:**
- Phase 1: ユーザーが手動でステータスを選択
- Phase 2: 一般的なキャラクタープリセットを数種類用意
- Phase 3: 全キャラクターのプリセットを網羅

#### 7.2 ビルド別プリセット
一般的なビルドパターンをプリセットとして提供：

```dart
enum BuildPreset {
  critBuild,      // 会心特化
  attackBuild,    // 攻撃特化
  reactionBuild,  // 元素反応特化
  defenseBuild,   // 防御特化
  hpBuild,        // HP特化
  chargeBuild,    // チャージ効率特化
}

class BuildPresetConfig {
  final BuildPreset type;
  final String displayName;
  final Set<String> evaluatedStats;
  final String description;
}

// 例: 会心特化ビルド
final critBuildConfig = BuildPresetConfig(
  type: BuildPreset.critBuild,
  displayName: '会心特化',
  evaluatedStats: {
    'FIGHT_PROP_CRITICAL',      // 会心率
    'FIGHT_PROP_CRITICAL_HURT', // 会心ダメージ
  },
  description: '会心率・会心ダメージのみを評価（最もシンプルな基準）',
);

// 例: 元素反応特化ビルド
final reactionBuildConfig = BuildPresetConfig(
  type: BuildPreset.reactionBuild,
  displayName: '元素反応特化',
  evaluatedStats: {
    'FIGHT_PROP_ELEMENT_MASTERY',    // 元素熟知
    'FIGHT_PROP_CHARGE_EFFICIENCY',  // 元素チャージ効率
  },
  description: '元素反応ダメージを重視するビルド',
);
```

**提供予定のプリセット:**
- **会心特化**: 会心率 + 会心ダメージ（汎用アタッカー）
- **攻撃特化**: 会心率 + 会心ダメージ + 攻撃力%（物理/元素アタッカー）
- **元素反応特化**: 元素熟知 + チャージ効率（反応トリガー役）
- **防御特化**: 会心率 + 会心ダメージ + 防御力%（一部キャラ）
- **HP特化**: 会心率 + 会心ダメージ + HP%（一部キャラ）
- **チャージ効率特化**: チャージ効率 + 会心系（サポーター）

#### 7.3 カスタムプリセットの保存
ユーザーが独自に作成したスコアリング設定を保存・管理：

```dart
class CustomPreset {
  final String id;
  final String name;
  final Set<String> evaluatedStats;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
}

// ユーザーが作成したプリセット例
final myCustomPreset = CustomPreset(
  id: 'custom_001',
  name: '私の胡桃ビルド',
  evaluatedStats: {
    'FIGHT_PROP_HP_PERCENT',
    'FIGHT_PROP_CRITICAL',
    'FIGHT_PROP_CRITICAL_HURT',
    'FIGHT_PROP_ELEMENT_MASTERY',
  },
  createdAt: DateTime.now(),
);
```

**機能:**
- プリセットの作成・編集・削除
- プリセットの名前変更
- よく使うプリセットをお気に入り登録
- 最近使用したプリセット履歴

#### 7.4 相対スコア（コミュニティ比較）
全ユーザーのデータと比較した相対的な評価：

```dart
class CommunityScoreData {
  final String slotType;          // 部位
  final double averageScore;      // コミュニティ平均スコア
  final double medianScore;       // 中央値
  final List<double> percentiles; // パーセンタイル（10%, 25%, 50%, 75%, 90%）
}

class RelativeScore {
  final double absoluteScore;     // 絶対スコア
  final double percentile;        // パーセンタイル（上位XX%）
  final int rank;                 // 順位
  final String evaluation;        // 評価（「上位10%」など）
}
```

**表示例:**
```
あなたのスコア: 45.7
コミュニティ平均: 32.4
パーセンタイル: 上位 8.3%
評価: SSランク（同一部位内で非常に優秀）
```

**実装上の注意:**
- プライバシーに配慮したデータ収集（オプトイン）
- 十分なサンプル数が集まるまでは表示しない
- ビルドタイプ別の比較も検討

---

## 📝 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-10-12 | 初版作成、基本計算式とデータモデル定義 |
| 2025-10-12 | 将来拡張の見直し：キャラ別評価は重み変更ではなくON/OFFのみ |
| 2025-10-12 | ビルド別プリセットの詳細化、カスタムプリセット機能追加 |
| 2025-10-12 | スコアランクをSS～Cの5段階に変更、部位別基準を実装（花羽50/45/40/30、杯/砂45/40/35/25、冠40/35/30/20） |
| 2025-10-12 | ランクカラーを原神レアリティに準拠し、既存システムに合わせてSS銀/S金に変更（SSプラチナ/S金/A紫/B青/C緑） |
| 2025-10-13 | 杯を砂と同じ-5.0寛容グループへ移動（花羽50/45/40/30、杯/砂45/40/35/25、冠40/35/30/20） |
