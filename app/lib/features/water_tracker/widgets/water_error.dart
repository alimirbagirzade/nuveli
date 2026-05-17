import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';

/// Error state — veri yüklenemediğinde gösterilir.
///
/// `WaterTrackerScreen`'deki `ref.invalidate(waterTrackerProvider)` ile
/// yeniden denenir.
class WaterError extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const WaterError({
    super.key,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Veri yüklenemedi',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryCyan,
                side: const BorderSide(color: AppColors.primaryCyan),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
