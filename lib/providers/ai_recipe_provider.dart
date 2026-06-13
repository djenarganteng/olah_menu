import 'package:flutter/foundation.dart';

import '../models/ai_recipe.dart';
import '../models/ingredient.dart';
import '../services/ai_recipe_service.dart';

enum AiRecipeState { idle, loading, success, error }

class AiRecipeProvider extends ChangeNotifier {
  AiRecipeProvider({required this.aiRecipeService});

  final AiRecipeService aiRecipeService;

  AiRecipeState _state = AiRecipeState.idle;
  AiRecipe? _recipe;
  String? _errorMessage;

  AiRecipeState get state => _state;
  AiRecipe? get recipe => _recipe;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AiRecipeState.loading;

  Future<void> generateFromIngredients(List<Ingredient> ingredients) async {
    _state = AiRecipeState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipe = await aiRecipeService.generateRecipe(
        ingredients.map((item) => item.name).toList(),
      );
      _state = AiRecipeState.success;
    } catch (error) {
      debugPrint('AI recipe generation failed: $error');
      _errorMessage = 'Gagal membuat resep AI. Silakan coba lagi.';
      _state = AiRecipeState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = AiRecipeState.idle;
    _recipe = null;
    _errorMessage = null;
    notifyListeners();
  }
}
