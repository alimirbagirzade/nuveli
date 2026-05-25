import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/repositories/exercise_repository.dart';
import '../../notifications/providers/notifications_provider.dart'
    show sharedPreferencesProvider;
import '../models/exercise_import_item.dart';
import '../services/health_service.dart';
import 'exercise_provider.dart';

/// Singleton wrapper over the `health` plugin.
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

/// Persisted on/off for the "connect phone health data" toggle.
///
/// Local-only (SharedPreferences). Reads synchronously off the warmed-up
/// [sharedPreferencesProvider]. The toggle being `true` is the single gate
/// for any health-store access — nothing reads health data unless the user
/// turned this on. Defaults to `false` (opt-in).
class HealthImportEnabledController extends StateNotifier<bool> {
  HealthImportEnabledController(this._prefs)
      : super(_prefs.getBool(_storageKey) ?? false);

  final SharedPreferences _prefs;
  static const _storageKey = 'nuveli.health.import.enabled.v1';

  Future<void> setEnabled(bool value) async {
    if (value == state) return;
    state = value;
    try {
      await _prefs.setBool(_storageKey, value);
    } catch (_) {
      // Non-fatal: worst case the toggle resets next launch.
    }
  }
}

final healthImportEnabledProvider =
    StateNotifierProvider<HealthImportEnabledController, bool>((ref) {
  return HealthImportEnabledController(ref.watch(sharedPreferencesProvider));
});

/// Outcome of a sync attempt surfaced to the settings tile.
class HealthSyncOutcome {
  final HealthStatus status;
  final int imported;
  final int skipped;

  const HealthSyncOutcome({
    required this.status,
    this.imported = 0,
    this.skipped = 0,
  });

  bool get isOk => status == HealthStatus.ok;
}

typedef HealthSyncFn = Future<HealthSyncOutcome> Function({int days});

/// Runs a health-data import: fetch recent workouts from the phone, push them
/// to the backend (deduped), then refresh the exercise providers so the new
/// rows appear. Never throws — maps everything to a [HealthSyncOutcome].
///
/// This is the only path that touches the health store, and callers must only
/// invoke it when [healthImportEnabledProvider] is on (or as part of turning
/// it on). iOS no-ops gracefully (returns unavailable/permissionDenied).
final healthSyncProvider = Provider<HealthSyncFn>((ref) {
  final service = ref.read(healthServiceProvider);
  final repo = ref.read(exerciseRepositoryProvider);

  return ({int days = 14}) async {
    final fetch = await service.fetchRecentWorkouts(days: days);
    if (fetch.status != HealthStatus.ok) {
      return HealthSyncOutcome(status: fetch.status);
    }
    if (fetch.items.isEmpty) {
      return const HealthSyncOutcome(status: HealthStatus.ok);
    }

    final ExerciseImportResult result;
    try {
      result = await repo.importLogs(fetch.items);
    } catch (_) {
      return const HealthSyncOutcome(status: HealthStatus.error);
    }

    // Surface the freshly imported activities everywhere.
    ref.invalidate(exerciseTodaySummaryProvider);
    ref.invalidate(todayExerciseLogsProvider);
    ref.invalidate(exerciseWeeklyProvider);

    return HealthSyncOutcome(
      status: HealthStatus.ok,
      imported: result.imported,
      skipped: result.skipped,
    );
  };
});
