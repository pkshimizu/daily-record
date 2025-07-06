import 'package:flutter/foundation.dart';

import '../../domain/usecases/get_dark_mode_usecase.dart';
import '../../domain/usecases/set_dark_mode_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final GetDarkModeUseCase _getDarkModeUseCase;
  final SetDarkModeUseCase _setDarkModeUseCase;

  bool _isDarkMode = false;
  bool _isLoading = false;

  SettingsProvider(this._getDarkModeUseCase, this._setDarkModeUseCase);

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  Future<void> loadDarkMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isDarkMode = await _getDarkModeUseCase.execute();
    } catch (e) {
      // エラーハンドリング
      debugPrint('Failed to load dark mode setting: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      await _setDarkModeUseCase.execute(_isDarkMode);
    } catch (e) {
      // エラーが発生した場合は元に戻す
      _isDarkMode = !_isDarkMode;
      notifyListeners();
      debugPrint('Failed to save dark mode setting: $e');
    }
  }
}
