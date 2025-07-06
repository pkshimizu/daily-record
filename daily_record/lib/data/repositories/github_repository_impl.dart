import 'package:daily_record/data/datasources/github_api_datasource.dart';
import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/data/models/github_settings_model.dart';
import 'package:daily_record/domain/repositories/github_repository.dart';

/// GitHubリポジトリの実装
class GitHubRepositoryImpl implements GitHubRepository {
  /// コンストラクタ
  GitHubRepositoryImpl(this._localDataSource, this._apiDataSource);

  final SettingsLocalDataSource _localDataSource;
  final GitHubApiDataSource _apiDataSource;

  /// GitHub設定を取得
  @override
  Future<GitHubSettingsModel?> getGitHubSettings() async =>
      _localDataSource.getGitHubSettings();

  /// GitHub設定を保存
  @override
  Future<void> saveGitHubSettings(GitHubSettingsModel settings) async =>
      _localDataSource.saveGitHubSettings(settings);

  /// GitHub連携有効フラグを更新
  @override
  Future<void> updateGitHubEnabled({required bool isEnabled}) async =>
      _localDataSource.updateGitHubEnabled(isEnabled: isEnabled);

  /// トークンを検証
  @override
  Future<bool> validateToken(String token) async =>
      _apiDataSource.validateToken(token);

  /// ユーザー情報を取得
  @override
  Future<Map<String, dynamic>?> getUserInfo(String token) async =>
      _apiDataSource.getUserInfo(token);

  /// リポジトリを検証
  @override
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  ) async => _apiDataSource.validateRepository(token, username, repository);

  /// ファイルを作成
  @override
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  ) async => _apiDataSource.createFile(
    token,
    username,
    repository,
    path,
    content,
    message,
  );

  /// ファイル内容を取得
  @override
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  ) async => _apiDataSource.getFileContent(token, username, repository, path);
}
