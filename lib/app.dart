import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ai_recipe_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/recipe_detail_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'services/ai_recipe_service.dart';
import 'services/auth_service.dart';
import 'services/recommendation_service.dart';
import 'services/supabase_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class OlahMenuApp extends StatelessWidget {
  const OlahMenuApp({super.key, this.initializationError});

  final String? initializationError;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;

    if (initializationError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OlahMenu',
        theme: theme,
        home: _ConfigurationErrorScreen(errorMessage: initializationError!),
      );
    }

    final supabaseService = SupabaseService();
    final recommendationService = RecommendationService(
      supabaseService: supabaseService,
    );
    final aiRecipeService = AiRecipeService();
    final authService = AuthService();

    return MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<RecommendationService>.value(value: recommendationService),
        Provider<AiRecipeService>.value(value: aiRecipeService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              IngredientProvider(supabaseService: supabaseService)
                ..loadIngredients(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(
            recommendationService: recommendationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AiRecipeProvider(aiRecipeService: aiRecipeService),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeDetailProvider(supabaseService: supabaseService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OlahMenu',
        theme: theme,
        home: const SplashScreen(),
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  const _ConfigurationErrorScreen({required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Konfigurasi Supabase Belum Lengkap',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Jalankan aplikasi dengan `--dart-define=SUPABASE_URL=...` '
                    'dan `--dart-define=SUPABASE_ANON_KEY=...`.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
