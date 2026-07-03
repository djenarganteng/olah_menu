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
      backgroundColor: const Color(0xFFF6FAF7),
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: 'Profil'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          // Background: botanical watercolor matching other screens
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF6FAF7),
                image: DecorationImage(
                  image: AssetImage('assets/backgrounds/favorites_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.12,
                ),
              ),
            ),
          ),
          const _ProfileBackdrop(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 103, 16, 24),
            children: [
              _ProfileHero(
                fullName: fullName,
                email: email,
                avatarUrl: avatarUrl,
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Ringkasan Akun',
                subtitle:
                    'Informasi cepat tentang penggunaan kamu di aplikasi.',
              ),
              const SizedBox(height: 12),
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
                          icon: Icons.favorite_rounded,
                          iconColor: AppColors.danger,
                          iconBgColor: AppColors.danger.withValues(alpha: 0.1),
                        ),
                        _StatCard(
                          value: '$selectedCount',
                          label: 'Bahan Dipilih',
                          icon: Icons.restaurant_menu_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primarySoft,
                        ),
                        _StatCard(
                          value: '${aiFavorites.length}',
                          label: 'Resep AI',
                          icon: Icons.auto_awesome_rounded,
                          iconColor: AppColors.accent,
                          iconBgColor: AppColors.accent.withValues(alpha: 0.12),
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
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Menu Tindakan',
                subtitle: 'Akses menu navigasi dan pengaturan akun.',
              ),
              const SizedBox(height: 12),
              _MenuGroup(
                children: [
                  _ProfileMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Pilih Bahan',
                    subtitle: 'Atur bahan yang tersedia di rumah',
                    iconColor: AppColors.primaryDark,
                    iconBgColor: AppColors.primarySoft,
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
                    iconColor: const Color(0xFF1976D2),
                    iconBgColor: const Color(0xFFE3F2FD),
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
                    iconColor: AppColors.danger,
                    iconBgColor: AppColors.danger.withValues(alpha: 0.1),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    subtitle: 'Ganti nama dan password akun',
                    iconColor: const Color(0xFF607D8B),
                    iconBgColor: const Color(0xFFECEFF1),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileSettingsScreen(),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Hapus Akun',
                    subtitle: 'Hapus akun dan semua data secara permanen',
                    iconColor: Colors.red,
                    iconBgColor: Colors.red.withValues(alpha: 0.1),
                    onTap: () => _handleDeleteAccount(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.danger.withValues(alpha: 0.1),
                        AppColors.danger.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar Sesi',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus akun ini?\n\n'
              'Semua data akun, foto profil, dan resep favorit akan dihapus secara permanen.\n\n'
              'Tindakan ini tidak dapat dibatalkan.',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Hapus Akun'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _DeleteAccountPasswordDialog(
          onContinue: (currentPassword) async {
            await context.read<AuthProvider>().deleteAccount(
              currentPassword: currentPassword,
            );
          },
        );
      },
    );

    if (password == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Akun berhasil dihapus.')));
    Navigator.of(context).popUntil((route) => route.isFirst);
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF2F8EE), Color(0xFFD9E9D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 22,
            offset: Offset(0, 10),
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
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
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
                              size: 52,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primaryDark,
                      size: 16,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Masak Tanpa Mubazir',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: _ProfileGlow(
              size: 220,
              colors: [Color(0x221B8F6A), Color(0x001B8F6A)],
            ),
          ),
          Positioned(
            top: 120,
            left: -40,
            child: _ProfileGlow(
              size: 160,
              colors: [Color(0x22FFB15C), Color(0x00FFB15C)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGlow extends StatelessWidget {
  const _ProfileGlow({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoft,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
                fontSize: 10,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: List.generate(children.length, (index) {
            if (index == children.length - 1) {
              return children[index];
            }
            return Column(
              children: [
                children[index],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AppColors.primaryDark,
    this.iconBgColor = AppColors.primarySoft,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSoft.withValues(alpha: 0.7),
              size: 14,
            ),
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
  try {
    await context.read<AuthProvider>().updateAvatar(
      bytes: Uint8List.fromList(bytes),
      extension: extension,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui foto profil.')),
      );
    }
  }
}

class _DeleteAccountPasswordDialog extends StatefulWidget {
  const _DeleteAccountPasswordDialog({required this.onContinue});

  final Future<void> Function(String currentPassword) onContinue;

  @override
  State<_DeleteAccountPasswordDialog> createState() =>
      _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPasswordDialogState
    extends State<_DeleteAccountPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Masukkan Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Untuk melanjutkan, masukkan password akun kamu sekali lagi.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onContinue(_passwordController.text);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(_passwordController.text);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_deleteAccountErrorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

String _deleteAccountErrorMessage(Object error) {
  final rawMessage = error.toString().toLowerCase();
  if (rawMessage.contains('server configuration is incomplete')) {
    return 'Fitur hapus akun belum siap di server. Coba lagi setelah Edge Function diperbarui.';
  }
  if (rawMessage.contains('user session is no longer valid') ||
      rawMessage.contains('unauthorized')) {
    return 'Sesi login sudah tidak valid. Silakan masuk kembali lalu coba lagi.';
  }
  if (rawMessage.contains('failed to delete account')) {
    return 'Gagal menghapus akun di server. Silakan coba lagi.';
  }
  if (rawMessage.contains('invalid login credentials') ||
      (rawMessage.contains('password') && rawMessage.contains('invalid')) ||
      rawMessage.contains('reauth')) {
    return 'Password salah. Silakan coba lagi.';
  }
  if (rawMessage.contains('session') ||
      rawMessage.contains('login') ||
      rawMessage.contains('authenticated')) {
    return 'Sesi login sudah berakhir. Silakan masuk kembali.';
  }
  if (rawMessage.contains('timeout') || rawMessage.contains('timed out')) {
    return 'Permintaan terlalu lama. Silakan coba lagi.';
  }
  if (rawMessage.contains('network') ||
      rawMessage.contains('socket') ||
      rawMessage.contains('failed host lookup') ||
      rawMessage.contains('connection') ||
      rawMessage.contains('fetch')) {
    return 'Koneksi internet bermasalah. Silakan coba lagi.';
  }
  if (rawMessage.contains('delete-account') ||
      rawMessage.contains('edge function') ||
      rawMessage.contains('functions') ||
      rawMessage.contains('functionexception')) {
    return 'Gagal menghapus akun di server. Silakan coba lagi beberapa saat lagi.';
  }
  return 'Gagal memproses permintaan. Silakan coba lagi.';
}
