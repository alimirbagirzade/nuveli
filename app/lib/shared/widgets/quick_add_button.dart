import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum QuickAddSize { small, medium, large }

/// Su tracker'da hızlı miktar ekleme butonu.
///
/// 3 boyut: small (+250ml), medium (+500ml), large (+1L)
/// Boyut arttıkça background opacity ve ikon büyüklüğü artar.
///
/// Row içinde 3'ünü Expanded ile sarınca eşit dağılır.
class QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final QuickAddSize size;
  final VoidCallback onPressed;

  const QuickAddButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = QuickAddSize.medium,
  });

  double get _bgOpacity {
    switch (size) {
      case QuickAddSize.small:
        return 0.12;
      case QuickAddSize.medium:
        return 0.18;
      case QuickAddSize.large:
        return 0.25;
    }
  }

  double get _iconSize {
    switch (size) {
      case QuickAddSize.small:
        return 18;
      case QuickAddSize.medium:
        return 20;
      case QuickAddSize.large:
        return 24;
    }
  }

  double get _fontSize {
    switch (size) {
      case QuickAddSize.small:
        return 13;
      case QuickAddSize.medium:
        return 14;
      case QuickAddSize.large:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        splashColor: AppColors.primaryCyan.withValues(alpha: 0.2),
        highlightColor: AppColors.primaryCyan.withValues(alpha: 0.1),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withValues(alpha: _bgOpacity),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primaryCyan.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: size == QuickAddSize.large
                ? [
                    BoxShadow(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: _iconSize,
                color: AppColors.primaryCyan,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryCyan,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
