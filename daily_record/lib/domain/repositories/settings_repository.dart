/// 設定リポジトリのインターフェース
abstract class SettingsRepository {
  /// ダークモード取得
  Future<bool> getDarkMode();

  /// ダークモード設定
  Future<void> setDarkMode({required bool isDarkMode});
}
