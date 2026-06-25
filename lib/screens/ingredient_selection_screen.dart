import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class IngredientSelectionScreen extends StatefulWidget {
  const IngredientSelectionScreen({super.key});

  @override
  State<IngredientSelectionScreen> createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8EF),
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: 'Pilih Bahan'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFFEFF8EF))),
          Positioned.fill(
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(
                'assets/backgrounds/ingredient_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Consumer<IngredientProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 103, 16, 154),
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
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Cari bahan, misalnya telur, nasi, ayam...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: provider.searchQuery.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Bersihkan pencarian',
                                  onPressed: () =>
                                      _resetIngredientFilters(provider),
                                  icon: const Icon(Icons.close_rounded),
                                ),
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
                          bool added = false;
                          for (final ingredient in provider.ingredients) {
                            if (defaultNames.contains(ingredient.name) &&
                                !provider.isSelected(ingredient.id)) {
                              provider.toggleSelection(ingredient);
                              added = true;
                            }
                          }
                          if (added) {
                            HapticFeedback.mediumImpact();
                          }
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Tambah bumbu dasar'),
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
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Bahan tidak ditemukan',
        message: 'Coba gunakan kata kunci lain atau ganti kategori bahan.',
        actionLabel: 'Reset pencarian',
        onAction: () => _resetIngredientFilters(provider),
      );
    }

    return AlignedGridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width < 430 ? 2 : 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: EdgeInsets.zero,
      itemCount: provider.filteredIngredients.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final ingredient = provider.filteredIngredients[index];
        return IngredientChip(
          ingredient: ingredient,
          isSelected: provider.isSelected(ingredient.id),
          onTap: () {
            provider.toggleSelection(ingredient);
            HapticFeedback.lightImpact();
          },
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

  void _resetIngredientFilters(IngredientProvider provider) {
    _searchController.clear();
    provider.resetFilters();
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
                    onPressed: () {
                      provider.clearSelectedIngredients();
                      HapticFeedback.mediumImpact();
                    },
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
