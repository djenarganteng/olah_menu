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

    return response
        .map((item) => Ingredient.fromMap(item as Map<String, dynamic>))
        .toList();
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
                  'id, recipe_id, ingredient_id, amount, unit, created_at, '
                  'ingredients(name, category)',
                )
                .eq('recipe_id', recipeId)
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
                  'id, recipe_id, ingredient_id, amount, unit, created_at, '
                  'ingredients(name, category)',
                )
                .order('recipe_id')
                .order('id')
            as List;

    return response
        .map((item) => RecipeIngredient.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
