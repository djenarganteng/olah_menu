import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/ingredient_provider.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_chip.dart';
import 'recommendation_screen.dart';

class IngredientSelectionScreen extends StatelessWidget {
  const IngredientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
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
                        TextField(
                          onChanged: provider.setSearchQuery,
                          decoration: const InputDecoration(
                            hintText: 'Cari bahan...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 38,
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
                        const SizedBox(height: 18),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Bahan belum berhasil dimuat',
        message: provider.errorMessage!,
        actionLabel: 'Coba Lagi',
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
        message: 'Coba ganti kata kunci pencarian atau filter kategori.',
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  '${provider.selectedCount} bahan terpilih',
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
                            content: Text(
                              'Pilih minimal satu bahan terlebih dahulu.',
                            ),
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
                child: const Text('Tampilkan Rekomendasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
