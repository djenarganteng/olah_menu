class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.sortOrder,
    this.imageUrl,
    this.createdAt,
  });

  final int id;
  final String name;
  final String category;
  final int sortOrder;
  final String? imageUrl;
  final DateTime? createdAt;

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      category: map['category'] as String,
      sortOrder: ((map['sort_order'] as num?) ?? 9999).toInt(),
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }
}
