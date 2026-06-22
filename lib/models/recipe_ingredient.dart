class RecipeIngredient {
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
    required this.isRequired,
    this.ingredientName,
    this.ingredientCategory,
    this.ingredientImageUrl,
    this.createdAt,
  });

  final int id;
  final int recipeId;
  final int ingredientId;
  final double amount;
  final String unit;
  final bool isRequired;
  final String? ingredientName;
  final String? ingredientCategory;
  final String? ingredientImageUrl;
  final DateTime? createdAt;

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    final ingredientMap = map['ingredients'] as Map<String, dynamic>?;

    return RecipeIngredient(
      id: (map['id'] as num).toInt(),
      recipeId: (map['recipe_id'] as num).toInt(),
      ingredientId: (map['ingredient_id'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      isRequired: map['is_required'] as bool? ?? true,
      ingredientName: ingredientMap?['name'] as String?,
      ingredientCategory: ingredientMap?['category'] as String?,
      ingredientImageUrl: ingredientMap?['image_url'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'amount': amount,
      'unit': unit,
      'is_required': isRequired,
      'created_at': createdAt?.toIso8601String(),
      'ingredients': {
        'name': ingredientName,
        'category': ingredientCategory,
        'image_url': ingredientImageUrl,
      },
    };
  }
}
