/// One weight measurement at a point in time.
///
/// Stored server-side via `POST /weight/logs`. The list endpoint
/// returns newest-first and the analytics line-chart consumes the
/// smoothed [WeightTrend] aggregate (computed server-side from these
/// rows) — clients should not roll their own smoothing.
class WeightLog {
  const WeightLog({
    required this.id,
    required this.kg,
    required this.loggedAt,
    this.notes,
  });

  final String id;
  final double kg;
  final DateTime loggedAt;
  final String? notes;

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'] as String,
      kg: (json['kg'] as num).toDouble(),
      loggedAt: DateTime.parse(json['logged_at'] as String).toLocal(),
      notes: json['notes'] as String?,
    );
  }
}
