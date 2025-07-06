class SettingsModel {
  final int id;
  final String key;
  final String value;

  SettingsModel({required this.id, required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'value': value};
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(id: map['id'], key: map['key'], value: map['value']);
  }
}
