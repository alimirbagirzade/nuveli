import 'package:intl/intl.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🍓';
      case MealType.lunch:
        return '🥗';
      case MealType.dinner:
        return '🐟';
      case MealType.snack:
        return '🥜';
    }
  }
}

class MacroBreakdown {
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MacroBreakdown({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}

class Meal {
  final String id;
  final MealType type;
  final String name;
  final int calories;
  final DateTime consumedAt;
  final String? imageUrl;
  final MacroBreakdown macros;

  const Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.consumedAt,
    this.imageUrl,
    required this.macros,
  });

  /// Returns "7:30 AM" formatted time.
  String get formattedTime => DateFormat.jm().format(consumedAt);
}
