import '../repositories/settings_repository.dart';

class GetDarkModeUseCase {
  final SettingsRepository _repository;

  GetDarkModeUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.getDarkMode();
  }
}
