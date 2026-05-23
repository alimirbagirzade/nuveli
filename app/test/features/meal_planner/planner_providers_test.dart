import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/meal_planner/providers/planner_providers.dart';
import 'package:nuveli/features/premium/providers/premium_provider.dart';

void main() {
  group('weekStartFor', () {
    test('offset=0 returns Monday of current local week', () {
      final ws = weekStartFor(0);
      expect(ws.weekday, DateTime.monday);
    });

    test('offset=1 returns Monday of next week', () {
      final wsThis = weekStartFor(0);
      final wsNext = weekStartFor(1);
      expect(wsNext.difference(wsThis).inDays, 7);
    });

    test('offset=-2 returns Monday 14 days ago', () {
      final wsThis = weekStartFor(0);
      final wsPrev = weekStartFor(-2);
      expect(wsThis.difference(wsPrev).inDays, 14);
    });
  });

  group('plannerGateProvider', () {
    ProviderContainer makeContainer({required bool isPremium}) {
      return ProviderContainer(
        overrides: [
          premiumProvider.overrideWith(() => _StubPremium(isPremium)),
        ],
      );
    }

    test('free user can view current week, cannot view past/future', () async {
      final c = makeContainer(isPremium: false);
      addTearDown(c.dispose);
      await c.read(premiumProvider.future);

      // offset 0
      expect(c.read(plannerGateProvider).canViewWeek, true);

      c.read(weekOffsetProvider.notifier).state = 1;
      expect(c.read(plannerGateProvider).canViewWeek, false);

      c.read(weekOffsetProvider.notifier).state = -1;
      expect(c.read(plannerGateProvider).canViewWeek, false);
    });

    test('free user cannot generate AI plan', () async {
      final c = makeContainer(isPremium: false);
      addTearDown(c.dispose);
      await c.read(premiumProvider.future);

      expect(c.read(plannerGateProvider).canGenerate, false);
    });

    test('premium user can view any week and can generate', () async {
      final c = makeContainer(isPremium: true);
      addTearDown(c.dispose);
      await c.read(premiumProvider.future);

      c.read(weekOffsetProvider.notifier).state = 5;
      final gate = c.read(plannerGateProvider);
      expect(gate.canViewWeek, true);
      expect(gate.canGenerate, true);

      c.read(weekOffsetProvider.notifier).state = -10;
      expect(c.read(plannerGateProvider).canViewWeek, true);
    });
  });
}

class _StubPremium extends PremiumNotifier {
  _StubPremium(this._value);
  final bool _value;

  @override
  Future<bool> build() async => _value;
}
