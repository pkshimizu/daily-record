/// GitHubの設定モデル
class GitHubSettingsModel {
  /// ID
  final int id;

  /// Personal Access Token
  final String token;

  /// GitHub連携が有効かどうか
  final bool isEnabled;

  /// コンストラクタ
  GitHubSettingsModel({
    required this.id,
    required this.token,
    required this.isEnabled,
  });

  /// Mapからインスタンス生成
  factory GitHubSettingsModel.fromMap(Map<String, dynamic> map) =>
      GitHubSettingsModel(
        id: map['id'] as int,
        token: map['token'] as String,
        isEnabled: (map['is_enabled'] as int) == 1,
      );

  /// Mapへ変換
  Map<String, dynamic> toMap() => {
    'id': id,
    'token': token,
    'is_enabled': isEnabled ? 1 : 0,
  };
}
