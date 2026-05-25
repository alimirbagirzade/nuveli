import 'dart:io' show Platform;

import 'package:health/health.dart';

import '../models/exercise_import_item.dart';
import '../widgets/log_exercise_sheet.dart' show kExerciseTypes;

/// Outcome of a health-data operation. The UI uses this to decide what to
/// show — never an exception. `ok` carries imported items; the other values
/// are terminal states the toggle must handle gracefully (flip back off +
/// explain), never crash on.
enum HealthStatus {
  /// Everything worked — see the returned items.
  ok,

  /// Health Connect not installed (Android) or HealthKit unavailable (iOS,
  /// e.g. iPad, or the paused-iOS no-entitlement case).
  unavailable,

  /// The user (or the OS) declined the read permissions.
  permissionDenied,

  /// An unexpected error talking to the health store — treated like a
  /// soft failure (empty import), never surfaced as a crash.
  error,
}

/// Result wrapper so callers get a status + payload without try/catch.
class HealthFetchResult {
  final HealthStatus status;
  final List<ExerciseImportItem> items;

  const HealthFetchResult(this.status, [this.items = const []]);
}

/// Thin, opt-in wrapper over the `health` plugin (Google Health Connect on
/// Android, Apple HealthKit on iOS).
///
/// Scope is deliberately tiny: READ recent workouts + active energy + steps,
/// map them onto Nuveli's activity-log contract, and hand back
/// [ExerciseImportItem]s for the backend. Nothing here ever writes to the
/// health store.
///
/// Wellness boundary: device active-energy is carried through as
/// `deviceCalories` strictly so the existing neutral "≈N kcal" badge can show
/// it. It is never added to the calorie budget and never framed as earned /
/// eat-back energy. See `docs/protocols/safety-wellness-boundary.md`.
///
/// iOS note: iOS is currently paused and the HealthKit entitlement is
/// intentionally not added to the build. On iOS [requestPermissions] will
/// simply fail to authorize and this service returns
/// [HealthStatus.permissionDenied] / [HealthStatus.unavailable] — the toggle
/// no-ops gracefully. The code path is kept fully aligned for when iOS ships.
class HealthService {
  HealthService({Health? health}) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  /// READ-only types we touch. WORKOUT carries the per-session active-energy
  /// figure (`totalEnergyBurned`), so a separate energy query isn't needed.
  static const List<HealthDataType> _types = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
  ];

  List<HealthDataAccess> get _readAccess =>
      _types.map((_) => HealthDataAccess.READ).toList(growable: false);

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Is the platform health store usable right now?
  /// Android: Health Connect app installed + SDK available.
  /// iOS: HealthKit available on the device (false on most iPads).
  Future<bool> isAvailable() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) {
        return _health.isHealthConnectAvailable();
      }
      // iOS: the plugin reports HealthKit availability via the SDK status
      // probe; isHealthConnectAvailable() returns true on iOS, so gate on
      // platform support instead.
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Request READ permission for workouts + active energy + steps.
  /// Returns false on denial or any error — never throws.
  Future<bool> requestPermissions() async {
    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _readAccess,
      );
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Fetch recent workouts from the health store and map them to the backend
  /// import contract. Never throws — returns a [HealthFetchResult] with a
  /// status the UI can act on.
  ///
  /// Each WORKOUT data point becomes one [ExerciseImportItem]:
  ///   - activity_type: platform workout type → Nuveli's 14-type set
  ///     (unknown → 'other')
  ///   - duration_min: dateTo - dateFrom, rounded, min 1
  ///   - logged_at: dateFrom (session start)
  ///   - external_id: the platform record UUID (dedup key)
  ///   - device_calories: the workout's active energy if present (display-only)
  ///   - source: 'health_connect' (Android) / 'apple_health' (iOS)
  Future<HealthFetchResult> fetchRecentWorkouts({int days = 14}) async {
    try {
      if (!await isAvailable()) {
        return const HealthFetchResult(HealthStatus.unavailable);
      }
      await _ensureConfigured();

      final hasPerm =
          await _health.hasPermissions(_types, permissions: _readAccess);
      if (hasPerm != true) {
        final granted = await requestPermissions();
        if (!granted) {
          return const HealthFetchResult(HealthStatus.permissionDenied);
        }
      }

      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));

      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: start,
        endTime: now,
      );

      final source = _sourceTag();
      final items = <ExerciseImportItem>[];
      for (final p in points) {
        final item = _toImportItem(p, source);
        if (item != null) items.add(item);
      }
      return HealthFetchResult(HealthStatus.ok, items);
    } catch (_) {
      return const HealthFetchResult(HealthStatus.error);
    }
  }

  String _sourceTag() =>
      Platform.isAndroid ? 'health_connect' : 'apple_health';

  ExerciseImportItem? _toImportItem(HealthDataPoint p, String source) {
    final value = p.value;
    if (value is! WorkoutHealthValue) return null;
    if (p.uuid.isEmpty) return null;

    final durationMin = p.dateTo.difference(p.dateFrom).inMinutes;
    if (durationMin <= 0) return null;

    final calories = value.totalEnergyBurned; // kcal, may be null
    return ExerciseImportItem(
      activityType: _mapActivityType(value.workoutActivityType),
      durationMin: durationMin,
      loggedAt: p.dateFrom,
      externalId: p.uuid,
      deviceCalories: (calories != null && calories > 0) ? calories : null,
      source: source,
    );
  }

  /// Maps a platform [HealthWorkoutActivityType] onto Nuveli's 14 canonical
  /// activity types. Anything unrecognised collapses to 'other'. The result is
  /// validated against [kExerciseTypes] so a future plugin enum change can
  /// never push an off-contract value to the backend.
  static String _mapActivityType(HealthWorkoutActivityType t) {
    String mapped;
    switch (t) {
      case HealthWorkoutActivityType.WALKING:
      case HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE:
        mapped = 'walking';
        break;
      case HealthWorkoutActivityType.RUNNING:
      case HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE:
      case HealthWorkoutActivityType.TRACK_AND_FIELD:
        mapped = 'running';
        break;
      case HealthWorkoutActivityType.BIKING:
      case HealthWorkoutActivityType.BIKING_STATIONARY:
      case HealthWorkoutActivityType.HAND_CYCLING:
        mapped = 'cycling';
        break;
      case HealthWorkoutActivityType.HIKING:
        mapped = 'hiking';
        break;
      case HealthWorkoutActivityType.SWIMMING:
      case HealthWorkoutActivityType.WATER_FITNESS:
      case HealthWorkoutActivityType.WATER_SPORTS:
      case HealthWorkoutActivityType.WATER_POLO:
        mapped = 'swimming';
        break;
      case HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.CROSS_TRAINING:
      case HealthWorkoutActivityType.STEP_TRAINING:
      case HealthWorkoutActivityType.STAIR_CLIMBING:
      case HealthWorkoutActivityType.STAIRS:
      case HealthWorkoutActivityType.ELLIPTICAL:
      case HealthWorkoutActivityType.CALISTHENICS:
      case HealthWorkoutActivityType.CORE_TRAINING:
        mapped = 'gym';
        break;
      case HealthWorkoutActivityType.YOGA:
      case HealthWorkoutActivityType.MIND_AND_BODY:
      case HealthWorkoutActivityType.TAI_CHI:
      case HealthWorkoutActivityType.FLEXIBILITY:
        mapped = 'yoga';
        break;
      case HealthWorkoutActivityType.PILATES:
      case HealthWorkoutActivityType.BARRE:
        mapped = 'pilates';
        break;
      case HealthWorkoutActivityType.CARDIO_DANCE:
      case HealthWorkoutActivityType.SOCIAL_DANCE:
        mapped = 'dancing';
        break;
      case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
      case HealthWorkoutActivityType.MIXED_CARDIO:
        mapped = 'hiit';
        break;
      case HealthWorkoutActivityType.JUMP_ROPE:
        mapped = 'jump_rope';
        break;
      case HealthWorkoutActivityType.ROWING:
        mapped = 'rowing';
        break;
      case HealthWorkoutActivityType.SOCCER:
      case HealthWorkoutActivityType.BASKETBALL:
      case HealthWorkoutActivityType.TENNIS:
      case HealthWorkoutActivityType.BASEBALL:
      case HealthWorkoutActivityType.SOFTBALL:
      case HealthWorkoutActivityType.VOLLEYBALL:
      case HealthWorkoutActivityType.AMERICAN_FOOTBALL:
      case HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL:
      case HealthWorkoutActivityType.RUGBY:
      case HealthWorkoutActivityType.HOCKEY:
      case HealthWorkoutActivityType.HANDBALL:
      case HealthWorkoutActivityType.CRICKET:
      case HealthWorkoutActivityType.BADMINTON:
      case HealthWorkoutActivityType.TABLE_TENNIS:
      case HealthWorkoutActivityType.SQUASH:
      case HealthWorkoutActivityType.RACQUETBALL:
      case HealthWorkoutActivityType.PICKLEBALL:
      case HealthWorkoutActivityType.GOLF:
      case HealthWorkoutActivityType.BOXING:
      case HealthWorkoutActivityType.KICKBOXING:
      case HealthWorkoutActivityType.MARTIAL_ARTS:
      case HealthWorkoutActivityType.WRESTLING:
      case HealthWorkoutActivityType.FENCING:
      case HealthWorkoutActivityType.GYMNASTICS:
      case HealthWorkoutActivityType.CLIMBING:
      case HealthWorkoutActivityType.DISC_SPORTS:
      case HealthWorkoutActivityType.LACROSSE:
        mapped = 'sports';
        break;
      default:
        mapped = 'other';
    }
    // Defensive: never emit an off-contract type.
    return kExerciseTypes.contains(mapped) ? mapped : 'other';
  }
}
