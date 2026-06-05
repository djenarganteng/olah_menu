import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ingredient_provider.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/recipe_detail_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/cooking_step_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/local_favorites_store.dart';
import '../widgets/section_title.dart';
import '../widgets/serving_counter.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.selectedIngredientIds,
  });

  final Recipe recipe;
  final Set<int>? selectedIngredientIds;

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
    final selectedIngredientIds =
        widget.selectedIngredientIds ??
        context
            .watch<IngredientProvider>()
            .selectedIngredients
            .map((item) => item.id)
            .toSet();

    return Scaffold(
      appBar: AppHeader(
        title: 'Detail Resep',
        trailing: ValueListenableBuilder<Set<int>>(
          valueListenable: LocalFavoritesStore.favorites,
          builder: (context, favorites, _) {
            final isFavorite = favorites.contains(widget.recipe.id);
            return IconButton(
              onPressed: () async {
                await LocalFavoritesStore.toggle(widget.recipe.id);
                final message = isFavorite
                    ? 'Resep dihapus dari favorit.'
                    : 'Resep disimpan ke favorit.';
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? const Color(0xFFD94B68)
                    : AppColors.primaryDark,
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<RecipeDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: LoadingState(
                  title: 'Memuat detail resep',
                  message:
                      'Bahan, langkah memasak, dan porsi sedang disiapkan.',
                ),
              );
            }

            if (provider.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Detail resep belum tersedia',
                  message: 'Gagal memuat data. Periksa koneksi internet kamu.',
                  actionLabel: 'Coba lagi',
                  onAction: () => provider.loadRecipeDetails(widget.recipe),
                ),
              );
            }

            final requiredIngredients = provider.ingredients
                .where((item) => item.isRequired)
                .toList();
            final optionalIngredients = provider.ingredients
                .where((item) => !item.isRequired)
                .toList();
            final sortedSteps = [...provider.steps]
              ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _RecipeHero(recipe: widget.recipe),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.recipe.description.isEmpty
                            ? 'Resep rumahan yang mudah diikuti dan cocok dimasak dari stok bahan yang tersedia.'
                            : widget.recipe.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: '${widget.recipe.cookingTime} menit',
                          ),
                          _InfoPill(
                            icon: Icons.people_alt_outlined,
                            label: '${provider.selectedServing} porsi',
                          ),
                          const _InfoPill(
                            icon: Icons.local_fire_department_outlined,
                            label: 'Mudah',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                              'Takaran bahan akan berubah otomatis.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 180,
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
                  subtitle:
                      'Semua takaran sudah disesuaikan dengan porsi pilihanmu.',
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const _IngredientGroupTitle(title: 'Wajib'),
                      ...requiredIngredients.map(
                        (ingredient) => _IngredientTile(
                          ingredient: ingredient,
                          adjustedAmount: provider.adjustedAmount(ingredient),
                          isOwned: selectedIngredientIds.contains(
                            ingredient.ingredientId,
                          ),
                        ),
                      ),
                      if (optionalIngredients.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const _IngredientGroupTitle(title: 'Opsional'),
                        ...optionalIngredients.map(
                          (ingredient) => _IngredientTile(
                            ingredient: ingredient,
                            adjustedAmount: provider.adjustedAmount(ingredient),
                            isOwned: selectedIngredientIds.contains(
                              ingredient.ingredientId,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Langkah Memasak',
                  subtitle:
                      'Ikuti urutan berikut agar proses memasak terasa lebih rapi dan mudah.',
                  compact: true,
                ),
                const SizedBox(height: 12),
                ...sortedSteps.asMap().entries.map(
                  (entry) => CookingStepItem(
                    step: entry.value,
                    isLast: entry.key == sortedSteps.length - 1,
                  ),
                ),
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
      child: Stack(
        children: [
          AspectRatio(
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xB2000000),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masak nyaman dengan langkah yang ringkas dan bahan yang sudah terukur.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

class _IngredientGroupTitle extends StatelessWidget {
  const _IngredientGroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    required this.adjustedAmount,
    this.isOwned,
  });

  final RecipeIngredient ingredient;
  final double adjustedAmount;
  final bool? isOwned;

  @override
  Widget build(BuildContext context) {
    final isChecked = isOwned == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.border,
                width: 1.4,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.ingredientName ?? 'Bahan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredient.isRequired ? 'Wajib' : 'Opsional',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ingredient.isRequired
                        ? AppColors.primaryDark
                        : AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(adjustedAmount)} ${ingredient.unit}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
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
