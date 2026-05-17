import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/mock_water_data.dart';
import '../models/water_log.dart';
import '../models/water_reminder.dart';
import '../models/water_tracker_state.dart';

/// Water Tracker ekranının state notifier'ı.
///
/// `AsyncNotifierProvider` kullanılır çünkü kullanıcı interaktif veri ekliyor
/// (+250ml, +500ml, +1L butonları, bardak tap'i, reminder toggle).
/// FutureProvider salt-okunur olurdu.
///
/// Chat 13-15'te gerçek Supabase repository'si ile değiştirilecek.
class WaterTrackerNotifier extends AsyncNotifier<WaterTrackerState> {
  final _uuid = const Uuid();

  @override
  Future<WaterTrackerState> build() async {
    // Loading state göstermek için kısa bir gecikme (mock).
    await Future.delayed(const Duration(milliseconds: 500));
    return _buildFromMock();
  }

  WaterTrackerState _buildFromMock() {
    return WaterTrackerState(
      consumedLiters: WaterMockData.consumedLiters,
      targetLiters: WaterMockData.targetLiters,
      filledGlasses: WaterMockData.filledGlasses,
      totalGlasses: WaterMockData.totalGlasses,
      timeline: List<WaterLog>.from(mockTodaysWaterLogs),
      reminders: List<WaterReminder>.from(mockWaterReminders),
      insight: mockWaterInsight,
    );
  }

  /// Su ekler ve state'i günceller.
  ///
  /// Halka, bardak ızgarası ve timeline anlık olarak güncellenir.
  /// [ml] parametresi 250, 500, 1000 gibi değerler alır.
  void addWater(int ml) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newLog = WaterLog(
      id: _uuid.v4(),
      amountMl: ml,
      loggedAt: DateTime.now(),
      isCompleted: true,
    );

    // Kronolojik sıraya göre ekle (en eski üstte, en yeni altta).
    final newTimeline = [...current.timeline, newLog]
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    final newConsumed = current.consumedLiters + (ml / 1000.0);
    final newFilledGlasses =
        (newConsumed * 1000 / WaterMockData.glassSizeMl)
            .floor()
            .clamp(0, current.totalGlasses);

    state = AsyncValue.data(current.copyWith(
      consumedLiters: newConsumed,
      filledGlasses: newFilledGlasses,
      timeline: newTimeline,
    ));
  }

  /// Reminder toggle eder (açık ↔ kapalı).
  void toggleReminder(String id, bool value) {
    final current = state.valueOrNull;
    if (current == null) return;

    final newReminders = current.reminders
        .map((r) => r.id == id ? r.copyWith(isEnabled: value) : r)
        .toList();

    state = AsyncValue.data(current.copyWith(reminders: newReminders));
  }

  /// Tüm günü sıfırlar (test için, ileride "Reset day" butonuyla).
  void resetDay() {
    final base = _buildFromMock();
    state = AsyncValue.data(base.copyWith(
      consumedLiters: 0,
      filledGlasses: 0,
      timeline: const [],
    ));
  }
}

final waterTrackerProvider =
    AsyncNotifierProvider<WaterTrackerNotifier, WaterTrackerState>(
  WaterTrackerNotifier.new,
);
