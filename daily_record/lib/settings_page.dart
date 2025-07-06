import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _githubSync = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              // 一般セクション
              _buildSectionHeader('一般'),
              _buildSwitchTile(
                title: 'ダークモード',
                subtitle: 'ダークテーマを有効にする',
                value: settingsProvider.isDarkMode,
                onChanged: (value) {
                  settingsProvider.toggleDarkMode();
                },
                icon: Icons.dark_mode,
              ),

              const SizedBox(height: 20),

              // 連携セクション
              _buildSectionHeader('連携'),
              _buildSwitchTile(
                title: 'GitHub連携',
                subtitle: 'GitHubリポジトリと同期する',
                value: _githubSync,
                onChanged: (value) {
                  setState(() {
                    _githubSync = value;
                  });
                },
                icon: Icons.code,
              ),

              const SizedBox(height: 20),

              // その他のセクション
              _buildSectionHeader('その他'),
              _buildListTile(
                title: 'アプリについて',
                subtitle: 'バージョン情報',
                icon: Icons.info,
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アプリについて'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Record'),
              SizedBox(height: 8),
              Text('バージョン: 1.0.0'),
              SizedBox(height: 8),
              Text('日々の記録を簡単に管理できるアプリです。'),
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
}
