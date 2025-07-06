/// アプリ全体の設定モデル
class SettingsModel {
  /// コンストラクタ
  SettingsModel({required this.id, required this.key, required this.value});

  /// ID
  final int id;

  /// 設定キー
  final String key;

  /// 設定値
  final String value;

  /// Mapからインスタンス生成
  factory SettingsModel.fromMap(Map<String, dynamic> map) => SettingsModel(
    id: map['id'] as int,
    key: map['key'] as String,
    value: map['value'] as String,
  );

  /// Mapへ変換
  Map<String, dynamic> toMap() => {'id': id, 'key': key, 'value': value};
}
