import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/github_settings_model.dart';
import '../../domain/usecases/github_usecases.dart';

class GitHubProvider extends ChangeNotifier {
  final GetGitHubSettingsUseCase _getSettingsUseCase;
  final SaveGitHubSettingsUseCase _saveSettingsUseCase;
  final UpdateGitHubEnabledUseCase _updateEnabledUseCase;
  final ValidateGitHubTokenUseCase _validateTokenUseCase;
  final GetGitHubUserInfoUseCase _getUserInfoUseCase;

  GitHubProvider({
    required GetGitHubSettingsUseCase getSettingsUseCase,
    required SaveGitHubSettingsUseCase saveSettingsUseCase,
    required UpdateGitHubEnabledUseCase updateEnabledUseCase,
    required ValidateGitHubTokenUseCase validateTokenUseCase,
    required GetGitHubUserInfoUseCase getUserInfoUseCase,
  }) : _getSettingsUseCase = getSettingsUseCase,
       _saveSettingsUseCase = saveSettingsUseCase,
       _updateEnabledUseCase = updateEnabledUseCase,
       _validateTokenUseCase = validateTokenUseCase,
       _getUserInfoUseCase = getUserInfoUseCase;

  GitHubSettingsModel? _settings;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userInfo;

  GitHubSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userInfo => _userInfo;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _getSettingsUseCase();
      if (_settings != null && _settings!.isEnabled) {
        await _loadUserInfo();
      }
    } catch (e) {
      _error = '設定の読み込みに失敗しました';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(String token, bool isEnabled) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSettings = GitHubSettingsModel(
        id: _settings?.id ?? 0,
        token: token,
        isEnabled: isEnabled,
      );

      await _saveSettingsUseCase(newSettings);
      _settings = newSettings;

      if (isEnabled) {
        await _loadUserInfo();
      } else {
        _userInfo = null;
      }
    } catch (e) {
      _error = '設定の保存に失敗しました: $e';
      print('GitHub settings save error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEnabled(bool isEnabled) async {
    if (_settings == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateEnabledUseCase(isEnabled);
      _settings = GitHubSettingsModel(
        id: _settings!.id,
        token: _settings!.token,
        isEnabled: isEnabled,
      );

      if (isEnabled) {
        await _loadUserInfo();
      } else {
        _userInfo = null;
      }
    } catch (e) {
      _error = '設定の更新に失敗しました';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      return await _validateTokenUseCase(token);
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadUserInfo() async {
    if (_settings == null || !_settings!.isEnabled) return;

    try {
      _userInfo = await _getUserInfoUseCase(_settings!.token);
    } catch (e) {
      // ユーザー情報の取得に失敗してもエラーにはしない
      _userInfo = null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
