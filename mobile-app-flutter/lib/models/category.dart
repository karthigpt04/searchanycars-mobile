class Category {
  final int id;
  final String name;
  final String slug;
  final String? vehicleType;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.vehicleType,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'vehicle_type': vehicleType,
        'description': description,
      };
}
