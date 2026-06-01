import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.kitchen_outlined, 'Pantry'),
      (Icons.menu_book_outlined, 'Recipes'),
      (Icons.delete_outline_rounded, 'Waste'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = index == currentIndex;
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onSelected == null ? null : () => onSelected!(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].$1,
                      size: 20,
                      color: selected ? AppColors.primary : AppColors.text,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index].$2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
