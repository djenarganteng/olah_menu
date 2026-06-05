import 'recipe.dart';

class RecipeRecommendation {
  const RecipeRecommendation({
    required this.recipe,
    required this.matchPercentage,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.missingRequiredIngredients,
    required this.missingOptionalIngredients,
    required this.totalIngredients,
    required this.matchedIngredientCount,
    required this.requiredTotalCount,
    required this.requiredMatchedCount,
    required this.optionalTotalCount,
    required this.optionalMatchedCount,
  });

  final Recipe recipe;
  final double matchPercentage;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;
  final List<String> missingRequiredIngredients;
  final List<String> missingOptionalIngredients;
  final int totalIngredients;
  final int matchedIngredientCount;
  final int requiredTotalCount;
  final int requiredMatchedCount;
  final int optionalTotalCount;
  final int optionalMatchedCount;

  String get matchLabel {
    if (matchPercentage >= 80) {
      return 'Sangat cocok';
    }
    if (matchPercentage >= 60) {
      return 'Cukup cocok';
    }
    return 'Bisa dicoba';
  }
}
