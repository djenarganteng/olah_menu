import 'package:flutter/material.dart';

import '../models/recipe_recommendation.dart';
import '../theme/app_colors.dart';
import 'local_favorites_store.dart';

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

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${recommendation.matchLabel} • ${recommendation.matchPercentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<Set<int>>(
                    valueListenable: LocalFavoritesStore.favorites,
                    builder: (context, favorites, _) {
                      final isFavorite = favorites.contains(recipe.id);
                      return InkWell(
                        onTap: () async {
                          await LocalFavoritesStore.toggle(recipe.id);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFFDECEF)
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: isFavorite
                                ? const Color(0xFFD94B68)
                                : AppColors.textSoft,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description.isEmpty
                    ? 'Resep cepat dari bahan yang sudah tersedia di rumah.'
                    : recipe.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    label: '${recipe.cookingTime} menit',
                  ),
                  _MetaChip(
                    icon: Icons.people_alt_outlined,
                    label: '${recipe.defaultServing} porsi',
                  ),
                  const _MetaChip(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Mudah',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Kamu punya ${recommendation.matchedIngredientCount} dari ${recommendation.totalIngredients} bahan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                !hasMissingRequired
                    ? 'Semua bahan sudah siap dipakai.'
                    : 'Perlu ditambah: $missingSummary${recommendation.missingRequiredIngredients.length > 2 ? '...' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: !hasMissingRequired
                      ? AppColors.textSoft
                      : AppColors.danger,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lihat Resep',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
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
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
