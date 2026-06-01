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
      color: isSelected ? const Color(0xFFF1FBF2) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isSelected ? 1 : 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC9F2CC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _emojiForIngredient(ingredient),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ingredient.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _emojiForIngredient(Ingredient ingredient) {
    final value = '${ingredient.name} ${ingredient.category}'.toLowerCase();
    if (value.contains('telur')) {
      return '🥚';
    }
    if (value.contains('ikan')) {
      return '🐟';
    }
    if (value.contains('ayam')) {
      return '🍗';
    }
    if (value.contains('daging')) {
      return '🥩';
    }
    if (value.contains('keju')) {
      return '🧀';
    }
    if (value.contains('jamur')) {
      return '🍄';
    }
    if (value.contains('tahu')) {
      return '🧈';
    }
    if (value.contains('tempe')) {
      return '🫘';
    }
    if (value.contains('sayur') || value.contains('bayam')) {
      return '🥬';
    }
    if (value.contains('karbo')) {
      return '🍚';
    }
    return '🥕';
  }
}
