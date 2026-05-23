/// Models mirroring `AIInsightResponse` from `backend/models/ai_coach.py`.
///
/// `GET /coach/today` returns:
///   {
///     id, user_id, insight_date,
///     nutrition_score: 0-100,
///     today_insight: "free-form coaching paragraph",
///     tips: [{icon, title, description, category?}],
///     recommended_action?: {text, action_type?, payload?},
///     generated_at, model_used?
///   }
///
/// Backend enum `TipIcon`: muscle | leaf | water | fire | moon | walk |
/// scale | sun. UI maps to Material icons via [TipIconMap].
class AIInsight {
  final String? id;
  final String userId;
  final DateTime insightDate;
  final int nutritionScore; // 0-100
  final String todayInsight;
  final List<CoachTip> tips;
  final RecommendedAction? recommendedAction;
  final DateTime generatedAt;
  final String? modelUsed;

  const AIInsight({
    this.id,
    required this.userId,
    required this.insightDate,
    required this.nutritionScore,
    required this.todayInsight,
    this.tips = const [],
    this.recommendedAction,
    required this.generatedAt,
    this.modelUsed,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    final tipsRaw = json['tips'] as List<dynamic>? ?? const [];
    return AIInsight(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      insightDate: _asDate(json['insight_date']),
      nutritionScore: _asInt(json['nutrition_score']).clamp(0, 100),
      todayInsight: json['today_insight']?.toString() ?? '',
      tips: tipsRaw
          .whereType<Map<String, dynamic>>()
          .map(CoachTip.fromJson)
          .toList(growable: false),
      recommendedAction: json['recommended_action'] is Map<String, dynamic>
          ? RecommendedAction.fromJson(
              json['recommended_action'] as Map<String, dynamic>)
          : null,
      generatedAt: _asDateTime(json['generated_at']),
      modelUsed: json['model_used']?.toString(),
    );
  }
}

class CoachTip {
  final String icon; // muscle | leaf | water | fire | moon | walk | scale | sun
  final String title;
  final String description;
  final String? category;

  const CoachTip({
    required this.icon,
    required this.title,
    required this.description,
    this.category,
  });

  factory CoachTip.fromJson(Map<String, dynamic> json) => CoachTip(
        icon: json['icon']?.toString() ?? 'leaf',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString(),
      );
}

class RecommendedAction {
  final String text;

  /// One of: add_meal | adjust_reminder | add_habit | log_water |
  /// increase_target. Null if there's just text with no executable action.
  final String? actionType;

  /// Optional payload bundle backend includes for the action.
  /// We re-send it via `POST /coach/apply-tip` so the server has full
  /// context.
  final Map<String, dynamic>? payload;

  const RecommendedAction({
    required this.text,
    this.actionType,
    this.payload,
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) =>
      RecommendedAction(
        text: json['text']?.toString() ?? '',
        actionType: json['action_type']?.toString(),
        payload: json['payload'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['payload'] as Map<String, dynamic>)
            : null,
      );

  /// True when the user can actually tap a button (vs read-only text).
  bool get isExecutable => actionType != null && actionType!.isNotEmpty;

  /// Short verb for the CTA button. Falls back to "Apply" for unknown
  /// action types.
  String get ctaLabel {
    switch (actionType) {
      case 'add_meal':
        return 'Add meal';
      case 'adjust_reminder':
        return 'Set reminder';
      case 'add_habit':
        return 'Add habit';
      case 'log_water':
        return 'Log water';
      case 'increase_target':
        return 'Update target';
      default:
        return 'Apply';
    }
  }
}

class ApplyTipResult {
  final bool success;
  final String actionTaken;
  final Map<String, dynamic>? details;

  const ApplyTipResult({
    required this.success,
    required this.actionTaken,
    this.details,
  });

  factory ApplyTipResult.fromJson(Map<String, dynamic> json) => ApplyTipResult(
        success: json['success'] == true,
        actionTaken: json['action_taken']?.toString() ?? '',
        details: json['details'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['details'] as Map<String, dynamic>)
            : null,
      );
}

DateTime _asDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString()) ?? DateTime.now();
}

DateTime _asDateTime(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString())?.toLocal() ?? DateTime.now();
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}
