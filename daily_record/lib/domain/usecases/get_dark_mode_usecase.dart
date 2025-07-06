import 'package:daily_record/domain/repositories/settings_repository.dart';

/// ダークモード取得ユースケース
class GetDarkModeUseCase {
  /// コンストラクタ
  GetDarkModeUseCase(this._repository);

  final SettingsRepository _repository;

  /// ダークモード設定を取得
  Future<bool> execute() async => _repository.getDarkMode();
}
