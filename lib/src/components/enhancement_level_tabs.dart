import 'package:flutter/material.dart';

/// 聖遺物の強化段階を切り替えるタブUI
///
/// +0/+4/+8/+12/+16/+20の6段階を選択できます。
class EnhancementLevelTabs extends StatelessWidget {
  const EnhancementLevelTabs({
    super.key,
    required this.currentLevel,
    required this.maxLevel,
    this.minLevel = 0,
    required this.onLevelChanged,
  });

  /// 現在選択されている強化レベル（0, 4, 8, 12, 16, 20）
  final int currentLevel;

  /// 聖遺物の最大強化レベル（通常は20）
  final int maxLevel;

  /// 聖遺物の最小強化レベル（初期サブステータス3個の場合は4）
  final int minLevel;

  /// 強化レベルが変更されたときのコールバック
  final ValueChanged<int> onLevelChanged;

  /// 利用可能な強化レベルのリスト
  static const List<int> _availableLevels = [0, 4, 8, 12, 16, 20];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
        segments: _availableLevels
            .where((level) => level >= minLevel && level <= maxLevel)
            .map(
              (level) => ButtonSegment<int>(
                value: level,
                label: Text('+$level'),
                enabled: level >= minLevel && level <= maxLevel,
              ),
            )
            .toList(),
        selected: {currentLevel},
        onSelectionChanged: (Set<int> newSelection) {
          onLevelChanged(newSelection.first);
        },
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(theme.textTheme.labelLarge),
        ),
      ),
    );
  }
}
