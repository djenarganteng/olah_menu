import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/loading_state.dart';
import '../services/supabase_service.dart';
import 'all_recipes_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'recommendation_screen.dart';

class IngredientSelectionScreen extends StatefulWidget {
  const IngredientSelectionScreen({super.key});

  @override
  State<IngredientSelectionScreen> createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8EF),
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: 'Pilih Bahan'),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onSelected: (index) => _handleNavigation(context, index),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFFEFF8EF))),
          Positioned.fill(
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(
                'assets/backgrounds/ingredient_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Consumer<IngredientProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 103, 16, 154),
                  children: [
                    Text(
                      'Masak dari bahan yang ada',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih bahan yang tersedia di rumahmu, lalu temukan resep yang cocok tanpa ribet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoft,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Cari bahan, misalnya telur, nasi, ayam...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: provider.searchQuery.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Bersihkan pencarian',
                                  onPressed: () =>
                                      _resetIngredientFilters(provider),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          return ChoiceChip(
                            label: Text(category),
                            selected: provider.selectedCategory == category,
                            onSelected: (_) => provider.setCategory(category),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          final defaultNames = {
                            'Garam',
                            'Minyak Goreng',
                            'Bawang Merah',
                            'Bawang Putih',
                            'Kecap',
                          };
                          bool added = false;
                          for (final ingredient in provider.ingredients) {
                            if (defaultNames.contains(ingredient.name) &&
                                !provider.isSelected(ingredient.id)) {
                              provider.toggleSelection(ingredient);
                              added = true;
                            }
                          }
                          if (added) {
                            HapticFeedback.mediumImpact();
                          }
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Tambah bumbu dasar'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildContent(context, provider),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<IngredientProvider>(
              builder: (context, provider, _) {
                return _BottomSelectionBar(provider: provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, IngredientProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(
        title: 'Memuat bahan...',
        message: 'Kami sedang menyiapkan daftar bahan dari database.',
        compact: true,
      );
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Bahan belum berhasil dimuat',
        message: 'Gagal memuat data. Periksa koneksi internet kamu.',
        actionLabel: 'Coba lagi',
        onAction: provider.loadIngredients,
      );
    }

    if (provider.ingredients.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada bahan',
        message: 'Daftar bahan dari database masih kosong.',
      );
    }

    if (provider.filteredIngredients.isEmpty) {
      final query = provider.searchQuery.trim();
      if (query.isNotEmpty) {
        return EmptyState(
          icon: Icons.add_circle_outline,
          title: 'Bahan tidak ditemukan',
          message:
              'Tambahkan bahan baru agar dapat digunakan mencari resep.',
          actionLabel: 'Tambahkan "$query"',
          onAction: () =>
              _showAddIngredientSheet(context, provider, initialName: query),
          secondaryActionLabel: 'Reset pencarian',
          onSecondaryAction: () => _resetIngredientFilters(provider),
        );
      }

      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Bahan tidak ditemukan',
        message: 'Coba gunakan kata kunci lain atau ganti kategori bahan.',
        actionLabel: 'Reset pencarian',
        onAction: () => _resetIngredientFilters(provider),
      );
    }

    return AlignedGridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width < 430 ? 2 : 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: EdgeInsets.zero,
      itemCount: provider.filteredIngredients.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final ingredient = provider.filteredIngredients[index];
        return IngredientChip(
          ingredient: ingredient,
          isSelected: provider.isSelected(ingredient.id),
          onTap: () {
            provider.toggleSelection(ingredient);
            HapticFeedback.lightImpact();
          },
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      );
    }
  }

  void _resetIngredientFilters(IngredientProvider provider) {
    _searchController.clear();
    provider.resetFilters();
  }

  Future<void> _showAddIngredientSheet(
    BuildContext context,
    IngredientProvider provider, {
    required String initialName,
  }) async {
    final createdIngredient = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddIngredientBottomSheet(
          initialName: initialName,
          onSubmit: ({required String name, required String category}) =>
              provider.addIngredient(name: name, category: category),
        );
      },
    );

    if (!context.mounted || createdIngredient == null) {
      return;
    }

    _searchController.text = createdIngredient.name;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bahan berhasil ditambahkan.')),
    );
  }
}

class _BottomSelectionBar extends StatelessWidget {
  const _BottomSelectionBar({required this.provider});

  final IngredientProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                  child: Text(
                    provider.selectedCount == 0
                        ? 'Pilih minimal 1 bahan'
                        : '${provider.selectedCount} bahan dipilih',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (provider.selectedCount > 0)
                  TextButton(
                    onPressed: () {
                      provider.clearSelectedIngredients();
                      HapticFeedback.mediumImpact();
                    },
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: provider.selectedCount == 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih minimal satu bahan dulu, ya.'),
                          ),
                        );
                      }
                    : () async {
                        final selectedIngredients =
                            provider.selectedIngredients;
                        await context
                            .read<RecommendationProvider>()
                            .fetchRecommendations(selectedIngredients);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecommendationScreen(
                              selectedIngredients: selectedIngredients,
                            ),
                          ),
                        );
                      },
                child: const Text('Cari Resep Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> _ingredientCreationCategories = [
  'Protein',
  'Sayuran',
  'Buah',
  'Karbohidrat',
  'Bumbu',
  'Seafood',
  'Minuman',
  'Susu & Olahan',
  'Lainnya',
];

class _AddIngredientBottomSheet extends StatefulWidget {
  const _AddIngredientBottomSheet({
    required this.initialName,
    required this.onSubmit,
  });

  final String initialName;
  final Future<Ingredient> Function({
    required String name,
    required String category,
  }) onSubmit;

  @override
  State<_AddIngredientBottomSheet> createState() =>
      _AddIngredientBottomSheetState();
}

class _AddIngredientBottomSheetState extends State<_AddIngredientBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _selectedCategory = _ingredientCreationCategories.last;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6FAF3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2E4CD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tambahkan Bahan Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bahan baru akan langsung muncul di daftar dan terpilih otomatis.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bahan',
                      hintText: 'Contoh: Mozzarella',
                    ),
                    validator: (value) {
                      final normalized = Ingredient.toTitleCase(value ?? '');
                      if (normalized.isEmpty) {
                        return 'Nama bahan wajib diisi.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                    ),
                    items: _ingredientCreationCategories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kategori bahan wajib dipilih.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await widget.onSubmit(
        name: _nameController.text,
        category: _selectedCategory,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _messageForError(Object error) {
    if (error is IngredientDuplicateException) {
      return error.message;
    }

    if (error is IngredientValidationException) {
      return error.message;
    }

    if (error is IngredientAuthException) {
      return error.message;
    }

    if (error is IngredientPermissionException) {
      return error.message;
    }

    if (error is IngredientDatabaseException) {
      return error.message;
    }

    if (error is TimeoutException) {
      return 'Permintaan terlalu lama. Coba lagi.';
    }

    return 'Gagal menambahkan bahan. Coba lagi atau cek status login/Supabase.';
  }
}
