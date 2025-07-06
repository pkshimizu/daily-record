import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<bool> getDarkMode() async {
    final value = await _localDataSource.getSetting('dark_mode');
    return value == 'true';
  }

  @override
  Future<void> setDarkMode(bool isDarkMode) async {
    await _localDataSource.setSetting('dark_mode', isDarkMode.toString());
  }
}
