import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/auth_provider.dart';
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
      backgroundColor: const Color(0xFFF4FAF5),
      extendBodyBehindAppBar: true,
      appBar: AppHeader(
        showBackButton: false,
        onLeadingTap: _showLogoutConfirmation,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          // Background: scattered vegetables on mint green
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF4FAF5), // Soft minty base color
                image: DecorationImage(
                  image: AssetImage('assets/backgrounds/home_bg.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  opacity: 0.15, // Faded for maximum contrast
                ),
              ),
            ),
          ),
          FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              return CustomScrollView(
                slivers: [
                  // ─── Hero Banner ───────────────────────────────────────────
                  SliverToBoxAdapter(child: _HeroBanner()),

                  // ─── Resep Rekomendasi Hari Ini (Grid) ─────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          const Text('🌿 '),
                          Text(
                            'Resep Rekomendasi Hari Ini',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (snapshot.connectionState != ConnectionState.done)
                    const SliverToBoxAdapter(child: _GridShimmer())
                  else if (snapshot.hasData &&
                      snapshot.data!.recipes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _RecommendationGrid(
                        recipes: snapshot.data!.recipes.take(6).toList(),
                        ingredientsMap: snapshot.data!.ingredientsMap,
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

                  // ─── Koleksi Rekomendasi Resep (List) ──────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'Koleksi Rekomendasi Resep',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ),
                  ),

                  if (snapshot.connectionState != ConnectionState.done)
                    const SliverToBoxAdapter(child: _ListShimmer())
                  else if (snapshot.hasData &&
                      snapshot.data!.recipes.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final all = snapshot.data!.recipes;
                          final recipe = all[index % all.length];
                          final count =
                              snapshot
                                  .data!
                                  .ingredientsMap[recipe.id]
                                  ?.length ??
                              0;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _CollectionTile(
                              recipe: recipe,
                              ingredientCount: count,
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
                        },
                        childCount: snapshot.hasData
                            ? snapshot.data!.recipes.length
                            : 0,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
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

// ─── Data class ──────────────────────────────────────────────────────────────

class _HomeData {
  const _HomeData({required this.recipes, required this.ingredientsMap});
  final List<Recipe> recipes;
  final Map<int, List<RecipeIngredient>> ingredientsMap;
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const topPad =
        68.0; // AppHeader preferredSize height only – Scaffold clips AppBar to this exact height
    return Container(
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD6EAD8), Color(0xFFA8CBAB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // decorative circles top right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // content
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 35, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masak dari bahan yang\nkamu punya.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IngredientSelectionScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pilih Bahan',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommendation Grid ─────────────────────────────────────────────────────

class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid({
    required this.recipes,
    required this.ingredientsMap,
    required this.onTap,
  });

  final List<Recipe> recipes;
  final Map<int, List<RecipeIngredient>> ingredientsMap;
  final void Function(Recipe, String) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 380 ? 2 : 3;
        final childAspectRatio = crossAxisCount == 2 ? 0.76 : 0.69;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final count = ingredientsMap[recipe.id]?.length ?? 0;
              final heroTag = 'recipe-image-grid-${recipe.id}';
              return _GridRecipeCard(
                recipe: recipe,
                ingredientCount: count,
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
    required this.recipe,
    required this.ingredientCount,
    required this.onTap,
  });

  final Recipe recipe;
  final int ingredientCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: LocalFavoritesStore.favorites,
      builder: (context, favorites, _) {
        final isFavorite = favorites.contains(recipe.id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 84,
                        width: double.infinity,
                        child: RecipeVisual(
                          recipe: recipe,
                          height: 84,
                          borderRadius: 0,
                          showFavoriteAction: false,
                          isFavorite: isFavorite,
                          heroTag: 'recipe-image-grid-${recipe.id}',
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () async {
                            await LocalFavoritesStore.toggle(recipe.id);
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 14,
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
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                fontSize: 10.5,
                                height: 1.2,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 10,
                              color: AppColors.textSoft,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${recipe.cookingTime}m',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSoft,
                                      fontSize: 9.5,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.people_alt_outlined,
                              size: 10,
                              color: AppColors.textSoft,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${recipe.defaultServing} porsi',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSoft,
                                      fontSize: 9.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$ingredientCount% bahan cocok',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Collection Tile (vertical list) ─────────────────────────────────────────

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.recipe,
    required this.ingredientCount,
    required this.onTap,
  });

  final Recipe recipe;
  final int ingredientCount;
  final VoidCallback onTap;

  /// Derive a star rating (1–5) from recipe id for display variety
  int get _stars => 3 + (recipe.id % 3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // thumbnail — mengikuti tinggi konten
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(19),
                ),
                child: SizedBox(
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
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppColors.textSoft,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${recipe.cookingTime}m',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSoft),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.people_alt_outlined,
                            size: 12,
                            color: AppColors.textSoft,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${recipe.defaultServing} porsi',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSoft),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Star rating row
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < _stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 15,
                            color: i < _stars
                                ? const Color(0xFFE4A01A)
                                : const Color(0xFFDDDDDD),
                          );
                        }),
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

// ─── Shimmer Placeholders ─────────────────────────────────────────────────────

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 380 ? 2 : 3;
        final childAspectRatio = crossAxisCount == 2 ? 0.76 : 0.69;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
