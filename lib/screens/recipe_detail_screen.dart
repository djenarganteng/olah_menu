import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_recipe.dart';
import '../models/ai_recipe_step.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../providers/recipe_detail_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/cooking_step_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_art_icon.dart';
import '../widgets/loading_state.dart';
import '../widgets/local_favorites_store.dart';
import '../widgets/ai_recipe_visual.dart';
import '../widgets/recipe_visual.dart';
import '../widgets/section_title.dart';
import '../widgets/serving_counter.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.selectedIngredientIds,
    this.heroTag,
  }) : aiRecipe = null;

  const RecipeDetailScreen.ai({
    super.key,
    required AiRecipe recipe,
    this.heroTag,
  }) : recipe = null,
       aiRecipe = recipe,
       selectedIngredientIds = null;

  final Recipe? recipe;
  final AiRecipe? aiRecipe;
  final Set<int>? selectedIngredientIds;
  final String? heroTag;

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

      final recipe = widget.recipe;
      if (recipe != null) {
        context.read<RecipeDetailProvider>().loadRecipeDetails(recipe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiRecipe = widget.aiRecipe;
    if (aiRecipe != null) {
      return _AiRecipeDetailView(recipe: aiRecipe, heroTag: widget.heroTag);
    }

    final recipe = widget.recipe!;
    final selectedIngredientIds =
        widget.selectedIngredientIds ??
        context
            .watch<IngredientProvider>()
            .selectedIngredients
            .map((item) => item.id)
            .toSet();
    final ingredientImagesById = {
      for (final item in context.watch<IngredientProvider>().ingredients)
        item.id: item.imageUrl?.trim() ?? '',
    };

    return Scaffold(
      appBar: AppHeader(
        title: recipe.name,
        trailing: ValueListenableBuilder<Set<int>>(
          valueListenable: LocalFavoritesStore.favorites,
          builder: (context, favorites, _) {
            final isFavorite = favorites.contains(recipe.id);
            return IconButton.filledTonal(
              onPressed: () async {
                await LocalFavoritesStore.toggle(recipe.id);
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
                    ? const Color(0xFFD65A72)
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
                  onAction: () => provider.loadRecipeDetails(recipe),
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
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              children: [
                RecipeVisual(
                  recipe: recipe,
                  height: 250,
                  borderRadius: 30,
                  topLabel: 'Detail Resep',
                  heroTag: widget.heroTag,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFE0A340),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '23 ulasan',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSoft),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe.description.isEmpty
                            ? 'Resep rumahan yang mudah diikuti dan cocok dimasak dari stok bahan yang tersedia.'
                            : recipe.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: '${recipe.cookingTime} menit',
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
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                            const SizedBox(height: 4),
                            Text(
                              'Takaran bahan akan berubah otomatis.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSoft),
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
                const SizedBox(height: 20),
                SectionTitle(
                  title: 'Bahan',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const _IngredientGroupTitle(title: 'Bahan utama'),
                      ...requiredIngredients.map(
                        (ingredient) => _IngredientTile(
                          ingredient: ingredient,
                          adjustedAmount: provider.adjustedAmount(ingredient),
                          isOwned: selectedIngredientIds.contains(
                            ingredient.ingredientId,
                          ),
                          imageUrl:
                              ingredient.ingredientImageUrl
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? ingredient.ingredientImageUrl!.trim()
                              : ingredientImagesById[ingredient.ingredientId] ??
                                    '',
                        ),
                      ),
                      if (optionalIngredients.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const _IngredientGroupTitle(title: 'Bumbu tambahan'),
                        ...optionalIngredients.map(
                          (ingredient) => _IngredientTile(
                            ingredient: ingredient,
                            adjustedAmount: provider.adjustedAmount(ingredient),
                            isOwned: selectedIngredientIds.contains(
                              ingredient.ingredientId,
                            ),
                            imageUrl:
                                ingredient.ingredientImageUrl
                                        ?.trim()
                                        .isNotEmpty ==
                                    true
                                ? ingredient.ingredientImageUrl!.trim()
                                : ingredientImagesById[ingredient
                                          .ingredientId] ??
                                      '',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'Langkah Memasak',
                  subtitle:
                      'Ikuti urutan berikut agar proses memasak lebih rapi dan mudah.',
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

class _AiRecipeDetailView extends StatelessWidget {
  const _AiRecipeDetailView({required this.recipe, this.heroTag});

  final AiRecipe recipe;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final hasStructuredIngredients = recipe.hasStructuredIngredients;
    final stepDetails = recipe.stepDetails;

    return Scaffold(
      appBar: AppHeader(title: recipe.title),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            AiRecipeVisual(
              recipe: recipe,
              height: 260,
              borderRadius: 30,
              heroTag: heroTag ?? 'ai-recipe-${recipe.id}',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AiDetailBadge(text: recipe.sourceBadgeLabel),
                  const SizedBox(height: 14),
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.description.isEmpty
                        ? 'Resep ini dibuat oleh AI berdasarkan bahan yang tersedia.'
                        : recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(
                        icon: Icons.schedule_rounded,
                        label: recipe.estimatedTime.isNotEmpty
                            ? recipe.estimatedTime
                            : '${recipe.cookingTime} menit',
                      ),
                      _InfoPill(
                        icon: Icons.people_alt_outlined,
                        label: '${recipe.servings} porsi',
                      ),
                      _InfoPill(
                        icon: Icons.local_fire_department_rounded,
                        label: recipe.difficulty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<AiRecipe>>(
                    valueListenable: LocalFavoritesStore.aiFavorites,
                    builder: (context, _, _) {
                      final isFavorite = LocalFavoritesStore.isAiFavorite(
                        recipe.id,
                      );

                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              LocalFavoritesStore.toggleAiRecipe(recipe),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          ),
                          label: Text(
                            isFavorite
                                ? 'Tersimpan di Favorit'
                                : 'Simpan ke Favorit',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (recipe.tips.isNotEmpty) ...[
              SectionTitle(
                title: 'Tips Memasak',
                subtitle: 'Catatan singkat agar hasil masakan lebih stabil.',
                compact: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: recipe.tips
                      .asMap()
                      .entries
                      .map(
                        (entry) => _TipTile(
                          number: entry.key + 1,
                          text: entry.value,
                          isLast: entry.key == recipe.tips.length - 1,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
            ],
            SectionTitle(
              title: 'Bahan',
              subtitle: hasStructuredIngredients
                  ? 'Bahan utama dan bumbu pelengkap dipisah agar lebih mudah dibaca.'
                  : 'Bahan pilihan dan bumbu umum yang disarankan AI.',
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
                  '${recipe.ingredients.length} item',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (recipe.mainIngredients.isNotEmpty) ...[
                    const _IngredientGroupTitle(title: 'Bahan utama'),
                    ...recipe.mainIngredients.map(
                      (ingredient) => _AiIngredientTile(label: ingredient),
                    ),
                  ] else ...[
                    ...recipe.ingredients.map(
                      (ingredient) => _AiIngredientTile(label: ingredient),
                    ),
                  ],
                  if (recipe.seasonings.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const _IngredientGroupTitle(
                      title: 'Bumbu dan pelengkap',
                    ),
                    ...recipe.seasonings.map(
                      (ingredient) => _AiIngredientTile(label: ingredient),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(
              title: 'Langkah Memasak',
              subtitle: 'Ikuti urutan berikut dan sesuaikan rasa di akhir.',
              compact: true,
            ),
            const SizedBox(height: 12),
            if (stepDetails.isNotEmpty)
              ...stepDetails.asMap().entries.map(
                (entry) => _AiStepTile(
                  step: entry.value,
                  isLast: entry.key == stepDetails.length - 1,
                ),
              )
            else
              ...recipe.steps.asMap().entries.map(
                (entry) => _AiStepTile(
                  step: AiRecipeStep(
                    step: entry.key + 1,
                    title: 'Langkah ${entry.key + 1}',
                    description: entry.value,
                  ),
                  isLast: entry.key == recipe.steps.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiDetailBadge extends StatelessWidget {
  const _AiDetailBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF8A5A18),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AiIngredientTile extends StatelessWidget {
  const _AiIngredientTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiStepTile extends StatelessWidget {
  const _AiStepTile({
    required this.step,
    required this.isLast,
  });

  final AiRecipeStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${step.step}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title.isEmpty ? 'Langkah ${step.step}' : step.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({
    required this.number,
    required this.text,
    required this.isLast,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
                height: 1.45,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    required this.adjustedAmount,
    required this.isOwned,
    required this.imageUrl,
  });

  final RecipeIngredient ingredient;
  final double adjustedAmount;
  final bool isOwned;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final artKind = ingredientArtKindForName(
      ingredient.ingredientName ?? '',
      ingredient.ingredientCategory ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOwned ? AppColors.primarySoft : AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOwned ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return _IngredientFallbackIcon(
                          artKind: artKind,
                          isOwned: isOwned,
                        );
                      },
                    )
                  : _IngredientFallbackIcon(artKind: artKind, isOwned: isOwned),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.ingredientName ?? 'Bahan tanpa nama',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredient.isRequired ? 'Wajib' : 'Opsional',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${adjustedAmount.toStringAsFixed(adjustedAmount.truncateToDouble() == adjustedAmount ? 0 : 1)} ${ingredient.unit}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientFallbackIcon extends StatelessWidget {
  const _IngredientFallbackIcon({required this.artKind, required this.isOwned});

  final IngredientArtKind artKind;
  final bool isOwned;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isOwned ? AppColors.primarySoft : AppColors.backgroundSoft,
      child: IngredientArtIcon(
        kind: artKind,
        color: isOwned ? AppColors.primaryDark : AppColors.textSoft,
        size: 36,
        strokeWidth: 1.8,
      ),
    );
  }
}
