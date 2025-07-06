import 'dart:developer' as developer;

import 'package:daily_record/data/models/github_activity_model.dart';
import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// ローカル設定データの管理を担当するデータソース
class SettingsLocalDataSource {
  static Database? _database;

  /// データベースインスタンスを取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'daily_record.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 設定テーブルを作成
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // GitHub設定テーブルを作成
    await db.execute('''
      CREATE TABLE github_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // GitHubアクティビティテーブルを作成
    await db.execute('''
      CREATE TABLE github_activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        event_type TEXT NOT NULL,
        repository TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        url TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // デフォルト設定を挿入
    await db.insert('settings', {'key': 'dark_mode', 'value': 'false'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // GitHub設定テーブルを追加
      await db.execute('''
        CREATE TABLE github_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          token TEXT NOT NULL,
          is_enabled INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 3) {
      // 古いテーブル構造を削除して新しい構造に再作成
      await db.execute('DROP TABLE IF EXISTS github_settings');
      await db.execute('''
        CREATE TABLE github_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          token TEXT NOT NULL,
          is_enabled INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 4) {
      // GitHubアクティビティテーブルを追加
      await db.execute('''
        CREATE TABLE github_activities(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          event_type TEXT NOT NULL,
          repository TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          url TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  /// 設定値を取得
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  /// 設定値を保存
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// GitHub設定を取得
  Future<GitHubSettingsModel?> getGitHubSettings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('github_settings');

      if (maps.isNotEmpty) {
        return GitHubSettingsModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      developer.log(
        'Error getting GitHub settings: $e',
        name: 'SettingsLocalDataSource',
      );
      return null;
    }
  }

  /// GitHub設定を保存
  Future<void> saveGitHubSettings(GitHubSettingsModel settings) async {
    try {
      developer.log(
        'Saving GitHub settings: ${settings.toMap()}',
        name: 'SettingsLocalDataSource',
      );

      final db = await database;

      // 既存の設定を確認
      final existingSettings = await getGitHubSettings();

      if (existingSettings != null) {
        // 既存の設定を更新
        await db.update(
          'github_settings',
          settings.toMap(),
          where: 'id = ?',
          whereArgs: [existingSettings.id],
        );
        developer.log(
          'Updated existing GitHub settings',
          name: 'SettingsLocalDataSource',
        );
      } else {
        // 新しい設定を挿入
        final id = await db.insert('github_settings', settings.toMap());
        developer.log(
          'Inserted new GitHub settings with id: $id',
          name: 'SettingsLocalDataSource',
        );
      }
    } catch (e) {
      developer.log(
        'Error saving GitHub settings: $e',
        name: 'SettingsLocalDataSource',
      );
      throw Exception('GitHub設定の保存に失敗しました: $e');
    }
  }

  /// GitHub連携有効フラグを更新
  Future<void> updateGitHubEnabled({required bool isEnabled}) async {
    try {
      final db = await database;
      final existingSettings = await getGitHubSettings();

      if (existingSettings != null) {
        await db.update(
          'github_settings',
          {'is_enabled': isEnabled ? 1 : 0},
          where: 'id = ?',
          whereArgs: [existingSettings.id],
        );
      } else {
        // 設定が存在しない場合は新規作成
        await saveGitHubSettings(
          GitHubSettingsModel(id: 0, token: '', isEnabled: isEnabled),
        );
      }
    } catch (e) {
      developer.log(
        'Error updating GitHub enabled: $e',
        name: 'SettingsLocalDataSource',
      );
      throw Exception('GitHub設定の更新に失敗しました: $e');
    }
  }

  /// DBをクローズ
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// GitHubアクティビティを保存
  Future<void> saveGitHubActivities(
    List<GitHubActivityModel> activities,
  ) async {
    try {
      final db = await database;

      // 既存のアクティビティを削除（同じ日付のもの）
      if (activities.isNotEmpty) {
        final firstActivity = activities.first;
        final dateStr = firstActivity.date.toIso8601String().split('T')[0];

        await db.delete(
          'github_activities',
          where: 'date = ?',
          whereArgs: [dateStr],
        );

        developer.log(
          'Deleted existing activities for date: $dateStr',
          name: 'SettingsLocalDataSource',
        );
      }

      // 新しいアクティビティを保存
      final batch = db.batch();

      for (final activity in activities) {
        // IDを除外して保存（AUTOINCREMENTで自動生成）
        final activityMap = activity.toMap();
        activityMap.remove('id');
        // dateカラムは日付のみ（YYYY-MM-DD）で保存
        activityMap['date'] = activity.date.toIso8601String().split('T')[0];
        batch.insert('github_activities', activityMap);
      }

      await batch.commit(noResult: true);
      developer.log(
        'Saved ${activities.length} GitHub activities',
        name: 'SettingsLocalDataSource',
      );
    } catch (e) {
      developer.log(
        'Error saving GitHub activities: $e',
        name: 'SettingsLocalDataSource',
      );
      throw Exception('GitHubアクティビティの保存に失敗しました: $e');
    }
  }

  /// 指定された日付のGitHubアクティビティを取得
  Future<List<GitHubActivityModel>> getGitHubActivities(DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> maps = await db.query(
        'github_activities',
        where: 'date = ?',
        whereArgs: [dateStr],
        orderBy: 'created_at DESC',
      );

      return maps.map(GitHubActivityModel.fromMap).toList();
    } catch (e) {
      developer.log(
        'Error getting GitHub activities: $e',
        name: 'SettingsLocalDataSource',
      );
      return [];
    }
  }

  /// 指定された日付のGitHubアクティビティを削除
  Future<void> deleteGitHubActivities(DateTime date) async {
    try {
      final db = await database;
      final dateStr = date.toIso8601String().split('T')[0];

      await db.delete(
        'github_activities',
        where: 'date = ?',
        whereArgs: [dateStr],
      );

      developer.log(
        'Deleted GitHub activities for date: $dateStr',
        name: 'SettingsLocalDataSource',
      );
    } catch (e) {
      developer.log(
        'Error deleting GitHub activities: $e',
        name: 'SettingsLocalDataSource',
      );
      throw Exception('GitHubアクティビティの削除に失敗しました: $e');
    }
  }
}
