import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/premium/services/premium_gate_service.dart';

void main() {
  late PremiumGateService gate;

  setUp(() {
    gate = PremiumGateService();
  });

  group('canAccess — premium users', () {
    test('premium user can access premium-only feature', () {
      expect(
        gate.canAccess(
          PremiumFeature.dataExport,
          isPremium: true,
          currentUsage: 0,
        ),
        isTrue,
      );
    });

    test('premium user can access unlimited-tier feature regardless of usage', () {
      expect(
        gate.canAccess(
          PremiumFeature.mealScanBeyond5Daily,
          isPremium: true,
          currentUsage: 9999,
        ),
        isTrue,
      );
    });
  });

  group('canAccess — free users', () {
    test('free user blocked from premium-only feature', () {
      expect(
        gate.canAccess(
          PremiumFeature.dataExport,
          isPremium: false,
        ),
        isFalse,
      );
    });

    test('free user blocked from healthIntegration (premium-only)', () {
      expect(
        gate.canAccess(
          PremiumFeature.healthIntegration,
          isPremium: false,
        ),
        isFalse,
      );
    });

    test('free user allowed below daily AI insight limit', () {
      expect(
        gate.canAccess(
          PremiumFeature.aiInsightSecond,
          isPremium: false,
          currentUsage: 0,
        ),
        isTrue,
      );
    });

    test('free user blocked at daily AI insight limit', () {
      expect(
        gate.canAccess(
          PremiumFeature.aiInsightSecond,
          isPremium: false,
          currentUsage: 1,
        ),
        isFalse,
      );
    });

    test('free user allowed up to 5 meal scans per day', () {
      expect(
        gate.canAccess(
          PremiumFeature.mealScanBeyond5Daily,
          isPremium: false,
          currentUsage: 4,
        ),
        isTrue,
      );
    });

    test('free user blocked at 5th meal scan (off-by-one check)', () {
      expect(
        gate.canAccess(
          PremiumFeature.mealScanBeyond5Daily,
          isPremium: false,
          currentUsage: 5,
        ),
        isFalse,
      );
    });

    test('free user allowed up to 5 habits', () {
      expect(
        gate.canAccess(
          PremiumFeature.habitCustomBeyond5,
          isPremium: false,
          currentUsage: 4,
        ),
        isTrue,
      );
    });

    test('free user blocked at 6th habit', () {
      expect(
        gate.canAccess(
          PremiumFeature.habitCustomBeyond5,
          isPremium: false,
          currentUsage: 5,
        ),
        isFalse,
      );
    });
  });

  group('remainingFree', () {
    test('returns full limit when no usage', () {
      expect(
        gate.remainingFree(
          PremiumFeature.mealScanBeyond5Daily,
          currentUsage: 0,
        ),
        equals(5),
      );
    });

    test('returns 0 for premium-only feature', () {
      expect(
        gate.remainingFree(PremiumFeature.dataExport, currentUsage: 0),
        equals(0),
      );
    });

    test('clamps to 0 when usage exceeds limit', () {
      expect(
        gate.remainingFree(
          PremiumFeature.mealScanBeyond5Daily,
          currentUsage: 99,
        ),
        equals(0),
      );
    });

    test('returns 1 when one slot left', () {
      expect(
        gate.remainingFree(
          PremiumFeature.mealScanBeyond5Daily,
          currentUsage: 4,
        ),
        equals(1),
      );
    });
  });

  group('freeTierLabel', () {
    test('formats daily limit', () {
      expect(
        gate.freeTierLabel(PremiumFeature.mealScanBeyond5Daily),
        equals('5 / day'),
      );
    });

    test('marks premium-only feature', () {
      expect(
        gate.freeTierLabel(PremiumFeature.dataExport),
        equals('Premium only'),
      );
    });

    test('formats weeks label', () {
      expect(
        gate.freeTierLabel(PremiumFeature.analyticsBeyond8Weeks),
        equals('Last 8 weeks'),
      );
    });

    test('singular "week" for 1', () {
      expect(
        gate.freeTierLabel(PremiumFeature.mealPlannerBeyondOneWeek),
        equals('1 week'),
      );
    });
  });

  group('premiumBenefitLabel', () {
    test('prefixes "Unlimited" for unlimited features', () {
      expect(
        gate.premiumBenefitLabel(PremiumFeature.mealScanBeyond5Daily),
        contains('Unlimited'),
      );
    });
  });

  group('limits map invariants', () {
    test('every PremiumFeature has a limit entry — paywall coverage guarantee', () {
      for (final feature in PremiumFeature.values) {
        expect(
          PremiumGateService.limits.containsKey(feature),
          isTrue,
          reason: 'Missing limit for $feature — UI will silently lock it out',
        );
      }
    });

    test('premium-only features have free=0', () {
      const premiumOnly = {
        PremiumFeature.mealPlannerAiGenerate,
        PremiumFeature.recipeCustom,
        PremiumFeature.dataExport,
        PremiumFeature.healthIntegration,
        PremiumFeature.premiumThemes,
      };
      for (final f in premiumOnly) {
        expect(PremiumGateService.limits[f]!.free, equals(0), reason: '$f');
      }
    });
  });

  test('singleton returns same instance', () {
    expect(PremiumGateService(), same(PremiumGateService.instance));
    expect(PremiumGateService(), same(PremiumGateService()));
  });
}
