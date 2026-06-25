import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/auth_provider.dart';
import '../providers/ingredient_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/local_favorites_store.dart';
import '../widgets/recipe_visual.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_HomeData> _loadData() async {
    final service = context.read<SupabaseService>();
    final recipes = await service.getRecipes();
    final ingredients = await service.getAllRecipeIngredientsWithIngredient();

    final ingredientMap = <int, List<RecipeIngredient>>{};
    for (final item in ingredients) {
      ingredientMap.putIfAbsent(item.recipeId, () => []).add(item);
    }

    return _HomeData(recipes: recipes, ingredientsMap: ingredientMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F4E6),
      extendBodyBehindAppBar: true,
      appBar: AppHeader(
        title: 'OlahMenu',
        showBackButton: false,
        onLeadingTap: _showLogoutConfirmation,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE4F1E0), Color(0xFFF7FAF4)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.48,
              child: Image.asset(
                'assets/backgrounds/home_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              final recipes = snapshot.data?.recipes ?? const <Recipe>[];
              final ingredientsMap =
                  snapshot.data?.ingredientsMap ??
                  const <int, List<RecipeIngredient>>{};
              final selectedIngredients = context
                  .watch<IngredientProvider>()
                  .selectedIngredients;

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _HeroBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resep Rekomendasi Hari Ini',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (snapshot.connectionState != ConnectionState.done)
                    const SliverToBoxAdapter(child: _GridShimmer())
                  else if (recipes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _RecommendationGrid(
                        recipes: recipes.take(6).toList(),
                        ingredientsMap: ingredientsMap,
                        selectedIngredients: selectedIngredients,
                        onTap: (recipe, heroTag) => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecipeDetailScreen(
                              recipe: recipe,
                              heroTag: heroTag,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (snapshot.connectionState == ConnectionState.done &&
                      recipes.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 34, 24, 14),
                        child: Text(
                          'Koleksi Rekomendasi Resep',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.text,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final recipe = recipes[index % recipes.length];
                        final match = _RecipeMatch.calculate(
                          recipeIngredients:
                              ingredientsMap[recipe.id] ??
                              const <RecipeIngredient>[],
                          selectedIngredients: selectedIngredients,
                        );
                        return Padding(
                          key: ValueKey('home-collection-${recipe.id}-$index'),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: _CollectionTile(
                            recipe: recipe,
                            match: match,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => RecipeDetailScreen(
                                  recipe: recipe,
                                  heroTag:
                                      'recipe-image-collection-${recipe.id}',
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: recipes.length),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const IngredientSelectionScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()));
      return;
    }

    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar sesi?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Apakah kamu yakin ingin logout dan kembali ke halaman login?',
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Tidak'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Iya'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _HomeData {
  const _HomeData({required this.recipes, required this.ingredientsMap});

  final List<Recipe> recipes;
  final Map<int, List<RecipeIngredient>> ingredientsMap;
}

class _RecipeMatch {
  const _RecipeMatch._({
    required this.percentage,
    required this.matchedIngredientCount,
    required this.totalIngredientCount,
  });

  final int percentage;
  final int matchedIngredientCount;
  final int totalIngredientCount;

  static _RecipeMatch? calculate({
    required List<RecipeIngredient> recipeIngredients,
    required List<Ingredient> selectedIngredients,
  }) {
    if (selectedIngredients.isEmpty || recipeIngredients.isEmpty) {
      return null;
    }

    final selectedIngredientIds = selectedIngredients
        .map((item) => item.id)
        .toSet();
    final selectedIngredientNames = selectedIngredients
        .map((item) => _normalizeIngredientName(item.name))
        .toSet();

    bool isMatched(RecipeIngredient item) {
      final itemName = item.ingredientName == null
          ? null
          : _normalizeIngredientName(item.ingredientName!);
      return selectedIngredientIds.contains(item.ingredientId) ||
          (itemName != null && selectedIngredientNames.contains(itemName));
    }

    final requiredIngredients = recipeIngredients
        .where((item) => item.isRequired)
        .toList();
    final optionalIngredients = recipeIngredients
        .where((item) => !item.isRequired)
        .toList();
    final matchedRequiredCount = requiredIngredients
        .where((item) => isMatched(item))
        .length;
    final matchedOptionalCount = optionalIngredients
        .where((item) => isMatched(item))
        .length;
    final matchedIngredientCount = matchedRequiredCount + matchedOptionalCount;

    final requiredScore = requiredIngredients.isEmpty
        ? 1.0
        : matchedRequiredCount / requiredIngredients.length;
    final optionalScore = optionalIngredients.isEmpty
        ? 1.0
        : matchedOptionalCount / optionalIngredients.length;
    final percentage = matchedIngredientCount == 0
        ? 0
        : ((requiredScore * 0.7 + optionalScore * 0.3) * 100).round().clamp(
            0,
            100,
          );

    return _RecipeMatch._(
      percentage: percentage,
      matchedIngredientCount: matchedIngredientCount,
      totalIngredientCount: recipeIngredients.length,
    );
  }
}

String _normalizeIngredientName(String value) {
  return value.trim().toLowerCase().replaceAll('pakcoy', 'pokcoy');
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 276,
      padding: const EdgeInsets.fromLTRB(24, 116, 24, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xDDE5F3DF), Color(0xCCB8DDB7)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -64,
            right: -28,
            child: _SoftCircle(size: 150, opacity: 0.18),
          ),
          Positioned(
            top: -10,
            right: 34,
            child: _SoftCircle(size: 92, opacity: 0.12),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masak dari bahan\nyang kamu punya.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 30,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Material(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IngredientSelectionScreen(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                      vertical: 13,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Pilih Bahan',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid({
    required this.recipes,
    required this.ingredientsMap,
    required this.selectedIngredients,
    required this.onTap,
  });

  final List<Recipe> recipes;
  final Map<int, List<RecipeIngredient>> ingredientsMap;
  final List<Ingredient> selectedIngredients;
  final void Function(Recipe, String) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 330 ? 2 : 3;
        final childAspectRatio = crossAxisCount == 2 ? 0.74 : 0.66;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final match = _RecipeMatch.calculate(
                recipeIngredients:
                    ingredientsMap[recipe.id] ?? const <RecipeIngredient>[],
                selectedIngredients: selectedIngredients,
              );
              final heroTag = 'recipe-image-grid-${recipe.id}';

              return _GridRecipeCard(
                key: ValueKey('home-grid-${recipe.id}'),
                recipe: recipe,
                match: match,
                heroTag: heroTag,
                onTap: () => onTap(recipe, heroTag),
              );
            },
          ),
        );
      },
    );
  }
}

class _GridRecipeCard extends StatelessWidget {
  const _GridRecipeCard({
    super.key,
    required this.recipe,
    required this.match,
    required this.heroTag,
    required this.onTap,
  });

  final Recipe recipe;
  final _RecipeMatch? match;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: LocalFavoritesStore.favorites,
      builder: (context, favorites, _) {
        final isFavorite = favorites.contains(recipe.id);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = (constraints.maxHeight * 0.49)
                    .clamp(74.0, 98.0)
                    .toDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RecipeVisual(
                              recipe: recipe,
                              height: imageHeight,
                              borderRadius: 0,
                              showFavoriteAction: false,
                              isFavorite: isFavorite,
                              heroTag: heroTag,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                await LocalFavoritesStore.toggle(recipe.id);
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
                                  color: isFavorite
                                      ? AppColors.danger
                                      : AppColors.textSoft,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 9, 9, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontSize: 12.2,
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Spacer(),
                            _RecipeMetaRow(recipe: recipe),
                            if (match != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${match!.percentage}% cocok',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RecipeMetaRow extends StatelessWidget {
  const _RecipeMetaRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.text,
      fontSize: 11,
      height: 1,
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSoft),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '${recipe.cookingTime}m',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.people_alt_outlined,
          size: 13,
          color: AppColors.textSoft,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '${recipe.defaultServing} porsi',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.recipe,
    required this.match,
    required this.onTap,
  });

  final Recipe recipe;
  final _RecipeMatch? match;
  final VoidCallback onTap;

  int get _stars => 3 + (recipe.id % 3);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 96,
                child: RecipeVisual(
                  recipe: recipe,
                  height: 96,
                  borderRadius: 0,
                  showFavoriteAction: false,
                  isFavorite: false,
                  heroTag: 'recipe-image-collection-${recipe.id}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _RecipeMetaRow(recipe: recipe),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < _stars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 15,
                              color: index < _stars
                                  ? const Color(0xFFE4A01A)
                                  : const Color(0xFFDDDDDD),
                            );
                          }),
                          if (match != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${match!.percentage}% cocok',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 330 ? 2 : 3;
        final childAspectRatio = crossAxisCount == 2 ? 0.74 : 0.66;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        );
      },
    );
  }
}
