/// Mirrors `WeightTrendResponse` from `GET /analytics/weight-trend`.
class WeightTrendPoint {
  final DateTime date;
  final double weightKg;
  final double movingAvgKg;

  const WeightTrendPoint({
    required this.date,
    required this.weightKg,
    required this.movingAvgKg,
  });

  factory WeightTrendPoint.fromJson(Map<String, dynamic> json) {
    return WeightTrendPoint(
      date: DateTime.parse((json['date'] as String).substring(0, 10)),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      movingAvgKg: (json['moving_avg_kg'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeightTrend {
  final List<WeightTrendPoint> points;
  final int periodDays;
  final double? startWeight;
  final double? currentWeight;
  final double? deltaKg;

  const WeightTrend({
    required this.points,
    required this.periodDays,
    required this.startWeight,
    required this.currentWeight,
    required this.deltaKg,
  });

  factory WeightTrend.fromJson(Map<String, dynamic> json) {
    final raw = (json['points'] as List?) ?? const [];
    return WeightTrend(
      points: raw
          .cast<Map<String, dynamic>>()
          .map(WeightTrendPoint.fromJson)
          .toList(growable: false),
      periodDays: (json['period_days'] as num?)?.toInt() ?? 0,
      startWeight: (json['start_weight'] as num?)?.toDouble(),
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      deltaKg: (json['delta_kg'] as num?)?.toDouble(),
    );
  }

  bool get hasData => points.isNotEmpty;

  /// Min weight in points (for chart Y-axis bottom). 0 when empty.
  double get minWeight {
    if (points.isEmpty) return 0;
    return points
        .map((p) => p.weightKg)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Max weight in points (for chart Y-axis top). 0 when empty.
  double get maxWeight {
    if (points.isEmpty) return 0;
    return points
        .map((p) => p.weightKg)
        .reduce((a, b) => a > b ? a : b);
  }
}
