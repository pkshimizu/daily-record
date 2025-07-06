import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:daily_record/presentation/providers/github_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// GitHub設定ページ
class GitHubSettingsPage extends StatefulWidget {
  /// コンストラクタ
  const GitHubSettingsPage({super.key});

  @override
  State<GitHubSettingsPage> createState() => _GitHubSettingsPageState();
}

/// GitHub設定ページの状態管理
class _GitHubSettingsPageState extends State<GitHubSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    final provider = context.read<GitHubProvider>();
    final settings = provider.settings;
    if (settings != null) {
      _tokenController.text = settings.token;
    }
  }

  Future<void> _validateToken() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final provider = context.read<GitHubProvider>();
      final isValid = await provider.validateToken(
        _tokenController.text.trim(),
      );

      if (isValid) {
        setState(() {
          _successMessage = 'トークンが有効です！';
        });
      } else {
        setState(() {
          _errorMessage = 'トークンが無効です。正しいPersonal Access Tokenを入力してください。';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'トークンの検証中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final provider = context.read<GitHubProvider>();
      final currentSettings = provider.settings;
      final newSettings = GitHubSettingsModel(
        id: currentSettings?.id ?? 0,
        token: _tokenController.text.trim(),
        isEnabled: true,
      );
      await provider.saveSettings(newSettings);

      setState(() {
        _successMessage = '設定が保存されました！';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '設定の保存中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('GitHub Personal Access Tokenについて'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Personal Access Tokenを取得する手順:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. GitHubにログイン'),
                  Text('2. 右上のプロフィールアイコン → Settings'),
                  Text('3. 左サイドバーの「Developer settings」'),
                  Text('4. 「Personal access tokens」→「Tokens (classic)」'),
                  Text(
                    '5. 「Generate new token」→「Generate new token (classic)」',
                  ),
                  Text('6. Noteに「Daily Record」など分かりやすい名前を入力'),
                  Text('7. Expirationは「No expiration」または適切な期間を選択'),
                  Text('8. Select scopesで「repo」にチェック'),
                  Text('9. 「Generate token」をクリック'),
                  Text('10. 表示されたトークンをコピーしてこのアプリに入力'),
                  SizedBox(height: 16),
                  Text(
                    '注意: トークンは一度しか表示されません。必ずコピーしてからページを閉じてください。',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('GitHub設定'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // エラーメッセージ
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // 成功メッセージ
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ),

            // トークン入力フィールド
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Personal Access Token',
                hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'トークンを入力してください';
                }
                if (!value.trim().startsWith('ghp_')) {
                  return '有効なPersonal Access Tokenを入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ヘルプボタン
            OutlinedButton.icon(
              onPressed: _showHelpDialog,
              icon: const Icon(Icons.help_outline),
              label: const Text('トークンの取得方法'),
            ),

            const SizedBox(height: 16),

            // ボタン群
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateToken,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('トークンを検証'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSettings,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('設定を保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
