import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';
import 'package:nuveli/shared/widgets/reminder_toggle_tile.dart';

import '../models/water_reminder.dart';

/// "🔔 Reminders" kartı — su hatırlatıcılarını toggle olarak listeler.
///
/// Üst satır: bell ikonu + "Reminders" başlığı.
/// İçerik: her reminder için `ReminderToggleTile` (Chat 3).
class WaterRemindersCard extends StatelessWidget {
  final List<WaterReminder> reminders;
  final void Function(String id, bool value)? onToggle;

  const WaterRemindersCard({
    super.key,
    required this.reminders,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: 🔔 + "Reminders".
          Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Reminders',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Reminder listesi (arada 8px gap, divider yok).
          ..._buildReminderList(),
        ],
      ),
    );
  }

  List<Widget> _buildReminderList() {
    final widgets = <Widget>[];
    for (var i = 0; i < reminders.length; i++) {
      final r = reminders[i];
      widgets.add(
        ReminderToggleTile(
          title: r.title,
          subtitle: r.formattedTime,
          initialValue: r.isEnabled,
          onChanged: (v) => onToggle?.call(r.id, v),
        ),
      );
      if (i < reminders.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }
}
