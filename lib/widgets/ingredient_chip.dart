import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../theme/app_colors.dart';
import 'ingredient_art_icon.dart';

class IngredientChip extends StatelessWidget {
  const IngredientChip({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  final Ingredient ingredient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColorForIngredient(ingredient);
    final palette = _paletteForIngredient(ingredient);
    final imageUrl = _imageUrlForIngredient(ingredient);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      palette.base.withValues(alpha: 0.7),
                      const Color(0xFFF4FAF0),
                    ]
                  : [const Color(0xFFEBF4E4), const Color(0xFFF8FCF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? palette.primary : const Color(0xFFD2E1C9),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 130;
              final imageSize = compact ? 52.0 : 64.0;

              final nameStyle = Theme.of(context).textTheme.titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: 1.1,
                    fontSize: compact ? 14 : 16,
                    letterSpacing: -0.2,
                  );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Kiri: Informasi Teks (Nama & Kategori)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ingredient.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ingredient.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSoft.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Kanan: Area Visual Gambar & Indikator Centang
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        _IngredientVisual(
                          ingredient: ingredient,
                          accent: accent,
                          imageUrl: imageUrl,
                          size: imageSize,
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: _SelectionDot(
                            isSelected: isSelected,
                            primary: palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _accentColorForIngredient(Ingredient ingredient) {
    final value = '${ingredient.name} ${ingredient.category}'.toLowerCase();
    if (value.contains('telur')) return const Color(0xFFE0A23A);
    if (value.contains('ayam') ||
        value.contains('daging') ||
        value.contains('bakso')) {
      return const Color(0xFFD66D4F);
    }
    if (value.contains('tahu') || value.contains('tempe')) {
      return const Color(0xFFC48A4E);
    }
    if (value.contains('brokoli') ||
        value.contains('sawi') ||
        value.contains('kol') ||
        value.contains('bayam') ||
        value.contains('wortel') ||
        value.contains('tomat') ||
        value.contains('sayur')) {
      return const Color(0xFF5F8F57);
    }
    if (value.contains('kentang') ||
        value.contains('nasi') ||
        value.contains('mie')) {
      return const Color(0xFFB98C4A);
    }
    if (value.contains('cabai')) {
      return const Color(0xFFD65A3C);
    }
    if (value.contains('garam') ||
        value.contains('minyak') ||
        value.contains('kecap') ||
        value.contains('bawang') ||
        value.contains('bumbu') ||
        value.contains('pantry')) {
      return const Color(0xFF9B7A53);
    }
    return AppColors.primaryDark;
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.isSelected, required this.primary});

  final bool isSelected;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? primary : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: isSelected ? primary : const Color(0xFFB0C4A7),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _IngredientVisual extends StatelessWidget {
  const _IngredientVisual({
    required this.ingredient,
    required this.accent,
    required this.imageUrl,
    required this.size,
  });

  final Ingredient ingredient;
  final Color accent;
  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Padding(
                padding: EdgeInsets.all(size * 0.05),
                child: Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    final artKind = ingredientArtKindForName(
                      ingredient.name,
                      ingredient.category,
                    );
                    return ColoredBox(
                      color: Colors.white,
                      child: IngredientArtIcon(
                        kind: artKind,
                        color: accent,
                        size: size,
                        strokeWidth: 2.0,
                      ),
                    );
                  },
                ),
              )
            : ColoredBox(
                color: Colors.white,
                child: IngredientArtIcon(
                  kind: ingredientArtKindForName(
                    ingredient.name,
                    ingredient.category,
                  ),
                  color: accent,
                  size: size,
                  strokeWidth: 2.0,
                ),
              ),
      ),
    );
  }
}

String _imageUrlForIngredient(Ingredient ingredient) {
  final current = ingredient.imageUrl?.trim();
  if (current == null || current.isEmpty) {
    return '';
  }
  return current;
}

class _IngredientPalette {
  const _IngredientPalette({required this.primary, required this.base});

  final Color primary;
  final Color base;
}

_IngredientPalette _paletteForIngredient(Ingredient ingredient) {
  final value = '${ingredient.name} ${ingredient.category}'.toLowerCase();
  if (value.contains('telur')) {
    return const _IngredientPalette(
      primary: Color(0xFFE0A23A),
      base: Color(0xFFFDF5E6),
    );
  }
  if (value.contains('ayam') ||
      value.contains('daging') ||
      value.contains('bakso')) {
    return const _IngredientPalette(
      primary: Color(0xFFD66D4F),
      base: Color(0xFFFDF0ED),
    );
  }
  if (value.contains('tahu') || value.contains('tempe')) {
    return const _IngredientPalette(
      primary: Color(0xFFC48A4E),
      base: Color(0xFFFAF2E8),
    );
  }
  if (value.contains('brokoli') ||
      value.contains('sawi') ||
      value.contains('kol') ||
      value.contains('bayam') ||
      value.contains('wortel') ||
      value.contains('tomat') ||
      value.contains('sayur')) {
    return const _IngredientPalette(
      primary: Color(0xFF5F8F57),
      base: Color(0xFFF0F7EC),
    );
  }
  if (value.contains('kentang') ||
      value.contains('nasi') ||
      value.contains('mie')) {
    return const _IngredientPalette(
      primary: Color(0xFFB98C4A),
      base: Color(0xFFFAF3E6),
    );
  }
  if (value.contains('cabai')) {
    return const _IngredientPalette(
      primary: Color(0xFFD65A3C),
      base: Color(0xFFFDF0ED),
    );
  }
  if (value.contains('garam') ||
      value.contains('minyak') ||
      value.contains('kecap') ||
      value.contains('bawang') ||
      value.contains('bumbu') ||
      value.contains('pantry')) {
    return const _IngredientPalette(
      primary: Color(0xFF9B7A53),
      base: Color(0xFFF6F0E7),
    );
  }
  return const _IngredientPalette(
    primary: AppColors.primaryDark,
    base: AppColors.primarySoft,
  );
}
