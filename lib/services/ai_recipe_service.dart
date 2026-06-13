import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ai_recipe.dart';

class AiRecipeService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<AiRecipe> generateRecipe(List<String> ingredients) async {
    final sanitizedIngredients = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (sanitizedIngredients.isEmpty) {
      throw const FormatException('Minimal satu bahan harus dipilih.');
    }

    final response = await _supabase.functions.invoke(
      'generate-recipe',
      body: {'ingredients': sanitizedIngredients},
    );

    final data = response.data;
    final payload = _decodePayload(data);
    return AiRecipe.fromMap(payload);
  }

  Map<String, dynamic> _decodePayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw const FormatException('Response AI tidak sesuai format.');
  }
}
