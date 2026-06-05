import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/section_title.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_selection_screen.dart';

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3FAF3), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pilih bahan di rumah, lalu temukan resep yang cocok tanpa bingung. Bahan di dapur hampir habis? Tenang, OlahMenu bantu carikan resep dari bahan yang kamu punya.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const IngredientSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text('Mulai Pilih Bahan'),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
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
                          title: 'Dapatkan resep',
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
            const SectionTitle(
              title: 'Cara Kerja',
              subtitle:
                  'Pengguna baru harus bisa paham fungsi aplikasi ini dalam beberapa detik.',
              compact: true,
            ),
            const SizedBox(height: 16),
            const _FeatureCard(
              icon: Icons.looks_one_rounded,
              title: 'Pilih bahan yang tersedia',
              description:
                  'Tandai bahan yang ada di rumahmu seperti telur, nasi, ayam, atau bumbu dasar.',
            ),
            const SizedBox(height: 14),
            const _FeatureCard(
              icon: Icons.looks_two_rounded,
              title: 'Dapatkan rekomendasi resep',
              description:
                  'OlahMenu menghitung resep yang paling cocok berdasarkan bahan wajib dan opsional.',
            ),
            const SizedBox(height: 14),
            const _FeatureCard(
              icon: Icons.looks_3_rounded,
              title: 'Masak sesuai porsi',
              description:
                  'Atur porsi langsung dari halaman detail supaya takaran bahan lebih pas.',
            ),
          ],
        ),
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
    }
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
