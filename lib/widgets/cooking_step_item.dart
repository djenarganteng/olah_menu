import 'package:flutter/material.dart';

import '../models/recipe_step.dart';
import '../theme/app_colors.dart';

class CookingStepItem extends StatelessWidget {
  const CookingStepItem({super.key, required this.step});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleForStep(step.stepNumber),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  step.instruction,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleForStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'Persiapan Bahan';
      case 2:
        return 'Mulai Meracik';
      case 3:
        return 'Tahap Memasak';
      default:
        return 'Langkah $stepNumber';
    }
  }
}
