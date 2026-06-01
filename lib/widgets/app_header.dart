import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.showBackButton = true,
    this.trailing,
    this.title = 'OlahMenu',
  });

  final bool showBackButton;
  final Widget? trailing;
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              _CircleButton(
                icon: showBackButton
                    ? Icons.arrow_back_rounded
                    : Icons.restaurant_menu_rounded,
                filled: !showBackButton,
                onTap: showBackButton
                    ? () => Navigator.of(context).maybePop()
                    : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              trailing ??
                  const _CircleButton(
                    icon: Icons.person_outline_rounded,
                    filled: true,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderAvatar extends StatelessWidget {
  const HeaderAvatar({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _CircleButton(
        icon: Icons.person_outline_rounded,
        filled: true,
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        image: DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap, this.filled = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primarySoft : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
