import 'package:daily_record/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';

/// 設定の状態管理
class SettingsProvider extends ChangeNotifier {
  /// コンストラクタ
  SettingsProvider(this._repository) {
    _loadDarkMode();
  }

  final SettingsRepository _repository;
  bool _isDarkMode = false;
  bool _isLoading = false;

  /// ダークモード設定
  bool get isDarkMode => _isDarkMode;

  /// ローディング状態
  bool get isLoading => _isLoading;

  /// ダークモード設定を読み込み
  Future<void> _loadDarkMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isDarkMode = await _repository.getDarkMode();
    } catch (e) {
      // エラーの場合はデフォルト値を使用
      _isDarkMode = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ダークモード設定を変更
  Future<void> setDarkMode({required bool isDarkMode}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.setDarkMode(isDarkMode: isDarkMode);
      _isDarkMode = isDarkMode;
    } catch (e) {
      // エラーの場合は元の値に戻す
      _isDarkMode = !isDarkMode;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
