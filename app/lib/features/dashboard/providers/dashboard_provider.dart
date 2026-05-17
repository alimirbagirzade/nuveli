import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_meals.dart';
import '../models/macros_data.dart';
import '../models/meal.dart';

class DashboardData {
  final double consumedCalories;
  final double targetCalories;
  final MacrosData macros;
  final List<Meal> todaysMeals;

  const DashboardData({
    required this.consumedCalories,
    required this.targetCalories,
    required this.macros,
    required this.todaysMeals,
  });

  double get remainingCalories =>
      (targetCalories - consumedCalories).clamp(0, targetCalories).toDouble();

  double get progress => targetCalories == 0
      ? 0
      : (consumedCalories / targetCalories).clamp(0.0, 1.0);
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return DashboardData(
    consumedCalories: DashboardMockData.consumedCalories,
    targetCalories: DashboardMockData.targetCalories,
    macros: DashboardMockData.macros,
    todaysMeals: mockTodaysMeals,
  );
});
