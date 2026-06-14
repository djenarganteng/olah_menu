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
import 'profile_screen.dart';
import 'recommendation_screen.dart';

class IngredientSelectionScreen extends StatelessWidget {
  const IngredientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Select Ingredients'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const _SoftGlow(top: -60, right: -30, size: 160),
          const _SoftGlow(bottom: 100, left: -40, size: 130),
          SafeArea(
            child: Consumer<IngredientProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 154),
                  children: [
                    Text(
                      'Masak dari bahan yang ada',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih bahan yang tersedia di rumahmu, lalu temukan resep yang cocok tanpa ribet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoft,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        onChanged: provider.setSearchQuery,
                        decoration: const InputDecoration(
                          hintText: 'Cari bahan, misalnya telur, nasi, ayam...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          return ChoiceChip(
                            label: Text(category),
                            selected: provider.selectedCategory == category,
                            onSelected: (_) => provider.setCategory(category),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
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
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Pilih bumbu dasar'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildContent(context, provider),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<IngredientProvider>(
              builder: (context, provider, _) {
                return _BottomSelectionBar(provider: provider);
              },
            ),
          ),
        ],
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
      crossAxisCount: MediaQuery.sizeOf(context).width < 430 ? 2 : 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: provider.filteredIngredients.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    provider.selectedCount == 0
                        ? 'Pilih minimal 1 bahan'
                        : '${provider.selectedCount} bahan dipilih',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
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
              colors: [Color(0x3F5F8F57), Color(0x005F8F57)],
            ),
          ),
        ),
      ),
    );
  }
}
