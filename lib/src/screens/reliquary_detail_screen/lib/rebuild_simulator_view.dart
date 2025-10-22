import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/models/domain.dart';
import 'package:artifact_diagnoser/src/services/rebuild_simulator_service.dart';

/// 再構築シミュレータービュー
///
/// サブステータス選択、再構築種別選択を行い、
/// 理論最大値と更新率を表示します。
class RebuildSimulatorView extends StatefulWidget {
  const RebuildSimulatorView({
    required this.summary,
    required this.scoreTargetPropIds,
    super.key,
  });

  final ReliquarySummary summary;

  /// スコア計算対象のpropIdセット（親コンポーネントから受け取る）
  final Set<String> scoreTargetPropIds;

  @override
  State<RebuildSimulatorView> createState() => _RebuildSimulatorViewState();
}

class _RebuildSimulatorViewState extends State<RebuildSimulatorView> {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① 希望サブオプション選択（常に表示）
          _buildSubstatSelection(),
          const SizedBox(height: 24),

          // ② 再構築種別選択（2つ選択後に表示）
          if (_selectedSubstatIds.length == 2) ...[
            if (_isCalculating && _updateRates.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildRebuildTypeSelection(),
            const SizedBox(height: 32),
          ],

          // ③ 結果セクション（再構築種別選択後に表示）
          if (_selectedRebuildType != null) ...[
            if (_isCalculating)
              const Center(child: CircularProgressIndicator())
            else if (_simulationResult != null) ...[
              _buildCurrentStateSection(),
              const SizedBox(height: 24),
              _buildTheoreticalMaxSection(),
              const SizedBox(height: 24),
              _buildUpdateRateSection(),
            ],
          ],
        ],
      ),
    );
  }

  /// サブステータス選択UI
  Widget _buildSubstatSelection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '希望サブオプションを選択（2つ選択必須）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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

  /// 再構築種別選択UI
  Widget _buildRebuildTypeSelection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '再構築種別を選択',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...RebuildType.values.map((type) {
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
                              Theme.of(context).textTheme.bodySmall?.color ??
                              Colors.black54,
                        ),
                      )
                    : null,
                value: type,
                groupValue: _selectedRebuildType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRebuildType = value;
                      _recalculate();
                    });
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 現在の状態セクション
  Widget _buildCurrentStateSection() {
    final result = _simulationResult!;

    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 8),
                Text(
                  '現在の状態（再構築前）',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.allSubstats.map((substat) {
              final isSelected = _selectedSubstatIds.contains(substat.propId);
              final isTarget = widget.scoreTargetPropIds.contains(
                substat.propId,
              );
              // 実数値(攻撃力、防御力、HP、元素熟知)は%なし、その他は%あり
              final hasPercent =
                  substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
                  substat.propId != 'FIGHT_PROP_ATTACK' &&
                  substat.propId != 'FIGHT_PROP_DEFENSE' &&
                  substat.propId != 'FIGHT_PROP_HP';
              final valueText = hasPercent
                  ? '${substat.statValue.toStringAsFixed(1)}%'
                  : substat.statValue.toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '• ${substat.label}: ',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isTarget
                            ? null
                            : (Theme.of(context).textTheme.bodyLarge?.color
                                      ?.withOpacity(0.65) ??
                                  Colors.black54),
                      ),
                    ),
                    Text(
                      '$valueText ',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isTarget
                            ? null
                            : (Theme.of(context).textTheme.bodyLarge?.color
                                      ?.withOpacity(0.65) ??
                                  Colors.black54),
                      ),
                    ),
                    Text(
                      '(×${substat.totalUpgrades}回強化)',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Text(
              'スコア対象合計: ${result.currentScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 理論最大値セクション
  Widget _buildTheoreticalMaxSection() {
    final result = _simulationResult!;

    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, size: 20),
                SizedBox(width: 8),
                Text(
                  '理論最大値（選択サブオプション）',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '優先: ${result.primarySubstat.label}（残り${result.remainingEnhancements}回強化）',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.allSubstats.map((substat) {
              final theoreticalValue =
                  result.theoreticalValues[substat.propId] ?? 0.0;
              final isSelected = _selectedSubstatIds.contains(substat.propId);
              final isTarget = widget.scoreTargetPropIds.contains(
                substat.propId,
              );
              final isPrimary = substat.propId == result.primarySubstat.propId;

              // 実数値(攻撃力、防御力、HP、元素熟知)は%なし、その他は%あり
              final hasPercent =
                  substat.propId != 'FIGHT_PROP_ELEMENT_MASTERY' &&
                  substat.propId != 'FIGHT_PROP_ATTACK' &&
                  substat.propId != 'FIGHT_PROP_DEFENSE' &&
                  substat.propId != 'FIGHT_PROP_HP';

              String explanation = '';
              if (isPrimary) {
                final initial = substat.rollValues[0];
                final max = substat.maxRollValue;
                if (hasPercent) {
                  explanation =
                      '(初回値 ${initial.toStringAsFixed(1)}% + 最大値${max.toStringAsFixed(1)}% × ${result.remainingEnhancements}回)';
                } else {
                  explanation =
                      '(初回値 ${initial.toStringAsFixed(0)} + 最大値${max.toStringAsFixed(0)} × ${result.remainingEnhancements}回)';
                }
              } else if (isSelected) {
                explanation = '(初回値のみ)';
              } else {
                explanation = '(初回値)';
              }

              final valueText = hasPercent
                  ? '${theoreticalValue.toStringAsFixed(1)}%'
                  : theoreticalValue.toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '• ${substat.label}: ',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTarget
                                ? null
                                : (Theme.of(context).textTheme.bodyLarge?.color
                                          ?.withOpacity(0.65) ??
                                      Colors.black54),
                          ),
                        ),
                        Text(
                          valueText,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTarget
                                ? null
                                : (Theme.of(context).textTheme.bodyLarge?.color
                                          ?.withOpacity(0.65) ??
                                      Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '  $explanation',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Text(
              '再構築前スコア: ${result.currentScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '理論スコア: ${result.theoreticalMaxScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (result.isUpdatePossible)
              Text(
                '(${result.scoreIncrease >= 0 ? '+' : ''}${result.scoreIncrease.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 14,
                  color: result.scoreIncrease > 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 更新率セクション
  Widget _buildUpdateRateSection() {
    final result = _simulationResult!;

    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.percent, size: 20),
                const SizedBox(width: 8),
                Text(
                  '更新率（${result.rebuildType.label}）',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result.isUpdatePossible) ...[
              // プログレスバー
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: result.updateRate / 100,
                        minHeight: 20,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getUpdateRateColor(result.updateRate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${result.updateRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '成功: ${result.successPatternCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / ${result.totalPatternCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} パターン',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.8) ??
                      Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(${result.totalPatternCount}通りのパターンを評価)',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '現在 ${result.currentScore.toStringAsFixed(1)} → 理論 ${result.theoreticalMaxScore.toStringAsFixed(1)} (${result.scoreIncrease >= 0 ? '+' : ''}${result.scoreIncrease.toStringAsFixed(1)})',
                style: const TextStyle(fontSize: 14),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '更新不可',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '理論値でも現在を超えられません',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color
                                      ?.withOpacity(0.75) ??
                                  Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '理論スコア: ${result.theoreticalMaxScore.toStringAsFixed(1)} < 現在スコア: ${result.currentScore.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 更新率に応じた色を取得
  Color _getUpdateRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.lightGreen;
    if (rate >= 30) return Colors.orange;
    return Colors.red;
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

    final selectedSubstats = widget.summary.substats
        .where((s) => _selectedSubstatIds.contains(s.propId))
        .toList();

    // 希望サブオプションが2つ選択された時点で、全種別の更新率を事前計算
    if (_selectedRebuildType == null) {
      setState(() {
        _isCalculating = true;
        _updateRates.clear();
      });

      await Future.delayed(const Duration(milliseconds: 100));

      final newUpdateRates = <RebuildType, double>{};
      for (final type in RebuildType.values) {
        final result = _simulatorService.simulate(
          substat1: selectedSubstats[0],
          substat2: selectedSubstats[1],
          allSubstats: widget.summary.substats,
          rebuildType: type,
          initialSubstatCount: widget.summary.initialSubstatCount,
          scoreTargetPropIds: widget.scoreTargetPropIds,
        );
        newUpdateRates[type] = result.updateRate;
      }

      setState(() {
        _updateRates.addAll(newUpdateRates);
        _isCalculating = false;
      });
      return;
    }

    // 再構築種別が選択されている場合は、その種別のみ計算
    setState(() {
      _isCalculating = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final result = _simulatorService.simulate(
      substat1: selectedSubstats[0],
      substat2: selectedSubstats[1],
      allSubstats: widget.summary.substats,
      rebuildType: _selectedRebuildType!,
      initialSubstatCount: widget.summary.initialSubstatCount,
      scoreTargetPropIds: widget.scoreTargetPropIds,
    );

    setState(() {
      _simulationResult = result;
      _isCalculating = false;
    });
  }
}
