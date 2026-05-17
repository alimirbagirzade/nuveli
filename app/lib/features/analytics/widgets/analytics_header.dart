import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

/// Analytics ekranının üst başlığı.
///
/// Layout: [🌊 Logo (sol)] [Analytics (ortalı)] [📅 Calendar (sağ)]
class AnalyticsHeader extends StatelessWidget {
  final VoidCallback? onCalendarTap;

  const AnalyticsHeader({
    super.key,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4, // 12px
      ),
      child: Row(
        children: [
          // Sol: Logo
          _NuveliLogo(),

          // Orta: Title (Expanded ile ortalı)
          Expanded(
            child: Text(
              'Analytics',
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Sağ: Calendar icon
          GestureDetector(
            onTap: onCalendarTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 20x20 mini Nuveli logosu (dalga ikonu).
///
/// Asset henüz hazır değilse fallback olarak Icons.waves kullanıyor.
class _NuveliLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Icon(
        Icons.waves_rounded,
        size: 20,
        color: AppColors.primaryCyan,
      ),
    );
  }
}
