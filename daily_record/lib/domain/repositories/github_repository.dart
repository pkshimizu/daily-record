import '../../data/models/github_settings_model.dart';

abstract class GitHubRepository {
  Future<GitHubSettingsModel?> getGitHubSettings();
  Future<void> saveGitHubSettings(GitHubSettingsModel settings);
  Future<void> updateGitHubEnabled(bool isEnabled);
  Future<bool> validateToken(String token);
  Future<Map<String, dynamic>?> getUserInfo(String token);
}
