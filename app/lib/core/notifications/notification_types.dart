/// All notification categories used across the app.
///
/// Each type maps to a dedicated Android channel and a stable
/// notification id range so we can target cancellation precisely.
enum NotificationType {
  water('water', 'Water Reminders'),
  meal('meal', 'Meal Reminders'),
  habit('habit', 'Habit Reminders'),
  sleep('sleep', 'Sleep Reminders'),
  streak('streak', 'Streak Warnings'),
  aiInsight('ai_insight', 'AI Coach Insights'),
  weeklyRecap('weekly_recap', 'Weekly Recap'),
  achievement('achievement', 'Achievements');

  const NotificationType(this.channelId, this.channelName);

  /// Stable Android channel id. Once shipped, NEVER change this string —
  /// users would see their notification preferences reset.
  final String channelId;

  /// Human-readable channel name shown in Android system settings.
  final String channelName;

  /// Reserved id range start (inclusive). Each type gets 1000 slots.
  /// e.g. water = 1000..1999, meal = 2000..2999.
  /// Use this so cancellation by type stays predictable.
  int get idBase {
    return switch (this) {
      NotificationType.water => 1000,
      NotificationType.meal => 2000,
      NotificationType.habit => 3000,
      NotificationType.sleep => 4000,
      NotificationType.streak => 5000,
      NotificationType.aiInsight => 6000,
      NotificationType.weeklyRecap => 7000,
      NotificationType.achievement => 8000,
    };
  }

  /// Convert string back to enum. Defaults to [water] if unknown so we
  /// never crash on a malformed payload from an old app version.
  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.water;
    return NotificationType.values.firstWhere(
      (t) => t.channelId == value,
      orElse: () => NotificationType.water,
    );
  }
}
