import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/providers/notifications_provider.dart';

/// Identifies which of the three water reminder slots a toggle controls.
enum WaterReminderSlot { morning, afternoon, evening }

/// Toggle tile shown on the Water Tracker screen.
///
/// Reads the matching boolean from [notificationSettingsProvider] so the
/// state is single-sourced — flipping it here flips it on the Settings
/// screen too, and vice versa.
class ReminderToggleTile extends ConsumerWidget {
  const ReminderToggleTile({
    super.key,
    required this.slot,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final WaterReminderSlot slot;
  final String title;
  final String subtitle;
  final IconData icon;

  bool _readValue(NotificationSettings s) => switch (slot) {
        WaterReminderSlot.morning => s.waterMorning,
        WaterReminderSlot.afternoon => s.waterAfternoon,
        WaterReminderSlot.evening => s.waterEvening,
      };

  Future<void> _write(
    NotificationSettingsController c,
    bool value,
  ) async {
    switch (slot) {
      case WaterReminderSlot.morning:
        await c.setWaterMorning(value);
      case WaterReminderSlot.afternoon:
        await c.setWaterAfternoon(value);
      case WaterReminderSlot.evening:
        await c.setWaterEvening(value);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);
    final value = _readValue(settings);
    final masterOff = !settings.masterEnabled;

    return Opacity(
      opacity: masterOff ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: masterOff,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF14233E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF00D4FF), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB8C5D6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                // Flutter 3.31+: activeColor deprecated → use activeThumbColor.
                activeThumbColor: const Color(0xFF00D4FF),
                onChanged: (v) => _write(controller, v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
