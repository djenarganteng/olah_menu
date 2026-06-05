import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesStore {
  static const _storageKey = 'favorite_recipe_ids';
  static final ValueNotifier<Set<int>> favorites = ValueNotifier(<int>{});
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_storageKey) ?? <String>[];
    favorites.value = values.map(int.parse).toSet();
    _isInitialized = true;
  }

  static bool isFavorite(int recipeId) {
    return favorites.value.contains(recipeId);
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

  const LocalFavoritesStore._();
}
