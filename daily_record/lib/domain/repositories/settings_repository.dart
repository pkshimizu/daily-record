abstract class SettingsRepository {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool isDarkMode);
}
