/// Mirrors the `MealResponse` shape from the Nuveli backend
/// (`GET /meals?date=YYYY-MM-DD` returns a list of these).
class Meal {
  final String id;
  final String mealType; // breakfast | lunch | dinner | snack
  final String? name;
  final int totalCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? imageUrl;
  final String? scanSource; // 'ai_scan' | 'manual' | 'barcode' | 'recipe'
  final DateTime consumedAt;

  const Meal({
    required this.id,
    required this.mealType,
    this.name,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.imageUrl,
    this.scanSource,
    required this.consumedAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id']?.toString() ?? '',
      mealType: (json['meal_type']?.toString() ?? 'snack').toLowerCase(),
      name: json['name']?.toString(),
      totalCalories: _asInt(json['total_calories']),
      // Accept either short (`protein_g`) or long (`total_protein_g`) key.
      proteinG: _asDouble(json['protein_g'] ?? json['total_protein_g']),
      carbsG: _asDouble(json['carbs_g'] ?? json['total_carbs_g']),
      fatG: _asDouble(json['fat_g'] ?? json['total_fat_g']),
      imageUrl: json['image_url']?.toString(),
      scanSource: json['scan_source']?.toString(),
      consumedAt: _asDate(json['consumed_at']),
    );
  }

  /// Convenience: e.g. "Breakfast", "Lunch", etc.
  String get mealTypeLabel {
    if (mealType.isEmpty) return 'Meal';
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  /// Used when [name] is null — fall back to "Breakfast", "Lunch", etc.
  String get displayName => name?.trim().isNotEmpty == true ? name! : mealTypeLabel;

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _asDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static DateTime _asDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString())?.toLocal() ?? DateTime.now();
  }
}
