// HABIT REMINDERS — Entegrasyon Notu
//
// Habits feature (Chat 10) henüz tamamlandıysa, habits provider'da
// habit listesi değiştiğinde notification service'i çağır:

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_service.dart';
import '../features/notifications/providers/notifications_provider.dart';

// Bu örnek snippet'i — Chat 10'daki habits_provider.dart'a entegre et.

class HabitsControllerExample extends StateNotifier<List</*Habit*/Object>> {
  HabitsControllerExample(this._ref) : super([]);

  final Ref _ref;

  /// Habits CRUD operation'larından sonra çağır (add/update/delete/toggle).
  Future<void> _resyncReminders() async {
    final settings = _ref.read(notificationSettingsProvider);
    final service = _ref.read(notificationServiceProvider);

    // Master switch veya habit reminders kapalıysa hepsini iptal et.
    if (!settings.masterEnabled || !settings.habitReminders) {
      await service.scheduleHabitReminders([]);
      return;
    }

    // Habit'leri HabitReminderSpec'e map et.
    // (Kendi Habit modelinizi değiştirin — bu sadece şablon.)
    final specs = state.map((h) {
      // final habit = h as Habit;
      // if (habit.reminderTime == null) return null;
      // return HabitReminderSpec(
      //   habitId: habit.id,
      //   title: habit.title,
      //   icon: habit.icon,
      //   subtitle: habit.subtitle,
      //   time: habit.reminderTime!,
      // );
      return null;
    }).whereType<HabitReminderSpec>().toList();

    await service.scheduleHabitReminders(specs);
  }

  // Her CRUD method'unun sonunda çağır:
  // Future<void> addHabit(Habit h) async {
  //   state = [...state, h];
  //   await _saveToBackend(h);
  //   await _resyncReminders(); // ← ÖNEMLİ
  // }
}

// ─────────────────────────────────────────────────────
//
// ALTERNATIF: Master habit reminders toggle değişince
// otomatik tetiklenmesi için settings provider'a listener bağla:
//
// final habitReminderSyncProvider = Provider<void>((ref) {
//   ref.listen<NotificationSettings>(
//     notificationSettingsProvider,
//     (prev, next) {
//       if (prev?.habitReminders != next.habitReminders ||
//           prev?.masterEnabled != next.masterEnabled) {
//         ref.read(habitsControllerProvider.notifier)._resyncReminders();
//       }
//     },
//   );
// });
