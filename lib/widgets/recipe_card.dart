import 'package:flutter/material.dart';

import '../models/recipe_recommendation.dart';
import '../theme/app_colors.dart';
import 'local_favorites_store.dart';
import 'recipe_visual.dart';

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
    final missingSummary = recommendation.missingRequiredIngredients
        .take(2)
        .join(', ');
    final hasMissingRequired =
        recommendation.missingRequiredIngredients.isNotEmpty;

    return ValueListenableBuilder<Set<int>>(
      valueListenable: LocalFavoritesStore.favorites,
      builder: (context, favorites, _) {
        final isFavorite = favorites.contains(recipe.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    RecipeVisual(
                      recipe: recipe,
                      height: 176,
                      borderRadius: 28,
                      showFavoriteAction: true,
                      isFavorite: isFavorite,
                      onFavoriteTap: () async {
                        await LocalFavoritesStore.toggle(recipe.id);
                      },
                      topLabel:
                          '${recommendation.matchLabel} · ${recommendation.matchPercentage.toStringAsFixed(0)}%',
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${recommendation.matchedIngredientCount}/${recommendation.totalIngredients} bahan',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description.isEmpty
                            ? 'Resep cepat dari bahan yang tersedia di rumah.'
                            : recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoft,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaPill(
                            icon: Icons.schedule_rounded,
                            label: '${recipe.cookingTime} menit',
                          ),
                          _MetaPill(
                            icon: Icons.people_alt_outlined,
                            label: '${recipe.defaultServing} porsi',
                          ),
                          const _MetaPill(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Mudah',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasMissingRequired
                                  ? 'Perlu ditambah: $missingSummary${recommendation.missingRequiredIngredients.length > 2 ? '...' : ''}'
                                  : 'Semua bahan wajib sudah ada.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasMissingRequired
                                        ? AppColors.danger
                                        : AppColors.textSoft,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: recommendation.matchPercentage / 100,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(999),
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onTap,
                          child: const Text('Lihat Resep'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
