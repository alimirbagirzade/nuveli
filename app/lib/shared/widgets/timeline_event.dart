import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Today's Timeline satırı (Görsel 5).
///
/// Sol tarafta dikey timeline çizgisi + ortada dot, sağda zaman + miktar + check.
///
/// Sıralı kullanım örneği:
/// ```dart
/// Column(children: [
///   TimelineEvent(time: '9:00 AM',  value: '250 ml', isCompleted: true,  isFirst: true),
///   TimelineEvent(time: '11:30 AM', value: '500 ml', isCompleted: true),
///   TimelineEvent(time: '6:30 PM',  value: '600 ml', isCompleted: false, isLast: true),
/// ])
/// ```
class TimelineEvent extends StatelessWidget {
  final String time;
  final String value;
  final IconData? icon;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const TimelineEvent({
    super.key,
    required this.time,
    required this.value,
    this.icon = Icons.water_drop_outlined,
    this.isCompleted = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineConnector(
            isFirst: isFirst,
            isLast: isLast,
            isCompleted: isCompleted,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  SizedBox(
                    width: 76,
                    child: Text(
                      time,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 18,
                    )
                  else
                    Icon(
                      Icons.circle_outlined,
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;

  const _TimelineConnector({
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColors.textSecondary.withValues(alpha: 0.25);
    final dotColor = isCompleted
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.5);

    return SizedBox(
      width: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical lines (top + bottom halves)
          Column(
            children: [
              Expanded(
                child: Container(
                  width: 1.5,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
              ),
              Expanded(
                child: Container(
                  width: 1.5,
                  color: isLast ? Colors.transparent : lineColor,
                ),
              ),
            ],
          ),
          // Center dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
