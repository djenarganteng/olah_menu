import 'package:flutter/material.dart';

class AiRecipePlaceholderSpec {
  const AiRecipePlaceholderSpec({
    required this.label,
    required this.icon,
    required this.background,
    required this.surface,
    required this.accent,
    this.assetPath,
  });

  final String label;
  final IconData icon;
  final List<Color> background;
  final Color surface;
  final Color accent;
  final String? assetPath;
}

AiRecipePlaceholderSpec aiRecipePlaceholderFor(String recipeName) {
  final value = recipeName.toLowerCase();

  if (value.contains('nasi') || value.contains('bubur')) {
    return const AiRecipePlaceholderSpec(
      label: 'Nasi',
      icon: Icons.rice_bowl_rounded,
      background: [Color(0xFFE9F1DE), Color(0xFFF9FBF7)],
      surface: Color(0xFFE4F0D2),
      accent: Color(0xFF4F8A5B),
      assetPath: 'assets/recipes/nasi_goreng_telur.jpg',
    );
  }

  if (value.contains('mie') || value.contains('pasta') || value.contains('spageti')) {
    return const AiRecipePlaceholderSpec(
      label: 'Mie',
      icon: Icons.ramen_dining_rounded,
      background: [Color(0xFFF7E7D4), Color(0xFFFFFBF7)],
      surface: Color(0xFFF3D4AE),
      accent: Color(0xFFB87436),
      assetPath: 'assets/recipes/mie_goreng_sayur.jpg',
    );
  }

  if (value.contains('ayam') || value.contains('sup')) {
    return const AiRecipePlaceholderSpec(
      label: 'Ayam',
      icon: Icons.set_meal_rounded,
      background: [Color(0xFFF1E1D2), Color(0xFFFFFCF8)],
      surface: Color(0xFFF3D4BD),
      accent: Color(0xFFC06B36),
      assetPath: 'assets/recipes/sup_ayam_wortel.jpg',
    );
  }

  if (value.contains('tahu')) {
    return const AiRecipePlaceholderSpec(
      label: 'Tahu',
      icon: Icons.lunch_dining_rounded,
      background: [Color(0xFFF4ECD8), Color(0xFFFFFCF7)],
      surface: Color(0xFFF0D9A8),
      accent: Color(0xFFC7922A),
      assetPath: 'assets/recipes/tahu_goreng_bumbu.jpg',
    );
  }

  if (value.contains('tempe')) {
    return const AiRecipePlaceholderSpec(
      label: 'Tempe',
      icon: Icons.fitness_center_rounded,
      background: [Color(0xFFF2E3D0), Color(0xFFFFFBF7)],
      surface: Color(0xFFE7C09B),
      accent: Color(0xFF9B5E2E),
      assetPath: 'assets/recipes/tempe_orek.jpg',
    );
  }

  if (value.contains('telur')) {
    return const AiRecipePlaceholderSpec(
      label: 'Telur',
      icon: Icons.egg_alt_rounded,
      background: [Color(0xFFF5EDD7), Color(0xFFFFFCF6)],
      surface: Color(0xFFF0D995),
      accent: Color(0xFFD19A23),
      assetPath: 'assets/recipes/telur_dadar_cabai.jpg',
    );
  }

  if (value.contains('kentang')) {
    return const AiRecipePlaceholderSpec(
      label: 'Kentang',
      icon: Icons.breakfast_dining_rounded,
      background: [Color(0xFFF1E7D4), Color(0xFFFFFDF9)],
      surface: Color(0xFFE8C68A),
      accent: Color(0xFFAD6E25),
      assetPath: 'assets/recipes/perkedel_kentang.jpg',
    );
  }

  if (value.contains('bakso') || value.contains('sawi') || value.contains('tumis')) {
    return const AiRecipePlaceholderSpec(
      label: 'Tumis',
      icon: Icons.restaurant_rounded,
      background: [Color(0xFFE6F0E2), Color(0xFFFAFCF8)],
      surface: Color(0xFFCFE1C9),
      accent: Color(0xFF5D8A57),
      assetPath: 'assets/recipes/tumis_sawi_bakso.jpg',
    );
  }

  if (value.contains('minuman') ||
      value.contains('jus') ||
      value.contains('es') ||
      value.contains('teh') ||
      value.contains('kopi')) {
    return const AiRecipePlaceholderSpec(
      label: 'Minuman',
      icon: Icons.local_cafe_rounded,
      background: [Color(0xFFE8F2F4), Color(0xFFF9FCFD)],
      surface: Color(0xFFCADEE4),
      accent: Color(0xFF4B7986),
    );
  }

  return const AiRecipePlaceholderSpec(
    label: 'Rekomendasi',
    icon: Icons.restaurant_rounded,
    background: [Color(0xFFF1F3E8), Color(0xFFF9FBF8)],
    surface: Color(0xFFDDE7CD),
    accent: Color(0xFF75915F),
    assetPath: 'assets/recipes/nasi_goreng_telur.jpg',
  );
}
