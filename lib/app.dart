import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ingredient_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/recipe_detail_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/recommendation_service.dart';
import 'services/supabase_service.dart';

class OlahMenuApp extends StatelessWidget {
  const OlahMenuApp({super.key, this.initializationError});

  final String? initializationError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Brightness.light,
      primary: const Color(0xFF2E7D32),
      secondary: const Color(0xFFFF9800),
      surface: const Color(0xFFFFFFFF),
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFAFAF5),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: const Color(0xFF263238),
        displayColor: const Color(0xFF263238),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF263238),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
        selectedColor: const Color(0xFF2E7D32),
        backgroundColor: const Color(0xFFE8F5E9),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF263238),
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF263238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

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

    return MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<RecommendationService>.value(value: recommendationService),
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
          create: (_) => RecipeDetailProvider(supabaseService: supabaseService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OlahMenu',
        theme: theme,
        home: const SplashScreen(),
        routes: {HomeScreen.routeName: (_) => const HomeScreen()},
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
                    color: Color(0xFF2E7D32),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF757575),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                    ),
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
