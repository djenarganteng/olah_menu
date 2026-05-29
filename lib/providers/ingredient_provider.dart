import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/supabase_service.dart';

class IngredientProvider extends ChangeNotifier {
  IngredientProvider({required this.supabaseService});

  final SupabaseService supabaseService;

  final Set<int> _selectedIngredientIds = {};
  List<Ingredient> _ingredients = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get selectedCount => _selectedIngredientIds.length;

  List<String> get categories {
    final result = _ingredients.map((item) => item.category).toSet().toList()
      ..sort();
    return ['Semua', ...result];
  }

  List<Ingredient> get selectedIngredients => _ingredients
      .where((item) => _selectedIngredientIds.contains(item.id))
      .toList();

  List<Ingredient> get filteredIngredients {
    return _ingredients.where((ingredient) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          ingredient.category == _selectedCategory;
      final matchesSearch = ingredient.name.toLowerCase().contains(
        _searchQuery.trim().toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  bool isSelected(int ingredientId) {
    return _selectedIngredientIds.contains(ingredientId);
  }

  Future<void> loadIngredients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ingredients = await supabaseService.getIngredients();
    } catch (error) {
      _errorMessage = 'Gagal mengambil daftar bahan. Coba lagi sebentar.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(Ingredient ingredient) {
    if (_selectedIngredientIds.contains(ingredient.id)) {
      _selectedIngredientIds.remove(ingredient.id);
    } else {
      _selectedIngredientIds.add(ingredient.id);
    }
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelectedIngredients() {
    _selectedIngredientIds.clear();
    notifyListeners();
  }
}
