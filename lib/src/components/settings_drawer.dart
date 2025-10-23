import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

          const Divider(),

          // クレジット表記
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '原神 © COGNOSPHERE.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '© ウェブサイトで使用されているGenshin Impactのすべてのゲームアセットの権利は、miHoYo Ltd.およびCognosphere Pte., Ltd.が保有しています。その他の財産はそれぞれの所有者に帰属します。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 12),
                // EnkaNetworkロゴ
                Image.asset(
                  'assets/image/enka_network.webp',
                  height: 32,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 12),
                Text(
                  'このサイトはEnka.NetworkのAPIを利用して聖遺物情報を取得しています。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          const Divider(),

          // 作成者情報
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '© katuoneko',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse('https://x.com/katuoneko_');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/image/x_logo_white.png'
                            : 'assets/image/x_logo_black.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'https://x.com/katuoneko_',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}
