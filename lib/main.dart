import 'package:flutter/material.dart';
import 'package:home_screen/home_screen.dart';
import 'package:reliquary_list_screen/reliquary_list_screen.dart';

/// アプリケーションのエントリーポイント
void main() {
  runApp(const MainApp());
}

/// メインアプリケーション
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '聖遺物診断器',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'GISDK',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/reliquary-list': (context) => const ReliquaryListScreen(),
      },
    );
  }
}
