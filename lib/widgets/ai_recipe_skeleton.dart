import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AiRecipeSkeleton extends StatefulWidget {
  const AiRecipeSkeleton({super.key});

  @override
  State<AiRecipeSkeleton> createState() => _AiRecipeSkeletonState();
}

class _AiRecipeSkeletonState extends State<AiRecipeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                animationValue: _controller.value,
                width: double.infinity,
                height: 180,
                radius: 24,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ShimmerBox(
                    animationValue: _controller.value,
                    width: 120,
                    height: 26,
                    radius: 999,
                  ),
                  const Spacer(),
                  _ShimmerBox(
                    animationValue: _controller.value,
                    width: 72,
                    height: 26,
                    radius: 999,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ShimmerBox(
                animationValue: _controller.value,
                width: double.infinity,
                height: 20,
              ),
              const SizedBox(height: 10),
              _ShimmerBox(
                animationValue: _controller.value,
                width: 220,
                height: 14,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ShimmerBox(
                    animationValue: _controller.value,
                    width: 92,
                    height: 34,
                    radius: 999,
                  ),
                  _ShimmerBox(
                    animationValue: _controller.value,
                    width: 92,
                    height: 34,
                    radius: 999,
                  ),
                  _ShimmerBox(
                    animationValue: _controller.value,
                    width: 110,
                    height: 34,
                    radius: 999,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ShimmerBox(
                animationValue: _controller.value,
                width: double.infinity,
                height: 56,
                radius: 20,
              ),
              const SizedBox(height: 10),
              _ShimmerBox(
                animationValue: _controller.value,
                width: double.infinity,
                height: 56,
                radius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animationValue,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final double animationValue;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final begin = Alignment(-1.4 + animationValue * 2.8, 0);
    final end = Alignment(-0.4 + animationValue * 2.8, 0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: const [
            AppColors.backgroundSoft,
            Color(0xFFE8EFE3),
            AppColors.backgroundSoft,
          ],
        ),
      ),
    );
  }
}
