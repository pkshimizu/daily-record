import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/domain/repositories/settings_repository.dart';

/// 設定リポジトリの実装
class SettingsRepositoryImpl implements SettingsRepository {
  /// コンストラクタ
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  /// 設定を取得
  Future<String?> getSetting(String key) async =>
      _localDataSource.getSetting(key);

  /// 設定を保存
  Future<void> setSetting(String key, String value) async =>
      _localDataSource.setSetting(key, value);

  /// ダークモード設定を取得
  @override
  Future<bool> getDarkMode() async {
    final value = await _localDataSource.getSetting('dark_mode');
    return value == 'true';
  }

  /// ダークモード設定
  @override
  Future<void> setDarkMode({required bool isDarkMode}) async {
    await _localDataSource.setSetting('dark_mode', isDarkMode.toString());
  }
}
