import 'package:daily_record/data/models/github_settings_model.dart';

abstract class GitHubRepository {
  Future<GitHubSettingsModel?> getGitHubSettings();
  Future<void> saveGitHubSettings(GitHubSettingsModel settings);
  Future<void> updateGitHubEnabled(bool isEnabled);
  Future<bool> validateToken(String token);
  Future<Map<String, dynamic>?> getUserInfo(String token);
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  );
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  );
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  );
}
