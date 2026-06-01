import 'package:flutter/material.dart';

import '../models/recipe_recommendation.dart';
import '../theme/app_colors.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  final RecipeRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: recipe.imageUrl == null || recipe.imageUrl!.isEmpty
                        ? Container(
                            color: AppColors.primarySoft,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 44,
                              color: AppColors.primary,
                            ),
                          )
                        : Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primarySoft,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 44,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${recommendation.matchPercentage.toStringAsFixed(0)}% Cocok',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.access_time_rounded,
                        label: '${recipe.cookingTime} Min',
                      ),
                      _MetaChip(
                        icon: Icons.people_outline_rounded,
                        label: '${recipe.defaultServing} Porsi',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          recommendation.missingIngredients.isEmpty
                              ? 'Semua bahan utama sudah tersedia'
                              : 'Bahan kurang: ${recommendation.missingIngredients.join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
