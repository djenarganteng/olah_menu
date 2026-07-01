import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../services/onboarding_service.dart';
import '../../theme/app_colors.dart';
import '../auth/auth_gate.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    await OnboardingService.markCompleted();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
    );
  }

  Future<void> _nextPage() async {
    if (_currentPage >= onboardingPages.length - 1) {
      await _finishOnboarding();
      return;
    }

    await _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() => _finishOnboarding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      body: Stack(
        children: [
          const Positioned.fill(child: _OnboardingBackdrop()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: onboardingPages.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final page = onboardingPages[index];
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    final pageValue = _pageController.hasClients
                                        ? (_pageController.page ?? _currentPage.toDouble())
                                        : _currentPage.toDouble();
                                    final distance =
                                        (pageValue - index).abs().clamp(0.0, 1.0);
                                    final progress = 1.0 - distance;
                                    final scale = ui.lerpDouble(0.94, 1.0, progress)!;
                                    final opacity = ui.lerpDouble(0.62, 1.0, progress)!;
                                    final offsetY = ui.lerpDouble(18, 0, progress)!;

                                    return Opacity(
                                      opacity: opacity,
                                      child: Transform.translate(
                                        offset: Offset(0, offsetY),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: _OnboardingPageContent(
                                            page: page,
                                            pageProgress: progress,
                                            availableWidth: constraints.maxWidth,
                                            availableHeight: constraints.maxHeight,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _OnboardingBottomRow(
                            currentPage: _currentPage,
                            isBusy: _isCompleting,
                            onSkip: _skip,
                            onNext: _nextPage,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({
    required this.page,
    required this.pageProgress,
    required this.availableWidth,
    required this.availableHeight,
  });

  final OnboardingPageData page;
  final double pageProgress;
  final double availableWidth;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final heroWidth = availableWidth.clamp(0.0, 520.0) * 0.84;
    final maxHeroWidth = page.frameStyle == OnboardingFrameStyle.circle
        ? heroWidth
        : heroWidth * 0.96;
    final heroSize = page.frameStyle == OnboardingFrameStyle.circle
        ? math.min(maxHeroWidth, availableHeight * 0.38)
        : math.min(maxHeroWidth, availableHeight * 0.34);

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: page.accentColor,
      fontFamily: 'Plus Jakarta Sans',
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      height: 1.12,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF555A52),
      fontFamily: 'Inter',
      height: 1.65,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: ui.lerpDouble(8, 20, pageProgress)!),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OnboardingIllustration(
                  page: page,
                  size: heroSize,
                  pageProgress: pageProgress,
                ),
                SizedBox(height: ui.lerpDouble(24, 34, pageProgress)!),
                if (page.showContentCard)
                  _ContentCard(
                    title: page.title,
                    description: page.description,
                    titleStyle: titleStyle,
                    bodyStyle: bodyStyle,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: titleStyle,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({
    required this.page,
    required this.size,
    required this.pageProgress,
  });

  final OnboardingPageData page;
  final double size;
  final double pageProgress;

  @override
  Widget build(BuildContext context) {
    final borderRadius = page.frameStyle == OnboardingFrameStyle.roundedSquare
        ? 32.0
        : 26.0;

    final image = Image.asset(
      page.assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: size * 0.06,
          top: size * 0.04,
          child: _FloatingSparkle(
            color: page.accentColor.withValues(alpha: 0.9),
            size: size * 0.07,
            opacity: ui.lerpDouble(0.55, 1.0, pageProgress)!,
          ),
        ),
        Positioned(
          left: size * 0.08,
          bottom: size * 0.06,
          child: _FloatingSparkle(
            color: const Color(0xFFD69B49),
            size: size * 0.085,
            opacity: ui.lerpDouble(0.35, 0.9, pageProgress)!,
          ),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: page.frameBackgroundColor ?? Colors.white.withValues(alpha: 0.82),
            shape: page.frameStyle == OnboardingFrameStyle.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: page.frameStyle == OnboardingFrameStyle.circle
                ? null
                : BorderRadius.circular(borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          padding: page.frameStyle == OnboardingFrameStyle.circle
              ? const EdgeInsets.all(18)
              : const EdgeInsets.all(16),
          child: page.frameStyle == OnboardingFrameStyle.circle
              ? ClipOval(child: image)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius - 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius - 6),
                      gradient: LinearGradient(
                        colors: [
                          page.backgroundStart.withValues(alpha: 0.95),
                          page.backgroundEnd.withValues(alpha: 0.98),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: image,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.title,
    required this.description,
    required this.titleStyle,
    required this.bodyStyle,
  });

  final String title;
  final String description;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          const SizedBox(height: 18),
          Text(
            description,
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        ],
      ),
    );
  }
}

class _OnboardingBottomRow extends StatelessWidget {
  const _OnboardingBottomRow({
    required this.currentPage,
    required this.isBusy,
    required this.onSkip,
    required this.onNext,
  });

  final int currentPage;
  final bool isBusy;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final page = onboardingPages[currentPage];
    final showSkip = page.showSkip && currentPage < onboardingPages.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSmoothIndicator(
            activeIndex: currentPage,
            count: onboardingPages.length,
            effect: const ExpandingDotsEffect(
              expansionFactor: 3.2,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
              radius: 12,
              activeDotColor: AppColors.primary,
              dotColor: Color(0xFFE2E4DD),
              paintStyle: PaintingStyle.fill,
            ),
          ),
          if (showSkip)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: TextButton(
                  onPressed: isBusy ? null : onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  child: const Text('Lewati'),
                ),
              ),
            ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: FilledButton(
                onPressed: isBusy ? null : onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C1F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.buttonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingSparkle extends StatelessWidget {
  const _FloatingSparkle({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size,
        color: color,
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FBF5), Color(0xFFFDFDF8)],
            ),
          ),
        ),
        Opacity(
          opacity: 0.08,
          child: Image.asset(
            'assets/backgrounds/leaf_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -120,
          right: -100,
          child: _GlowBlob(
            color: const Color(0xFFBEE0B9).withValues(alpha: 0.5),
            size: 280,
          ),
        ),
        Positioned(
          bottom: -120,
          left: -90,
          child: _GlowBlob(
            color: const Color(0xFFDFF0D9).withValues(alpha: 0.55),
            size: 260,
          ),
        ),
        const Positioned.fill(child: _SoftDotPattern()),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _SoftDotPattern extends StatelessWidget {
  const _SoftDotPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotPainter(),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x0F5A8B5C);
    const step = 24.0;

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x + 1.5, y + 1.5), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
