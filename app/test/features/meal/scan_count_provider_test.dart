import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/data/repositories/meals_repository.dart';
import 'package:nuveli/features/dashboard/models/meal.dart';
import 'package:nuveli/features/meal/providers/scan_count_provider.dart';
import 'package:nuveli/features/premium/providers/premium_provider.dart';

class _MockMealsRepo extends Mock implements MealsRepository {}

Meal _meal({required String source, int kcal = 100}) {
  return Meal(
    id: 'm-${DateTime.now().microsecondsSinceEpoch}',
    mealType: 'lunch',
    totalCalories: kcal,
    proteinG: 0,
    carbsG: 0,
    fatG: 0,
    scanSource: source,
    consumedAt: DateTime.now(),
  );
}

void main() {
  late _MockMealsRepo repo;

  setUp(() {
    repo = _MockMealsRepo();
  });

  ProviderContainer makeContainer({bool isPremium = false}) {
    return ProviderContainer(
      overrides: [
        mealsRepositoryProvider.overrideWithValue(repo),
        // Pre-seed premiumProvider as a synchronous value to skip the RC
        // network bootstrap. The notifier .build() still runs, but tests
        // can override via overrideWith to short-circuit it.
        premiumProvider.overrideWith(() => _StubPremium(isPremium)),
      ],
    );
  }

  test('scanCountTodayProvider counts only ai_scan rows', () async {
    when(() => repo.getTodaysMeals()).thenAnswer((_) async => [
          _meal(source: 'manual'),
          _meal(source: 'ai_scan'),
          _meal(source: 'ai_scan'),
          _meal(source: 'barcode'),
        ]);

    final container = makeContainer();
    addTearDown(container.dispose);

    final count = await container.read(scanCountTodayProvider.future);
    expect(count, 2);
  });

  test('scanCountTodayProvider returns 0 when no meals', () async {
    when(() => repo.getTodaysMeals()).thenAnswer((_) async => const []);
    final container = makeContainer();
    addTearDown(container.dispose);
    final count = await container.read(scanCountTodayProvider.future);
    expect(count, 0);
  });

  test('scanGateProvider exposes remainingFree=2 when 3 of 5 used (free user)',
      () async {
    when(() => repo.getTodaysMeals()).thenAnswer((_) async => [
          _meal(source: 'ai_scan'),
          _meal(source: 'ai_scan'),
          _meal(source: 'ai_scan'),
        ]);

    final container = makeContainer(isPremium: false);
    addTearDown(container.dispose);

    await container.read(premiumProvider.future);
    await container.read(scanCountTodayProvider.future);

    final gate = container.read(scanGateProvider).valueOrNull;
    expect(gate, isNotNull);
    expect(gate!.used, 3);
    expect(gate.isPremium, false);
    expect(gate.remainingFree, 2);
    expect(gate.canScan, true);
    expect(gate.counterLabel, '2/5 scans left today');
  });

  test('scanGateProvider blocks scan when free user reached 5/day', () async {
    when(() => repo.getTodaysMeals()).thenAnswer((_) async => List.filled(
          5,
          _meal(source: 'ai_scan'),
        ));

    final container = makeContainer(isPremium: false);
    addTearDown(container.dispose);

    await container.read(premiumProvider.future);
    await container.read(scanCountTodayProvider.future);

    final gate = container.read(scanGateProvider).valueOrNull!;
    expect(gate.remainingFree, 0);
    expect(gate.canScan, false);
  });

  test('scanGateProvider shows Unlimited for premium', () async {
    when(() => repo.getTodaysMeals()).thenAnswer((_) async => List.filled(
          12,
          _meal(source: 'ai_scan'),
        ));

    final container = makeContainer(isPremium: true);
    addTearDown(container.dispose);

    await container.read(premiumProvider.future);
    await container.read(scanCountTodayProvider.future);

    final gate = container.read(scanGateProvider).valueOrNull!;
    expect(gate.isPremium, true);
    expect(gate.remainingFree, isNull);
    expect(gate.canScan, true);
    expect(gate.counterLabel, 'Unlimited');
  });
}

/// Synchronous premium notifier so tests don't hit RevenueCat.
class _StubPremium extends PremiumNotifier {
  _StubPremium(this._value);
  final bool _value;

  @override
  Future<bool> build() async => _value;
}
