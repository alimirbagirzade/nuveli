import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/habits/models/habit.dart';

void main() {
  group('Habit.fromJson', () {
    test('parses standard backend shape (Python model)', () {
      final h = Habit.fromJson({
        'id': 'h-1',
        'name': 'Drink water',
        'icon': 'water_drop',
        'completed_today': true,
        'current_streak': 3,
      });
      expect(h.id, equals('h-1'));
      expect(h.name, equals('Drink water'));
      expect(h.icon, equals('water_drop'));
      expect(h.completedToday, isTrue);
      expect(h.currentStreak, equals(3));
    });

    test('falls back to `title` when `name` missing (DB drift)', () {
      final h = Habit.fromJson({
        'id': 'h-1',
        'title': 'Log breakfast',
        'icon': 'rice_bowl',
        'completed_today': false,
      });
      expect(h.name, equals('Log breakfast'));
    });

    test('defaults missing fields safely', () {
      final h = Habit.fromJson({'id': 'h-1'});
      expect(h.name, equals(''));
      expect(h.icon, isNull);
      expect(h.completedToday, isFalse);
      expect(h.currentStreak, equals(0));
    });
  });

  group('Habit.copyWith', () {
    test('flips completedToday without touching other fields', () {
      const h = Habit(
        id: 'h-1',
        name: 'Sleep',
        icon: '🌙',
        completedToday: false,
        currentStreak: 5,
      );
      final flipped = h.copyWith(completedToday: true);
      expect(flipped.completedToday, isTrue);
      expect(flipped.id, equals(h.id));
      expect(flipped.name, equals(h.name));
      expect(flipped.icon, equals(h.icon));
      expect(flipped.currentStreak, equals(h.currentStreak));
    });
  });
}
