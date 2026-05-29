import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../services/supabase_service.dart';

class RecipeDetailProvider extends ChangeNotifier {
  RecipeDetailProvider({required this.supabaseService});

  final SupabaseService supabaseService;

  List<RecipeIngredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedServing = 1;
  int _defaultServing = 1;

  List<RecipeIngredient> get ingredients => _ingredients;
  List<RecipeStep> get steps => _steps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedServing => _selectedServing;
  int get defaultServing => _defaultServing;

  Future<void> loadRecipeDetails(Recipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    _defaultServing = recipe.defaultServing;
    _selectedServing = recipe.defaultServing;
    notifyListeners();

    try {
      final results = await Future.wait([
        supabaseService.getRecipeIngredientsByRecipeId(recipe.id),
        supabaseService.getRecipeStepsByRecipeId(recipe.id),
      ]);

      _ingredients = results[0] as List<RecipeIngredient>;
      _steps = results[1] as List<RecipeStep>;
    } catch (error) {
      _errorMessage = 'Detail resep belum bisa dimuat. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void incrementServing() {
    _selectedServing += 1;
    notifyListeners();
  }

  void decrementServing() {
    if (_selectedServing <= 1) {
      return;
    }
    _selectedServing -= 1;
    notifyListeners();
  }

  double adjustedAmount(RecipeIngredient ingredient) {
    return ingredient.amount * _selectedServing / _defaultServing;
  }
}
