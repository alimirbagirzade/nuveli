import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/providers/coach_provider.dart';
import 'package:nuveli/features/premium/providers/premium_provider.dart';

void main() {
  ProviderContainer makeContainer({required bool isPremium}) {
    return ProviderContainer(
      overrides: [
        premiumProvider.overrideWith(() => _StubPremium(isPremium)),
      ],
    );
  }

  test('free user starts with 1 regen available (aiInsightSecond limit)',
      () async {
    final c = makeContainer(isPremium: false);
    addTearDown(c.dispose);
    await c.read(premiumProvider.future);

    final gate = c.read(coachGateProvider);
    expect(gate.isPremium, false);
    expect(gate.regensUsedToday, 0);
    expect(gate.remainingFreeRegens, 1);
    expect(gate.canRegenerate, true);
    expect(gate.ctaLabel, contains('1 free'));
  });

  test('after 1 free regen, free user is blocked and CTA flips to upgrade',
      () async {
    final c = makeContainer(isPremium: false);
    addTearDown(c.dispose);
    await c.read(premiumProvider.future);

    c.read(regenerateCountProvider.notifier).recordRegen();

    final gate = c.read(coachGateProvider);
    expect(gate.regensUsedToday, 1);
    expect(gate.remainingFreeRegens, 0);
    expect(gate.canRegenerate, false);
    expect(gate.ctaLabel, contains('Upgrade'));
  });

  test('premium user always canRegenerate, CTA is short "Regenerate"',
      () async {
    final c = makeContainer(isPremium: true);
    addTearDown(c.dispose);
    await c.read(premiumProvider.future);

    c.read(regenerateCountProvider.notifier).recordRegen();
    c.read(regenerateCountProvider.notifier).recordRegen();
    c.read(regenerateCountProvider.notifier).recordRegen();

    final gate = c.read(coachGateProvider);
    expect(gate.isPremium, true);
    expect(gate.remainingFreeRegens, isNull);
    expect(gate.canRegenerate, true);
    expect(gate.ctaLabel, 'Regenerate');
  });
}

class _StubPremium extends PremiumNotifier {
  _StubPremium(this._value);
  final bool _value;

  @override
  Future<bool> build() async => _value;
}
