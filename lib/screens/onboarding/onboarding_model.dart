import 'package:flutter/material.dart';

enum OnboardingFrameStyle {
  circle,
  square,
  roundedSquare,
}

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.accentColor,
    required this.frameStyle,
    required this.buttonLabel,
    required this.showContentCard,
    this.showSkip = true,
    this.frameBackgroundColor,
  });

  final String title;
  final String description;
  final String assetPath;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color accentColor;
  final OnboardingFrameStyle frameStyle;
  final String buttonLabel;
  final bool showContentCard;
  final bool showSkip;
  final Color? frameBackgroundColor;
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Masak dengan Bahan yang Ada',
    description:
        'Pilih bahan-bahan yang tersedia di dapurmu dan temukan resep lezat tanpa membuang makanan.',
    assetPath: 'assets/onboarding/onboarding_1.png',
    backgroundStart: Color(0xFFF3F9EE),
    backgroundEnd: Color(0xFFF9FCF7),
    accentColor: Color(0xFF2E7D32),
    frameStyle: OnboardingFrameStyle.circle,
    buttonLabel: 'Lanjut',
    showContentCard: false,
  ),
  OnboardingPageData(
    title: 'Rekomendasi Resep Pintar',
    description:
        'OlahMenu merekomendasikan resep terbaik berdasarkan bahan pilihan lengkap dengan info waktu memasak dan tingkat kesulitan.',
    assetPath: 'assets/onboarding/onboarding_2.png',
    backgroundStart: Color(0xFFF9FAF5),
    backgroundEnd: Color(0xFFF6F7F1),
    accentColor: Color(0xFF355A34),
    frameStyle: OnboardingFrameStyle.square,
    buttonLabel: 'Lanjut',
    showContentCard: true,
  ),
  OnboardingPageData(
    title: 'AI Buatkan Resep Untukmu',
    description:
        'Jika tidak ada resep yang cocok, AI akan membuatkan panduan memasak detail berdasarkan bahan yang kamu pilih.',
    assetPath: 'assets/onboarding/onboarding_3.png',
    backgroundStart: Color(0xFFF2FAF2),
    backgroundEnd: Color(0xFFF7FBF7),
    accentColor: Color(0xFF1B6D24),
    frameStyle: OnboardingFrameStyle.roundedSquare,
    buttonLabel: 'Mulai Memasak',
    showContentCard: true,
    showSkip: false,
  ),
];
