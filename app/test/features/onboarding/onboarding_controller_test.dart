import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/onboarding/data/onboarding_data.dart';
import 'package:nuveli/features/onboarding/data/onboarding_repository.dart';
import 'package:nuveli/features/onboarding/providers/onboarding_controller.dart';

import '../../_helpers/test_helpers.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository mockRepo;

  setUpAll(() {
    registerFallbackValuesForTests();
    registerFallbackValue(const OnboardingData());
  });

  setUp(() {
    mockRepo = MockOnboardingRepository();
  });

  group('OnboardingData', () {
    test('fresh data is incomplete', () {
      const data = OnboardingData();
      expect(data.isProfileComplete, false);
      expect(data.isComplete, false);
    });

    test('profile is complete when all physical fields set', () {
      const data = OnboardingData(
        birthYear: 1990,
        gender: 'female',
        heightCm: 165,
        weightKg: 60,
        activityLevel: 'moderate',
      );
      expect(data.isProfileComplete, true);
    });

    test('full onboarding complete needs goal + persona too', () {
      const base = OnboardingData(
        birthYear: 1990,
        gender: 'female',
        heightCm: 165,
        weightKg: 60,
        activityLevel: 'moderate',
      );
      expect(base.isComplete, false); // goal + persona yok

      final withGoal = base.copyWith(goal: 'lose');
      expect(withGoal.isComplete, false); // persona yok

      final full = withGoal.copyWith(coachPersona: 'supportive');
      expect(full.isComplete, true);
    });

    test('copyWith preserves unrelated fields', () {
      const data = OnboardingData(goal: 'lose', birthYear: 1990);
      final updated = data.copyWith(gender: 'female');
      expect(updated.goal, 'lose');
      expect(updated.birthYear, 1990);
      expect(updated.gender, 'female');
    });

    test('toOnboardingPayload produces backend shape', () {
      const data = OnboardingData(
        goal: 'lose',
        birthYear: 1990,
        gender: 'female',
        heightCm: 165,
        weightKg: 60,
        activityLevel: 'moderate',
      );
      final payload = data.toOnboardingPayload();
      expect(payload['goal'], 'lose');
      expect(payload['birth_year'], 1990);
      expect(payload['gender'], 'female');
      expect(payload['height_cm'], 165);
      expect(payload['weight_kg'], 60);
      expect(payload['activity_level'], 'moderate');
      expect(payload['special_conditions'], isEmpty);
    });

    test('toNotifPayload includes quiet hours', () {
      const data = OnboardingData();
      final p = data.toNotifPayload();
      expect(p['meal_reminders'], true);
      expect(p['coach_nudges'], true);
      expect(p['quiet_start'], '22:00');
      expect(p['quiet_end'], '08:00');
    });
  });

  group('OnboardingController state updates', () {
    test('setGoal updates only goal', () {
      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      container.read(onboardingControllerProvider.notifier).setGoal('lose');

      final state = container.read(onboardingControllerProvider);
      expect(state.goal, 'lose');
      expect(state.birthYear, isNull);
    });

    test('setProfileBasics updates birthYear + gender', () {
      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      container.read(onboardingControllerProvider.notifier).setProfileBasics(
            birthYear: 1990,
            gender: 'female',
          );

      final state = container.read(onboardingControllerProvider);
      expect(state.birthYear, 1990);
      expect(state.gender, 'female');
    });

    test('reset clears all fields', () {
      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setGoal('lose');
      notifier.setProfileBasics(birthYear: 1990, gender: 'female');
      notifier.reset();

      final state = container.read(onboardingControllerProvider);
      expect(state.goal, isNull);
      expect(state.birthYear, isNull);
    });
  });

  group('OnboardingController backend submission', () {
    test('submitProfile throws if incomplete', () async {
      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setGoal('lose');
      // Profile eksik

      expect(
        () => notifier.submitProfile(),
        throwsA(isA<StateError>()),
      );
    });

    test('submitProfile calls repo and returns result', () async {
      when(() => mockRepo.saveProfile(any())).thenAnswer(
        (_) async => {'daily_calorie_target': 1650},
      );

      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setGoal('lose');
      notifier.setProfileBasics(birthYear: 1990, gender: 'female');
      notifier.setPhysical(
        heightCm: 165,
        weightKg: 60,
        activityLevel: 'moderate',
      );

      final result = await notifier.submitProfile();
      expect(result['daily_calorie_target'], 1650);
      verify(() => mockRepo.saveProfile(any())).called(1);
    });

    test('submitCoachPersona throws when persona unset', () async {
      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      expect(
        () => container
            .read(onboardingControllerProvider.notifier)
            .submitCoachPersona(),
        throwsA(isA<StateError>()),
      );
    });

    test('submitCoachPersona calls repo with correct persona', () async {
      when(() => mockRepo.saveCoachPersona(any())).thenAnswer((_) async {});

      final container = makeContainer(overrides: [
        onboardingRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setCoachPersona('supportive');
      await notifier.submitCoachPersona();

      verify(() => mockRepo.saveCoachPersona('supportive')).called(1);
    });
  });
}
