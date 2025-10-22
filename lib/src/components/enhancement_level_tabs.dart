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

    // 利用可能なレベルをフィルタリング
    final availableLevels = _availableLevels
        .where((level) => level >= minLevel && level <= maxLevel)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面幅に応じてボタンのサイズを調整
        final buttonWidth = constraints.maxWidth / availableLevels.length;
        final useFixedWidth = buttonWidth > 60; // 60px以上なら固定幅を使用

        return useFixedWidth
            ? Row(
                children: availableLevels
                    .map((level) => Expanded(child: _buildButton(level, theme)))
                    .toList(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableLevels
                      .map(
                        (level) => SizedBox(
                          width: 60,
                          child: _buildButton(level, theme),
                        ),
                      )
                      .toList(),
                ),
              );
      },
    );
  }

  /// ボタンを構築
  Widget _buildButton(int level, ThemeData theme) {
    final isSelected = currentLevel == level;
    final isEnabled = level >= minLevel && level <= maxLevel;

    return InkWell(
      onTap: isEnabled ? () => onLevelChanged(level) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.zero,
        ),
        child: Center(
          child: Text(
            '+$level',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isEnabled
                  ? (isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
