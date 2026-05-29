import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/recipe_detail_provider.dart';
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
      appBar: AppBar(title: Text(widget.recipe.name)),
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
                const SizedBox(height: 20),
                Text(
                  widget.recipe.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.recipe.description.isEmpty
                      ? 'Resep rumahan sederhana yang cocok dimasak dari stok bahan yang tersedia.'
                      : widget.recipe.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoPill(
                      icon: Icons.timer_outlined,
                      label: '${widget.recipe.cookingTime} menit',
                    ),
                    _InfoPill(
                      icon: Icons.people_alt_outlined,
                      label: '${widget.recipe.defaultServing} porsi',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: 'Atur Porsi',
                  subtitle:
                      'Bahan akan dihitung ulang dari porsi dasar ${widget.recipe.defaultServing}.',
                ),
                const SizedBox(height: 12),
                ServingCounter(
                  value: provider.selectedServing,
                  onIncrement: provider.incrementServing,
                  onDecrement: provider.decrementServing,
                ),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Bahan',
                  subtitle:
                      'Takaran bahan menyesuaikan jumlah porsi yang dipilih.',
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
                color: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 72,
                  color: Color(0xFF2E7D32),
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      size: 72,
                      color: Color(0xFF2E7D32),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF9800)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
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
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w800,
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
