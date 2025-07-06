import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:daily_record/domain/repositories/github_repository.dart';

/// GitHub設定取得ユースケース
class GetGitHubSettingsUseCase {
  /// コンストラクタ
  GetGitHubSettingsUseCase(this._repository);

  final GitHubRepository _repository;

  /// GitHub設定を取得
  Future<GitHubSettingsModel?> execute() async =>
      _repository.getGitHubSettings();
}

/// GitHub設定保存ユースケース
class SaveGitHubSettingsUseCase {
  /// コンストラクタ
  SaveGitHubSettingsUseCase(this._repository);

  final GitHubRepository _repository;

  /// GitHub設定を保存
  Future<void> execute(GitHubSettingsModel settings) async =>
      _repository.saveGitHubSettings(settings);
}

/// GitHub連携有効フラグ更新ユースケース
class UpdateGitHubEnabledUseCase {
  /// コンストラクタ
  UpdateGitHubEnabledUseCase(this._repository);

  final GitHubRepository _repository;

  /// GitHub連携有効フラグを更新
  Future<void> execute({required bool isEnabled}) async =>
      _repository.updateGitHubEnabled(isEnabled: isEnabled);
}

/// GitHubトークン検証ユースケース
class ValidateGitHubTokenUseCase {
  /// コンストラクタ
  ValidateGitHubTokenUseCase(this._repository);

  final GitHubRepository _repository;

  /// トークンを検証
  Future<bool> execute(String token) async => _repository.validateToken(token);
}

/// GitHubユーザー情報取得ユースケース
class GetGitHubUserInfoUseCase {
  /// コンストラクタ
  GetGitHubUserInfoUseCase(this._repository);

  final GitHubRepository _repository;

  /// ユーザー情報を取得
  Future<Map<String, dynamic>?> execute(String token) async =>
      _repository.getUserInfo(token);
}
