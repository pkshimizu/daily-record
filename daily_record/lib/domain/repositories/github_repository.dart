import 'package:daily_record/data/models/github_settings_model.dart';

/// GitHubリポジトリのインターフェース
abstract class GitHubRepository {
  /// GitHub設定を取得
  Future<GitHubSettingsModel?> getGitHubSettings();

  /// GitHub設定を保存
  Future<void> saveGitHubSettings(GitHubSettingsModel settings);

  /// GitHub連携有効フラグを更新
  Future<void> updateGitHubEnabled({required bool isEnabled});

  /// トークンを検証
  Future<bool> validateToken(String token);

  /// ユーザー情報を取得
  Future<Map<String, dynamic>?> getUserInfo(String token);

  /// リポジトリを検証
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  );

  /// ファイルを作成
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  );

  /// ファイル内容を取得
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  );
}
