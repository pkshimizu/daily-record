class GitHubSettingsModel {
  final int id;
  final String token;
  final bool isEnabled;

  GitHubSettingsModel({
    required this.id,
    required this.token,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'token': token, 'is_enabled': isEnabled ? 1 : 0};
  }

  factory GitHubSettingsModel.fromMap(Map<String, dynamic> map) {
    return GitHubSettingsModel(
      id: map['id'],
      token: map['token'],
      isEnabled: map['is_enabled'] == 1,
    );
  }
}
