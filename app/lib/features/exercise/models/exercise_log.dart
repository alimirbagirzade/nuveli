/// A single logged activity session.
///
/// Mirrors the Nuveli backend `ExerciseLog` (`POST /exercise/logs`,
/// `GET /exercise/logs`). Exercise is a **positive wellness habit only**.
///
/// `estCalories` is an *informational* estimate of energy used during the
/// session (backend MET table). It is **display-only**: it is never added to
/// the calorie budget/target and never implies the user "earned" food. It is
/// `null` whenever the backend lacks the user's weight — in that case the UI
/// simply omits the badge rather than guessing. See
/// `docs/protocols/safety-wellness-boundary.md`.
class ExerciseLog {
  final String id;
  final String userId;

  /// One of: walking | running | cycling | hiking | swimming | gym | yoga |
  /// pilates | dancing | hiit | jump_rope | rowing | sports | other.
  final String activityType;

  final int durationMin;

  /// Optional: light | moderate | vigorous.
  final String? intensity;

  final String? note;

  /// Informational estimate of calories used during this session. Display-only
  /// — never affects the calorie budget. `null` when the backend can't estimate
  /// (e.g. user weight unknown); the UI hides the badge in that case.
  final int? estCalories;

  /// When the activity happened (rendered in device-local TZ).
  final DateTime loggedAt;

  /// Server-side row creation timestamp.
  final DateTime createdAt;

  const ExerciseLog({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.durationMin,
    this.intensity,
    this.note,
    this.estCalories,
    required this.loggedAt,
    required this.createdAt,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      activityType: (json['activity_type'] as String?) ?? 'other',
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
      intensity: json['intensity'] as String?,
      note: json['note'] as String?,
      estCalories: (json['est_calories'] as num?)?.toInt(),
      loggedAt: _parseLocal(json['logged_at']) ?? DateTime.now(),
      createdAt: _parseLocal(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'duration_min': durationMin,
      if (intensity != null) 'intensity': intensity,
      if (note != null) 'note': note,
      if (estCalories != null) 'est_calories': estCalories,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Backend stores UTC; render in the device's local timezone.
  static DateTime? _parseLocal(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }
}
