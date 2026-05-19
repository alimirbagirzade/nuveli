// ============================================================================
// onboarding_progress_bar.dart
// 5 step için yatay progress göstergesi (5 nokta + arasında çizgi).
// Animated geçişler.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final dotIndex = index ~/ 2 + 1;
            final isPassed = dotIndex <= currentStep;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isPassed ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (_, t, __) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(
                      Colors.white.withValues(alpha: 0.2),
                      AppColors.primaryCyan,
                      t,
                    ),
                    boxShadow: isPassed
                        ? [
                            BoxShadow(
                              color: AppColors.primaryCyan
                                  .withValues(alpha: 0.5 * t),
                              blurRadius: 8 * t,
                              spreadRadius: 1 * t,
                            ),
                          ]
                        : null,
                  ),
                );
              },
            );
          } else {
            final lineLeftDotIndex = index ~/ 2 + 1;
            final isPassed = lineLeftDotIndex < currentStep;
            return Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: isPassed ? 1 : 0),
                duration: const Duration(milliseconds: 300),
                builder: (_, t, __) {
                  return Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.white.withValues(alpha: 0.12),
                        AppColors.primaryCyan,
                        t,
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                },
              ),
            );
          }
        }),
      ),
    );
  }
}
