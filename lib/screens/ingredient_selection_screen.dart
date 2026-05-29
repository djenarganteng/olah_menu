import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/ingredient_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/section_title.dart';
import 'recommendation_screen.dart';

class IngredientSelectionScreen extends StatelessWidget {
  const IngredientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Bahan')),
      body: SafeArea(
        child: Consumer<IngredientProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Isi Kulkasmu Hari Ini',
                    subtitle:
                        'Cari dan pilih bahan yang tersedia untuk mendapatkan rekomendasi resep.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: provider.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Cari bahan, misalnya telur atau sawi',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${provider.selectedCount} bahan dipilih',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (provider.selectedCount > 0)
                          TextButton(
                            onPressed: provider.clearSelectedIngredients,
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildContent(context, provider)),
                  const SizedBox(height: 16),
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
      crossAxisCount: 2,
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
