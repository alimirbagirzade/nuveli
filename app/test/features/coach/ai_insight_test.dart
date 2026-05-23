import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/models/ai_insight.dart';

void main() {
  group('AIInsight.fromJson', () {
    test('parses canonical /coach/today payload', () {
      final ins = AIInsight.fromJson({
        'id': '00000000-0000-0000-0000-000000000001',
        'user_id': '11111111-1111-1111-1111-111111111111',
        'insight_date': '2026-05-23',
        'nutrition_score': 76,
        'today_insight':
            'You hit your protein and water targets — that\'s a strong day.',
        'tips': [
          {
            'icon': 'muscle',
            'title': 'Keep protein steady',
            'description': 'Aim for ~25g at each meal tomorrow.',
            'category': 'protein',
          },
          {
            'icon': 'water',
            'title': 'Front-load hydration',
            'description': 'Drink 500ml within an hour of waking.',
          },
        ],
        'recommended_action': {
          'text': 'Want me to set a 10:00 hydration reminder?',
          'action_type': 'adjust_reminder',
          'payload': {'reminder_type': 'water', 'time': '10:00'},
        },
        'generated_at': '2026-05-23T08:14:00Z',
        'model_used': 'gpt-4o',
      });
      expect(ins.nutritionScore, 76);
      expect(ins.tips.length, 2);
      expect(ins.tips.first.icon, 'muscle');
      expect(ins.recommendedAction!.actionType, 'adjust_reminder');
      expect(ins.recommendedAction!.isExecutable, true);
      expect(ins.recommendedAction!.ctaLabel, 'Set reminder');
    });

    test('clamps nutrition_score above 100', () {
      final ins = AIInsight.fromJson({
        'user_id': 'u',
        'insight_date': '2026-05-23',
        'nutrition_score': 250,
        'today_insight': '',
        'generated_at': '2026-05-23T08:14:00Z',
      });
      expect(ins.nutritionScore, 100);
    });

    test('handles missing tips + recommended_action gracefully', () {
      final ins = AIInsight.fromJson({
        'user_id': 'u',
        'insight_date': '2026-05-23',
        'nutrition_score': 50,
        'today_insight': 'Body of insight',
        'generated_at': '2026-05-23T08:14:00Z',
      });
      expect(ins.tips, isEmpty);
      expect(ins.recommendedAction, isNull);
    });

    test('RecommendedAction.isExecutable=false when action_type missing', () {
      final a = RecommendedAction.fromJson({'text': 'Reflect on today.'});
      expect(a.isExecutable, false);
      expect(a.ctaLabel, 'Apply');
    });
  });

  group('RecommendedAction.ctaLabel', () {
    test('maps every backend action_type to a short verb', () {
      const cases = {
        'add_meal': 'Add meal',
        'adjust_reminder': 'Set reminder',
        'add_habit': 'Add habit',
        'log_water': 'Log water',
        'increase_target': 'Update target',
        'unknown_future_type': 'Apply',
      };
      for (final entry in cases.entries) {
        final a = RecommendedAction(text: '', actionType: entry.key);
        expect(a.ctaLabel, entry.value, reason: entry.key);
      }
    });
  });
}
