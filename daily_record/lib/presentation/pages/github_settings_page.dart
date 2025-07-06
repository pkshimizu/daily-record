import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/github_provider.dart';

class GitHubSettingsPage extends StatefulWidget {
  const GitHubSettingsPage({super.key});

  @override
  State<GitHubSettingsPage> createState() => _GitHubSettingsPageState();
}

class _GitHubSettingsPageState extends State<GitHubSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isEnabled = false;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final provider = context.read<GitHubProvider>();
    await provider.loadSettings();

    final settings = provider.settings;
    if (settings != null) {
      setState(() {
        _tokenController.text = settings.token;
        _isEnabled = settings.isEnabled;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GitHubProvider>();
    await provider.saveSettings(_tokenController.text, _isEnabled);

    if (provider.error == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.error!)));
      }
    }
  }

  Future<void> _validateToken() async {
    if (_tokenController.text.isEmpty) return;

    setState(() {
      _isValidating = true;
    });

    print('=== Token Validation Debug ===');
    print('Token length: ${_tokenController.text.length}');
    print('Token starts with: ${_tokenController.text.substring(0, 4)}');
    print('Token contains spaces: ${_tokenController.text.contains(' ')}');

    final provider = context.read<GitHubProvider>();
    final isValid = await provider.validateToken(_tokenController.text);

    setState(() {
      _isValidating = false;
    });

    print('Validation result: $isValid');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isValid ? 'トークンが有効です' : 'トークンが無効です。トークンの形式と権限を確認してください。',
          ),
          backgroundColor: isValid ? Colors.green : Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '詳細',
            onPressed: () {
              _showTokenValidationHelp();
            },
          ),
        ),
      );
    }
  }

  void _showTokenValidationHelp() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('トークン検証について'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Access Tokenが無効と判定される場合:'),
              SizedBox(height: 8),
              Text('• トークンが正しくコピーされているか確認'),
              Text('• トークンに適切な権限が付与されているか確認'),
              Text('• トークンの有効期限が切れていないか確認'),
              SizedBox(height: 8),
              Text('必要な権限:'),
              Text('• repo (リポジトリへのアクセス)'),
              Text('• user (ユーザー情報の読み取り)'),
              SizedBox(height: 8),
              Text('トークン形式: ghp_xxxxxxxxxxxxxxxxxxxx'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub連携設定'),
        actions: [
          TextButton(onPressed: _saveSettings, child: const Text('保存')),
        ],
      ),
      body: Consumer<GitHubProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Access Token',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tokenController,
                          decoration: const InputDecoration(
                            hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'トークンを入力してください';
                            }
                            // GitHub Personal Access Tokenの形式をチェック
                            final tokenPattern = RegExp(r'^ghp_[a-zA-Z0-9]+$');
                            if (!tokenPattern.hasMatch(value.trim())) {
                              return 'トークンの形式が正しくありません (ghp_で始まる必要があります)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isValidating ? null : _validateToken,
                        child:
                            _isValidating
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('検証'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Personal Access Tokenの取得方法:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. GitHubにログイン\n'
                    '2. Settings > Developer settings > Personal access tokens\n'
                    '3. Generate new token (classic)\n'
                    '4. 必要な権限を選択（repo, user等）\n'
                    '5. トークンを生成してコピー',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('GitHub連携を有効にする'),
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  ),
                  if (provider.userInfo != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '連携中のユーザー情報:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ユーザー名: ${provider.userInfo!['login']}'),
                            Text('表示名: ${provider.userInfo!['name'] ?? '未設定'}'),
                            Text(
                              'メール: ${provider.userInfo!['email'] ?? '非公開'}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
