enum FieldType { number, string, date, enumField, boolean }

class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumOptions;

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.enumOptions,
  });
}

/// 标准插件卡片接口
/// v0.1 仅定义接口，v0.2+ 实现内置插件
abstract class IPluginCard {
  String get pluginId;
  String get displayName;
  String get iconName;
  List<FieldDefinition> get fields;

  Future<void> onSubmit(Map<String, dynamic> data);
}
