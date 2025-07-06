/// GitHubアクティビティのモデル
class GitHubActivityModel {
  /// コンストラクタ
  GitHubActivityModel({
    required this.id,
    required this.date,
    required this.eventType,
    required this.repository,
    required this.title,
    required this.description,
    required this.url,
    required this.createdAt,
  });

  /// ID
  final int id;

  /// 日付
  final DateTime date;

  /// イベントタイプ
  final String eventType;

  /// リポジトリ名
  final String repository;

  /// タイトル
  final String title;

  /// 説明
  final String description;

  /// URL
  final String url;

  /// 作成日時
  final DateTime createdAt;

  /// Mapからインスタンス生成
  factory GitHubActivityModel.fromMap(Map<String, dynamic> map) =>
      GitHubActivityModel(
        id: map['id'] as int,
        date: DateTime.parse(map['date'] as String),
        eventType: map['event_type'] as String,
        repository: map['repository'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        url: map['url'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Mapへ変換
  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'event_type': eventType,
    'repository': repository,
    'title': title,
    'description': description,
    'url': url,
    'created_at': createdAt.toIso8601String(),
  };
}
