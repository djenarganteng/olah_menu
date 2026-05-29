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

      final matched = ingredients
          .where((item) => selectedIngredientIds.contains(item.ingredientId))
          .toList();
      final matchedCount = matched.length;
      final totalCount = ingredients.length;
      final matchPercentage = (matchedCount / totalCount) * 100;

      if (matchPercentage < 50) {
        continue;
      }

      final matchedNames = matched
          .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
          .toList();
      final missingNames = ingredients
          .where((item) => !selectedIngredientIds.contains(item.ingredientId))
          .map((item) => item.ingredientName ?? 'Bahan tanpa nama')
          .toList();

      recommendations.add(
        RecipeRecommendation(
          recipe: recipe,
          matchPercentage: matchPercentage,
          missingIngredients: missingNames,
          matchedIngredients: matchedNames,
        ),
      );
    }

    recommendations.sort((a, b) {
      final percentageCompare = b.matchPercentage.compareTo(a.matchPercentage);
      if (percentageCompare != 0) {
        return percentageCompare;
      }

      return a.recipe.name.compareTo(b.recipe.name);
    });

    return recommendations;
  }
}
