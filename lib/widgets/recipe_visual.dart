import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/food_image_urls.dart';
import '../models/recipe.dart';
import '../theme/app_colors.dart';

class RecipeVisual extends StatelessWidget {
  const RecipeVisual({
    super.key,
    required this.recipe,
    this.height = 200,
    this.borderRadius = 24,
    this.showFavoriteAction = false,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.topLabel,
    this.heroTag,
  });

  final Recipe recipe;
  final double height;
  final double borderRadius;
  final bool showFavoriteAction;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final String? topLabel;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(recipe.name);
    final imageUrl = _imageUrlFor(recipe);
    final hasImage = imageUrl.isNotEmpty;

    Widget visualContent;
    if (hasImage) {
      visualContent = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => Container(
          color: palette.background.first,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            _FallbackArt(recipe: recipe, palette: palette),
      );
    } else {
      visualContent = _FallbackArt(recipe: recipe, palette: palette);
    }

    if (heroTag != null) {
      visualContent = Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: visualContent,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: palette.background,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -height * 0.22,
              right: -height * 0.14,
              child: _GlowBlob(color: palette.glow, size: height * 0.68),
            ),
            Positioned(
              left: -height * 0.15,
              bottom: -height * 0.18,
              child: _GlowBlob(
                color: palette.secondaryGlow,
                size: height * 0.52,
              ),
            ),
            Positioned.fill(child: visualContent),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0x26000000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            if (topLabel != null)
              Positioned(left: 14, top: 14, child: _Badge(text: topLabel!)),
            if (showFavoriteAction)
              Positioned(
                right: 12,
                top: 12,
                child: InkWell(
                  onTap: onFavoriteTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isFavorite
                          ? const Color(0xFFD65A72)
                          : AppColors.textSoft,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x12000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackArt extends StatelessWidget {
  const _FallbackArt({required this.recipe, required this.palette});

  final Recipe recipe;
  final _RecipePalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : width * 0.68;
        final plateSize = width * 0.68;
        final foodSize = width * 0.42;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: palette.background,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -width * 0.08,
                top: height * 0.08,
                child: _OrbitDot(
                  color: palette.accent.withValues(alpha: 0.26),
                  size: width * 0.22,
                ),
              ),
              Positioned(
                right: -width * 0.05,
                bottom: height * 0.05,
                child: _OrbitDot(
                  color: palette.accent.withValues(alpha: 0.18),
                  size: width * 0.28,
                ),
              ),
              Center(
                child: Container(
                  width: plateSize,
                  height: plateSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF9F5EC),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE7DFCE)),
                  ),
                  child: Center(
                    child: Container(
                      width: foodSize,
                      height: foodSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: palette.food,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: foodSize * 0.12,
                            top: foodSize * 0.14,
                            child: _ToppingDot(
                              color: palette.secondary,
                              size: foodSize * 0.16,
                            ),
                          ),
                          Positioned(
                            right: foodSize * 0.11,
                            top: foodSize * 0.12,
                            child: _ToppingDot(
                              color: palette.highlight,
                              size: foodSize * 0.19,
                            ),
                          ),
                          Positioned(
                            left: foodSize * 0.14,
                            bottom: foodSize * 0.12,
                            child: _ToppingDot(
                              color: palette.highlight.withValues(alpha: 0.9),
                              size: foodSize * 0.12,
                            ),
                          ),
                          Positioned(
                            right: foodSize * 0.15,
                            bottom: foodSize * 0.13,
                            child: _ToppingDot(
                              color: palette.secondary.withValues(alpha: 0.92),
                              size: foodSize * 0.14,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: foodSize * 0.34,
                              height: foodSize * 0.34,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF5EAD7),
                              ),
                              child: Center(
                                child: Container(
                                  width: foodSize * 0.24,
                                  height: foodSize * 0.24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF2C94C),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 32,
                  margin: const EdgeInsets.fromLTRB(26, 0, 26, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconForRecipe(recipe.name),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          recipe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ToppingDot extends StatelessWidget {
  const _ToppingDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _RecipePalette {
  const _RecipePalette({
    required this.background,
    required this.food,
    required this.accent,
    required this.secondary,
    required this.highlight,
    required this.glow,
    required this.secondaryGlow,
  });

  final List<Color> background;
  final List<Color> food;
  final Color accent;
  final Color secondary;
  final Color highlight;
  final Color glow;
  final Color secondaryGlow;
}

_RecipePalette _paletteFor(String recipeName) {
  final value = recipeName.toLowerCase();

  if (value.contains('sup')) {
    return const _RecipePalette(
      background: [Color(0xFFE3F0EC), Color(0xFFF7FBF8)],
      food: [Color(0xFF81C7B0), Color(0xFFF3D9AE)],
      accent: Color(0xFF7BB39C),
      secondary: Color(0xFFF2C879),
      highlight: Color(0xFFFAF2DC),
      glow: Color(0x5581C7B0),
      secondaryGlow: Color(0x3FD7A25C),
    );
  }

  if (value.contains('mie')) {
    return const _RecipePalette(
      background: [Color(0xFFF7E8DD), Color(0xFFFFF9F2)],
      food: [Color(0xFFD7A063), Color(0xFFEAC38E)],
      accent: Color(0xFFD59B58),
      secondary: Color(0xFF8DC48A),
      highlight: Color(0xFFF5E6B6),
      glow: Color(0x55D59B58),
      secondaryGlow: Color(0x3F8DC48A),
    );
  }

  if (value.contains('tahu') || value.contains('tempe')) {
    return const _RecipePalette(
      background: [Color(0xFFF4ECDD), Color(0xFFF8FBF5)],
      food: [Color(0xFFC18D57), Color(0xFFD9B181)],
      accent: Color(0xFFC18D57),
      secondary: Color(0xFF95BD7A),
      highlight: Color(0xFFF7E9BB),
      glow: Color(0x55C18D57),
      secondaryGlow: Color(0x3F95BD7A),
    );
  }

  if (value.contains('telur')) {
    return const _RecipePalette(
      background: [Color(0xFFF4F0E5), Color(0xFFF9FCF6)],
      food: [Color(0xFFF0BE60), Color(0xFFF3DBA8)],
      accent: Color(0xFFE1B35C),
      secondary: Color(0xFF8DBE7A),
      highlight: Color(0xFFF9F0D2),
      glow: Color(0x55E1B35C),
      secondaryGlow: Color(0x3F8DBE7A),
    );
  }

  if (value.contains('nasi')) {
    return const _RecipePalette(
      background: [Color(0xFFF3E9D9), Color(0xFFF8FBF7)],
      food: [Color(0xFFE2AB61), Color(0xFFF0D39B)],
      accent: Color(0xFFD39B58),
      secondary: Color(0xFF96C280),
      highlight: Color(0xFFF8F0CF),
      glow: Color(0x55D39B58),
      secondaryGlow: Color(0x3F96C280),
    );
  }

  return const _RecipePalette(
    background: [Color(0xFFF0F3E8), Color(0xFFF9FCF8)],
    food: [Color(0xFFB9D48E), Color(0xFFE2C18A)],
    accent: Color(0xFF9CB47F),
    secondary: Color(0xFFF0C768),
    highlight: Color(0xFFF7EDC8),
    glow: Color(0x559CB47F),
    secondaryGlow: Color(0x3FF0C768),
  );
}

String _imageUrlFor(Recipe recipe) {
  final current = recipe.imageUrl?.trim();
  if (current != null &&
      current.isNotEmpty &&
      !current.contains('images.unsplash.com') &&
      !current.contains('source.unsplash.com')) {
    return current;
  }

  return recipePhotoUrlFor(recipe.name);
}

IconData _iconForRecipe(String recipeName) {
  final value = recipeName.toLowerCase();
  if (value.contains('nasi')) {
    return Icons.rice_bowl_rounded;
  }
  if (value.contains('sup')) {
    return Icons.soup_kitchen_rounded;
  }
  if (value.contains('mie')) {
    return Icons.ramen_dining_rounded;
  }
  if (value.contains('tahu') || value.contains('tempe')) {
    return Icons.lunch_dining_rounded;
  }
  if (value.contains('telur')) {
    return Icons.egg_alt_rounded;
  }
  return Icons.restaurant_rounded;
}
