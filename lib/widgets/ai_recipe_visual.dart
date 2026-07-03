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
    final palette = kAiRecipeHeroPalette;

    Widget visual = ClipRRect(
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
              top: -height * 0.2,
              right: -height * 0.14,
              child: _GlowBlob(
                color: palette.accent.withValues(alpha: 0.18),
                size: height * 0.72,
              ),
            ),
            Positioned(
              left: -height * 0.16,
              bottom: -height * 0.18,
              child: _GlowBlob(
                color: palette.surface.withValues(alpha: 0.68),
                size: height * 0.64,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _AiPatternPainter(
                  accent: palette.accent.withValues(alpha: 0.12),
                  surface: palette.highlight.withValues(alpha: 0.26),
                ),
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
            Center(
              child: Container(
                width: height * 0.82,
                height: height * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.58),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            palette.surface.withValues(alpha: 0.98),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.restaurant_rounded,
                      size: height * 0.18,
                      color: palette.accent,
                    ),
                    Positioned(
                      right: height * 0.13,
                      top: height * 0.13,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: height * 0.055,
                          color: palette.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _MiniChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Recipe',
                  background: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ),
          ],
        ),
      ),
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

    return visual;
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryDark),
          const SizedBox(width: 5),
          Text(
            label,
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

class _AiPatternPainter extends CustomPainter {
  const _AiPatternPainter({
    required this.accent,
    required this.surface,
  });

  final Color accent;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()..color = accent;

    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 9; col++) {
        final offsetX = size.width * 0.08 + col * size.width * 0.11;
        final offsetY = size.height * 0.12 + row * size.height * 0.12;
        canvas.drawCircle(
          Offset(offsetX, offsetY),
          row.isEven ? 1.6 : 1.2,
          accentPaint,
        );
      }
    }

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.02,
        size.width * 0.62,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.38,
        size.width * 0.9,
        size.height * 0.1,
      );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = surface,
    );
  }

  @override
  bool shouldRepaint(covariant _AiPatternPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.surface != surface;
  }
}
