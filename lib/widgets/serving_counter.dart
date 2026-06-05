import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ServingCounter extends StatelessWidget {
  const ServingCounter({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _CounterButton(
            onTap: onDecrement,
            backgroundColor: AppColors.primary,
            borderColor: AppColors.primary,
            iconColor: Colors.white,
            label: '−',
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          _CounterButton(
            onTap: onIncrement,
            backgroundColor: AppColors.primary,
            borderColor: AppColors.primary,
            iconColor: Colors.white,
            label: '+',
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.label,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 22,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
