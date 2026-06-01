import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/recipe_card.dart';
import '../widgets/section_title.dart';
import 'recipe_detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key, required this.selectedIngredients});

  final List<Ingredient> selectedIngredients;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<RecommendationProvider>().fetchRecommendations(
        widget.selectedIngredients,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Consumer<RecommendationProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Recommendations',
                    subtitle:
                        'Based on your pantry items, here\'s what you can cook today.',
                    compact: true,
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: _buildContent(context, provider)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RecommendationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Rekomendasi belum tersedia',
        message: provider.errorMessage!,
        actionLabel: 'Coba Lagi',
        onAction: () =>
            provider.fetchRecommendations(widget.selectedIngredients),
      );
    }

    if (provider.recommendations.isEmpty) {
      return const EmptyState(
        icon: Icons.ramen_dining_outlined,
        title: 'Belum ada resep yang cocok',
        message: 'Coba pilih bahan lain.',
      );
    }

    return ListView.separated(
      itemCount: provider.recommendations.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == provider.recommendations.length) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC9E6C9)),
            ),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Need more ideas?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Update your pantry or check out popular community recipes.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Explore Recipes'),
                ),
              ],
            ),
          );
        }

        final recommendation = provider.recommendations[index];
        return RecipeCard(
          recommendation: recommendation,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    RecipeDetailScreen(recipe: recommendation.recipe),
              ),
            );
          },
        );
      },
    );
  }
}
