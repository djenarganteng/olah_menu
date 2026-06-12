import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/recipe_summary_card.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'recipe_detail_screen.dart';

enum RecipeListFilter { all, quick, easy, fewerIngredients }

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  late Future<_RecipeCatalogData> _future;
  RecipeListFilter _selectedFilter = RecipeListFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_RecipeCatalogData> _loadData() async {
    final service = context.read<SupabaseService>();
    final recipes = await service.getRecipes();
    final ingredients = await service.getAllRecipeIngredientsWithIngredient();

    final ingredientMap = <int, List<RecipeIngredient>>{};
    for (final item in ingredients) {
      ingredientMap.putIfAbsent(item.recipeId, () => []).add(item);
    }

    return _RecipeCatalogData(recipes: recipes, ingredientsMap: ingredientMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'All Recipes'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const _SoftGlow(top: -60, right: -50, size: 160),
          const _SoftGlow(bottom: 140, left: -40, size: 150),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) => setState(() => _query = value),
                          decoration: const InputDecoration(
                            hintText: 'Cari resep...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: RecipeListFilter.values.map((filter) {
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: FutureBuilder<_RecipeCatalogData>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LoadingState(
                            title: 'Memuat daftar resep',
                            message:
                                'Kami sedang menyiapkan resep yang tersedia.',
                            compact: true,
                          );
                        }

                        if (snapshot.hasError) {
                          return EmptyState(
                            icon: Icons.cloud_off_rounded,
                            title: 'Gagal memuat resep',
                            message:
                                'Periksa koneksi internet kamu lalu coba lagi.',
                            actionLabel: 'Coba lagi',
                            onAction: () {
                              setState(() {
                                _future = _loadData();
                              });
                            },
                          );
                        }

                        final data = snapshot.data!;
                        final recipes = _filterRecipes(
                          data.recipes,
                          data.ingredientsMap,
                        );

                        if (recipes.isEmpty) {
                          return const EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'Resep tidak ditemukan',
                            message:
                                'Coba ubah kata kunci pencarian atau pilih filter lain.',
                          );
                        }

                        return ListView.builder(
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            final count =
                                data.ingredientsMap[recipe.id]?.length ?? 0;
                            return RecipeSummaryCard(
                              recipe: recipe,
                              ingredientCount: count,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
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

  List<Recipe> _filterRecipes(
    List<Recipe> recipes,
    Map<int, List<RecipeIngredient>> ingredientMap,
  ) {
    final query = _query.trim().toLowerCase();
    final filtered = recipes.where((recipe) {
      return query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query);
    }).toList();

    switch (_selectedFilter) {
      case RecipeListFilter.all:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RecipeListFilter.quick:
        filtered.sort((a, b) => a.cookingTime.compareTo(b.cookingTime));
        break;
      case RecipeListFilter.easy:
        filtered.sort((a, b) {
          final aCount = ingredientMap[a.id]?.length ?? 0;
          final bCount = ingredientMap[b.id]?.length ?? 0;
          return aCount.compareTo(bCount);
        });
        break;
      case RecipeListFilter.fewerIngredients:
        filtered.sort((a, b) {
          final aCount =
              ingredientMap[a.id]?.where((e) => e.isRequired).length ?? 0;
          final bCount =
              ingredientMap[b.id]?.where((e) => e.isRequired).length ?? 0;
          return aCount.compareTo(bCount);
        });
        break;
    }

    return filtered;
  }

  String _labelFor(RecipeListFilter filter) {
    switch (filter) {
      case RecipeListFilter.all:
        return 'Semua';
      case RecipeListFilter.quick:
        return 'Cepat';
      case RecipeListFilter.easy:
        return 'Mudah';
      case RecipeListFilter.fewerIngredients:
        return 'Bahan Sedikit';
    }
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
    }
  }
}

class _RecipeCatalogData {
  const _RecipeCatalogData({
    required this.recipes,
    required this.ingredientsMap,
  });

  final List<Recipe> recipes;
  final Map<int, List<RecipeIngredient>> ingredientsMap;
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x335F8F57), Color(0x005F8F57)],
            ),
          ),
        ),
      ),
    );
  }
}
