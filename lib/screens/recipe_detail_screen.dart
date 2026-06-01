import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/recipe_detail_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/cooking_step_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_title.dart';
import '../widgets/serving_counter.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<RecipeDetailProvider>().loadRecipeDetails(widget.recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SafeArea(
        child: Consumer<RecipeDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Detail resep belum tersedia',
                  message: provider.errorMessage!,
                  actionLabel: 'Coba Lagi',
                  onAction: () => provider.loadRecipeDetails(widget.recipe),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _RecipeHero(recipe: widget.recipe),
                const SizedBox(height: 18),
                Text(
                  widget.recipe.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.recipe.description.isEmpty
                      ? 'Resep rumahan sederhana yang cocok dimasak dari stok bahan yang tersedia.'
                      : widget.recipe.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoPill(
                      icon: Icons.timer_outlined,
                      label: '${widget.recipe.cookingTime} Min',
                    ),
                    const _InfoPill(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Mudah',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Atur Porsi',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sesuaikan bahan masakan',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 152,
                        child: ServingCounter(
                          value: provider.selectedServing,
                          onIncrement: provider.incrementServing,
                          onDecrement: provider.decrementServing,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: 'Bahan-bahan',
                  subtitle: 'Takaran menyesuaikan jumlah porsi yang dipilih.',
                  compact: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${provider.ingredients.length} item',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.ingredients.map(
                  (ingredient) => _IngredientTile(
                    ingredient: ingredient,
                    adjustedAmount: provider.adjustedAmount(ingredient),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Langkah Memasak',
                  subtitle: 'Ikuti langkah berikut secara berurutan.',
                  compact: true,
                ),
                const SizedBox(height: 12),
                ...provider.steps.map((step) => CookingStepItem(step: step)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  const _RecipeHero({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: imageUrl == null || imageUrl.isEmpty
            ? Container(
                color: AppColors.primarySoft,
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 72,
                  color: AppColors.primary,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: AppColors.primarySoft,
                    child: const Icon(
                      Icons.restaurant_rounded,
                      size: 72,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    required this.adjustedAmount,
  });

  final RecipeIngredient ingredient;
  final double adjustedAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          Expanded(
            child: Text(
              ingredient.ingredientName ?? 'Bahan',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${_formatAmount(adjustedAmount)} ${ingredient.unit}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
