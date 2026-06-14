import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/ai_recipe.dart';
import '../providers/auth_provider.dart';
import '../providers/ingredient_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/local_favorites_store.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final fullName = _displayName(user?.userMetadata);
    final email = user?.email ?? '-';
    final avatarUrl = user?.userMetadata?['avatar_url']?.toString();
    final selectedCount = context.watch<IngredientProvider>().selectedCount;

    return Scaffold(
      appBar: const AppHeader(title: 'Profil'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            _ProfileHero(
              fullName: fullName,
              email: email,
              avatarUrl: avatarUrl,
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<Set<int>>(
              valueListenable: LocalFavoritesStore.favorites,
              builder: (context, favoriteIds, _) {
                return ValueListenableBuilder<List<AiRecipe>>(
                  valueListenable: LocalFavoritesStore.aiFavorites,
                  builder: (context, aiFavorites, _) {
                    final totalFavorites =
                        favoriteIds.length + aiFavorites.length;
                    final cards = [
                      _StatCard(
                        value: '$totalFavorites',
                        label: 'Resep Tersimpan',
                      ),
                      _StatCard(
                        value: '$selectedCount',
                        label: 'Bahan Dipilih',
                      ),
                      _StatCard(
                        value: '${aiFavorites.length}',
                        label: 'Resep AI',
                      ),
                    ];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 340) {
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: cards
                                .map(
                                  (card) => SizedBox(
                                    width: (constraints.maxWidth - 10) / 2,
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 10),
                            Expanded(child: cards[1]),
                            const SizedBox(width: 10),
                            Expanded(child: cards[2]),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 22),
            _MenuGroup(
              children: [
                _ProfileMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Pilih Bahan',
                  subtitle: 'Atur bahan yang tersedia di rumah',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IngredientSelectionScreen(),
                    ),
                  ),
                ),
                _ProfileMenuTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Daftar Resep',
                  subtitle: 'Lihat semua resep di OlahMenu',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AllRecipesScreen(),
                    ),
                  ),
                ),
                _ProfileMenuTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Resep Tersimpan',
                  subtitle: 'Gabungan resep favorit database dan AI',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MenuGroup(
              children: [
                _ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  subtitle: 'Ganti nama dan password akun',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileSettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Sesi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: Color(0xFFF1B7A8)),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(Map<String, dynamic>? metadata) {
    final name = metadata?['full_name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'OlahMenu Cook';
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const IngredientSelectionScreen(),
        ),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()),
      );
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickAvatar(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: avatarUrl == null || avatarUrl!.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(avatarUrl!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: avatarUrl == null || avatarUrl!.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryDark,
                          size: 42,
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Masak Tanpa Mubazir',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAvatar(BuildContext context) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (file == null || !context.mounted) {
    return;
  }

  final bytes = await file.readAsBytes();
  if (!context.mounted) {
    return;
  }
  final extension = file.name.split('.').last;
  await context.read<AuthProvider>().updateAvatar(
    bytes: Uint8List.fromList(bytes),
    extension: extension,
  );
}
