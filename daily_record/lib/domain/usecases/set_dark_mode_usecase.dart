import 'package:daily_record/domain/repositories/settings_repository.dart';

/// ダークモード設定ユースケース
class SetDarkModeUseCase {
  /// コンストラクタ
  SetDarkModeUseCase(this._repository);

  final SettingsRepository _repository;

  /// ダークモード設定を変更
  Future<void> execute({required bool isDarkMode}) async =>
      _repository.setDarkMode(isDarkMode: isDarkMode);
}
