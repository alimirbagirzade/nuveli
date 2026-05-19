// ============================================================================
// step_1_welcome.dart
// "Hi! Let's get to know you" — info screen, sadece Continue butonu.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../widgets/auth_primary_button.dart';

class Step1Welcome extends StatelessWidget {
  final VoidCallback onNext;

  const Step1Welcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryCyan.withValues(alpha: 0.5),
                  AppColors.primaryCyan.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.4),
                  blurRadius: 48,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.waving_hand_outlined,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Hi! Let's get to know you",
            textAlign: TextAlign.center,
            style: AppTypography.heading32Bold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            "We'll personalize your nutrition coaching based on your body, "
            "lifestyle, and goals. It only takes a minute.",
            textAlign: TextAlign.center,
            style: AppTypography.body16.copyWith(
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          AuthPrimaryButton(label: 'Continue', onPressed: onNext),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
