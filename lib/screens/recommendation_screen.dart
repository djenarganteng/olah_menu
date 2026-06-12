import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe_recommendation.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/recipe_card.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'recipe_detail_screen.dart';

enum RecommendationFilter { bestMatch, quick, missingFew, easy }

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key, required this.selectedIngredients});

  final List<Ingredient> selectedIngredients;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  RecommendationFilter _selectedFilter = RecommendationFilter.bestMatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<RecommendationProvider>().fetchRecommendations(
        widget.selectedIngredients,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Recipe Results'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: SafeArea(
        child: Consumer<RecommendationProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    selectedCount: widget.selectedIngredients.length,
                    onFilterTap: () => _showFilterSheet(context),
                  ),
                  const SizedBox(height: 12),
                  _SelectedIngredientSummary(
                    ingredients: widget.selectedIngredients,
                  ),
                  const SizedBox(height: 14),
                  Expanded(child: _buildContent(context, provider)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RecommendationProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(
        title: 'Mencari resep terbaik...',
        message:
            'Kami sedang mencocokkan bahan pilihanmu dengan resep yang tersedia.',
        compact: true,
      );
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Rekomendasi belum tersedia',
        message: 'Gagal memuat data. Periksa koneksi internet kamu.',
        actionLabel: 'Coba lagi',
        onAction: () =>
            provider.fetchRecommendations(widget.selectedIngredients),
      );
    }

    if (provider.recommendations.isEmpty) {
      return EmptyState(
        icon: Icons.ramen_dining_outlined,
        title: 'Belum ada resep yang cocok',
        message:
            'Coba tambah bahan seperti telur, nasi, bawang, atau minyak agar pilihan resep lebih banyak.',
        actionLabel: 'Tambah Bahan',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    final sortedRecommendations = _applyFilter(provider.recommendations);

    return ListView.builder(
      itemCount: sortedRecommendations.length,
      itemBuilder: (context, index) {
        final recommendation = sortedRecommendations[index];
        return RecipeCard(
          recommendation: recommendation,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecipeDetailScreen(
                  recipe: recommendation.recipe,
                  selectedIngredientIds: widget.selectedIngredients
                      .map((item) => item.id)
                      .toSet(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<RecipeRecommendation> _applyFilter(
    List<RecipeRecommendation> recommendations,
  ) {
    final items = List<RecipeRecommendation>.from(recommendations);

    switch (_selectedFilter) {
      case RecommendationFilter.bestMatch:
        items.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
        break;
      case RecommendationFilter.quick:
        items.sort(
          (a, b) => a.recipe.cookingTime.compareTo(b.recipe.cookingTime),
        );
        break;
      case RecommendationFilter.missingFew:
        items.sort(
          (a, b) => a.missingIngredients.length.compareTo(
            b.missingIngredients.length,
          ),
        );
        break;
      case RecommendationFilter.easy:
        items.sort((a, b) => a.totalIngredients.compareTo(b.totalIngredients));
        break;
    }

    return items;
  }

  String _labelForFilter(RecommendationFilter filter) {
    switch (filter) {
      case RecommendationFilter.bestMatch:
        return 'Paling Cocok';
      case RecommendationFilter.quick:
        return 'Cepat';
      case RecommendationFilter.missingFew:
        return 'Bahan Kurang Sedikit';
      case RecommendationFilter.easy:
        return 'Mudah';
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter resep',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...RecommendationFilter.values.map((filter) {
                final selected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primarySoft
                            : AppColors.backgroundSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSoft,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _labelForFilter(filter),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.primaryDark
                                        : AppColors.text,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const IngredientSelectionScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.selectedCount, required this.onFilterTap});

  final int selectedCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipe Results',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$selectedCount ingredients selected',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onFilterTap,
          icon: const Icon(Icons.filter_alt_rounded),
        ),
      ],
    );
  }
}

class _SelectedIngredientSummary extends StatelessWidget {
  const _SelectedIngredientSummary({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    const maxVisible = 5;
    final visibleIngredients = ingredients.take(maxVisible).toList();
    final remainingCount = ingredients.length - visibleIngredients.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Bahan dipilih:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSoft,
            ),
          ),
          ...visibleIngredients.map(
            (ingredient) => _IngredientPill(label: ingredient.name),
          ),
          if (remainingCount > 0)
            _IngredientPill(label: '+$remainingCount lainnya'),
        ],
      ),
    );
  }
}

class _IngredientPill extends StatelessWidget {
  const _IngredientPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
