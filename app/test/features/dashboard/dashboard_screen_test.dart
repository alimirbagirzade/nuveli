// Widget tests for DashboardScreen — now unblocked after Chat 24
// refactored DashboardHeader off the Supabase global singleton.
//
// We override:
//  - currentAuthUserProvider (so the header can resolve identity)
//  - dashboardSummaryProvider + todayMealsProvider (the two
//    FutureProviders the screen consumes)
//
// and exercise the three render paths: loading skeleton, error
// block, data view.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/network/api_exception.dart';
import 'package:nuveli/features/auth/models/auth_user.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/dashboard/dashboard_screen.dart';
import 'package:nuveli/features/dashboard/models/meal.dart';
import 'package:nuveli/features/dashboard/providers/dashboard_provider.dart';
import 'package:nuveli/features/dashboard/widgets/add_food_button.dart';
import 'package:nuveli/features/dashboard/widgets/macros_row.dart';
import 'package:nuveli/features/habits/models/habit.dart';
import 'package:nuveli/features/habits/providers/habits_providers.dart';
import 'package:nuveli/features/profile/models/weekly_analytics.dart';
import 'package:nuveli/features/profile/providers/profile_provider.dart';
import 'package:nuveli/shared/widgets/app_error_view.dart';
import 'package:nuveli/shared/widgets/skeleton.dart';

AuthUser _fakeUser() => AuthUser(
      id: 'fake-uid',
      email: 'ali@nuveli.com.tr',
      displayName: 'Ali Test',
      isAppleSignIn: false,
      createdAt: DateTime(2026, 1, 1),
    );

DashboardSummary _summarySample() => const DashboardSummary(
      todaySummary: TodaySummary(
        caloriesConsumed: 1200,
        caloriesTarget: 2000,
        proteinConsumedG: 80,
        carbsConsumedG: 150,
        fatConsumedG: 50,
        mealsLogged: 3,
      ),
      streakDays: 7,
      nutritionScore: 78,
      waterConsumedMl: 1500,
      waterTargetMl: 2500,
    );

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<DashboardSummary> summary,
  AsyncValue<List<Meal>>? meals,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => _fakeUser()),
        dashboardSummaryProvider.overrideWith(
          (ref) => switch (summary) {
            AsyncData(:final value) => Future.value(value),
            AsyncError(:final error) => Future<DashboardSummary>.error(error),
            _ => Completer<DashboardSummary>().future,
          },
        ),
        todayMealsProvider.overrideWith(
          (ref) => switch (meals ?? const AsyncValue.data(<Meal>[])) {
            AsyncData(:final value) => Future.value(value),
            AsyncError(:final error) => Future<List<Meal>>.error(error),
            _ => Completer<List<Meal>>().future,
          },
        ),
        // HabitsTodaySection makes a real /habits call in production
        // — stub to empty so the dashboard test doesn't try to hit
        // the network.
        habitsProvider.overrideWith((ref) async => const <Habit>[]),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    ),
  );
}

void main() {
  testWidgets('loading state renders shimmer skeleton boxes', (tester) async {
    await _pump(tester, summary: const AsyncValue.loading());
    await tester.pump(); // one frame — do NOT settle (loading never resolves)

    // The shared SkeletonBox widget is what the dashboard's skeleton
    // is now made of — at least one is on screen, MacrosRow is not.
    expect(find.byType(SkeletonBox), findsWidgets);
    expect(find.byType(MacrosRow), findsNothing);
  });

  testWidgets('error state renders AppErrorView with a retry button',
      (tester) async {
    await _pump(
      tester,
      summary: AsyncValue.error(
        ApiException(
          requestOptions: RequestOptions(path: '/analytics/dashboard'),
          userMessage: 'Could not reach the server.',
        ),
        StackTrace.empty,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    // Retry CTA visible (the dashboard always passes onRetry).
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('data state renders MacrosRow + AddFoodButton', (tester) async {
    await _pump(
      tester,
      summary: AsyncValue.data(_summarySample()),
      meals: const AsyncValue.data(<Meal>[]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MacrosRow), findsOneWidget);
    expect(find.byType(AddFoodButton), findsOneWidget);
  });

  testWidgets('greets the user by displayName (from currentAuthUserProvider)',
      (tester) async {
    await _pump(
      tester,
      summary: AsyncValue.data(_summarySample()),
    );
    await tester.pumpAndSettle();

    // displayName is "Ali Test" → header first-name takes "Ali".
    // Greeting prefix varies with the test machine's wall clock, so
    // just match the name part.
    expect(find.textContaining('Ali'), findsWidgets);
  });
}
