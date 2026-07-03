import 'package:flutter/material.dart';

import '../models/ai_recipe.dart';
import '../theme/app_colors.dart';
import 'ai_recipe_visual.dart';
import 'local_favorites_store.dart';

class AiRecipeCard extends StatelessWidget {
  const AiRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.heroTag,
  });

  final AiRecipe recipe;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
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
            ValueListenableBuilder<List<AiRecipe>>(
              valueListenable: LocalFavoritesStore.aiFavorites,
              builder: (context, favorites, _) {
                final isFavorite = favorites.any((item) => item.id == recipe.id);

                return AiRecipeVisual(
                  recipe: recipe,
                  height: 188,
                  borderRadius: 28,
                  heroTag: heroTag ?? 'ai-recipe-${recipe.id}',
                  showFavoriteAction: true,
                  isFavorite: isFavorite,
                  onFavoriteTap: () => LocalFavoritesStore.toggleAiRecipe(
                    recipe,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: _AiBody(
                recipe: recipe,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBody extends StatelessWidget {
  const _AiBody({required this.recipe, required this.onTap});

  final AiRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final description = recipe.description.isEmpty
        ? 'Resep rumahan yang dibuat dari bahan pilihanmu.'
        : recipe.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(
              icon: Icons.smart_toy_rounded,
              label: recipe.aiBadgeLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          recipe.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoft,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          recipe.aiDisclosureText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoft,
            height: 1.35,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(
              icon: Icons.schedule_rounded,
              label: recipe.estimatedTime.isNotEmpty
                  ? recipe.estimatedTime
                  : '${recipe.cookingTime} menit',
            ),
            _MetaPill(
              icon: Icons.people_alt_outlined,
              label: '${recipe.servings} porsi',
            ),
            _MetaPill(
              icon: Icons.local_fire_department_rounded,
              label: recipe.difficulty,
            ),
          ],
        ),
        if (recipe.tips.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${recipe.tips.length} tips memasak siap dipakai',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Lihat Resep AI'),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
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
