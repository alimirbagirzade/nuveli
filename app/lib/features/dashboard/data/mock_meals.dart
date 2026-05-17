import '../models/macros_data.dart';
import '../models/meal.dart';

DateTime _todayAt(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

final mockTodaysMeals = <Meal>[
  Meal(
    id: '1',
    type: MealType.breakfast,
    name: 'Greek Yogurt Bowl',
    calories: 350,
    consumedAt: _todayAt(7, 30),
    macros: const MacroBreakdown(proteinG: 18, carbsG: 42, fatG: 12),
  ),
  Meal(
    id: '2',
    type: MealType.lunch,
    name: 'Grilled Chicken Salad',
    calories: 520,
    consumedAt: _todayAt(12, 45),
    macros: const MacroBreakdown(proteinG: 42, carbsG: 28, fatG: 22),
  ),
  Meal(
    id: '3',
    type: MealType.dinner,
    name: 'Salmon & Quinoa',
    calories: 610,
    consumedAt: _todayAt(19, 15),
    macros: const MacroBreakdown(proteinG: 35, carbsG: 90, fatG: 14),
  ),
];

/// Aggregations for the dashboard from mock meals.
/// Chat 15: This whole class disappears; values come from MealsRepository.
class DashboardMockData {
  static const double targetCalories = 2100.0;
  static const double proteinTarget = 140.0;
  static const double carbsTarget = 210.0;
  static const double fatTarget = 70.0;

  static double get consumedCalories =>
      mockTodaysMeals.fold(0.0, (sum, m) => sum + m.calories);

  static MacrosData get macros {
    final p = mockTodaysMeals.fold(0.0, (s, m) => s + m.macros.proteinG);
    final c = mockTodaysMeals.fold(0.0, (s, m) => s + m.macros.carbsG);
    final f = mockTodaysMeals.fold(0.0, (s, m) => s + m.macros.fatG);
    return MacrosData(
      proteinCurrent: p,
      proteinTarget: proteinTarget,
      carbsCurrent: c,
      carbsTarget: carbsTarget,
      fatCurrent: f,
      fatTarget: fatTarget,
    );
  }
}
