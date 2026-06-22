import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ai_recipe.dart';

class LocalFavoritesStore {
  static const _storageKey = 'favorite_recipe_ids';
  static const _aiStorageKey = 'favorite_ai_recipes';
  static final ValueNotifier<Set<int>> favorites = ValueNotifier(<int>{});
  static final ValueNotifier<List<AiRecipe>> aiFavorites = ValueNotifier(
    <AiRecipe>[],
  );
  static bool _isInitialized = false;
  static bool _syncEnabled = false;
  static bool _isSyncing = false;

  static Future<void> init({bool enableAccountSync = false}) async {
    if (_isInitialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_storageKey) ?? <String>[];
    favorites.value = values.map(int.tryParse).whereType<int>().toSet();

    final aiValues = prefs.getStringList(_aiStorageKey) ?? <String>[];
    aiFavorites.value = aiValues
        .map((item) => jsonDecode(item))
        .whereType<Map>()
        .map((item) => AiRecipe.fromMap(Map<String, dynamic>.from(item)))
        .where((recipe) => recipe.id.isNotEmpty)
        .toList();
    _isInitialized = true;

    if (enableAccountSync) {
      _syncEnabled = true;
      Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        if (state.session != null) {
          syncWithAccount();
        }
      });
      await syncWithAccount();
    }
  }

  static bool isFavorite(int recipeId) {
    return favorites.value.contains(recipeId);
  }

  static bool isAiFavorite(String recipeId) {
    return aiFavorites.value.any((recipe) => recipe.id == recipeId);
  }

  static Future<void> toggle(int recipeId) async {
    final next = Set<int>.from(favorites.value);
    final isAdded = next.add(recipeId);
    if (!isAdded) {
      next.remove(recipeId);
    }
    favorites.value = next;

    await _persistRecipeFavorites(next);
    await _syncRecipeFavoriteChange(recipeId: recipeId, isFavorite: isAdded);
  }

  static Future<void> toggleAiRecipe(AiRecipe recipe) async {
    if (recipe.id.isEmpty) {
      return;
    }

    final next = List<AiRecipe>.from(aiFavorites.value);
    final existingIndex = next.indexWhere((item) => item.id == recipe.id);
    final isAdded = existingIndex < 0;
    if (existingIndex >= 0) {
      next.removeAt(existingIndex);
    } else {
      next.insert(0, recipe);
    }
    aiFavorites.value = next;

    await _persistAiFavorites(next);
    await _syncAiFavoriteChange(recipe: recipe, isFavorite: isAdded);
  }

  static Future<void> syncWithAccount() async {
    if (!_syncEnabled || _isSyncing || !_hasUser) {
      return;
    }

    _isSyncing = true;
    try {
      await _syncRecipeFavorites();
      await _syncAiFavorites();
    } catch (error) {
      debugPrint('Favorite account sync failed: $error');
    } finally {
      _isSyncing = false;
    }
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  static String? get _userId => _supabase.auth.currentUser?.id;

  static bool get _hasUser => _userId != null;

  static Future<void> _persistRecipeFavorites(Set<int> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      values.map((item) => item.toString()).toList(),
    );
  }

  static Future<void> _persistAiFavorites(List<AiRecipe> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _aiStorageKey,
      values.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  static Future<void> _syncRecipeFavorites() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    final response =
        await _supabase
                .from('user_favorite_recipes')
                .select('recipe_id')
                .eq('user_id', userId)
            as List;
    final remoteIds = response
        .map((item) => (item as Map<String, dynamic>)['recipe_id'])
        .whereType<num>()
        .map((item) => item.toInt())
        .toSet();
    final mergedIds = {...remoteIds, ...favorites.value};

    favorites.value = mergedIds;
    await _persistRecipeFavorites(mergedIds);

    if (mergedIds.isEmpty) {
      return;
    }

    await _supabase
        .from('user_favorite_recipes')
        .upsert(
          mergedIds
              .map((recipeId) => {'user_id': userId, 'recipe_id': recipeId})
              .toList(),
          onConflict: 'user_id,recipe_id',
        );
  }

  static Future<void> _syncAiFavorites() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }

    final response =
        await _supabase
                .from('user_favorite_ai_recipes')
                .select(
                  'recipe_id, title, description, cooking_time, servings, '
                  'ingredients, steps, source, created_at',
                )
                .eq('user_id', userId)
                .order('created_at', ascending: false)
            as List;
    final remoteRecipes = response
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => AiRecipe.fromMap({
            'id': item['recipe_id'],
            'title': item['title'],
            'description': item['description'],
            'cooking_time': item['cooking_time'],
            'servings': item['servings'],
            'ingredients': item['ingredients'],
            'steps': item['steps'],
            'source': item['source'],
          }),
        )
        .where((recipe) => recipe.id.isNotEmpty)
        .toList();

    final mergedById = <String, AiRecipe>{};
    for (final recipe in [...aiFavorites.value, ...remoteRecipes]) {
      mergedById.putIfAbsent(recipe.id, () => recipe);
    }
    final mergedRecipes = mergedById.values.toList();

    aiFavorites.value = mergedRecipes;
    await _persistAiFavorites(mergedRecipes);

    if (mergedRecipes.isEmpty) {
      return;
    }

    await _supabase
        .from('user_favorite_ai_recipes')
        .upsert(
          mergedRecipes
              .map((recipe) => _aiFavoriteRow(userId, recipe))
              .toList(),
          onConflict: 'user_id,recipe_id',
        );
  }

  static Future<void> _syncRecipeFavoriteChange({
    required int recipeId,
    required bool isFavorite,
  }) async {
    if (!_syncEnabled || !_hasUser || _isSyncing) {
      return;
    }

    try {
      final userId = _userId!;
      if (isFavorite) {
        await _supabase.from('user_favorite_recipes').upsert({
          'user_id': userId,
          'recipe_id': recipeId,
        }, onConflict: 'user_id,recipe_id');
      } else {
        await _supabase
            .from('user_favorite_recipes')
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      }
    } catch (error) {
      debugPrint('Recipe favorite sync failed: $error');
    }
  }

  static Future<void> _syncAiFavoriteChange({
    required AiRecipe recipe,
    required bool isFavorite,
  }) async {
    if (!_syncEnabled || !_hasUser || _isSyncing) {
      return;
    }

    try {
      final userId = _userId!;
      if (isFavorite) {
        await _supabase
            .from('user_favorite_ai_recipes')
            .upsert(
              _aiFavoriteRow(userId, recipe),
              onConflict: 'user_id,recipe_id',
            );
      } else {
        await _supabase
            .from('user_favorite_ai_recipes')
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipe.id);
      }
    } catch (error) {
      debugPrint('AI favorite sync failed: $error');
    }
  }

  static Map<String, dynamic> _aiFavoriteRow(String userId, AiRecipe recipe) {
    return {
      'user_id': userId,
      'recipe_id': recipe.id,
      'title': recipe.title,
      'description': recipe.description,
      'cooking_time': recipe.cookingTime,
      'servings': recipe.servings,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'source': recipe.source,
    };
  }

  const LocalFavoritesStore._();
}
