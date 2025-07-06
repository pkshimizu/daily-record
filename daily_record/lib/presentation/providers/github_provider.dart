import 'dart:developer' as developer;

import 'package:daily_record/data/models/github_activity_model.dart';
import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:daily_record/domain/repositories/github_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// GitHub設定の状態管理
class GitHubProvider extends ChangeNotifier {
  /// コンストラクタ
  GitHubProvider(this._repository) {
    _initialize();
  }

  final GitHubRepository _repository;
  GitHubSettingsModel? _settings;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  /// 設定
  GitHubSettingsModel? get settings => _settings;

  /// ローディング状態
  bool get isLoading => _isLoading;

  /// エラーメッセージ
  String? get error => _error;

  /// GitHub連携が有効かどうか
  bool get isEnabled => _settings?.isEnabled ?? false;

  /// 初期化完了フラグ
  bool get isInitialized => _isInitialized;

  /// 初期化処理
  Future<void> _initialize() async {
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// 設定を読み込み
  Future<void> _loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _repository.getGitHubSettings();
    } catch (e) {
      _error = '設定の読み込みに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 設定を保存
  Future<void> saveSettings(GitHubSettingsModel settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveGitHubSettings(settings);
      _settings = settings;
    } catch (e) {
      _error = '設定の保存に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// トークンを検証
  Future<bool> validateToken(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.validateToken(token);
    } catch (e) {
      _error = 'トークンの検証に失敗しました: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ユーザー情報を取得
  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.getUserInfo(token);
    } catch (e) {
      _error = 'ユーザー情報の取得に失敗しました: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// リポジトリを検証
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.validateRepository(token, username, repository);
    } catch (e) {
      _error = 'リポジトリの検証に失敗しました: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ファイルを作成
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.createFile(
        token,
        username,
        repository,
        path,
        content,
        message,
      );
    } catch (e) {
      _error = 'ファイルの作成に失敗しました: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ファイル内容を取得
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.getFileContent(
        token,
        username,
        repository,
        path,
      );
    } catch (e) {
      _error = 'ファイル内容の取得に失敗しました: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ユーザーアクティビティを取得
  Future<List<Map<String, dynamic>>> getUserActivity(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_settings == null || !_settings!.isEnabled) {
        _error = 'GitHub連携が有効になっていません';
        return [];
      }

      developer.log(
        'Fetching GitHub activity for date: ${date.toIso8601String()}',
        name: 'GitHubProvider',
      );

      final result = await _repository.getUserActivity(_settings!.token, date);

      developer.log(
        'GitHub activity fetch result: ${result.length} activities',
        name: 'GitHubProvider',
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error in getUserActivity: $e',
        name: 'GitHubProvider',
        error: e,
        stackTrace: stackTrace,
      );

      _error = 'アクティビティの取得に失敗しました: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GitHubアクティビティを保存
  Future<void> saveGitHubActivities(
    List<GitHubActivityModel> activities,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveGitHubActivities(activities);
    } catch (e) {
      _error = 'アクティビティの保存に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 指定された日付のGitHubアクティビティを取得
  Future<List<GitHubActivityModel>> getGitHubActivities(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.getGitHubActivities(date);
    } catch (e) {
      _error = 'アクティビティの取得に失敗しました: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 指定された日付のGitHubアクティビティを削除
  Future<void> deleteGitHubActivities(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteGitHubActivities(date);
    } catch (e) {
      _error = 'アクティビティの削除に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// エラーをクリア
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
