class FilterDefinition {
  final int id;
  final String key;
  final String label;
  final String type;
  final List<String> options;

  const FilterDefinition({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
  });

  factory FilterDefinition.fromJson(Map<String, dynamic> json) {
    return FilterDefinition(
      id: json['id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      options: json['options'] is List
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'label': label,
        'type': type,
        'options': options,
      };
}
