import 'macros_data.dart';
import 'meal.dart';

/// Aggregated dashboard payload that the screen widget watches.
///
/// Builds on top of:
///   - [TodaySummary] (raw server numbers)
///   - [MacrosData]   (macro current/target pairs, in `models/macros_data.dart`)
///   - [Meal]         (today's logged meals)
///
/// Provider source: `lib/features/dashboard/providers/dashboard_provider.dart`
class DashboardData {
  const DashboardData({
    required this.consumedCalories,
    required this.targetCalories,
    required this.macros,
    required this.todaysMeals,
  });

  final double consumedCalories;
  final double targetCalories;
  final MacrosData macros;
  final List<Meal> todaysMeals;

  DashboardData copyWith({
    double? consumedCalories,
    double? targetCalories,
    MacrosData? macros,
    List<Meal>? todaysMeals,
  }) {
    return DashboardData(
      consumedCalories: consumedCalories ?? this.consumedCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      macros: macros ?? this.macros,
      todaysMeals: todaysMeals ?? this.todaysMeals,
    );
  }
}
