import 'package:daily_record/data/datasources/github_api_datasource.dart';
import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:daily_record/domain/repositories/github_repository.dart';

class GitHubRepositoryImpl implements GitHubRepository {
  final SettingsLocalDataSource _localDataSource;
  final GitHubApiDataSource _apiDataSource;

  GitHubRepositoryImpl(this._localDataSource, this._apiDataSource);

  @override
  Future<GitHubSettingsModel?> getGitHubSettings() async {
    return await _localDataSource.getGitHubSettings();
  }

  @override
  Future<void> saveGitHubSettings(GitHubSettingsModel settings) async {
    await _localDataSource.saveGitHubSettings(settings);
  }

  @override
  Future<void> updateGitHubEnabled(bool isEnabled) async {
    await _localDataSource.updateGitHubEnabled(isEnabled);
  }

  @override
  Future<bool> validateToken(String token) async {
    return await _apiDataSource.validateToken(token);
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    return await _apiDataSource.getUserInfo(token);
  }

  @override
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  ) async {
    return await _apiDataSource.validateRepository(token, username, repository);
  }

  @override
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  ) async {
    return await _apiDataSource.createFile(
      token,
      username,
      repository,
      path,
      content,
      message,
    );
  }

  @override
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  ) async {
    return await _apiDataSource.getFileContent(
      token,
      username,
      repository,
      path,
    );
  }
}
