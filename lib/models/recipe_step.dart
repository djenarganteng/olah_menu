class RecipeStep {
  const RecipeStep({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.instruction,
    this.createdAt,
  });

  final int id;
  final int recipeId;
  final int stepNumber;
  final String instruction;
  final DateTime? createdAt;

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: (map['id'] as num).toInt(),
      recipeId: (map['recipe_id'] as num).toInt(),
      stepNumber: (map['step_number'] as num).toInt(),
      instruction: map['instruction'] as String,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }
}
