/// A single activity to be imported from the phone's health store into the
/// Nuveli activity log via `POST /exercise/import`.
///
/// Built by [HealthService] from a Health Connect (Android) / Apple Health
/// (iOS) workout record. The backend dedupes on `(source, external_id)`, so
/// re-running a sync never creates duplicates.
///
/// Wellness boundary: [deviceCalories] is the device's own active-energy
/// estimate for the session. It is carried purely so the existing neutral
/// "≈N kcal" badge can display it — it is **never** added to the calorie
/// budget/target and never framed as "earned" or "eat-back" energy. See
/// `docs/protocols/safety-wellness-boundary.md`.
class ExerciseImportItem {
  /// One of the 14 canonical Nuveli activity types (see `kExerciseTypes`).
  /// Unknown platform workout types are mapped to `'other'`.
  final String activityType;

  final int durationMin;

  /// Optional: light | moderate | vigorous. Device records rarely expose this,
  /// so it is usually null.
  final String? intensity;

  /// When the activity started (maps to the platform record's start time).
  final DateTime loggedAt;

  /// The platform record UUID. Required — this is the dedup key.
  final String externalId;

  /// Device-reported active energy for this session, in kcal. Display-only.
  /// Null when the platform didn't attach an energy figure to the workout.
  final int? deviceCalories;

  /// `'health_connect'` (Android) or `'apple_health'` (iOS).
  final String source;

  const ExerciseImportItem({
    required this.activityType,
    required this.durationMin,
    this.intensity,
    required this.loggedAt,
    required this.externalId,
    this.deviceCalories,
    required this.source,
  });

  /// Matches the `POST /exercise/import` contract item shape.
  Map<String, dynamic> toJson() {
    return {
      'activity_type': activityType,
      'duration_min': durationMin,
      if (intensity != null) 'intensity': intensity,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'external_id': externalId,
      if (deviceCalories != null) 'device_calories': deviceCalories,
      'source': source,
    };
  }
}

/// Result of an import call: how many new rows were created vs. skipped
/// (already present, deduped by the backend).
class ExerciseImportResult {
  final int imported;
  final int skipped;

  const ExerciseImportResult({required this.imported, required this.skipped});

  factory ExerciseImportResult.fromJson(Map<String, dynamic> json) {
    return ExerciseImportResult(
      imported: (json['imported'] as num?)?.toInt() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
    );
  }
}
