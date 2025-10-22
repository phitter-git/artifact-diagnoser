import 'package:flutter/material.dart';
import 'package:artifact_diagnoser/src/services/user_data_service.dart';

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
        '/reliquary-list',
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
                Text(
                  '聖遺物診断機',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Artifact Diagnoser',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

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
