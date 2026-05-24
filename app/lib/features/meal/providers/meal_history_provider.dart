import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../dashboard/models/meal.dart';

/// Full meal history (newest first), independent of the dashboard's
/// today-only providers. Fetches a generous first page; the list is
/// read-mostly so we don't paginate further in v1.
final mealHistoryProvider = FutureProvider.autoDispose<List<Meal>>((ref) async {
  final repo = ref.watch(mealsRepositoryProvider);
  return repo.getMealHistory(limit: 100);
});

/// Meals grouped by local calendar day, newest day first, each day's
/// meals newest-first. Pure transform over [mealHistoryProvider]'s data.
Map<DateTime, List<Meal>> groupMealsByDay(List<Meal> meals) {
  final grouped = <DateTime, List<Meal>>{};
  for (final meal in meals) {
    final d = meal.consumedAt.toLocal();
    final day = DateTime(d.year, d.month, d.day);
    grouped.putIfAbsent(day, () => <Meal>[]).add(meal);
  }
  return grouped;
}
