class AiRecipe {
  const AiRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.source,
    this.isAiGenerated = true,
  });

  final String id;
  final String title;
  final String description;
  final int cookingTime;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final String source;
  final bool isAiGenerated;

  factory AiRecipe.fromMap(Map<String, dynamic> map) {
    return AiRecipe(
      id: (map['id'] as String?)?.trim() ?? '',
      title: (map['title'] as String?)?.trim() ?? 'Resep AI',
      description: (map['description'] as String?)?.trim() ?? '',
      cookingTime: _toInt(map['cooking_time']),
      servings: _toInt(map['servings'], fallback: 1),
      ingredients: _toStringList(map['ingredients']),
      steps: _toStringList(map['steps']),
      source: (map['source'] as String?)?.trim() == 'cache'
          ? 'cache'
          : 'gemini',
    );
  }

  String get sourceBadgeLabel =>
      source == 'cache' ? '\u26A1 Dari Cache' : '\u2728 Dibuat oleh AI';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cooking_time': cookingTime,
      'servings': servings,
      'ingredients': ingredients,
      'steps': steps,
      'source': source,
      'is_ai_generated': isAiGenerated,
    };
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
