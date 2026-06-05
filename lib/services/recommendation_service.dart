import '../models/ingredient.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_recommendation.dart';
import 'supabase_service.dart';

class RecommendationService {
  RecommendationService({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<List<RecipeRecommendation>> getRecommendations(
    List<Ingredient> selectedIngredients,
  ) async {
    final selectedIngredientIds = selectedIngredients.map((e) => e.id).toSet();

    final recipes = await supabaseService.getRecipes();
    final allRecipeIngredients = await supabaseService
        .getAllRecipeIngredientsWithIngredient();

    final recipeIngredientsMap = <int, List<RecipeIngredient>>{};
    for (final item in allRecipeIngredients) {
      recipeIngredientsMap.putIfAbsent(item.recipeId, () => []).add(item);
    }

    final recommendations = <RecipeRecommendation>[];

    for (final recipe in recipes) {
      final ingredients = recipeIngredientsMap[recipe.id] ?? [];
      if (ingredients.isEmpty) {
        continue;
      }

      final requiredIngredients = ingredients
          .where((item) => item.isRequired)
          .toList();
      final optionalIngredients = ingredients
          .where((item) => !item.isRequired)
          .toList();

      final matchedRequired = requiredIngredients
          .where((item) => selectedIngredientIds.contains(item.ingredientId))
          .toList();
      final matchedOptional = optionalIngredients
          .where((item) => selectedIngredientIds.contains(item.ingredientId))
          .toList();

      final requiredTotalCount = requiredIngredients.length;
      final requiredMatchedCount = matchedRequired.length;
      final optionalTotalCount = optionalIngredients.length;
      final optionalMatchedCount = matchedOptional.length;

      final requiredScore = requiredTotalCount == 0
          ? 1.0
          : requiredMatchedCount / requiredTotalCount;
      final optionalScore = optionalTotalCount == 0
          ? 1.0
          : optionalMatchedCount / optionalTotalCount;
      final matchPercentage = (requiredScore * 0.7 + optionalScore * 0.3) * 100;

      if (requiredMatchedCount == 0 ||
          requiredScore < 0.5 ||
          matchPercentage < 50) {
        continue;
      }

      final matchedIngredients = [...matchedRequired, ...matchedOptional];
      final missingRequired = requiredIngredients
          .where((item) => !selectedIngredientIds.contains(item.ingredientId))
          .toList();
      final missingOptional = optionalIngredients
          .where((item) => !selectedIngredientIds.contains(item.ingredientId))
          .toList();
      final missingIngredients = [...missingRequired, ...missingOptional];

      recommendations.add(
        RecipeRecommendation(
          recipe: recipe,
          matchPercentage: matchPercentage,
          matchedIngredients: matchedIngredients
              .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
              .toList(),
          missingIngredients: missingIngredients
              .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
              .toList(),
          missingRequiredIngredients: missingRequired
              .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
              .toList(),
          missingOptionalIngredients: missingOptional
              .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
              .toList(),
          totalIngredients: ingredients.length,
          matchedIngredientCount: matchedIngredients.length,
          requiredTotalCount: requiredTotalCount,
          requiredMatchedCount: requiredMatchedCount,
          optionalTotalCount: optionalTotalCount,
          optionalMatchedCount: optionalMatchedCount,
        ),
      );
    }

    recommendations.sort((a, b) {
      final percentageCompare = b.matchPercentage.compareTo(a.matchPercentage);
      if (percentageCompare != 0) {
        return percentageCompare;
      }

      final requiredCompare = b.requiredMatchedCount.compareTo(
        a.requiredMatchedCount,
      );
      if (requiredCompare != 0) {
        return requiredCompare;
      }

      return a.recipe.name.compareTo(b.recipe.name);
    });

    return recommendations;
  }
}
