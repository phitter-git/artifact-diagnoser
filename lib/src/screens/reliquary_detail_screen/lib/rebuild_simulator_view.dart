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

  // アニメーション関連
  bool _isAnimating = false; // アニメーション実行中フラグ
  int _currentEnhancementLevel = 0; // 現在の強化レベル（0=初期値、1-5=+4,+8,+12,+16,+20）
  int _highlightedSubstatIndex = -1; // 光らせるサブステータスのインデックス

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

      // シミュレーション結果がある場合、再構築後のスコアも再計算
      if (_simulationTrial != null) {
        _recalculateSimulationTrial();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin用
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
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
                else if (_isRebuildTypeCollapsed &&
                    _selectedRebuildType != null)
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

              // 説明カード（常に表示）
              _buildIntroductionCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// 説明カード（初回表示時）
  Widget _buildIntroductionCard() {
    return Card(
      elevation: 2,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '再構築シミュレーターについて',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize:
                        (Theme.of(context).textTheme.titleMedium?.fontSize ??
                            16) +
                        2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              icon: Icons.auto_fix_high,
              title: '「聖啓の塵」の活用を支援',
              description: '再構築すべき聖遺物かどうかの判断材料を提供',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.calculate_outlined,
              title: 'スコア更新率を自動計算',
              description: '現在のスコアを超える確率を3種類の再構築タイプごとに表示',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: Icons.replay,
              title: '何度でもシミュレーション',
              description: '聖啓の塵を消費せず何度もつよくてニューゲーム',
            ),
            // const SizedBox(height: 16),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(
            //       color: Theme.of(context).dividerColor,
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.arrow_downward,
            //         size: 20,
            //         color: Theme.of(context).colorScheme.primary,
            //       ),
            //       const SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           'まずは希望サブオプションを2つ選択してください',
            //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// 機能説明行
  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
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
                title: Text(substat.label, overflow: TextOverflow.ellipsis),
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
            Row(
              children: [
                const Text('再構築種別を選択', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Tooltip(
                  message:
                      '※更新率はモンテカルロ法(N=200k)による計算結果です。\nわずかな誤差(平均±0.22%)を含む場合があります。',
                  padding: const EdgeInsets.all(12),
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
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
    // メインステータスの表示値を取得
    String getMainStatDisplayValue() {
      final value = widget.summary.mainStatValue;
      if (value == null) return '';

      // メインステータスがパーセント表示が必要か判定
      final propId = widget.summary.mainPropId;
      if (propId != null && _isPercentageStat(propId)) {
        return '${value.toStringAsFixed(1)}%';
      }
      return value.toStringAsFixed(0);
    }

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 聖遺物ヘッダー（アイコン + 部位 + メインステータス）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // アイコン
                if (widget.summary.iconAssetPath != null)
                  Image.asset(
                    widget.summary.iconAssetPath!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(width: 12),
                // 部位名とメインステータス
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 部位名
                      Text(
                        widget.summary.equipTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      // メインステータス
                      Text(
                        '${widget.summary.mainPropLabel} ${getMainStatDisplayValue()}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // 現在のサブステータス表示
            const Text('現在の聖遺物ステータス', style: TextStyle(fontSize: 18)),
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
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 結果表示（余白なし）
            _buildSimulationResult(),

            // 下部余白のみ
            const SizedBox(height: 8),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${rebuildType.label}によって現在のスコアを更新する確率は${updateRate.toStringAsFixed(2)}%です。実行しますか？',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message:
                        '※この結果はモンテカルロ法(N=200k)によるシミュレーションを用いており、\nわずかな誤差(平均±0.22%)を含む場合があります。',
                    padding: const EdgeInsets.all(12),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 実行ボタン（大きめサイズ、コントラスト強化）
        ElevatedButton.icon(
          onPressed: _isCalculating ? null : _executeSimulation,
          icon: _isCalculating
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.play_arrow, size: 24),
          label: Text(
            _isCalculating ? '実行中...' : '再構築を実行',
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(200, 56),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 4,
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
                  overflow: TextOverflow.ellipsis,
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
          const Text('現在のスコア', style: TextStyle(fontSize: 18)),
          Row(
            children: [
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(fontSize: 22),
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
                    fontSize: 16,
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
        // サブステータス一覧（左右余白なし）
        _buildSubstatsList(trial),
        
        // アニメーション完了後のみスコア比較とボタンを表示
        if (!_isAnimating) ...[
          const SizedBox(height: 8),
          // スコア比較（左右余白なし）
          _buildScoreComparison(trial),
          const SizedBox(height: 8),

          // アクションボタン（横余白のみ追加）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isCalculating ? null : _executeSimulation,
                    icon: _isCalculating
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh, size: 22),
                  label: Text(
                    _isCalculating ? '実行中...' : '再構築！',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 50),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCalculating ? null : _resetSimulation,
                  icon: const Icon(Icons.close, size: 22),
                  label: const Text('リセット', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 50),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
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
              style: TextStyle(fontSize: 20, color: Colors.green.shade700),
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
                    '再構築前スコア: ${_simulationResult!.currentScore.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '再構築後スコア: ${trial.newScore.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 18),
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
                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
    // メインステータスの表示値を取得
    String getMainStatDisplayValue() {
      final value = widget.summary.mainStatValue;
      if (value == null) return '';

      // メインステータスがパーセント表示が必要か判定
      final propId = widget.summary.mainPropId;
      if (propId != null && _isPercentageStat(propId)) {
        return '${value.toStringAsFixed(1)}%';
      }
      return value.toStringAsFixed(0);
    }

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
          // 聖遺物ヘッダー（アイコン + 部位 + メインステータス）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコン
              if (widget.summary.iconAssetPath != null)
                Image.asset(
                  widget.summary.iconAssetPath!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              const SizedBox(width: 12),
              // 部位名とメインステータス
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 部位名
                    Text(
                      widget.summary.equipTypeLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // メインステータス
                    Text(
                      '${widget.summary.mainPropLabel} ${getMainStatDisplayValue()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('シミュレーション結果', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          // すべてのサブステータスを表示（アニメーションは強化レベルで制御）
          ...trial.newSubstats.asMap().entries.map(
            (entry) => _buildSimulationSubstatView(
              entry.value,
              entry.key,
            ),
          ),
        ],
      ),
    );
  }

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

  /// シミュレーション結果のサブステータス表示（ランク付き履歴）
  Widget _buildSimulationSubstatView(SubstatSummary substat, int index) {
    final theme = Theme.of(context);
    final isScoreTarget =
        _getSelectedStatsMap()[_getPropIdToStatName(substat.propId)] == true;

    // ハイライト判定
    final isHighlighted = _highlightedSubstatIndex == index;

    // パーセント表示判定
    final isPercentage =
        substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
        substat.propId != 'FIGHT_PROP_ATTACK' &&
        substat.propId != 'FIGHT_PROP_DEFENSE' &&
        substat.propId != 'FIGHT_PROP_HP';

    // 現在の強化レベルまでの累積値を計算
    final currentArtifactLevel = _currentEnhancementLevel * 4; // 0,4,8,12,16,20
    double displayValue = 0.0;
    int visibleRolls = 0;
    
    for (int i = 0; i < substat.enhancementLevels.length; i++) {
      if (substat.enhancementLevels[i] <= currentArtifactLevel) {
        displayValue += substat.rollValues[i];
        visibleRolls++;
      } else {
        break;
      }
    }

    final valueText = isPercentage
        ? '${displayValue.toStringAsFixed(1)}%'
        : displayValue.toStringAsFixed(0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
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
                  overflow: TextOverflow.ellipsis,
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
          // 2行目: 強化回数と履歴（現在のレベルまでのロールのみ表示）
          if (visibleRolls > 0)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: Row(
                children: [
                  // 強化回数バッジ（現在表示中のロール数）
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
                      '×$visibleRolls',
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
                  // 強化履歴（現在のレベルまでのロールのみ表示）
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (int i = 0; i < visibleRolls; i++) ...[
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
            style: const TextStyle(fontSize: 13, color: Colors.white),
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
  Future<void> _executeSimulation() async {
    if (_simulationResult == null || _selectedRebuildType == null) return;

    // ローディング開始
    setState(() {
      _isCalculating = true;
    });

    // ローディング時間（0.6秒）
    await Future.delayed(const Duration(milliseconds: 600));

    // ユーザーが選択した希望サブオプションからprimaryとsecondaryを取得
    final selectedSubstats = widget.summary.substats
        .where((s) => _selectedSubstatIds.contains(s.propId))
        .toList();

    if (selectedSubstats.length != 2) {
      setState(() {
        _isCalculating = false;
      });
      return;
    }

    // 優先度順にソート（高い方がprimary）
    selectedSubstats.sort((a, b) {
      const priority = {
        'FIGHT_PROP_CRITICAL': 7,
        'FIGHT_PROP_CRITICAL_HURT': 6,
        'FIGHT_PROP_DEFENSE_PERCENT': 5,
        'FIGHT_PROP_CHARGE_EFFICIENCY': 4,
        'FIGHT_PROP_ATTACK_PERCENT': 3,
        'FIGHT_PROP_HP_PERCENT': 2,
        'FIGHT_PROP_ELEMENT_MASTERY': 1,
      };
      final priorityA = priority[a.propId] ?? 0;
      final priorityB = priority[b.propId] ?? 0;
      return priorityB.compareTo(priorityA);
    });

    final trial = _simulatorService.simulateRebuild(
      currentSubstats: _simulationResult!.allSubstats,
      currentScore: _simulationResult!.currentScore,
      primarySubstat: selectedSubstats[0], // ユーザー選択の第1希望
      secondarySubstat: selectedSubstats[1], // ユーザー選択の第2希望
      initialSubstatCount: widget.summary.initialSubstatCount,
      scoreTargetPropIds: widget.scoreTargetPropIds,
      rebuildType: _selectedRebuildType!,
    );

    // 結果を設定してアニメーション開始
    // すべてのサブステータスを初期値で表示後、強化ロールごとにアニメーション
    setState(() {
      _simulationTrial = trial;
      _isCalculating = false;
      _isAnimating = true;
      _currentEnhancementLevel = 0; // 初期値から開始
      _highlightedSubstatIndex = -1;
    });

    // 5回の強化ロールをアニメーション表示（0.3秒間隔）
    for (int rollLevel = 1; rollLevel <= 5; rollLevel++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // この強化レベルでどのサブステータスが強化されたかを判定
      final enhancedIndex = _findEnhancedSubstatIndexForLevel(trial, rollLevel);
      
      setState(() {
        _currentEnhancementLevel = rollLevel;
        _highlightedSubstatIndex = enhancedIndex;
      });

      // ハイライトを0.2秒間表示
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      
      setState(() {
        _highlightedSubstatIndex = -1;
      });
    }

    // アニメーション完了
    setState(() {
      _isAnimating = false;
      _currentEnhancementLevel = 5; // 最終強化レベル
    });
  }

  /// 指定した強化レベルで強化されたサブステータスのインデックスを返す
  /// rollLevel: 1-5（+4, +8, +12, +16, +20に対応）
  int _findEnhancedSubstatIndexForLevel(RebuildSimulationTrial trial, int rollLevel) {
    // rollLevelを聖遺物の強化レベルに変換
    // rollLevel 1 → +4, rollLevel 2 → +8, ... rollLevel 5 → +20
    final artifactLevel = rollLevel * 4;
    
    // 各サブステータスのenhancementLevelsを確認して、該当レベルで強化されたものを探す
    for (int i = 0; i < trial.newSubstats.length; i++) {
      final substat = trial.newSubstats[i];
      if (substat.enhancementLevels.contains(artifactLevel)) {
        return i;
      }
    }
    
    // 該当なしの場合は最初のサブステータス（本来は起こらない）
    return 0;
  }

  /// シミュレーションリセット
  void _resetSimulation() {
    setState(() {
      // 希望サブオプション選択まで戻る
      _selectedSubstatIds.clear();
      _selectedRebuildType = null;
      _simulationResult = null;
      _updateRates.clear();
      _simulationTrial = null;
      _isRebuildTypeCollapsed = false;
      _isSubstatSelectionCollapsed = false;
      // アニメーション状態もリセット
      _isAnimating = false;
      _currentEnhancementLevel = 0;
      _highlightedSubstatIndex = -1;
    });
  }

  /// シミュレーション結果のスコアを再計算
  /// スコア計算対象が変更された際に、再構築後のサブステータスから新しいスコアを計算
  void _recalculateSimulationTrial() {
    if (_simulationTrial == null || _simulationResult == null) return;

    // アニメーション状態をリセット（即座に全表示）
    setState(() {
      _isAnimating = false;
      _currentEnhancementLevel = 5; // 最終強化レベルを表示
      _highlightedSubstatIndex = -1;
    });

    // 再構築後のサブステータスから新しいスコアを計算
    double newScore = 0.0;
    for (final substat in _simulationTrial!.newSubstats) {
      if (widget.scoreTargetPropIds.contains(substat.propId)) {
        // スコア係数を適用（会心率は×2、会心ダメージは×1）
        final coefficient = substat.propId == 'FIGHT_PROP_CRITICAL' ? 2.0 : 1.0;
        newScore += substat.statValue * coefficient;
      }
    }

    // 現在のスコアは_simulationResultから取得（すでに_recalculate()で更新済み）
    final currentScore = _simulationResult!.currentScore;
    final scoreDiff = newScore - currentScore;
    final isImproved = newScore > currentScore;

    // 新しいRebuildSimulationTrialを作成
    setState(() {
      _simulationTrial = RebuildSimulationTrial(
        newSubstats: _simulationTrial!.newSubstats,
        newScore: newScore,
        scoreDiff: scoreDiff,
        isImproved: isImproved,
      );
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
        desiredSubstatIds: _selectedSubstatIds, // ユーザーが選択した希望サブオプション
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
