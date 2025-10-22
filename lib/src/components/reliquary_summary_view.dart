import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain/reliquary_summary.dart';
import 'package:artifact_diagnoser/src/utils/format_utils.dart';
import 'package:artifact_diagnoser/src/components/enhancement_level_tabs.dart';
import 'package:artifact_diagnoser/src/components/substat_detail_view.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// 聖遺物の解析結果を表示するコンポーネント
class ReliquarySummaryView extends StatefulWidget {
  const ReliquarySummaryView({
    super.key,
    required this.summary,
    required this.statAppendResolver,
    this.selectedStats = const {},
  });

  final ReliquarySummary summary;
  final StatAppendResolver statAppendResolver;

  /// スコア計算対象として選択されているステータス（ラベル名 -> 選択状態）
  final Map<String, bool> selectedStats;

  @override
  State<ReliquarySummaryView> createState() => _ReliquarySummaryViewState();
}

class _ReliquarySummaryViewState extends State<ReliquarySummaryView> {
  /// 現在選択されている強化レベル
  int _selectedLevel = 20;

  /// パーセント表示が必要なステータスかどうか
  bool _isPercentageStat(String propId) {
    const percentageStats = [
      'FIGHT_PROP_HP_PERCENT',
      'FIGHT_PROP_ATTACK_PERCENT',
      'FIGHT_PROP_DEFENSE_PERCENT',
      'FIGHT_PROP_CRITICAL',
      'FIGHT_PROP_CRITICAL_HURT',
      'FIGHT_PROP_CHARGE_EFFICIENCY',
      'FIGHT_PROP_FIRE_ADD_HURT',
      'FIGHT_PROP_WATER_ADD_HURT',
      'FIGHT_PROP_GRASS_ADD_HURT',
      'FIGHT_PROP_ELEC_ADD_HURT',
      'FIGHT_PROP_WIND_ADD_HURT',
      'FIGHT_PROP_ICE_ADD_HURT',
      'FIGHT_PROP_ROCK_ADD_HURT',
      'FIGHT_PROP_PHYSICAL_ADD_HURT',
      'FIGHT_PROP_HEAL_ADD',
    ];
    return percentageStats.contains(propId);
  }

  /// メインステータスの表示値を取得（%付き）
  String _getMainStatDisplayValue() {
    final value = widget.summary.mainStatValue;
    if (value == null) return '';

    // メインステータスがパーセント表示が必要か判定
    if (widget.summary.mainPropId != null &&
        _isPercentageStat(widget.summary.mainPropId!)) {
      return '${formatNumber(value)}%';
    }
    return formatNumber(value);
  }

  /// スコアランクの色を取得
  Color _getScoreRankColor(String rank) {
    switch (rank) {
      case 'SS':
        return const Color(0xFFC0C0C0); // 銀色（プラチナ級の最高品質）
      case 'S':
        return const Color(0xFFFFD700); // 金色（☆5相当）
      case 'A':
        return const Color(0xFFA256E1); // 紫色（☆4相当）
      case 'B':
        return const Color(0xFF4A90E2); // 青色（☆3相当）
      default: // 'C'
        return const Color(0xFF73C990); // 緑色（☆2相当、再構築推奨）
    }
  }

  /// スコアを計算する
  ///
  /// 係数:
  /// - 会心率: ×2
  /// - 元素熟知: ÷4
  /// - その他: ×1
  double _calculateScore() {
    double score = 0.0;

    const statNameToPropId = {
      '会心率': 'FIGHT_PROP_CRITICAL',
      '会心ダメージ': 'FIGHT_PROP_CRITICAL_HURT',
      '攻撃力%': 'FIGHT_PROP_ATTACK_PERCENT',
      '防御力%': 'FIGHT_PROP_DEFENSE_PERCENT',
      'HP%': 'FIGHT_PROP_HP_PERCENT',
      '元素チャージ効率': 'FIGHT_PROP_CHARGE_EFFICIENCY',
      '元素熟知': 'FIGHT_PROP_ELEMENT_MASTERY',
    };

    for (final entry in widget.selectedStats.entries) {
      if (entry.value) {
        final propId = statNameToPropId[entry.key];
        if (propId != null) {
          final substat = widget.summary.substats
              .where((s) => s.propId == propId)
              .firstOrNull;
          if (substat != null) {
            final value = substat.statValue;
            if (propId == 'FIGHT_PROP_CRITICAL') {
              score += value * 2;
            } else if (propId == 'FIGHT_PROP_ELEMENT_MASTERY') {
              score += value / 4;
            } else {
              score += value;
            }
          }
        }
      }
    }

    return score;
  }

  /// スコアに基づいてランクを計算（部位別基準）
  String _getScoreBasedRank() {
    // 少なくとも1つのステータスが選択されている場合のみスコアベースのランクを計算
    if (widget.selectedStats.values.any((selected) => selected)) {
      final score = _calculateScore();

      // 部位に応じて基準値を調整
      double ssThreshold, sThreshold, aThreshold, bThreshold;

      switch (widget.summary.equipType) {
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

      if (score >= ssThreshold) return 'SS';
      if (score >= sThreshold) return 'S';
      if (score >= aThreshold) return 'A';
      if (score >= bThreshold) return 'B';
      return 'C';
    }

    // 何も選択されていない場合は空文字を返す
    return '';
  }

  @override
  void initState() {
    super.initState();
    // 初期値として聖遺物の現在レベルを設定 (level: 1-21 → 表示: +0~+20)
    // 表示用レベルに変換: (level - 1)
    final displayLevel = widget.summary.displayLevel;

    // 初期レベルは常に0から選択可能
    _selectedLevel = displayLevel;
  }

  @override
  Widget build(BuildContext context) {
    // maxLevel: API値 (1-21) を表示用 (+0~+20) に変換
    final maxLevel = widget.summary.displayLevel;

    // 最小レベルは常に0（+0から選択可能）
    const minLevel = 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white, // 背景色を白に変更
      elevation: 2, // 軽い影を追加
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー：アイコン、部位名+メインステータス（一覧画面と同じレイアウト）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // アイコン（左端）
                if (widget.summary.iconAssetPath != null)
                  Image.asset(
                    widget.summary.iconAssetPath!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),

                const SizedBox(width: 12),

                // 部位名+メインステータスのColumn（ランクを背後に配置）
                Expanded(
                  child: SizedBox(
                    height: 80, // アイコンと同じ高さを確保
                    child: Stack(
                      clipBehavior: Clip.none, // はみ出しを許可
                      children: [
                        // 背後のスコアランク（半透明、縁取り付き）
                        if (widget.selectedStats.values.any(
                          (selected) => selected,
                        ))
                          Positioned(
                            right: -10, // 少し右にずらす
                            top: -10, // 少し上にずらして中央に配置
                            child: Opacity(
                              opacity: 0.15, // 透明度を大幅に下げる
                              child: Stack(
                                children: [
                                  // 縁取り（黒）
                                  Text(
                                    _getScoreBasedRank(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 4
                                        ..color = Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                    ),
                                  ),
                                  // 本体
                                  Text(
                                    _getScoreBasedRank(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreRankColor(
                                        _getScoreBasedRank(),
                                      ),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // 前面のテキスト
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 部位名（少し小さめ、灰色）
                            Text(
                              widget.summary.equipTypeLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[600],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // メインステータス（黒字、%付き）
                            Text(
                              '${widget.summary.mainPropLabel} ${_getMainStatDisplayValue()}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 強化レベル切り替えタブ
            EnhancementLevelTabs(
              currentLevel: _selectedLevel,
              maxLevel: maxLevel,
              minLevel: minLevel,
              onLevelChanged: (newLevel) {
                setState(() {
                  _selectedLevel = newLevel;
                });
              },
            ),
            const SizedBox(height: 16),

            // サブステータス表示
            const Text('サブステータス:'),
            const SizedBox(height: 8),

            // 各サブステータスの詳細
            for (final substat in widget.summary.substats)
              // +0の場合、初期サブステータスのみ表示
              if (_selectedLevel == 0 && !substat.isInitial)
                const SizedBox.shrink()
              else
                SubstatDetailView(
                  substat: substat,
                  currentLevel: _selectedLevel,
                  isInitial: substat.isInitial,
                  statAppendResolver: widget.statAppendResolver,
                ),

            // 初期3の+0の場合、4つ目のサブステータス欄に「アクティブ化待ち」を表示
            if (_selectedLevel == 0 && widget.summary.initialSubstatCount == 3)
              _buildPendingSubstatRow(context),

            // スコア表示
            if (widget.selectedStats.values.any((selected) => selected)) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // マーカースペース（サブステータスと揃える）
                    const SizedBox(width: 30), // ○マーカー(20px) + 間隔(10px)
                    // スコアラベル
                    Expanded(
                      flex: 3,
                      child: Text(
                        'スコア',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                      ),
                    ),
                    // スコア値
                    SizedBox(
                      width: 80,
                      child: Text(
                        _calculateScore().toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // 右側の余白（増加値表示領域分）
                    const SizedBox(width: 120),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// アクティブ化待ちのサブステータス行を構築
  Widget _buildPendingSubstatRow(BuildContext context) {
    // 初期サブステータスでない（後から追加された）サブステータスを探す
    final pendingSubstat = widget.summary.substats.firstWhere(
      (s) => !s.isInitial,
      orElse: () => widget.summary.substats.first,
    );

    final optionName = pendingSubstat.label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // サブステータスマーカー（グレーアウト）
          Text(
            '○',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 20),
          ),
          const SizedBox(width: 10),
          // アクティブ化待ちのテキスト
          Expanded(
            flex: 3,
            child: Text(
              optionName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          // 右側の空白スペース（他の行とレイアウトを揃える）
          const SizedBox(width: 200), // 現在値と増加値のスペース分
        ],
      ),
    );
  }
}
