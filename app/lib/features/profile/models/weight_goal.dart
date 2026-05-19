/// Weight goal model — mirrors backend `GET /weight/goal` response.
///
/// Backend endpoint: https://nuveli-api.onrender.com/weight/goal
/// Returns 404 when user has no active goal — provider should return `null`.
class WeightGoal {
  final String id;
  final String userId;
  final double targetKg;
  final DateTime? targetDate;
  final WeightGoalDirection direction;
  final double startingWeightKg;
  final WeightGoalStatus status;
  final DateTime createdAt;

  /// 0..100 — server-calculated. Distance covered toward target.
  final double progressPercent;

  /// Negative = losing, positive = gaining. Average over last 4 weeks.
  final double? weeklyChangeKg;

  const WeightGoal({
    required this.id,
    required this.userId,
    required this.targetKg,
    required this.targetDate,
    required this.direction,
    required this.startingWeightKg,
    required this.status,
    required this.createdAt,
    required this.progressPercent,
    required this.weeklyChangeKg,
  });

  factory WeightGoal.fromJson(Map<String, dynamic> json) {
    return WeightGoal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetKg: (json['target_kg'] as num).toDouble(),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      direction: WeightGoalDirection.fromJson(json['direction'] as String?),
      startingWeightKg: (json['starting_weight_kg'] as num?)?.toDouble() ?? 0,
      status: WeightGoalStatus.fromJson(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      weeklyChangeKg: (json['weekly_change_kg'] as num?)?.toDouble(),
    );
  }

  /// Difference between starting weight and target. Positive number = loss target,
  /// negative = gain target. (e.g. 101 → 85 returns 16.0)
  double get deltaKg => (startingWeightKg - targetKg).abs();

  /// Days remaining until target_date. Null if no date set or already past.
  int? get daysRemaining {
    if (targetDate == null) return null;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Human-readable summary: "16 kg to go" / "Maintain 75 kg" / "+5 kg to gain"
  String summaryText() {
    switch (direction) {
      case WeightGoalDirection.lose:
        return '${deltaKg.toStringAsFixed(deltaKg.truncateToDouble() == deltaKg ? 0 : 1)} kg to go';
      case WeightGoalDirection.gain:
        return '+${deltaKg.toStringAsFixed(deltaKg.truncateToDouble() == deltaKg ? 0 : 1)} kg to gain';
      case WeightGoalDirection.maintain:
        return 'Maintain ${targetKg.toStringAsFixed(0)} kg';
    }
  }
}

enum WeightGoalDirection {
  lose,
  maintain,
  gain;

  static WeightGoalDirection fromJson(String? value) {
    switch (value) {
      case 'lose':
        return WeightGoalDirection.lose;
      case 'gain':
        return WeightGoalDirection.gain;
      case 'maintain':
        return WeightGoalDirection.maintain;
      default:
        return WeightGoalDirection.lose;
    }
  }

  String toJson() => name;
}

enum WeightGoalStatus {
  active,
  achieved,
  paused,
  cancelled;

  static WeightGoalStatus fromJson(String? value) {
    switch (value) {
      case 'active':
        return WeightGoalStatus.active;
      case 'achieved':
        return WeightGoalStatus.achieved;
      case 'paused':
        return WeightGoalStatus.paused;
      case 'cancelled':
        return WeightGoalStatus.cancelled;
      default:
        return WeightGoalStatus.active;
    }
  }

  String toJson() => name;
}
