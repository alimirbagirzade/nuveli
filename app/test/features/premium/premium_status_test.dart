import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/premium/data/premium_service.dart';

void main() {
  group('PremiumStatus tier flags', () {
    test('free tier → isFree true, isPremium false', () {
      final s = PremiumStatus.free();
      expect(s.isFree, true);
      expect(s.isPremium, false);
      expect(s.isTrialing, false);
    });

    test('trial tier counts as premium (for feature access)', () {
      const s = PremiumStatus(tier: 'trial');
      expect(s.isPremium, true);
      expect(s.isTrialing, true);
      expect(s.isFree, false);
    });

    test('premium tier is premium but not trialing', () {
      const s = PremiumStatus(tier: 'premium');
      expect(s.isPremium, true);
      expect(s.isTrialing, false);
      expect(s.isFree, false);
    });

    test('unknown tier defaults to free-like behavior (not premium)', () {
      const s = PremiumStatus(tier: 'expired');
      expect(s.isPremium, false);
      expect(s.isFree, false); // it's not "free" either, but not premium
    });
  });

  group('PremiumStatus.fromJson', () {
    test('parses complete premium response', () {
      final s = PremiumStatus.fromJson({
        'tier': 'premium',
        'subscription_ends_at': '2025-12-31T23:59:59Z',
      });
      expect(s.tier, 'premium');
      expect(s.subscriptionEndsAt?.year, 2025);
      expect(s.trialEndsAt, isNull);
    });

    test('parses trial with end date', () {
      final s = PremiumStatus.fromJson({
        'tier': 'trial',
        'trial_ends_at': '2025-05-01T00:00:00Z',
      });
      expect(s.isTrialing, true);
      expect(s.trialEndsAt, isNotNull);
    });

    test('missing tier defaults to free', () {
      final s = PremiumStatus.fromJson({});
      expect(s.tier, 'free');
      expect(s.isFree, true);
    });

    test('malformed date string is null, not exception', () {
      final s = PremiumStatus.fromJson({
        'tier': 'premium',
        'subscription_ends_at': 'not-a-date',
      });
      expect(s.tier, 'premium');
      expect(s.subscriptionEndsAt, isNull);
    });
  });
}
