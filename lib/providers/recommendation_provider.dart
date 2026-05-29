import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../models/recipe_recommendation.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider({required this.recommendationService});

  final RecommendationService recommendationService;

  List<RecipeRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RecipeRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecommendations(
    List<Ingredient> selectedIngredients,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await recommendationService.getRecommendations(
        selectedIngredients,
      );
    } catch (error) {
      _errorMessage = 'Gagal mengambil rekomendasi resep. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _recommendations = [];
    _errorMessage = null;
    notifyListeners();
  }
}
