/// Server-smoothed weight trend over the requested window.
///
/// Returned by `GET /weight/trend?weeks=8`. Each [WeightTrendPoint]
/// represents a smoothed weekly value; the raw daily logs sit behind
/// [WeightLog] and are not surfaced here.
class WeightTrend {
  const WeightTrend({
    required this.points,
    required this.startKg,
    required this.currentKg,
    this.targetKg,
  });

  final List<WeightTrendPoint> points;
  final double startKg;
  final double currentKg;

  /// Optional — only present when the user has an active weight goal.
  final double? targetKg;

  factory WeightTrend.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List<dynamic>?) ?? const [];
    return WeightTrend(
      points: rawPoints
          .cast<Map<String, dynamic>>()
          .map(WeightTrendPoint.fromJson)
          .toList(growable: false),
      startKg: (json['start_kg'] as num).toDouble(),
      currentKg: (json['current_kg'] as num).toDouble(),
      targetKg: (json['target_kg'] as num?)?.toDouble(),
    );
  }

  /// Net change since the start of the window (negative when losing).
  double get delta => currentKg - startKg;
}

class WeightTrendPoint {
  const WeightTrendPoint({required this.date, required this.kg});

  final DateTime date;
  final double kg;

  factory WeightTrendPoint.fromJson(Map<String, dynamic> json) {
    return WeightTrendPoint(
      date: DateTime.parse(json['date'] as String).toLocal(),
      kg: (json['kg'] as num).toDouble(),
    );
  }
}
