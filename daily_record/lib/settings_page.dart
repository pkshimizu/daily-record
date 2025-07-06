import 'package:daily_record/presentation/pages/github_settings_page.dart';
import 'package:daily_record/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 設定ページ
class SettingsPage extends StatefulWidget {
  /// コンストラクタ
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// 設定ページの状態管理
class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('設定'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: Consumer<SettingsProvider>(
      builder:
          (context, settingsProvider, child) => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // ダークモード設定
              Card(
                child: ListTile(
                  leading: Icon(
                    settingsProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('ダークモード'),
                  subtitle: const Text('アプリのテーマを切り替えます'),
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged:
                        (value) =>
                            settingsProvider.setDarkMode(isDarkMode: value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // GitHub連携設定
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('GitHub連携'),
                  subtitle: const Text('GitHubとの連携設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<GitHubSettingsPage>(
                        builder: (context) => const GitHubSettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // アプリ情報
              Card(
                child: Column(
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('アプリ情報'),
                      subtitle: Text('バージョン情報など'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('アプリ名: Daily Record'),
                          Text('バージョン: 1.0.0'),
                          Text('開発者: Your Name'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // その他の設定
              Card(
                child: Column(
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('その他の設定'),
                      subtitle: Text('追加の設定オプション'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text('今後追加予定の設定項目です。')],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    ),
  );
}
