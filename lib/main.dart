import 'package:flutter/material.dart';
import 'package:demo_page/demo_page.dart';

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
      theme: ThemeData(useMaterial3: true, fontFamily: 'GISDK'),
      home: const DemoPage(),
    );
  }
}
