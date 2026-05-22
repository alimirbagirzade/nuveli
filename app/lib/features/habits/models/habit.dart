/// Mirrors `HabitResponse` from `GET /habits`. The live DB has
/// columns the Python model doesn't fully expose (`title`/`name`
/// drift — see [[project-schema-drift-endemic]]), so this model
/// tolerates either key on read.
class Habit {
  final String id;
  final String name;
  final String? icon;
  final bool completedToday;
  final int currentStreak;

  const Habit({
    required this.id,
    required this.name,
    this.icon,
    required this.completedToday,
    required this.currentStreak,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id']?.toString() ?? '',
      // Backend Python model uses `name`; DB seed migration writes
      // a `title` column. Accept either.
      name: (json['name'] ?? json['title'] ?? '').toString(),
      icon: json['icon']?.toString(),
      completedToday: json['completed_today'] == true,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
    );
  }

  Habit copyWith({bool? completedToday, int? currentStreak}) {
    return Habit(
      id: id,
      name: name,
      icon: icon,
      completedToday: completedToday ?? this.completedToday,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
