import 'package:flutter/material.dart';
import 'package:home_screen/home_screen.dart';
import 'package:reliquary_list_screen/reliquary_list_screen.dart';
import 'package:artifact_diagnoser/src/services/theme_service.dart';

/// アプリケーションのエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  await themeService.initialize();
  runApp(MainApp(themeService: themeService));
}

/// ThemeServiceを子Widgetに提供するInheritedWidget
class ThemeServiceProvider extends InheritedWidget {
  const ThemeServiceProvider({
    required this.themeService,
    required super.child,
    super.key,
  });

  final ThemeService themeService;

  static ThemeService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeServiceProvider>();
    assert(provider != null, 'ThemeServiceProvider not found in context');
    return provider!.themeService;
  }

  @override
  bool updateShouldNotify(ThemeServiceProvider oldWidget) {
    return themeService != oldWidget.themeService;
  }
}

/// メインアプリケーション
class MainApp extends StatelessWidget {
  const MainApp({required this.themeService, super.key});

  final ThemeService themeService;

  @override
  Widget build(BuildContext context) {
    return ThemeServiceProvider(
      themeService: themeService,
      child: ListenableBuilder(
        listenable: themeService,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '聖遺物診断機',
            themeMode: themeService.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'GISDK',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'GISDK',
              colorScheme:
                  ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ).copyWith(
                    surface: const Color(0xFF1E1E1E), // 暗いグレー
                    background: const Color(0xFF1E1E1E),
                  ),
              scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/reliquary-list': (context) => const ReliquaryListScreen(),
            },
          );
        },
      ),
    );
  }
}
