class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultServing,
    required this.cookingTime,
    this.imageUrl,
    this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int defaultServing;
  final int cookingTime;
  final DateTime? createdAt;

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      imageUrl: map['image_url'] as String?,
      defaultServing: ((map['default_serving'] as num?) ?? 1).toInt(),
      cookingTime: ((map['cooking_time'] as num?) ?? 0).toInt(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }
}
