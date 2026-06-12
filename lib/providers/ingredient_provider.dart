import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/supabase_service.dart';

final List<Ingredient> _fallbackIngredients = [
  Ingredient(
    id: -1,
    name: 'Wortel',
    category: 'Sayur',
    sortOrder: 1,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/wortel.jpg',
  ),
  Ingredient(
    id: -2,
    name: 'Tempe',
    category: 'Protein',
    sortOrder: 2,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/tempe.jpg',
  ),
  Ingredient(
    id: -3,
    name: 'Telur',
    category: 'Protein',
    sortOrder: 3,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/telur.jpg',
  ),
  Ingredient(
    id: -4,
    name: 'Sawi',
    category: 'Sayur',
    sortOrder: 4,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/sawi.jpg',
  ),
  Ingredient(
    id: -5,
    name: 'Minyak Goreng',
    category: 'Bahan Dasar',
    sortOrder: 5,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/minyak_goreng.jpg',
  ),
  Ingredient(
    id: -6,
    name: 'Nasi',
    category: 'Karbohidrat',
    sortOrder: 6,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/nasi.jpg',
  ),
  Ingredient(
    id: -7,
    name: 'Kentang',
    category: 'Carb',
    sortOrder: 7,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kentang.jpg',
  ),
  Ingredient(
    id: -8,
    name: 'Ayam',
    category: 'Protein',
    sortOrder: 8,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/ayam.jpg',
  ),
  Ingredient(
    id: -9,
    name: 'Tahu',
    category: 'Sayur/Bumbu',
    sortOrder: 9,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/tahu.jpg',
  ),
  Ingredient(
    id: -10,
    name: 'Brokoli',
    category: 'Vegetable',
    sortOrder: 10,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/brokoli.jpg',
  ),
  Ingredient(
    id: -11,
    name: 'Kol',
    category: 'Sayur',
    sortOrder: 11,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kol.jpg',
  ),
  Ingredient(
    id: -12,
    name: 'Mie',
    category: 'Karbohidrat',
    sortOrder: 12,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/mie.jpg',
  ),
  Ingredient(
    id: -13,
    name: 'Kecap',
    category: 'Bumbu',
    sortOrder: 13,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/kecap.jpg',
  ),
  Ingredient(
    id: -14,
    name: 'Garam',
    category: 'Bumbu',
    sortOrder: 14,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/garam.jpg',
  ),
  Ingredient(
    id: -15,
    name: 'Cabai',
    category: 'Sayur/Bumbu',
    sortOrder: 15,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/cabai.jpg',
  ),
  Ingredient(
    id: -16,
    name: 'Bawang Putih',
    category: 'Bumbu',
    sortOrder: 16,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bawang_putih.jpg',
  ),
  Ingredient(
    id: -17,
    name: 'Bawang Merah',
    category: 'Bumbu',
    sortOrder: 17,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bawang_merah.jpg',
  ),
  Ingredient(
    id: -18,
    name: 'Bakso',
    category: 'Protein',
    sortOrder: 18,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/bakso.jpg',
  ),
  Ingredient(
    id: -19,
    name: 'Daun Bawang',
    category: 'Sayur',
    sortOrder: 19,
    imageUrl:
        'https://nvbaxhlexcfaahmzeauq.supabase.co/storage/v1/object/public/ingredient-images/ingredients/daun_bawang.jpg',
  ),
];

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
      debugPrint('Failed to load ingredients from Supabase: $error');
      _ingredients = List<Ingredient>.of(_fallbackIngredients);
      _errorMessage = null;
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
