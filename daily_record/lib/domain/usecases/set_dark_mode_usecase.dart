import '../repositories/settings_repository.dart';

class SetDarkModeUseCase {
  final SettingsRepository _repository;

  SetDarkModeUseCase(this._repository);

  Future<void> execute(bool isDarkMode) async {
    await _repository.setDarkMode(isDarkMode);
  }
}
