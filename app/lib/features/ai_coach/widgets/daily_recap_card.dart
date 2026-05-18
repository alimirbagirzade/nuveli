import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/coach_recommendation.dart';

class DailyRecapCard extends StatelessWidget {
  final DailyRecap recap;

  const DailyRecapCard({super.key, required this.recap});

  _RecapVisuals get _visuals {
    switch (recap.status) {
      case RecapStatus.onTrack:
        return _RecapVisuals(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        );
      case RecapStatus.behind:
        return _RecapVisuals(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        );
      case RecapStatus.ahead:
        return _RecapVisuals(
          icon: Icons.rocket_launch_outlined,
          color: AppColors.primaryCyan,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visuals;
    return NuveliCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: v.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(v.icon, size: 22, color: v.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Recap',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recap.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapVisuals {
  final IconData icon;
  final Color color;
  _RecapVisuals({required this.icon, required this.color});
}
