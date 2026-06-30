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

  Future<Ingredient> createIngredient({
    required String name,
    required String category,
  }) async {
    final normalizedName = Ingredient.toTitleCase(name);
    final normalizedCategory = Ingredient.toTitleCase(category);

    if (normalizedName.isEmpty) {
      throw const IngredientValidationException('Nama bahan wajib diisi.');
    }

    if (normalizedCategory.isEmpty) {
      throw const IngredientValidationException('Kategori bahan wajib dipilih.');
    }

    final refreshedSession = await _supabase.auth.refreshSession();
    final currentUser = refreshedSession.session?.user ?? _supabase.auth.currentUser;
    if (currentUser == null) {
      throw const IngredientAuthException(
        'Silakan masuk terlebih dahulu untuk menambahkan bahan.',
      );
    }

    final existingIngredients = await getIngredients();
    final normalizedKey = Ingredient.normalizeKey(normalizedName);
    final alreadyExists = existingIngredients.any(
      (ingredient) => Ingredient.normalizeKey(ingredient.name) == normalizedKey,
    );
    if (alreadyExists) {
      throw const IngredientDuplicateException('Bahan sudah tersedia.');
    }

    try {
      final response = await _supabase
          .from('ingredients')
          .insert({
            'name': normalizedName,
            'category': normalizedCategory,
            'created_by': currentUser.id,
            'is_user_created': true,
          })
          .select()
          .single();

      return Ingredient.fromMap(response);
    } on PostgrestException catch (error) {
      final message = error.message.toLowerCase();
      if (error.code == '23505' || message.contains('duplicate')) {
        throw const IngredientDuplicateException('Bahan sudah tersedia.');
      }
      if (error.code == '42501' ||
          message.contains('row-level security') ||
          message.contains('permission denied')) {
        throw const IngredientPermissionException(
          'Tidak punya izin menambahkan bahan. Coba login ulang atau jalankan migration Supabase terbaru.',
        );
      }
      throw IngredientDatabaseException(
        'Gagal menyimpan bahan ke database: ${error.message}',
      );
    }
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
                  'created_at, ingredients(name, category, image_url)',
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
                  'created_at, ingredients(name, category, image_url)',
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

class IngredientValidationException implements Exception {
  const IngredientValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IngredientDuplicateException implements Exception {
  const IngredientDuplicateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IngredientAuthException implements Exception {
  const IngredientAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IngredientPermissionException implements Exception {
  const IngredientPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IngredientDatabaseException implements Exception {
  const IngredientDatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}
