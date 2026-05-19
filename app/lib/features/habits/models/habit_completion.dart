/// A single "I completed habit X at time Y" log row.
///
/// Returned by `POST /habits/{id}/toggle` when a habit is marked
/// done. When the same habit is toggled OFF the backend returns
/// `{ "completed": false }` instead and we surface `null` upstream.
class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
  });

  final String id;
  final String habitId;
  final DateTime completedAt;

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      completedAt:
          DateTime.parse(json['completed_at'] as String).toLocal(),
    );
  }
}
