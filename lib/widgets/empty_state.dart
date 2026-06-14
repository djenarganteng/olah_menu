import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: hasBoundedHeight ? constraints.maxHeight : 0,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, size: 30, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoft,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onAction,
                          child: Text(actionLabel!),
                        ),
                      ),
                    ],
                    if (secondaryActionLabel != null &&
                        onSecondaryAction != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onSecondaryAction,
                          child: Text(secondaryActionLabel!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
