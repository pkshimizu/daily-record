import 'dart:developer' as developer;

import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/data/models/github_activity_model.dart';
import 'package:daily_record/presentation/providers/github_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 日付詳細ページ
class DayDetailPage extends StatefulWidget {
  /// コンストラクタ
  const DayDetailPage({required this.selectedDate, super.key});

  /// 選択された日付
  final DateTime selectedDate;

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

/// 日付詳細ページの状態
class _DayDetailPageState extends State<DayDetailPage> {
  bool _isLoadingActivity = false;
  bool _isInitialLoading = true;
  List<GitHubActivityModel> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  /// アクティビティを読み込み
  Future<void> _loadActivities() async {
    setState(() {
      _isInitialLoading = true;
    });
    try {
      final dataSource = SettingsLocalDataSource();
      final activities = await dataSource.getGitHubActivities(
        widget.selectedDate,
      );
      setState(() {
        _activities = activities;
      });
    } catch (e) {
      // エラーハンドリング
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  /// GitHubアクティビティを取得
  Future<void> _fetchGitHubActivity() async {
    setState(() {
      _isLoadingActivity = true;
    });

    try {
      final provider = context.read<GitHubProvider>();

      // GitHub連携の状態をチェック
      if (!provider.isEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub連携が無効になっています。設定ページで有効にしてください。'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (provider.settings == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub設定が保存されていません。設定ページでトークンを入力してください。'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (provider.settings!.token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHubトークンが設定されていません。設定ページでトークンを入力してください。'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final activities = await provider.getUserActivity(widget.selectedDate);

      // デバッグログ
      developer.log(
        'GitHub API Response: ${activities.length} activities received',
        name: 'DayDetailPage',
      );

      // プロバイダーのエラーをチェック
      if (provider.error != null) {
        developer.log(
          'GitHub Provider Error: ${provider.error}',
          name: 'DayDetailPage',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GitHub API エラー: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (activities.isNotEmpty) {
        final List<GitHubActivityModel> activityModels = [];
        for (final activity in activities) {
          try {
            final repo = activity['repo'] as Map<String, dynamic>?;
            final createdAtStr = activity['created_at'] as String?;
            if (createdAtStr == null) continue;
            final createdAt = DateTime.tryParse(createdAtStr);
            if (createdAt == null) continue;
            final eventType = activity['type'] as String? ?? '';
            final repository = repo?['name'] as String? ?? '';
            final title = _getActivityTitle(activity);
            final description = _getActivityDescription(activity);
            final url = (activity['html_url'] as String?) ?? '';
            activityModels.add(
              GitHubActivityModel(
                id: 0,
                date: widget.selectedDate,
                eventType: eventType,
                repository: repository,
                title: title,
                description: description,
                url: url,
                createdAt: createdAt,
              ),
            );
          } catch (e) {
            // 1件ごとのパースエラーは無視
            continue;
          }
        }
        if (activityModels.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('この日の有効なアクティビティはありません'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        // DBに保存
        final dataSource = SettingsLocalDataSource();
        await dataSource.saveGitHubActivities(activityModels);
        _activities = activityModels;
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activityModels.length}件のアクティビティを取得・保存しました'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('この日のアクティビティはありません'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      // エラーの詳細をログに出力
      developer.log(
        'Error fetching GitHub activity: $e',
        name: 'DayDetailPage',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('アクティビティの取得・保存に失敗しました: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingActivity = false;
      });
    }
  }

  /// アクティビティのタイトルを取得
  String _getActivityTitle(Map<String, dynamic> activity) {
    final type = activity['type'] as String? ?? '';

    switch (type) {
      case 'PushEvent':
        return 'コードをプッシュ';
      case 'CreateEvent':
        return 'リポジトリを作成';
      case 'ForkEvent':
        return 'リポジトリをフォーク';
      case 'IssuesEvent':
        return 'Issueを${activity['payload']?['action'] == 'opened' ? '作成' : ''}';
      case 'PullRequestEvent':
        return 'Pull Requestを${activity['payload']?['action'] == 'opened' ? '作成' : ''}';
      default:
        return type;
    }
  }

  /// アクティビティの説明を取得
  String _getActivityDescription(Map<String, dynamic> activity) {
    final type = activity['type'] as String? ?? '';
    final repo = activity['repo'] as Map<String, dynamic>?;

    switch (type) {
      case 'PushEvent':
        final commits = activity['payload']?['commits'] as List<dynamic>? ?? [];
        return '${repo?['name'] ?? ''}に${commits.length}件のコミット';
      case 'CreateEvent':
        return '${repo?['name'] ?? ''}を作成';
      case 'ForkEvent':
        return '${repo?['name'] ?? ''}をフォーク';
      case 'IssuesEvent':
        final issue = activity['payload']?['issue'] as Map<String, dynamic>?;
        return '${repo?['name'] ?? ''}: ${issue?['title'] ?? ''}';
      case 'PullRequestEvent':
        final pr =
            activity['payload']?['pull_request'] as Map<String, dynamic>?;
        return '${repo?['name'] ?? ''}: ${pr?['title'] ?? ''}';
      default:
        return '${repo?['name'] ?? ''}でアクティビティ';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        '${widget.selectedDate.year}年'
        '${widget.selectedDate.month}月'
        '${widget.selectedDate.day}日',
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        TextButton.icon(
          onPressed: _goToPreviousDay,
          icon: const Icon(Icons.chevron_left),
          label: const Text('前の日'),
        ),
        TextButton.icon(
          onPressed: _goToNextDay,
          icon: const Text('次の日'),
          label: const Icon(Icons.chevron_right),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          // GitHubアクティビティ取得ボタン
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'GitHubアクティビティ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoadingActivity ? null : _fetchGitHubActivity,
                    icon:
                        _isLoadingActivity
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.download),
                    label: Text(_isLoadingActivity ? '取得中...' : 'データ取得'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // アクティビティ一覧またはローディング・空表示
          Expanded(
            child:
                _isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _activities.isNotEmpty
                    ? Card(
                      child: ListView.builder(
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final activity = _activities[index];
                          final timeStr =
                              '${activity.createdAt.hour.toString().padLeft(2, '0')}:${activity.createdAt.minute.toString().padLeft(2, '0')}';
                          return ListTile(
                            leading: const Icon(Icons.code),
                            title: Text(activity.title),
                            subtitle: Text(
                              '$timeStr - ${activity.description}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // URLを開く処理（必要に応じて実装）
                            },
                          );
                        },
                      ),
                    )
                    : const Center(child: Text('この日のアクティビティはありません')),
          ),
        ],
      ),
    ),
  );

  /// 前の日に遷移
  void _goToPreviousDay() {
    final previousDay = widget.selectedDate.subtract(const Duration(days: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<DayDetailPage>(
        builder: (context) => DayDetailPage(selectedDate: previousDay),
      ),
    );
  }

  /// 次の日に遷移
  void _goToNextDay() {
    final nextDay = widget.selectedDate.add(const Duration(days: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<DayDetailPage>(
        builder: (context) => DayDetailPage(selectedDate: nextDay),
      ),
    );
  }
}
