import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';

/// Ekran üst başlığı: [N logo] [Water Tracker] [🔔]
///
/// Logo sol, başlık ortalı, bell sağda. Padding: 16h × 12v.
class WaterHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const WaterHeader({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Sol: Nuveli N logosu (cyan glow). Asset ya da SVG yoksa
          // basit bir cyan-glow N harfi göster.
          _NuveliLogoMark(),
          // Ortada başlık (Expanded ile gerçekten ortalanır).
          Expanded(
            child: Text(
              'Water Tracker',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Sağ: Bildirim ikonu.
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Nuveli marka logosu (küçük versiyon). Asset yoksa stilize bir "N"
/// gösterir; ileride `Image.asset('assets/logo/nuveli_n.svg')` ile
/// değiştirilebilir.
class _NuveliLogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryCyan, AppColors.cyanGlow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Text(
        'N',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
