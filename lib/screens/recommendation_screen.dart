import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../providers/recommendation_provider.dart';
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
      appBar: AppBar(title: const Text('Rekomendasi Resep')),
      body: SafeArea(
        child: Consumer<RecommendationProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: 'Resep Paling Cocok',
                    subtitle:
                        'Dihitung dari ${widget.selectedIngredients.length} bahan yang kamu pilih.',
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
      itemCount: provider.recommendations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
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
