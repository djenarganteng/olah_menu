import 'dart:async';

import 'package:flutter/material.dart';

import '../services/onboarding_service.dart';
import '../theme/app_colors.dart';
import 'auth/auth_gate.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoPulseController;
  late final Animation<double> _logoScale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _logoPulseController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(seconds: 2), _redirectAfterSplash);
  }

  Future<void> _redirectAfterSplash() async {
    final onboardingCompleted = await OnboardingService.isCompleted();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            onboardingCompleted ? const AuthGate() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF2F8F4), Colors.white],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, -0.08),
                    child: _SplashMainContent(logoScale: _logoScale),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: Text(
                        'MENYIAPKAN DAPUR DIGITAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9AA19B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashMainContent extends StatelessWidget {
  const _SplashMainContent({required this.logoScale});

  final Animation<double> logoScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: logoScale,
          child: Image.asset(
            'assets/branding/olah_menu_logo.png',
            width: 220,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'Masak lezat dari bahan yang kamu\npunya.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF474B59),
            fontSize: 22,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 76),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
            backgroundColor: Color(0x224CAF50),
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x144CAF50);
    const step = 20.0;

    for (double y = 1; y < size.height; y += step) {
      for (double x = 1; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.85, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
