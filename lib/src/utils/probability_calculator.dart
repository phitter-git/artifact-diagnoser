import 'dart:math';

/// 再構築シミュレーションの確率計算ユーティリティ
///
/// 厳密計算（分布畳み込み）により、指定された条件下で
/// スコアがしきい値を超える確率を計算します。
class ProbabilityCalculator {
  /// しきい値を超える確率を厳密計算で求める
  ///
  /// [valueSets] 各サブステータスのTier1~4の値リスト（係数適用済み）
  /// [score] しきい値（理論最大スコア - 初期値スコア）
  /// [selectCount] 総抽選回数（残り強化回数）
  /// [forcedCount] forcedTargetの最低出現回数（再構築種別による保証回数2~4回）
  /// [forcedTarget] 希望サブオプション（2個、valueSetsに含まれる）
  /// [scoredTarget] スコア計算対象サブオプション（valueSetsに含まれるもの）
  ///
  /// 返り値: 確率（0.0～1.0）
  ///
  /// アルゴリズム:
  /// 1) F=forcedTarget, S=scoredTarget, 全変数集合 U
  /// 2) 自然に F が選ばれる回数 K_F ~ Binomial(selectCount, pF=|F|/|U|)
  /// 3) 強制後の F 回数 K' = max(K_F, forcedCount)、残りは U\F から
  /// 4) K' 回の F から「S∩F に属する確率」p1 = |S∩F|/|F|
  ///    (selectCount-K') 回の U\F から「S\F に属する確率」p2 = |S\F|/|U\F|
  /// 5) S の当たり回数 X = X1 + X2（X1~Binomial(K',p1), X2~Binomial(selectCount-K',p2)）
  /// 6) 値は、X1回は「S∩F 混合PMF」、X2回は「S\F 混合PMF」からの和
  /// 7) これを K' と (X1, X2) で混合し、P(sum > score) を厳密に出す
  /// 8) 値はすべて「小数第2位で丸め → ×10 の整数」にして畳み込み
  static double calculateExceedingProbability({
    required Map<String, List<double>> valueSets,
    required double score,
    required int selectCount,
    required int forcedCount,
    required List<String> forcedTarget,
    required List<String> scoredTarget,
  }) {
    const int scale = 10; // 小数第1位保持（×10）

    final U = valueSets.keys.toList(growable: false);
    final F = List<String>.from(forcedTarget);
    final S = List<String>.from(scoredTarget);

    final setU = U.toSet();
    final setF = F.toSet();
    final setS = S.toSet();
    final setC = setU.difference(setF); // U\F
    final setSiF = setS.intersection(setF); // S∩F
    final setSmF = setS.difference(setF); // S\F

    // 値PMF（整数化）を作るヘルパ
    Map<int, double> mixPmf(Set<String> names) {
      if (names.isEmpty) return {0: 1.0}; // 使われる回数が0なら影響なし
      final w = 1.0 / names.length;
      final out = <int, double>{};
      for (final name in names) {
        final pmf = _pmfFromListInt(valueSets[name]!, scale);
        pmf.forEach((v, p) {
          out[v] = (out[v] ?? 0.0) + w * p;
        });
      }
      return out;
    }

    final pmfSiF = mixPmf(setSiF); // S∩F からの1回のPMF
    final pmfSmF = mixPmf(setSmF); // S\F からの1回のPMF

    // F が選ばれる自然回数のPMF：K_F ~ Binomial(selectCount, pF)
    final pF = setF.isEmpty ? 0.0 : setF.length / setU.length;
    final pkF = _binomialPmf(selectCount, pF);
    final pkp = _forcedKPrimePmf(
      pkF,
      forcedCount,
    ); // K' = max(K_F, forcedCount)

    // F 部分で S に当たる確率 p1、補集合側で S に当たる確率 p2
    final p1 = setF.isEmpty ? 0.0 : (setSiF.length / setF.length);
    final p2 = setC.isEmpty ? 0.0 : (setSmF.length / setC.length);

    double ans = 0.0;

    pkp.forEach((kPrime, pKp) {
      if (pKp == 0.0) return;

      final nF = kPrime; // F からの回数
      final nC = selectCount - kPrime; // U\F からの回数

      // X1 ~ Binomial(nF, p1): S∩F の回数
      // X2 ~ Binomial(nC, p2): S\F の回数
      final pmfX1 = _binomialPmf(nF, p1);
      final pmfX2 = _binomialPmf(nC, p2);

      pmfX1.forEach((x1, px1) {
        if (px1 == 0.0) return;
        // pmfSiF を x1 回畳み込み（x1==0 なら {0:1}）
        final pmfPart1 = _convolvePowerInt(pmfSiF, x1);

        pmfX2.forEach((x2, px2) {
          if (px2 == 0.0) return;

          // pmfSmF を x2 回畳み込み
          final pmfPart2 = _convolvePowerInt(pmfSmF, x2);

          // 合算（S 由来だけを足す）
          final pmfSum = _convolveInt(pmfPart1, pmfPart2);

          // 重み付けで P(sum > score) を加算
          final pEx = _probExceeds(pmfSum, score, scale);
          ans += pKp * px1 * px2 * pEx;
        });
      });
    });

    return ans;
  }

  /// 小数第2位で四捨五入し、小数第1位に揃える
  static double _round1(double x) => (x * 10).round() / 10.0;

  /// 1変数の PMF（値は小数第2位で丸め→×10整数化、重複にも対応）
  static Map<int, double> _pmfFromListInt(List<double> values, int scale) {
    final counts = <int, int>{};
    for (final v in values) {
      final vi = (_round1(v) * scale).round();
      counts[vi] = (counts[vi] ?? 0) + 1;
    }
    final total = values.length.toDouble();
    return counts.map((k, c) => MapEntry(k, c / total));
  }

  /// Z=X+Y の PMF（整数化）畳み込み
  static Map<int, double> _convolveInt(Map<int, double> a, Map<int, double> b) {
    final out = <int, double>{};
    a.forEach((x, px) {
      b.forEach((y, py) {
        out[x + y] = (out[x + y] ?? 0.0) + px * py;
      });
    });
    return out;
  }

  /// 同一 PMF を k 回畳み込み（k=0 → {0:1}）
  static Map<int, double> _convolvePowerInt(Map<int, double> pmf, int k) {
    if (k == 0) return {0: 1.0};
    var acc = Map<int, double>.from(pmf);
    for (int i = 1; i < k; i++) {
      acc = _convolveInt(acc, pmf);
    }
    return acc;
  }

  /// P(Sum > score)
  static double _probExceeds(Map<int, double> pmf, double score, int scale) {
    double p = 0.0;
    pmf.forEach((sumInt, prob) {
      // sumInt は×10の整数、score はdouble
      // sumInt/scale > score かを判定
      if (sumInt / scale > score) p += prob;
    });
    return p;
  }

  /// Binomial(n, p) の PMF（k → 確率）
  static Map<int, double> _binomialPmf(int n, double p) {
    final q = 1.0 - p;
    final out = <int, double>{};
    for (int k = 0; k <= n; k++) {
      out[k] = _nCk(n, k) * pow(p, k) * pow(q, n - k).toDouble();
    }
    return out;
  }

  /// K' = max(K, nMin) の PMF（K の pmf → K' の pmf）
  static Map<int, double> _forcedKPrimePmf(Map<int, double> pk, int nMin) {
    final out = <int, double>{};
    double massLe = 0.0;
    pk.forEach((k, p) {
      if (k <= nMin) {
        massLe += p; // K<=nMin は K'==nMin に集約
      } else {
        out[k] = (out[k] ?? 0.0) + p; // それ以外はそのまま
      }
    });
    out[nMin] = (out[nMin] ?? 0.0) + massLe;
    return out;
  }

  /// nCk（安定計算）
  static double _nCk(int n, int k) {
    if (k < 0 || k > n) return 0.0;
    k = min(k, n - k);
    double num = 1.0, den = 1.0;
    for (int i = 1; i <= k; i++) {
      num *= (n - (k - i));
      den *= i;
    }
    return num / den;
  }
}
