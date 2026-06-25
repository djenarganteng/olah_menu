import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/ai_recipe_placeholders.dart';
import '../models/ai_recipe.dart';
import '../theme/app_colors.dart';

class AiRecipeVisual extends StatelessWidget {
  const AiRecipeVisual({
    super.key,
    required this.recipe,
    this.height = 210,
    this.borderRadius = 28,
    this.heroTag,
    this.showFavoriteAction = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final AiRecipe recipe;
  final double height;
  final double borderRadius;
  final String? heroTag;
  final bool showFavoriteAction;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final spec = aiRecipePlaceholderFor(recipe.title);
    final imageUrl = recipe.imageUrl?.trim();
    final hasNetworkImage = imageUrl != null && imageUrl.isNotEmpty;

    Widget visual = _buildVisualContent(
      context,
      spec: spec,
      hasNetworkImage: hasNetworkImage,
      imageUrl: imageUrl,
    );

    if (heroTag != null) {
      visual = Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: visual,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: spec.background,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -height * 0.2,
              right: -height * 0.12,
              child: _GlowBlob(color: spec.accent.withValues(alpha: 0.25), size: height * 0.72),
            ),
            Positioned(
              left: -height * 0.14,
              bottom: -height * 0.18,
              child: _GlowBlob(
                color: spec.surface.withValues(alpha: 0.55),
                size: height * 0.58,
              ),
            ),
            Positioned.fill(child: visual),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0x24000000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: _Badge(
                icon: Icons.auto_awesome_rounded,
                text: recipe.sourceBadgeLabel,
              ),
            ),
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
              left: 14,
              bottom: 14,
              child: _Badge(
                icon: spec.icon,
                text: spec.label,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualContent(
    BuildContext context, {
    required AiRecipePlaceholderSpec spec,
    required bool hasNetworkImage,
    required String? imageUrl,
  }) {
    if (hasNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => _FallbackArt(spec: spec),
        errorWidget: (context, url, error) => _FallbackArt(spec: spec),
      );
    }

    if (spec.assetPath != null) {
      return Image.asset(
        spec.assetPath!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _FallbackArt(spec: spec),
      );
    }

    return _FallbackArt(spec: spec);
  }
}

class _FallbackArt extends StatelessWidget {
  const _FallbackArt({required this.spec});

  final AiRecipePlaceholderSpec spec;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: spec.background,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: _Halo(color: spec.accent.withValues(alpha: 0.16), size: 72),
          ),
          Positioned(
            left: 14,
            bottom: 26,
            child: _Halo(color: spec.surface.withValues(alpha: 0.7), size: 96),
          ),
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.65),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              ),
              child: Icon(
                spec.icon,
                size: 54,
                color: spec.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.color, required this.size});

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
