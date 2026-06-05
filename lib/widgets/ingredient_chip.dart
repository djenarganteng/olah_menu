import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../theme/app_colors.dart';

class IngredientChip extends StatelessWidget {
  const IngredientChip({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  final Ingredient ingredient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF3FBF4) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconForIngredient(ingredient),
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Spacer(),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: isSelected ? 1 : 0.85,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: isSelected ? 1 : 0.2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  ingredient.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ingredient.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textSoft,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForIngredient(Ingredient ingredient) {
    final value = '${ingredient.name} ${ingredient.category}'.toLowerCase();
    if (value.contains('ikan')) {
      return Icons.set_meal_rounded;
    }
    if (value.contains('ayam') || value.contains('daging')) {
      return Icons.lunch_dining_rounded;
    }
    if (value.contains('telur')) {
      return Icons.egg_alt_rounded;
    }
    if (value.contains('sayur') || value.contains('bayam')) {
      return Icons.eco_rounded;
    }
    if (value.contains('jamur')) {
      return Icons.spa_rounded;
    }
    if (value.contains('keju') || value.contains('susu')) {
      return Icons.icecream_rounded;
    }
    if (value.contains('karbo') || value.contains('nasi')) {
      return Icons.rice_bowl_rounded;
    }
    return Icons.restaurant_menu_rounded;
  }
}
