/// Weight trend model — mirrors backend `GET /analytics/weight-trend?period=8w` response.
///
/// Backend endpoint: https://nuveli-api.onrender.com/analytics/weight-trend
class WeightTrend {
  final List<WeightTrendPoint> points;
  final int periodDays;
  final double startWeight;
  final double currentWeight;
  final double deltaKg;

  const WeightTrend({
    required this.points,
    required this.periodDays,
    required this.startWeight,
    required this.currentWeight,
    required this.deltaKg,
  });

  factory WeightTrend.fromJson(Map<String, dynamic> json) {
    return WeightTrend(
      points: (json['points'] as List<dynamic>? ?? [])
          .map((p) => WeightTrendPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      periodDays: (json['period_days'] as num?)?.toInt() ?? 0,
      startWeight: (json['start_weight'] as num?)?.toDouble() ?? 0,
      currentWeight: (json['current_weight'] as num?)?.toDouble() ?? 0,
      deltaKg: (json['delta_kg'] as num?)?.toDouble() ?? 0,
    );
  }

  /// True if the trend has at least 2 data points (enough to draw a line).
  bool get hasEnoughData => points.length >= 2;

  /// Min/max weight across all points, useful for chart Y-axis scaling.
  double get minWeight {
    if (points.isEmpty) return currentWeight;
    return points.map((p) => p.weightKg).reduce((a, b) => a < b ? a : b);
  }

  double get maxWeight {
    if (points.isEmpty) return currentWeight;
    return points.map((p) => p.weightKg).reduce((a, b) => a > b ? a : b);
  }

  /// Direction summary for UI: "▼ 4.2 kg" / "▲ 1.5 kg" / "± 0 kg"
  String deltaText() {
    if (deltaKg.abs() < 0.1) return '± 0 kg';
    final arrow = deltaKg < 0 ? '▼' : '▲';
    return '$arrow ${deltaKg.abs().toStringAsFixed(1)} kg';
  }
}

class WeightTrendPoint {
  final DateTime date;
  final double weightKg;
  final double? movingAvgKg;

  const WeightTrendPoint({
    required this.date,
    required this.weightKg,
    required this.movingAvgKg,
  });

  factory WeightTrendPoint.fromJson(Map<String, dynamic> json) {
    return WeightTrendPoint(
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      movingAvgKg: (json['moving_avg_kg'] as num?)?.toDouble(),
    );
  }
}
