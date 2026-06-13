import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_recipe.dart';

class LocalFavoritesStore {
  static const _storageKey = 'favorite_recipe_ids';
  static const _aiStorageKey = 'favorite_ai_recipes';
  static final ValueNotifier<Set<int>> favorites = ValueNotifier(<int>{});
  static final ValueNotifier<List<AiRecipe>> aiFavorites = ValueNotifier(
    <AiRecipe>[],
  );
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_storageKey) ?? <String>[];
    favorites.value = values.map(int.parse).toSet();

    final aiValues = prefs.getStringList(_aiStorageKey) ?? <String>[];
    aiFavorites.value = aiValues
        .map((item) => jsonDecode(item))
        .whereType<Map>()
        .map((item) => AiRecipe.fromMap(Map<String, dynamic>.from(item)))
        .where((recipe) => recipe.id.isNotEmpty)
        .toList();
    _isInitialized = true;
  }

  static bool isFavorite(int recipeId) {
    return favorites.value.contains(recipeId);
  }

  static bool isAiFavorite(String recipeId) {
    return aiFavorites.value.any((recipe) => recipe.id == recipeId);
  }

  static Future<void> toggle(int recipeId) async {
    final next = Set<int>.from(favorites.value);
    if (!next.add(recipeId)) {
      next.remove(recipeId);
    }
    favorites.value = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      next.map((item) => item.toString()).toList(),
    );
  }

  static Future<void> toggleAiRecipe(AiRecipe recipe) async {
    if (recipe.id.isEmpty) {
      return;
    }

    final next = List<AiRecipe>.from(aiFavorites.value);
    final existingIndex = next.indexWhere((item) => item.id == recipe.id);
    if (existingIndex >= 0) {
      next.removeAt(existingIndex);
    } else {
      next.add(recipe);
    }

    next.sort((a, b) => a.title.compareTo(b.title));
    aiFavorites.value = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _aiStorageKey,
      next.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  const LocalFavoritesStore._();
}
