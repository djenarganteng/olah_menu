import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ai_recipe.dart';

class LocalFavoritesStore {
  static const _legacyStorageKey = 'favorite_recipe_ids';
  static const _legacyAiStorageKey = 'favorite_ai_recipes';
  static const _storageKeyPrefix = 'favorite_recipe_ids_';
  static const _aiStorageKeyPrefix = 'favorite_ai_recipes_';
  static final ValueNotifier<Set<int>> favorites = ValueNotifier(<int>{});
  static final ValueNotifier<List<AiRecipe>> aiFavorites = ValueNotifier(
    <AiRecipe>[],
  );
  static bool _isInitialized = false;
  static bool _syncEnabled = false;
  static String? _activeUserId;
  static String? _legacyMigrationUserId;
  static final Set<String> _syncingUserIds = <String>{};

  static Future<void> init({bool enableAccountSync = false}) async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _syncEnabled = enableAccountSync;

    if (!enableAccountSync) {
      await _loadLegacyFavorites();
      return;
    }

    final initialUserId = _userId;
    _legacyMigrationUserId = initialUserId;

    Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      unawaited(_activateUser(state.session?.user.id));
    });
    await _activateUser(initialUserId);
  }

  static bool isFavorite(int recipeId) {
    return favorites.value.contains(recipeId);
  }

  static bool isAiFavorite(String recipeId) {
    return aiFavorites.value.any((recipe) => recipe.id == recipeId);
  }

  static Future<void> toggle(int recipeId) async {
    final userId = _currentStorageUserId;
    if (_syncEnabled && userId == null) {
      return;
    }

    final next = Set<int>.from(favorites.value);
    final isAdded = next.add(recipeId);
    if (!isAdded) {
      next.remove(recipeId);
    }
    favorites.value = next;

    await _persistRecipeFavorites(next);
    await _syncRecipeFavoriteChange(
      userId: userId,
      recipeId: recipeId,
      isFavorite: isAdded,
    );
  }

  static Future<void> toggleAiRecipe(AiRecipe recipe) async {
    final userId = _currentStorageUserId;
    if (_syncEnabled && userId == null) {
      return;
    }

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
    await _syncAiFavoriteChange(
      userId: userId,
      recipe: recipe,
      isFavorite: isAdded,
    );
  }

  static Future<void> syncWithAccount() async {
    final userId = _currentStorageUserId;
    if (!_syncEnabled || userId == null || _syncingUserIds.contains(userId)) {
      return;
    }

    _syncingUserIds.add(userId);
    try {
      await _syncRecipeFavorites(userId);
      await _syncAiFavorites(userId);
    } catch (error) {
      debugPrint('Favorite account sync failed: $error');
    } finally {
      _syncingUserIds.remove(userId);
    }
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  static String? get _userId => _supabase.auth.currentUser?.id;

  static String? get _currentStorageUserId {
    if (!_syncEnabled) {
      return null;
    }

    final userId = _userId;
    if (userId == null || _activeUserId != userId) {
      return null;
    }
    return userId;
  }

  static String _recipeStorageKey(String userId) {
    return '$_storageKeyPrefix$userId';
  }

  static String _aiStorageKey(String userId) {
    return '$_aiStorageKeyPrefix$userId';
  }

  static bool _isActiveUser(String userId) {
    return _activeUserId == userId && _userId == userId;
  }

  static Future<void> _activateUser(String? userId) async {
    if (_activeUserId == userId) {
      if (userId != null) {
        await syncWithAccount();
      }
      return;
    }

    _activeUserId = userId;
    if (userId == null) {
      favorites.value = <int>{};
      aiFavorites.value = <AiRecipe>[];
      return;
    }

    await _loadFavoritesForUser(userId);
    if (!_isActiveUser(userId)) {
      return;
    }
    await syncWithAccount();
  }

  static Future<void> _loadLegacyFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites.value = _readRecipeFavorites(prefs, _legacyStorageKey);
    aiFavorites.value = _readAiFavorites(prefs, _legacyAiStorageKey);
  }

  static Future<void> _loadFavoritesForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final recipeKey = _recipeStorageKey(userId);
    final aiKey = _aiStorageKey(userId);
    final hasScopedRecipeKey = prefs.containsKey(recipeKey);
    final hasScopedAiKey = prefs.containsKey(aiKey);

    var recipeFavorites = _readRecipeFavorites(prefs, recipeKey);
    var aiRecipeFavorites = _readAiFavorites(prefs, aiKey);

    if (_legacyMigrationUserId == userId) {
      if (!hasScopedRecipeKey) {
        recipeFavorites = {
          ..._readRecipeFavorites(prefs, _legacyStorageKey),
          ...recipeFavorites,
        };
        await _persistRecipeFavoritesForUser(userId, recipeFavorites);
      }
      if (!hasScopedAiKey) {
        aiRecipeFavorites = _dedupeAiFavorites([
          ..._readAiFavorites(prefs, _legacyAiStorageKey),
          ...aiRecipeFavorites,
        ]);
        await _persistAiFavoritesForUser(userId, aiRecipeFavorites);
      }
      _legacyMigrationUserId = null;
    }

    if (!_isActiveUser(userId)) {
      return;
    }

    favorites.value = recipeFavorites;
    aiFavorites.value = aiRecipeFavorites;
  }

  static Set<int> _readRecipeFavorites(
    SharedPreferences prefs,
    String storageKey,
  ) {
    final values = prefs.getStringList(storageKey) ?? <String>[];
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  static List<AiRecipe> _readAiFavorites(
    SharedPreferences prefs,
    String storageKey,
  ) {
    final values = prefs.getStringList(storageKey) ?? <String>[];
    final recipes = <AiRecipe>[];
    for (final item in values) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          final recipe = AiRecipe.fromMap(Map<String, dynamic>.from(decoded));
          if (recipe.id.isNotEmpty) {
            recipes.add(recipe);
          }
        }
      } catch (error) {
        debugPrint('Invalid AI favorite cache item ignored: $error');
      }
    }
    return _dedupeAiFavorites(recipes);
  }

  static List<AiRecipe> _dedupeAiFavorites(Iterable<AiRecipe> recipes) {
    final byId = <String, AiRecipe>{};
    for (final recipe in recipes) {
      if (recipe.id.isNotEmpty) {
        byId.putIfAbsent(recipe.id, () => recipe);
      }
    }
    return byId.values.toList();
  }

  static Future<void> _persistRecipeFavorites(Set<int> values) async {
    final userId = _currentStorageUserId;
    if (userId != null) {
      await _persistRecipeFavoritesForUser(userId, values);
      return;
    }

    if (!_syncEnabled) {
      await _persistRecipeFavoritesForKey(_legacyStorageKey, values);
    }
  }

  static Future<void> _persistAiFavorites(List<AiRecipe> values) async {
    final userId = _currentStorageUserId;
    if (userId != null) {
      await _persistAiFavoritesForUser(userId, values);
      return;
    }

    if (!_syncEnabled) {
      await _persistAiFavoritesForKey(_legacyAiStorageKey, values);
    }
  }

  static Future<void> _persistRecipeFavoritesForUser(
    String userId,
    Set<int> values,
  ) async {
    await _persistRecipeFavoritesForKey(_recipeStorageKey(userId), values);
  }

  static Future<void> _persistAiFavoritesForUser(
    String userId,
    List<AiRecipe> values,
  ) async {
    await _persistAiFavoritesForKey(_aiStorageKey(userId), values);
  }

  static Future<void> _persistRecipeFavoritesForKey(
    String storageKey,
    Set<int> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      values.map((item) => item.toString()).toList(),
    );
  }

  static Future<void> _persistAiFavoritesForKey(
    String storageKey,
    List<AiRecipe> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      values.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  static Future<void> _syncRecipeFavorites(String userId) async {
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

    if (!_isActiveUser(userId)) {
      return;
    }

    final mergedIds = {...remoteIds, ...favorites.value};

    favorites.value = mergedIds;
    await _persistRecipeFavoritesForUser(userId, mergedIds);

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

  static Future<void> _syncAiFavorites(String userId) async {
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

    if (!_isActiveUser(userId)) {
      return;
    }

    final mergedRecipes = _dedupeAiFavorites([
      ...aiFavorites.value,
      ...remoteRecipes,
    ]);

    aiFavorites.value = mergedRecipes;
    await _persistAiFavoritesForUser(userId, mergedRecipes);

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
    required String? userId,
    required int recipeId,
    required bool isFavorite,
  }) async {
    if (!_syncEnabled ||
        userId == null ||
        !_isActiveUser(userId) ||
        _syncingUserIds.contains(userId)) {
      return;
    }

    try {
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
    required String? userId,
    required AiRecipe recipe,
    required bool isFavorite,
  }) async {
    if (!_syncEnabled ||
        userId == null ||
        !_isActiveUser(userId) ||
        _syncingUserIds.contains(userId)) {
      return;
    }

    try {
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
