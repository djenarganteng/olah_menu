import 'recipe.dart';

class RecipeRecommendation {
  const RecipeRecommendation({
    required this.recipe,
    required this.matchPercentage,
    required this.missingIngredients,
    required this.matchedIngredients,
  });

  final Recipe recipe;
  final double matchPercentage;
  final List<String> missingIngredients;
  final List<String> matchedIngredients;
}
