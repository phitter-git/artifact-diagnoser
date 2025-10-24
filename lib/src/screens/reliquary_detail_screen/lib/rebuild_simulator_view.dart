import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain.dart';
import 'package:artifact_diagnoser/src/services/rebuild_simulator_service.dart';
import 'package:artifact_diagnoser/src/services/stat_append_resolver.dart';

/// 再構築シミュレータービュー
///
/// サブステータス選択、再構築種別選択を行い、
/// 理論最大値と更新率を表示します。
class RebuildSimulatorView extends StatefulWidget {
  const RebuildSimulatorView({
    required this.summary,
    required this.scoreTargetPropIds,
    required this.statAppendResolver,
    super.key,
  });

  final ReliquarySummary summary;

  /// スコア計算対象のpropIdセット（親コンポーネントから受け取る）
  final Set<String> scoreTargetPropIds;

  /// ステータス付加値リゾルバー
  final StatAppendResolver statAppendResolver;

  @override
  State<RebuildSimulatorView> createState() => _RebuildSimulatorViewState();
}

class _RebuildSimulatorViewState extends State<RebuildSimulatorView>
    with AutomaticKeepAliveClientMixin {
  final _simulatorService = RebuildSimulatorService();

  // 選択された2つのサブステータスのpropId
  final Set<String> _selectedSubstatIds = {};

  // 選択された再構築種別
  RebuildType? _selectedRebuildType;

  // 各再構築種別の更新率（事前計算用）
  final Map<RebuildType, double> _updateRates = {};

  // シミュレーション結果
  RebuildSimulationResult? _simulationResult;

  // 計算中フラグ
  bool _isCalculating = false;

  // 再構築シミュレーション試行結果
  RebuildSimulationTrial? _simulationTrial;

  // 再構築種別選択の折りたたみ状態
  bool _isRebuildTypeCollapsed = false;

  // 希望サブオプション選択の折りたたみ状態
  bool _isSubstatSelectionCollapsed = false;

  @override
  bool get wantKeepAlive => true;

  /// 選択されたサブステータスのラベルをカンマ区切りで取得
  String _getSelectedSubstatLabels() {
    final labels = <String>[];
    for (final substat in widget.summary.substats) {
      if (_selectedSubstatIds.contains(substat.propId)) {
        labels.add(substat.label);
      }
    }
    return labels.join('、');
  }

  @override
  void didUpdateWidget(RebuildSimulatorView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // スコア計算対象が変更された場合、結果を再計算（入力は保持）
    if (oldWidget.scoreTargetPropIds != widget.scoreTargetPropIds &&
        _simulationResult != null) {
      // 現在の選択状態で再計算
      _recalculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin用
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ③ 再構築シミュレーション結果（実行後に最上部に表示）
          if (_selectedRebuildType != null &&
              _isRebuildTypeCollapsed &&
              _simulationTrial != null) ...[
            _buildSimulationResultCard(),
            const SizedBox(height: 8),
          ],

          // ④ 再構築シミュレーション操作カード（種別選択後に表示、結果がない場合のみ）
          if (_selectedRebuildType != null &&
              _isRebuildTypeCollapsed &&
              _simulationTrial == null) ...[
            _buildSimulationControlCard(),
            const SizedBox(height: 8),
          ],

          // ② 再構築種別選択（2つ選択後に表示）
          if (_selectedSubstatIds.length == 2) ...[
            if (_isCalculating && _updateRates.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_isRebuildTypeCollapsed && _selectedRebuildType != null)
              _buildRebuildTypeSelectionCollapsed()
            else
              _buildRebuildTypeSelection(),
            const SizedBox(height: 8),
          ],

          // ① 希望サブオプション選択（2つ選択前のみ展開、選択後は折りたたむ）
          if (_isSubstatSelectionCollapsed)
            _buildSubstatSelectionCollapsed()
          else
            _buildSubstatSelection(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// サブステータス選択UI（展開時）
  Widget _buildSubstatSelection() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('希望サブオプションを選択（2つ選択必須）', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ...widget.summary.substats.map((substat) {
              final isSelected = _selectedSubstatIds.contains(substat.propId);
              // 実数値(攻撃力、防御力、HP、元素熟知)は%なし、その他は%あり
              final hasPercent =
                  substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
                  substat.propId != 'FIGHT_PROP_ATTACK' &&
                  substat.propId != 'FIGHT_PROP_DEFENSE' &&
                  substat.propId != 'FIGHT_PROP_HP';
              final valueText = hasPercent
                  ? '${substat.statValue.toStringAsFixed(1)}%'
                  : substat.statValue.toStringAsFixed(0);
              return CheckboxListTile(
                title: Text(substat.label),
                subtitle: Text(
                  '$valueText (×${substat.totalUpgrades}回)',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.black54,
                  ),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (_selectedSubstatIds.length < 2) {
                        _selectedSubstatIds.add(substat.propId);
                        // 2つ選択完了したら折りたたむ
                        if (_selectedSubstatIds.length == 2) {
                          _isSubstatSelectionCollapsed = true;
                        }
                      }
                    } else {
                      _selectedSubstatIds.remove(substat.propId);
                    }
                    _recalculate();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// サブステータス選択UI（折りたたまれた状態）
  Widget _buildSubstatSelectionCollapsed() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _isSubstatSelectionCollapsed = false;
            _selectedSubstatIds.clear();
            _selectedRebuildType = null;
            _simulationResult = null;
            _updateRates.clear();
            _simulationTrial = null;
            _isRebuildTypeCollapsed = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '選択: ${_getSelectedSubstatLabels()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 再構築種別選択UI
  Widget _buildRebuildTypeSelection() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('再構築種別を選択', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            RadioGroup<RebuildType>(
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRebuildType = value;
                    _isRebuildTypeCollapsed = true; // 選択後に折りたたむ
                    // ⑧ 種別選択時は既存の計算結果を使用（再計算なし）
                    // 更新率の表示のみ更新
                  });
                }
              },
              child: Column(
                children: RebuildType.values.map((type) {
                  // 各種別の更新率を表示
                  final updateRate = _updateRates[type];

                  return RadioListTile<RebuildType>(
                    title: Text(type.labelWithCount),
                    subtitle: updateRate != null
                        ? Text(
                            '更新率: ${updateRate.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  Colors.black54,
                            ),
                          )
                        : null,
                    value: type,
                    selected: _selectedRebuildType == type,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 【一時的に非表示】現在の状態セクション
  /// 必要性を検討中のため、コードは残しつつコメントアウト
  // Widget _buildCurrentStateSection() {
  //   final result = _simulationResult!;

  //   return Card(
  //     color: Theme.of(context).cardColor,
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Row(
  //             children: [
  //               Icon(Icons.analytics, size: 20),
  //               SizedBox(width: 8),
  //               Text('現在の状態（再構築前）', style: TextStyle(fontSize: 16)),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           ...result.allSubstats.map((substat) {
  //             final isSelected = _selectedSubstatIds.contains(substat.propId);
  //             final isTarget = widget.scoreTargetPropIds.contains(
  //               substat.propId,
  //             );
  //             // 実数値(攻撃力、防御力、HP、元素熟知)は%なし、その他は%あり
  //             final hasPercent =
  //                 substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
  //                 substat.propId != 'FIGHT_PROP_ATTACK' &&
  //                 substat.propId != 'FIGHT_PROP_DEFENSE' &&
  //                 substat.propId != 'FIGHT_PROP_HP';
  //             final valueText = hasPercent
  //                 ? '${substat.statValue.toStringAsFixed(1)}%'
  //                 : substat.statValue.toStringAsFixed(0);
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 4.0),
  //               child: Row(
  //                 children: [
  //                   Text(
  //                     '• ${substat.label}: ',
  //                     style: TextStyle(
  //                       fontWeight: isSelected
  //                           ? FontWeight.bold
  //                           : FontWeight.normal,
  //                       color: isTarget
  //                           ? null
  //                           : (Theme.of(context).textTheme.bodyLarge?.color
  //                                     ?.withValues(alpha: 0.65) ??
  //                                 Colors.black54),
  //                     ),
  //                   ),
  //                   Text(
  //                     '$valueText ',
  //                     style: TextStyle(
  //                       fontWeight: isSelected
  //                           ? FontWeight.bold
  //                           : FontWeight.normal,
  //                       color: isTarget
  //                           ? null
  //                           : (Theme.of(context).textTheme.bodyLarge?.color
  //                                     ?.withValues(alpha: 0.65) ??
  //                                 Colors.black54),
  //                     ),
  //                   ),
  //                   Text(
  //                     '(×${substat.totalUpgrades}回強化)',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color:
  //                           Theme.of(context).textTheme.bodySmall?.color ??
  //                           Colors.black54,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }),
  //           const Divider(height: 24),
  //           Text(
  //             'スコア対象合計: ${result.currentScore.toStringAsFixed(1)}',
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// 理論最大値セクション
  /// 再構築種別選択UI（折りたたみ時）
  Widget _buildRebuildTypeSelectionCollapsed() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _isRebuildTypeCollapsed = false;
            _simulationTrial = null; // シミュレーション結果をクリア
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '選択: ${_selectedRebuildType!.label}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 再構築シミュレーション操作カード（実行ボタン付き）
  Widget _buildSimulationControlCard() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在のサブステータス表示
            const Text(
              '現在の聖遺物ステータス',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.summary.substats.map(
              (substat) => _buildCurrentSubstatView(substat),
            ),
            const SizedBox(height: 12),

            // 現在のスコア表示
            _buildCurrentScoreDisplay(),
            const SizedBox(height: 16),

            // 更新率と実行ボタン
            _buildExecutionPrompt(),
          ],
        ),
      ),
    );
  }

  /// 再構築シミュレーション結果カード
  Widget _buildSimulationResultCard() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                const Icon(Icons.casino, size: 20),
                const SizedBox(width: 8),
                Text(
                  '再構築シミュレーション結果',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSimulationResult(),
          ],
        ),
      ),
    );
  }

  /// 実行確認プロンプト（更新率 + 実行ボタン）
  Widget _buildExecutionPrompt() {
    final rebuildType = _selectedRebuildType!;
    final updateRate = _updateRates[rebuildType] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 更新率メッセージ（中央揃え）
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            '${rebuildType.label}によって現在のスコアを更新する確率は${updateRate.toStringAsFixed(2)}%です。実行しますか？',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // 実行ボタン（大きめサイズ）
        ElevatedButton.icon(
          onPressed: _executeSimulation,
          icon: const Icon(Icons.play_arrow, size: 24),
          label: const Text(
            '再構築を実行',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(200, 56),
          ),
        ),
      ],
    );
  }

  /// 現在のサブステータス表示（強化回数と履歴を表示）
  Widget _buildCurrentSubstatView(SubstatSummary substat) {
    final theme = Theme.of(context);
    final isScoreTarget =
        _getSelectedStatsMap()[_getPropIdToStatName(substat.propId)] == true;

    // パーセント表示判定
    final isPercentage =
        substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
        substat.propId != 'FIGHT_PROP_ATTACK' &&
        substat.propId != 'FIGHT_PROP_DEFENSE' &&
        substat.propId != 'FIGHT_PROP_HP';

    final valueText = isPercentage
        ? '${substat.statValue.toStringAsFixed(1)}%'
        : substat.statValue.toStringAsFixed(0);

    // 強化履歴を作成（初期値を含む）
    final rollHistory = substat.rollValues
        .map((value) {
          return isPercentage
              ? '${value.toStringAsFixed(1)}%'
              : value.toStringAsFixed(0);
        })
        .join(' + ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1行目: マーカー、ステータス名、現在値
          Row(
            children: [
              // マーカー
              Text(
                isScoreTarget ? '●' : '○',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 20),
              ),
              const SizedBox(width: 10),
              // ステータス名
              Expanded(
                flex: 3,
                child: Text(
                  substat.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
              // 現在値
              Expanded(
                flex: 2,
                child: Text(
                  valueText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          // 2行目: 強化回数と履歴
          if (rollHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: Row(
                children: [
                  // 強化回数バッジ（SubstatDetailViewと同じスタイル）
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5DEB3).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '×${substat.totalUpgrades}',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFFE8C547)
                            : const Color(0xFF8B6914),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 強化履歴
                  Expanded(
                    child: Text(
                      rollHistory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                            : Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 現在のスコア表示
  Widget _buildCurrentScoreDisplay() {
    if (_simulationResult == null) return const SizedBox.shrink();

    final score = _simulationResult!.currentScore;
    final rank = _getScoreRank(score);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '現在のスコア',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreRankColor(rank).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getScoreRankColor(rank),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  rank,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreRankColor(rank),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// スコアからランクを取得（部位別基準）
  String _getScoreRank(double score) {
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

  /// ランクに応じた色を取得（詳細画面と同じ色）
  Color _getScoreRankColor(String rank) {
    switch (rank) {
      case 'SS':
        return const Color(0xFFC0C0C0); // 銀色（プラチナ級）
      case 'S':
        return const Color(0xFFFFD700); // 金色（☆5相当）
      case 'A':
        return const Color(0xFFA256E1); // 紫色（☆4相当）
      case 'B':
        return const Color(0xFF4A90E2); // 青色（☆3相当）
      default: // 'C'
        return const Color(0xFF73C990); // 緑色（☆2相当）
    }
  }

  /// propIdから日本語ステータス名を取得
  String? _getPropIdToStatName(String propId) {
    const propIdToStatName = {
      'FIGHT_PROP_CRITICAL': '会心率',
      'FIGHT_PROP_CRITICAL_HURT': '会心ダメージ',
      'FIGHT_PROP_ATTACK_PERCENT': '攻撃力%',
      'FIGHT_PROP_DEFENSE_PERCENT': '防御力%',
      'FIGHT_PROP_HP_PERCENT': 'HP%',
      'FIGHT_PROP_CHARGE_EFFICIENCY': '元素チャージ効率',
      'FIGHT_PROP_ELEMENT_MASTERY': '元素熟知',
    };
    return propIdToStatName[propId];
  }

  /// シミュレーション結果表示
  Widget _buildSimulationResult() {
    final trial = _simulationTrial!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // スコア比較
        _buildScoreComparison(trial),
        const SizedBox(height: 8),

        // サブステータス一覧
        _buildSubstatsList(trial),
        const SizedBox(height: 8),

        // アクションボタン（大きめサイズ）
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _executeSimulation,
                icon: const Icon(Icons.refresh, size: 22),
                label: const Text(
                  'もう一度試す',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetSimulation,
                icon: const Icon(Icons.close, size: 22),
                label: const Text(
                  'リセット',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// スコア比較表示
  Widget _buildScoreComparison(RebuildSimulationTrial trial) {
    // お祝いメッセージ
    String congratsMessage = '';
    // if (trial.isImproved) {
    //   if (trial.scoreDiff >= 10.0) {
    //     congratsMessage = '🎉 大成功！';
    //   } else if (trial.scoreDiff >= 5.0) {
    //     congratsMessage = '✨ 素晴らしい！';
    //   } else {
    //     congratsMessage = '👍 改善！';
    //   }
    // }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trial.isImproved
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: trial.isImproved ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // お祝いメッセージ
          if (congratsMessage.isNotEmpty) ...[
            Text(
              congratsMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // スコア表示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '現在: ${_simulationResult!.currentScore.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'シミュレーション: ${trial.newScore.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: trial.isImproved ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${trial.scoreDiff >= 0 ? '+' : ''}${trial.scoreDiff.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// サブステータス一覧表示
  Widget _buildSubstatsList(RebuildSimulationTrial trial) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '新しいサブステータス',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...trial.newSubstats.map(
            (substat) => _buildSimulationSubstatView(substat),
          ),
        ],
      ),
    );
  }

  /// シミュレーション結果のサブステータス表示（ランク付き履歴）
  Widget _buildSimulationSubstatView(SubstatSummary substat) {
    final theme = Theme.of(context);
    final isScoreTarget =
        _getSelectedStatsMap()[_getPropIdToStatName(substat.propId)] == true;

    // パーセント表示判定
    final isPercentage =
        substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
        substat.propId != 'FIGHT_PROP_ATTACK' &&
        substat.propId != 'FIGHT_PROP_DEFENSE' &&
        substat.propId != 'FIGHT_PROP_HP';

    final valueText = isPercentage
        ? '${substat.statValue.toStringAsFixed(1)}%'
        : substat.statValue.toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1行目: マーカー、ステータス名、現在値
          Row(
            children: [
              // マーカー
              Text(
                isScoreTarget ? '●' : '○',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 20),
              ),
              const SizedBox(width: 10),
              // ステータス名
              Expanded(
                flex: 3,
                child: Text(
                  substat.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
              // 現在値
              Expanded(
                flex: 2,
                child: Text(
                  valueText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          // 2行目: 強化回数と履歴（リッチなランク表示）
          if (substat.rollValues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: Row(
                children: [
                  // 強化回数バッジ（SubstatDetailViewと同じスタイル）
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5DEB3).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '×${substat.totalUpgrades}',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFFE8C547)
                            : const Color(0xFF8B6914),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 強化履歴（リッチなランク表示）
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (int i = 0; i < substat.rollValues.length; i++) ...[
                          if (i > 0)
                            Text(
                              '+',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      )
                                    : Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          _buildRollValueChip(
                            substat.rollValues[i],
                            i < substat.rollTiers.length
                                ? substat.rollTiers[i]
                                : 1,
                            isPercentage,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tierからランクを取得
  String _getTierRank(int tier) {
    switch (tier) {
      case 4:
        return 'S';
      case 3:
        return 'A';
      case 2:
        return 'B';
      case 1:
        return 'C';
      default:
        return 'C';
    }
  }

  /// Tierから色を取得（SubstatDetailViewと同じ定義）
  Color _getRollTierColor(int tier) {
    switch (tier) {
      case 4:
        return const Color(0xFFFF9800); // オレンジ
      case 3:
        return const Color(0xFFFF9800); // オレンジ
      case 2:
        return const Color(0xFF9E9E9E); // グレー
      case 1:
        return const Color(0xFF795548); // ブラウン
      default:
        return const Color(0xFF757575); // ダークグレー
    }
  }

  /// 強化値チップを構築（値+ランクバッジ）
  Widget _buildRollValueChip(double value, int tier, bool isPercentage) {
    final theme = Theme.of(context);
    final valueStr = isPercentage
        ? '${value.toStringAsFixed(1)}%'
        : value.toStringAsFixed(0);
    final rank = _getTierRank(tier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          valueStr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: _getRollTierColor(tier),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            rank,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// スコア計算対象のマップを作成
  Map<String, bool> _getSelectedStatsMap() {
    return {
      for (final propId in widget.scoreTargetPropIds)
        _getPropIdToStatName(propId) ?? '': true,
    };
  }

  /// シミュレーション実行
  void _executeSimulation() {
    if (_simulationResult == null || _selectedRebuildType == null) return;

    final trial = _simulatorService.simulateRebuild(
      currentSubstats: _simulationResult!.allSubstats,
      currentScore: _simulationResult!.currentScore,
      primarySubstat: _simulationResult!.primarySubstat,
      secondarySubstat: _simulationResult!.secondarySubstat,
      initialSubstatCount: widget.summary.initialSubstatCount,
      scoreTargetPropIds: widget.scoreTargetPropIds,
      rebuildType: _selectedRebuildType!,
    );

    setState(() {
      _simulationTrial = trial;
    });
  }

  /// シミュレーションリセット
  void _resetSimulation() {
    setState(() {
      _simulationTrial = null;
    });
  }

  /// 再計算を実行
  Future<void> _recalculate() async {
    if (_selectedSubstatIds.length != 2) {
      setState(() {
        _simulationResult = null;
        _updateRates.clear();
      });
      return;
    }

    // ③ 基本情報を1回計算（再構築種別に依存しない）
    final baseInfo = _simulatorService.calculateBaseInfo(
      allSubstats: widget.summary.substats,
      initialSubstatCount: widget.summary.initialSubstatCount,
      scoreTargetPropIds: widget.scoreTargetPropIds,
    );

    // ④ UIに基本情報を表示
    setState(() {
      _simulationResult = baseInfo;
      _isCalculating = true;
      _updateRates.clear();
    });

    // ⑤⑥ 更新率を計算
    // 3種別分の更新率を計算
    final newUpdateRates = <RebuildType, double>{};
    for (final type in RebuildType.values) {
      final updateRate = _simulatorService.calculateUpdateRate(
        baseInfo: baseInfo,
        rebuildType: type,
        scoreTargetPropIds: widget.scoreTargetPropIds,
      );
      newUpdateRates[type] = updateRate;
    }

    // ⑦ 計算完了後UIに反映
    setState(() {
      _updateRates.addAll(newUpdateRates);
      _isCalculating = false;
    });
  }
}
