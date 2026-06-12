import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';

class SupabaseService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<Ingredient>> getIngredients() async {
    final response =
        await _supabase.from('ingredients').select().order('name') as List;

    final ingredients = response
        .map((item) => Ingredient.fromMap(item as Map<String, dynamic>))
        .toList();

    ingredients.sort((a, b) {
      final aRank = _ingredientRank(a);
      final bRank = _ingredientRank(b);
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.name.compareTo(b.name);
    });

    return ingredients;
  }

  Future<List<Recipe>> getRecipes() async {
    final response =
        await _supabase.from('recipes').select().order('name') as List;

    return response
        .map((item) => Recipe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecipeIngredient>> getRecipeIngredientsByRecipeId(
    int recipeId,
  ) async {
    final response =
        await _supabase
                .from('recipe_ingredients')
                .select(
                  'id, recipe_id, ingredient_id, amount, unit, is_required, '
                  'created_at, ingredients(name, category)',
                )
                .eq('recipe_id', recipeId)
                .order('is_required', ascending: false)
                .order('id')
            as List;

    return response
        .map((item) => RecipeIngredient.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecipeStep>> getRecipeStepsByRecipeId(int recipeId) async {
    final response =
        await _supabase
                .from('recipe_steps')
                .select()
                .eq('recipe_id', recipeId)
                .order('step_number')
            as List;

    return response
        .map((item) => RecipeStep.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecipeIngredient>> getAllRecipeIngredientsWithIngredient() async {
    final response =
        await _supabase
                .from('recipe_ingredients')
                .select(
                  'id, recipe_id, ingredient_id, amount, unit, is_required, '
                  'created_at, ingredients(name, category)',
                )
                .order('recipe_id')
                .order('is_required', ascending: false)
                .order('id')
            as List;

    return response
        .map((item) => RecipeIngredient.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  int _ingredientRank(Ingredient ingredient) {
    final value = '${ingredient.name} ${ingredient.category}'.toLowerCase();

    const orderedNames = <String>[
      'wortel',
      'tempe',
      'telur',
      'sawi',
      'minyak goreng',
      'nasi',
      'kentang',
      'ayam',
      'tahu',
      'brokoli',
      'kol',
      'mie',
      'kecap',
      'garam',
      'cabai',
      'bawang putih',
      'bawang merah',
      'bakso',
      'daun bawang',
    ];

    for (var index = 0; index < orderedNames.length; index++) {
      if (value.contains(orderedNames[index])) {
        return index;
      }
    }

    return 9999;
  }
}
