import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_recipe.dart';
import '../models/recipe.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_recipe_card.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/local_favorites_store.dart';
import '../widgets/recipe_summary_card.dart';
import 'all_recipes_screen.dart';
import 'ingredient_selection_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

enum FavoriteFilter { all, database, ai }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Recipe>> _future;
  FavoriteFilter _selectedFilter = FavoriteFilter.all;

  @override
  void initState() {
    super.initState();
    _future = context.read<SupabaseService>().getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Favorit'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            Text(
              'Resep yang kamu simpan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Semua resep database dan AI yang sudah kamu favoritkan ada di sini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoft,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FavoriteFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(_labelFor(filter)),
                  selected: _selectedFilter == filter,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<Set<int>>(
              valueListenable: LocalFavoritesStore.favorites,
              builder: (context, favorites, _) {
                return ValueListenableBuilder<List<AiRecipe>>(
                  valueListenable: LocalFavoritesStore.aiFavorites,
                  builder: (context, aiFavorites, _) {
                    return FutureBuilder<List<Recipe>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LoadingState(
                            title: 'Memuat favorit',
                            message:
                                'Kami sedang menyiapkan resep yang sudah kamu simpan.',
                            compact: true,
                          );
                        }

                        if (snapshot.hasError) {
                          return EmptyState(
                            icon: Icons.cloud_off_rounded,
                            title: 'Favorit belum bisa dimuat',
                            message:
                                'Periksa koneksi internet kamu lalu coba lagi.',
                            actionLabel: 'Coba lagi',
                            onAction: () {
                              setState(() {
                                _future = context
                                    .read<SupabaseService>()
                                    .getRecipes();
                              });
                            },
                          );
                        }

                        final favoriteOrder = favorites.toList().reversed;
                        final recipeById = {
                          for (final recipe in snapshot.data!)
                            recipe.id: recipe,
                        };
                        final recipes = favoriteOrder
                            .map((id) => recipeById[id])
                            .whereType<Recipe>()
                            .toList();
                        final visibleCount =
                            (_selectedFilter == FavoriteFilter.ai
                                ? 0
                                : recipes.length) +
                            (_selectedFilter == FavoriteFilter.database
                                ? 0
                                : aiFavorites.length);
                        final favoriteCards = <Widget>[
                          if (_selectedFilter != FavoriteFilter.ai)
                            ...recipes.map(
                              (recipe) => RecipeSummaryCard(
                                recipe: recipe,
                                ingredientCount: 0,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (_selectedFilter != FavoriteFilter.database)
                            ...aiFavorites.map(
                              (recipe) => AiRecipeCard(
                                recipe: recipe,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          RecipeDetailScreen.ai(recipe: recipe),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ];

                        if (favoriteCards.isEmpty) {
                          return EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: 'Belum ada resep favorit',
                            message:
                                'Simpan resep yang kamu suka agar mudah ditemukan lagi.',
                            actionLabel: 'Cari Resep',
                            onAction: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AllRecipesScreen(),
                                ),
                              );
                            },
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$visibleCount resep tersimpan',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSoft,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: favoriteCards.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  favoriteCards[index],
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
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
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()),
      );
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      );
    }
  }

  String _labelFor(FavoriteFilter filter) {
    switch (filter) {
      case FavoriteFilter.all:
        return 'Semua';
      case FavoriteFilter.database:
        return 'Database';
      case FavoriteFilter.ai:
        return 'AI';
    }
  }
}
