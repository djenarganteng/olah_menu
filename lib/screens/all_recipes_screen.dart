import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/recipe_summary_card.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

enum RecipeListFilter { all, quick, easy, fewerIngredients }

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  late Future<_RecipeCatalogData> _future;
  final _searchController = TextEditingController();
  RecipeListFilter _selectedFilter = RecipeListFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF9FBF8),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: 'Daftar Resep'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFF9FBF8)),
            ),
          ),
          const Positioned(
            left: -130,
            top: -160,
            child: _SoftBlob(
              size: 320,
              colors: [Color(0x66DFF2D8), Color(0x00DFF2D8)],
            ),
          ),
          const Positioned(
            right: -150,
            bottom: -170,
            child: _SoftBlob(
              size: 360,
              colors: [Color(0x66D7F0CC), Color(0x00D7F0CC)],
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.24,
              child: Image.asset(
                'assets/backgrounds/favorites_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: FutureBuilder<_RecipeCatalogData>(
              future: _future,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final recipes = data == null
                    ? const <Recipe>[]
                    : _filterRecipes(data.recipes, data.ingredientsMap);
                final selectedIngredients =
                    context.watch<IngredientProvider>().selectedIngredients;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 103, 16, 20),
                  children: [
                    _SearchField(
                      controller: _searchController,
                      query: _query,
                      onChanged: (value) => setState(() => _query = value),
                      onClear: _resetSearchAndFilter,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: RecipeListFilter.values.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = RecipeListFilter.values[index];
                          return ChoiceChip(
                            label: Text(_labelFor(filter)),
                            selected: _selectedFilter == filter,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (snapshot.connectionState != ConnectionState.done)
                      const LoadingState(
                        title: 'Memuat daftar resep',
                        message: 'Kami sedang menyiapkan resep yang tersedia.',
                        compact: true,
                      )
                    else if (snapshot.hasError)
                      EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Gagal memuat resep',
                        message: 'Periksa koneksi internet kamu lalu coba lagi.',
                        actionLabel: 'Coba lagi',
                        onAction: _reloadData,
                      )
                    else if (recipes.isEmpty)
                      EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Resep tidak ditemukan',
                        message:
                            'Coba ubah kata kunci pencarian atau pilih filter lain.',
                        actionLabel: 'Reset pencarian',
                        onAction: _resetSearchAndFilter,
                      )
                    else ...[
                      Text(
                        '${recipes.length} resep ditemukan',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: recipes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          final count = data?.ingredientsMap[recipe.id]?.length ?? 0;
                          final matchPercentage = data == null
                              ? null
                              : _RecipeMatch.calculate(
                                  recipeIngredients:
                                      data.ingredientsMap[recipe.id] ??
                                      const <RecipeIngredient>[],
                                  selectedIngredients: selectedIngredients,
                                )?.percentage;
                          return RecipeSummaryCard(
                            recipe: recipe,
                            ingredientCount: count,
                            matchPercentage: matchPercentage,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RecipeDetailScreen(
                                    recipe: recipe,
                                    heroTag: 'recipe-image-${recipe.id}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
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
          final aCount = ingredientMap[a.id]?.where((e) => e.isRequired).length ?? 0;
          final bCount = ingredientMap[b.id]?.where((e) => e.isRequired).length ?? 0;
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

  void _resetSearchAndFilter() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedFilter = RecipeListFilter.all;
    });
  }

  void _reloadData() {
    setState(() {
      _future = _loadData();
    });
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
    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      );
    }
  }
}

class _RecipeMatch {
  const _RecipeMatch._(this.percentage);

  final int percentage;

  static _RecipeMatch? calculate({
    required List<RecipeIngredient> recipeIngredients,
    required List<Ingredient> selectedIngredients,
  }) {
    if (recipeIngredients.isEmpty || selectedIngredients.isEmpty) {
      return null;
    }

    final selectedIngredientIds = selectedIngredients.map((item) => item.id).toSet();
    final selectedIngredientNames = selectedIngredients
        .map((item) => item.name.trim().toLowerCase().replaceAll('pakcoy', 'pokcoy'))
        .toSet();

    bool isMatched(RecipeIngredient item) {
      final ingredientName = item.ingredientName
          ?.trim()
          .toLowerCase()
          .replaceAll('pakcoy', 'pokcoy');
      return selectedIngredientIds.contains(item.ingredientId) ||
          (ingredientName != null && selectedIngredientNames.contains(ingredientName));
    }

    final requiredIngredients = recipeIngredients.where((item) => item.isRequired).toList();
    final optionalIngredients = recipeIngredients.where((item) => !item.isRequired).toList();
    final matchedRequiredCount = requiredIngredients.where(isMatched).length;
    final matchedOptionalCount = optionalIngredients.where(isMatched).length;
    final matchedIngredientCount = matchedRequiredCount + matchedOptionalCount;

    if (matchedIngredientCount == 0) {
      return null;
    }

    final requiredScore = requiredIngredients.isEmpty
        ? 1.0
        : matchedRequiredCount / requiredIngredients.length;
    final optionalScore = optionalIngredients.isEmpty
        ? 1.0
        : matchedOptionalCount / optionalIngredients.length;
    final percentage = ((requiredScore * 0.7 + optionalScore * 0.3) * 100)
        .round()
        .clamp(0, 100);

    return _RecipeMatch._(percentage);
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

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x13000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari resep...',
          prefixIcon: const Icon(Icons.search_rounded, size: 28),
          suffixIcon: query.trim().isEmpty
              ? null
              : IconButton(
                  tooltip: 'Bersihkan pencarian',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
