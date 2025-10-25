import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/services/user_data_service.dart';
import 'package:artifact_diagnoser/src/components/settings_drawer.dart';
import 'package:artifact_diagnoser/main.dart';

/// ホーム画面（UID入力）
///
/// ユーザーのUIDを入力し、聖遺物データを読み込む画面です。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _uidController = TextEditingController();
  final _userDataService = UserDataService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  /// UID入力のバリデーション
  String? _validateUid(String? value) {
    if (value == null || value.isEmpty) {
      return 'UIDを入力してください';
    }
    if (value.length != 9 && value.length != 10) {
      return 'UIDは9～10桁の数字です';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'UIDは数字のみです';
    }
    return null;
  }

  /// データ読み込み処理
  Future<void> _handleLoadData() async {
    final uid = _uidController.text;
    final validationError = _validateUid(uid);

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // UserDataServiceを使ってデータ取得
      final userData = await _userDataService.fetchUserData(uid);

      if (!mounted) return;

      // 聖遺物一覧画面に遷移（userDataを渡す）
      Navigator.pushNamed(
        context,
        '/artifact-list',
        arguments: {'uid': uid, 'userData': userData},
      );
    } on UserDataServiceException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'データの読み込みに失敗しました';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              tooltip: '設定',
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(themeService: ThemeServiceProvider.of(context)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // タイトル
                Column(
                  children: [
                    Text(
                      '聖遺物診断機',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '再構築シミュレーター',
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Artifact Diagnoser',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 説明文
                Card(
                  elevation: 0,
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '聖遺物の初期値・強化履歴を詳細分析',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_fix_high,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '聖啓の塵の再構築を何度でもシミュレーション',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '再構築のスコア更新率を比較して最適な投資先を判断',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // UID入力フィールド
                Text(
                  'UIDを入力してください',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uidController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: '123456789',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLoadData(),
                ),
                const SizedBox(height: 16),

                // 読み込みボタン
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLoadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('読み込み', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // ヒント表示
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'UIDはゲーム内で確認できます',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
