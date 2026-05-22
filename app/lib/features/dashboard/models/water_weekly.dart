/// Mirrors `WaterWeeklyResponse` from the Nuveli backend
/// (`GET /water/weekly`). 7 day buckets, oldest → today.
class WaterDayTotal {
  final DateTime day;
  final int totalMl;
  final int targetMl;

  const WaterDayTotal({
    required this.day,
    required this.totalMl,
    required this.targetMl,
  });

  factory WaterDayTotal.fromJson(Map<String, dynamic> json) {
    return WaterDayTotal(
      day: DateTime.parse((json['day'] as String).substring(0, 10)),
      totalMl: (json['total_ml'] as num?)?.toInt() ?? 0,
      targetMl: (json['target_ml'] as num?)?.toInt() ?? 2500,
    );
  }

  /// True when this bucket represents today's calendar date.
  bool get isToday {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  /// 0..1 fraction toward target. Capped at 1.0 so the bar fills the
  /// chart cleanly when the user over-drinks.
  double get fractionOfTarget {
    if (targetMl <= 0) return 0;
    return (totalMl / targetMl).clamp(0.0, 1.0);
  }
}

class WaterWeekly {
  final List<WaterDayTotal> days;
  final int targetMl;

  const WaterWeekly({required this.days, required this.targetMl});

  factory WaterWeekly.fromJson(Map<String, dynamic> json) {
    final raw = (json['days'] as List?) ?? const [];
    return WaterWeekly(
      days: raw
          .cast<Map<String, dynamic>>()
          .map(WaterDayTotal.fromJson)
          .toList(growable: false),
      targetMl: (json['target_ml'] as num?)?.toInt() ?? 2500,
    );
  }

  int get totalConsumedMl =>
      days.fold<int>(0, (sum, d) => sum + d.totalMl);

  int get daysHittingTarget =>
      days.where((d) => d.totalMl >= d.targetMl && d.targetMl > 0).length;
}
