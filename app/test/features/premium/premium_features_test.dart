import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/premium/models/premium_features.dart';

void main() {
  group('PremiumFeatures.all', () {
    test('contains items the paywall expects to render', () {
      // Empty list would silently produce an empty paywall — guard that.
      expect(PremiumFeatures.all, isNotEmpty);
      expect(PremiumFeatures.all.length, greaterThanOrEqualTo(6));
    });

    test('every item has a non-empty title and description', () {
      for (final item in PremiumFeatures.all) {
        expect(item.title, isNotEmpty, reason: 'icon=${item.icon}');
        expect(item.description, isNotEmpty, reason: 'title=${item.title}');
      }
    });

    test('titles are unique — no accidental duplicates', () {
      final titles = PremiumFeatures.all.map((e) => e.title).toList();
      expect(titles.toSet().length, equals(titles.length));
    });
  });

  group('PremiumFeatures.shortlist', () {
    test('shorter than full list', () {
      expect(PremiumFeatures.shortlist.length,
          lessThan(PremiumFeatures.all.length));
    });

    test('contains 3-4 items (upsell dialog space constraint)', () {
      expect(PremiumFeatures.shortlist.length, inInclusiveRange(3, 4));
    });
  });

  group('headlineForSource', () {
    test('returns specific headline for known sources', () {
      expect(
        PremiumFeatures.headlineForSource('ai_coach'),
        contains('AI insights'),
      );
      expect(
        PremiumFeatures.headlineForSource('analytics'),
        contains('progress'),
      );
      expect(
        PremiumFeatures.headlineForSource('meal_planner'),
        contains('plan'),
      );
    });

    test('falls back to generic headline for null source', () {
      final headline = PremiumFeatures.headlineForSource(null);
      expect(headline, isNotEmpty);
      expect(headline.toLowerCase(), contains('nuveli'));
    });

    test('falls back to generic headline for unknown source', () {
      final headline = PremiumFeatures.headlineForSource('zzz_unknown');
      expect(headline, isNotEmpty);
      expect(headline.toLowerCase(), contains('nuveli'));
    });
  });
}
