import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(showBackButton: false),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const _BackgroundAccent(top: -70, right: -40, size: 180),
          const _BackgroundAccent(bottom: 120, left: -50, size: 150),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8FBF5), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 26,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              color: AppColors.primaryDark,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Masak Tanpa Mubazir',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Masak dari bahan yang kamu punya',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pilih stok dapurmu, lalu temukan resep yang paling cocok tanpa bingung.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const IngredientSelectionScreen(),
                              ),
                            );
                          },
                          child: const Text('Mulai Pilih Bahan'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.inventory_2_rounded,
                              title: 'Pilih bahan',
                              subtitle: 'Yang tersedia',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.restaurant_menu_rounded,
                              title: 'Cari resep',
                              subtitle: 'Yang cocok',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.scale_rounded,
                              title: 'Atur porsi',
                              subtitle: 'Lebih pas',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Cara Kerja',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tiga langkah sederhana untuk menemukan resep dari bahan yang sudah ada.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                ),
                const SizedBox(height: 16),
                const _FeatureCard(
                  icon: Icons.looks_one_rounded,
                  title: 'Pilih bahan yang tersedia',
                  description:
                      'Tandai bahan seperti telur, nasi, ayam, sayur, dan bumbu yang sudah ada di dapur.',
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  icon: Icons.looks_two_rounded,
                  title: 'Dapatkan resep yang pas',
                  description:
                      'Aplikasi mencocokkan bahan wajib dan opsional untuk menampilkan hasil terbaik.',
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  icon: Icons.looks_3_rounded,
                  title: 'Masak sesuai porsi',
                  description:
                      'Atur jumlah porsi di halaman detail agar takaran bahan langsung menyesuaikan.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const IngredientSelectionScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AllRecipesScreen()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()));
      return;
    }

    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
    }
  }
}

class _BackgroundAccent extends StatelessWidget {
  const _BackgroundAccent({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x402E7D32), Color(0x002E7D32)],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoft,
                    height: 1.45,
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
