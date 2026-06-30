import 'package:flutter/material.dart';

class AiRecipeHeroPalette {
  const AiRecipeHeroPalette({
    required this.background,
    required this.surface,
    required this.accent,
    required this.highlight,
  });

  final List<Color> background;
  final Color surface;
  final Color accent;
  final Color highlight;
}

const AiRecipeHeroPalette kAiRecipeHeroPalette = AiRecipeHeroPalette(
  background: [Color(0xFFEAF2E3), Color(0xFFF9FCF7)],
  surface: Color(0xFFDCE9CF),
  accent: Color(0xFF5A8B5C),
  highlight: Color(0xFFBFD5AF),
);
