class RecipeIngredient {
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
    this.ingredientName,
    this.ingredientCategory,
    this.createdAt,
  });

  final int id;
  final int recipeId;
  final int ingredientId;
  final double amount;
  final String unit;
  final String? ingredientName;
  final String? ingredientCategory;
  final DateTime? createdAt;

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    final ingredientMap = map['ingredients'] as Map<String, dynamic>?;

    return RecipeIngredient(
      id: (map['id'] as num).toInt(),
      recipeId: (map['recipe_id'] as num).toInt(),
      ingredientId: (map['ingredient_id'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      ingredientName: ingredientMap?['name'] as String?,
      ingredientCategory: ingredientMap?['category'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }
}
