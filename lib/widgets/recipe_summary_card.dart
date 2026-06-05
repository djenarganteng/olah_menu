import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_colors.dart';
import 'local_favorites_store.dart';

class RecipeSummaryCard extends StatelessWidget {
  const RecipeSummaryCard({
    super.key,
    required this.recipe,
    required this.ingredientCount,
    required this.onTap,
  });

  final Recipe recipe;
  final int ingredientCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.primaryDark,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<Set<int>>(
                          valueListenable: LocalFavoritesStore.favorites,
                          builder: (context, favorites, _) {
                            final isFavorite = favorites.contains(recipe.id);
                            return InkWell(
                              onTap: () async {
                                await LocalFavoritesStore.toggle(recipe.id);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
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
                    const SizedBox(height: 6),
                    Text(
                      recipe.description.isEmpty
                          ? 'Resep rumahan praktis untuk stok bahan sederhana.'
                          : recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SmallChip(
                          icon: Icons.schedule_rounded,
                          label: '${recipe.cookingTime} menit',
                        ),
                        _SmallChip(
                          icon: Icons.people_alt_outlined,
                          label: '${recipe.defaultServing} porsi',
                        ),
                        _SmallChip(
                          icon: Icons.ramen_dining_rounded,
                          label: ingredientCount > 0
                              ? '$ingredientCount bahan'
                              : 'Lihat detail',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
