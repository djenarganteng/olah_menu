import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/ingredient_provider.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/loading_state.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'recommendation_screen.dart';

class IngredientSelectionScreen extends StatelessWidget {
  const IngredientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Bahan Saya'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: SafeArea(
        child: Consumer<IngredientProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bahan Saya',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih bahan yang tersedia di rumahmu.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSoft),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: TextField(
                            onChanged: provider.setSearchQuery,
                            decoration: const InputDecoration(
                              hintText:
                                  'Cari bahan, misalnya telur, nasi, ayam...',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final category = provider.categories[index];
                              return ChoiceChip(
                                label: Text(category),
                                selected: provider.selectedCategory == category,
                                onSelected: (_) =>
                                    provider.setCategory(category),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            final defaultNames = {
                              'Garam',
                              'Minyak Goreng',
                              'Bawang Merah',
                              'Bawang Putih',
                              'Kecap',
                            };
                            for (final ingredient in provider.ingredients) {
                              if (defaultNames.contains(ingredient.name) &&
                                  !provider.isSelected(ingredient.id)) {
                                provider.toggleSelection(ingredient);
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                          ),
                          label: const Text('Pilih Bumbu Dasar'),
                        ),
                        const SizedBox(height: 10),
                        Expanded(child: _buildContent(context, provider)),
                      ],
                    ),
                  ),
                ),
                _BottomSelectionBar(provider: provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, IngredientProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(
        title: 'Memuat bahan...',
        message: 'Kami sedang menyiapkan daftar bahan dari database.',
        compact: true,
      );
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Bahan belum berhasil dimuat',
        message: 'Gagal memuat data. Periksa koneksi internet kamu.',
        actionLabel: 'Coba lagi',
        onAction: provider.loadIngredients,
      );
    }

    if (provider.ingredients.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada bahan',
        message: 'Daftar bahan dari database masih kosong.',
      );
    }

    if (provider.filteredIngredients.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Bahan tidak ditemukan',
        message: 'Coba gunakan kata kunci lain atau ganti kategori bahan.',
      );
    }

    return AlignedGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: provider.filteredIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = provider.filteredIngredients[index];
        return IngredientChip(
          ingredient: ingredient,
          isSelected: provider.isSelected(ingredient.id),
          onTap: () => provider.toggleSelection(ingredient),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()),
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

class _BottomSelectionBar extends StatelessWidget {
  const _BottomSelectionBar({required this.provider});

  final IngredientProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  provider.selectedCount == 0
                      ? 'Pilih minimal 1 bahan untuk mulai'
                      : '${provider.selectedCount} bahan dipilih',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (provider.selectedCount > 0)
                  TextButton(
                    onPressed: provider.clearSelectedIngredients,
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: provider.selectedCount == 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih minimal satu bahan dulu, ya.'),
                          ),
                        );
                      }
                    : () async {
                        final selectedIngredients =
                            provider.selectedIngredients;
                        await context
                            .read<RecommendationProvider>()
                            .fetchRecommendations(selectedIngredients);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecommendationScreen(
                              selectedIngredients: selectedIngredients,
                            ),
                          ),
                        );
                      },
                child: const Text('Cari Resep Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
