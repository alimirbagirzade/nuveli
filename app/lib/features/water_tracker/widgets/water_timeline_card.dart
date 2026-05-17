import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';
import 'package:nuveli/shared/widgets/timeline_event.dart';

import '../models/water_log.dart';

/// "Today's Timeline" kartı — su kayıtlarını kronolojik sırada listeler.
///
/// Üst satır: başlık + "View all" linki.
/// İçerik: her log için bir `TimelineEvent` (Chat 3).
class WaterTimelineCard extends StatelessWidget {
  final List<WaterLog> events;
  final VoidCallback? onViewAll;

  const WaterTimelineCard({
    super.key,
    required this.events,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: "Today's Timeline" + "View all".
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Today's Timeline",
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Event listesi.
          ..._buildEventList(),
        ],
      ),
    );
  }

  List<Widget> _buildEventList() {
    if (events.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Henüz su kaydı yok.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      ];
    }

    return List.generate(events.length, (index) {
      final event = events[index];
      return TimelineEvent(
        time: event.formattedTime,
        value: event.formattedAmount,
        isCompleted: event.isCompleted,
        isFirst: index == 0,
        isLast: index == events.length - 1,
      );
    });
  }
}
