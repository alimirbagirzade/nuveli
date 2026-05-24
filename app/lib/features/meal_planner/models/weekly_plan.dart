/// Models mirroring `WeeklyPlanResponse`, `MealPlanResponse`, and
/// `GrocerySummaryResponse` from `backend/models/meal_plan.py`.
///
/// `GET /meal-plans?week_start=YYYY-MM-DD` returns:
///   {
///     week_start, week_end,
///     days: [{plan_date, total_calories, total_protein_g, ..., meal_count}],
///     total_calories,
///     plans: [{id, plan_date, meal_type, recipe?, custom_name?,
///              total_calories, total_protein_g, ...}],
///   }
class WeeklyPlan {
  final DateTime weekStart; // local midnight
  final DateTime weekEnd;
  final List<DailyPlanTotal> days;
  final int totalCalories;
  final List<MealPlanEntry> plans;

  const WeeklyPlan({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.totalCalories,
    required this.plans,
  });

  bool get isEmpty => plans.isEmpty;

  /// All plan entries on a specific calendar day (local TZ).
  List<MealPlanEntry> plansFor(DateTime day) {
    return plans
        .where((p) =>
            p.planDate.year == day.year &&
            p.planDate.month == day.month &&
            p.planDate.day == day.day)
        .toList(growable: false);
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'] as List<dynamic>? ?? const [];
    final plansRaw = json['plans'] as List<dynamic>? ?? const [];
    return WeeklyPlan(
      weekStart: _asDate(json['week_start']),
      weekEnd: _asDate(json['week_end']),
      totalCalories: _asInt(json['total_calories']),
      days: daysRaw
          .whereType<Map<String, dynamic>>()
          .map(DailyPlanTotal.fromJson)
          .toList(growable: false),
      plans: plansRaw
          .whereType<Map<String, dynamic>>()
          .map(MealPlanEntry.fromJson)
          .toList(growable: false),
    );
  }
}

class DailyPlanTotal {
  final DateTime planDate;
  final int totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final int mealCount;

  const DailyPlanTotal({
    required this.planDate,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.mealCount,
  });

  factory DailyPlanTotal.fromJson(Map<String, dynamic> json) => DailyPlanTotal(
        planDate: _asDate(json['plan_date']),
        totalCalories: _asInt(json['total_calories']),
        totalProteinG: _asDouble(json['total_protein_g']),
        totalCarbsG: _asDouble(json['total_carbs_g']),
        totalFatG: _asDouble(json['total_fat_g']),
        mealCount: _asInt(json['meal_count']),
      );
}

class MealPlanEntry {
  final String id;
  final DateTime planDate;
  final String mealType; // breakfast | lunch | dinner | snack
  final String? recipeName; // resolved from `recipe.name` if present
  final String? recipeImageUrl;
  final String? customName;
  final double servings;
  final int totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final String? note;

  const MealPlanEntry({
    required this.id,
    required this.planDate,
    required this.mealType,
    this.recipeName,
    this.recipeImageUrl,
    this.customName,
    this.servings = 1.0,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    this.note,
  });

  /// Display name — recipe name first, else custom_name, else fall back
  /// to the meal-type label.
  String get displayName {
    if (recipeName != null && recipeName!.isNotEmpty) return recipeName!;
    if (customName != null && customName!.isNotEmpty) return customName!;
    return mealTypeLabel;
  }

  String get mealTypeLabel {
    if (mealType.isEmpty) return 'Meal';
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe'] is Map<String, dynamic>
        ? json['recipe'] as Map<String, dynamic>
        : null;
    return MealPlanEntry(
      id: json['id']?.toString() ?? '',
      planDate: _asDate(json['plan_date']),
      mealType: (json['meal_type']?.toString() ?? 'snack').toLowerCase(),
      recipeName: recipe?['name']?.toString(),
      recipeImageUrl: recipe?['image_url']?.toString(),
      customName: json['custom_name']?.toString(),
      servings: _asDouble(json['servings'], fallback: 1.0),
      totalCalories: _asInt(json['total_calories']),
      totalProteinG: _asDouble(json['total_protein_g']),
      totalCarbsG: _asDouble(json['total_carbs_g']),
      totalFatG: _asDouble(json['total_fat_g']),
      note: json['note']?.toString(),
    );
  }
}

class GrocerySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<GroceryItem> items;
  final int recipeCount;

  const GrocerySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.items,
    required this.recipeCount,
  });

  bool get isEmpty => items.isEmpty;

  factory GrocerySummary.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? const [];
    return GrocerySummary(
      weekStart: _asDate(json['week_start']),
      weekEnd: _asDate(json['week_end']),
      recipeCount: _asInt(json['recipe_count']),
      items: itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(GroceryItem.fromJson)
          .toList(growable: false),
    );
  }
}

class GroceryItem {
  final String name;
  final double totalAmount;
  final String unit;
  final int usedInRecipes;

  const GroceryItem({
    required this.name,
    required this.totalAmount,
    required this.unit,
    this.usedInRecipes = 1,
  });

  String get displayAmount {
    if (totalAmount == totalAmount.roundToDouble()) {
      return '${totalAmount.toInt()} $unit';
    }
    return '${totalAmount.toStringAsFixed(1)} $unit';
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        name: json['name']?.toString() ?? '',
        totalAmount: _asDouble(json['total_amount']),
        unit: json['unit']?.toString() ?? '',
        usedInRecipes: _asInt(json['used_in_recipes'], fallback: 1),
      );
}

/// Mirrors `RecipeResponse` from `backend/models/meal_plan.py`.
///
/// `GET /recipes` returns a list of these objects.
class RecipeResponse {
  final String id;
  final String name;
  final String? imageUrl;
  final int caloriesPerServing;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double servings;

  const RecipeResponse({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.caloriesPerServing,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.servings,
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) => RecipeResponse(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        imageUrl: json['image_url']?.toString(),
        caloriesPerServing: _asInt(json['calories_per_serving']),
        proteinG: _asDouble(json['protein_g']),
        carbsG: _asDouble(json['carbs_g']),
        fatG: _asDouble(json['fat_g']),
        servings: _asDouble(json['servings'], fallback: 1.0),
      );
}

/// Helpers shared by all models above.
DateTime _asDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString()) ?? DateTime.now();
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

double _asDouble(dynamic v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}
