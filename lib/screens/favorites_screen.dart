import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_recipe.dart';
import '../models/recipe.dart';
import '../services/supabase_service.dart';
import '../widgets/ai_recipe_card.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/local_favorites_store.dart';
import '../widgets/recipe_summary_card.dart';
import 'all_recipes_screen.dart';
import 'ingredient_selection_screen.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Recipe>> _future;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ValueListenableBuilder<Set<int>>(
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

                      final recipes = snapshot.data!
                          .where((recipe) => favorites.contains(recipe.id))
                          .toList();
                      final favoriteCards = <Widget>[
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
                        return const EmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: 'Belum ada resep favorit',
                          message:
                              'Simpan resep yang kamu suka agar mudah ditemukan lagi.',
                        );
                      }

                      return ListView.separated(
                        itemCount: favoriteCards.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => favoriteCards[index],
                      );
                    },
                  );
                },
              );
            },
          ),
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
    }
  }
}
