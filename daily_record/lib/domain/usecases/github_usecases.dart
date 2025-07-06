import '../../data/models/github_settings_model.dart';
import '../repositories/github_repository.dart';

class GetGitHubSettingsUseCase {
  final GitHubRepository _repository;

  GetGitHubSettingsUseCase(this._repository);

  Future<GitHubSettingsModel?> call() async {
    return await _repository.getGitHubSettings();
  }
}

class SaveGitHubSettingsUseCase {
  final GitHubRepository _repository;

  SaveGitHubSettingsUseCase(this._repository);

  Future<void> call(GitHubSettingsModel settings) async {
    await _repository.saveGitHubSettings(settings);
  }
}

class UpdateGitHubEnabledUseCase {
  final GitHubRepository _repository;

  UpdateGitHubEnabledUseCase(this._repository);

  Future<void> call(bool isEnabled) async {
    await _repository.updateGitHubEnabled(isEnabled);
  }
}

class ValidateGitHubTokenUseCase {
  final GitHubRepository _repository;

  ValidateGitHubTokenUseCase(this._repository);

  Future<bool> call(String token) async {
    return await _repository.validateToken(token);
  }
}

class GetGitHubUserInfoUseCase {
  final GitHubRepository _repository;

  GetGitHubUserInfoUseCase(this._repository);

  Future<Map<String, dynamic>?> call(String token) async {
    return await _repository.getUserInfo(token);
  }
}
