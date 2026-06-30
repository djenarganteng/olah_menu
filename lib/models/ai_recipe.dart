import 'ai_recipe_step.dart';

class AiRecipe {
  const AiRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTime,
    required this.estimatedTime,
    required this.difficulty,
    required this.servings,
    required this.tips,
    required this.mainIngredients,
    required this.seasonings,
    required this.ingredients,
    required this.steps,
    required this.stepDetails,
    required this.source,
    this.imageUrl,
    this.imagePrompt,
    this.imageSource,
    this.aiNote,
    this.isAiGenerated = true,
  });

  final String id;
  final String title;
  final String description;
  final int cookingTime;
  final String estimatedTime;
  final String difficulty;
  final int servings;
  final List<String> tips;
  final List<String> mainIngredients;
  final List<String> seasonings;
  final List<String> ingredients;
  final List<String> steps;
  final List<AiRecipeStep> stepDetails;
  final String source;
  final String? imageUrl;
  final String? imagePrompt;
  final String? imageSource;
  final String? aiNote;
  final bool isAiGenerated;

  factory AiRecipe.fromMap(Map<String, dynamic> map) {
    final title = _stringValue(
      _valueFor(map, ['title', 'nama_masakan']),
      fallback: 'Resep AI',
    );
    final cookingTime = _extractCookingTime(map);
    final estimatedTime = _stringValue(
      _valueFor(map, ['estimated_time', 'estimasi_waktu']),
      fallback: cookingTime > 0 ? '$cookingTime menit' : '30 menit',
    );
    final difficulty = _stringValue(
      _valueFor(map, ['difficulty', 'tingkat_kesulitan']),
      fallback: 'Mudah',
    );
    final mainIngredients = _stringList(
      _valueFor(map, ['main_ingredients', 'bahan_utama']),
    );
    final seasonings = _stringList(
      _valueFor(map, ['seasonings', 'bumbu_dan_pelengkap']),
    );
    final legacyIngredients = _stringList(
      _valueFor(map, ['ingredients']),
    );
    final ingredients = legacyIngredients.isNotEmpty
        ? legacyIngredients
        : [...mainIngredients, ...seasonings];
    final stepDetails = _stepDetailsFromMap(map);
    final legacySteps = _stringList(_valueFor(map, ['steps']));
    final steps = legacySteps.isNotEmpty
        ? legacySteps
        : stepDetails.map((step) => step.toDisplayText()).toList();
    final imageUrl = _stringOrNull(
      _valueFor(map, ['image_url', 'imageUrl']),
    );
    final imagePrompt = _stringOrNull(
      _valueFor(map, ['image_prompt', 'imagePrompt']),
    );
    final imageSource = _stringValue(
      _valueFor(map, ['image_source', 'imageSource']),
      fallback: imageUrl == null ? 'placeholder' : 'generated',
    );
    final aiNote = _stringOrNull(
      _valueFor(map, ['ai_note', 'aiNote', 'catatan_ai', 'notes', 'note']),
    );

    return AiRecipe(
      id: _stringValue(_valueFor(map, ['id']), fallback: ''),
      title: title,
      description: _stringValue(
        _valueFor(map, ['description', 'deskripsi']),
        fallback: '',
      ),
      cookingTime: cookingTime,
      estimatedTime: estimatedTime,
      difficulty: difficulty,
      servings: _toInt(_valueFor(map, ['servings', 'jumlah_porsi']), fallback: 1),
      tips: _stringList(_valueFor(map, ['tips', 'tips_memasak'])),
      mainIngredients: mainIngredients,
      seasonings: seasonings,
      ingredients: ingredients,
      steps: steps,
      stepDetails: stepDetails,
      source: _stringValue(_valueFor(map, ['source']), fallback: 'gemini') ==
              'cache'
          ? 'cache'
          : 'gemini',
      imageUrl: imageUrl,
      imagePrompt: imagePrompt,
      imageSource: imageSource,
      aiNote: aiNote,
    );
  }

  String get aiBadgeLabel => '\u{1F916} Dibuat oleh AI';

  String get sourceBadgeLabel =>
      source == 'cache' ? '\u{26A1} Dari Cache' : aiBadgeLabel;

  String get aiDisclosureText {
    final note = aiNote?.trim();
    if (note != null && note.isNotEmpty) {
      return note;
    }

    return 'Resep ini dihasilkan AI berdasarkan bahan yang kamu pilih. '
        'Hasilnya bisa sedikit berbeda dari resep tradisional.';
  }

  bool get hasDetailedSteps =>
      stepDetails.isNotEmpty &&
      stepDetails.any(
        (step) =>
            step.title.trim().isNotEmpty || step.description.trim().isNotEmpty,
      );

  bool get hasStructuredIngredients =>
      mainIngredients.isNotEmpty || seasonings.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cooking_time': cookingTime,
      'estimated_time': estimatedTime,
      'difficulty': difficulty,
      'servings': servings,
      'tips': tips,
      'main_ingredients': mainIngredients,
      'seasonings': seasonings,
      'ingredients': ingredients,
      'steps': steps,
      'step_details': stepDetails.map((step) => step.toMap()).toList(),
      'image_url': imageUrl,
      'image_prompt': imagePrompt,
      'image_source': imageSource,
      'ai_note': aiNote,
      'source': source,
      'is_ai_generated': isAiGenerated,
    };
  }

  static Object? _valueFor(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) {
        return map[key];
      }
    }
    return null;
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

  static String _stringValue(dynamic value, {required String fallback}) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _extractCookingTime(Map<String, dynamic> map) {
    final rawCookingTime = _valueFor(map, ['cooking_time']);
    final parsedCookingTime = _toInt(rawCookingTime, fallback: 0);
    if (parsedCookingTime > 0) {
      return parsedCookingTime;
    }

    final estimatedTime = _stringOrNull(
      _valueFor(map, ['estimated_time', 'estimasi_waktu']),
    );
    if (estimatedTime == null) {
      return 30;
    }

    final match = RegExp(r'(\d+)').firstMatch(estimatedTime);
    if (match == null) {
      return 30;
    }

    return _toInt(match.group(1), fallback: 30);
  }

  static List<AiRecipeStep> _stepDetailsFromMap(Map<String, dynamic> map) {
    final rawSteps = _valueFor(map, ['step_details', 'langkah_memasak']);
    if (rawSteps is List && rawSteps.isNotEmpty) {
      return rawSteps.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        if (item is Map) {
          return AiRecipeStep.fromMap(
            Map<String, dynamic>.from(item),
            fallbackStep: index,
          );
        }
        return AiRecipeStep.fromText(item.toString(), fallbackStep: index);
      }).toList();
    }

    final legacySteps = _stringList(_valueFor(map, ['steps']));
    return legacySteps.asMap().entries.map((entry) {
      return AiRecipeStep.fromText(entry.value, fallbackStep: entry.key + 1);
    }).toList();
  }
}
