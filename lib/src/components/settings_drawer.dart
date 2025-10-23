import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/services/theme_service.dart';

/// 設定ドロワー（右側）
///
/// アプリケーションの設定を行うための右側ドロワーです。
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({required this.themeService, super.key});

  final ThemeService themeService;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ヘッダー
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.settings,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  '設定',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // 表示設定セクション
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '表示設定',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // ダークモード切り替え
          ListenableBuilder(
            listenable: themeService,
            builder: (context, _) {
              // ThemeMode.systemの場合、MediaQueryからシステム設定を取得
              bool isDarkMode;
              if (themeService.themeMode == ThemeMode.system) {
                isDarkMode =
                    MediaQuery.of(context).platformBrightness ==
                    Brightness.dark;
              } else {
                isDarkMode = themeService.isDarkMode;
              }

              return SwitchListTile(
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: Text(
                  'ダークモード',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  isDarkMode ? 'オン' : 'オフ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: isDarkMode,
                onChanged: (value) {
                  themeService.toggleDarkMode(value);
                },
              );
            },
          ),

          const Divider(),

          // アプリ情報セクション
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'アプリ情報',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('バージョン', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text(
              '0.1.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            enabled: false,
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: Text('ライセンス', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '聖遺物診断機',
                applicationVersion: '0.1.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
