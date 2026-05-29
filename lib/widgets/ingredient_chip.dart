import 'package:flutter/material.dart';

import '../models/ingredient.dart';

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
      color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ingredient.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ingredient.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.82)
                      : const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
