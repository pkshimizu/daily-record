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
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSettings();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    final provider = context.read<GitHubProvider>();

    // 初期化が完了するまで待機
    while (!provider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final settings = provider.settings;
    if (settings != null) {
      _tokenController.text = settings.token;
      setState(() {
        _isEnabled = settings.isEnabled;
      });
    }
  }

  Future<void> _validateToken() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<GitHubProvider>();
      final isValid = await provider.validateToken(
        _tokenController.text.trim(),
      );

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('トークンが有効です！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('トークンが無効です。正しいPersonal Access Tokenを入力してください。'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('トークンの検証中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    });

    try {
      final provider = context.read<GitHubProvider>();
      final currentSettings = provider.settings;
      final newSettings = GitHubSettingsModel(
        id: currentSettings?.id ?? 0,
        token: _tokenController.text.trim(),
        isEnabled: _isEnabled,
      );
      await provider.saveSettings(newSettings);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('設定が保存されました！'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('設定の保存中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    body: Consumer<GitHubProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('設定を読み込み中...'),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                // GitHub連携の有効/無効設定
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.power_settings_new),
                    title: const Text('GitHub連携'),
                    subtitle: const Text('GitHubとの連携を有効/無効にします'),
                    trailing: Switch(
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),
                  ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('設定を保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
