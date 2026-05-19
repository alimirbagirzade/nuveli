import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/network/authed_dio_provider.dart';

import 'profile_provider.dart';

/// Mutation surface for the Goals & Profile screen.
///
/// All methods POST/PATCH to the backend, then invalidate the relevant
/// FutureProviders so the UI re-fetches automatically.
final profileActionsProvider =
    Provider<ProfileActions>((ref) => ProfileActions(ref));

class ProfileActions {
  final Ref ref;
  ProfileActions(this.ref);

  /// `POST /weight/goal` — create or replace the active weight goal.
  ///
  /// After success, [weightGoalProvider] is invalidated so the card re-renders.
  Future<void> setWeightGoal({
    required double targetKg,
    DateTime? targetDate,
    required String direction, // "lose" | "gain" | "maintain"
    double? startingWeightKg,
  }) async {
    final dio = ref.read(authedDioProvider);
    await dio.post(
      '/weight/goal',
      data: {
        'target_kg': targetKg,
        if (targetDate != null)
          'target_date': targetDate.toIso8601String().split('T').first,
        'direction': direction,
        if (startingWeightKg != null) 'starting_weight_kg': startingWeightKg,
      },
    );
    ref.invalidate(weightGoalProvider);
    ref.invalidate(weightTrendProvider); // progress percent may change
  }

  /// `POST /weight/logs` — log a new weight measurement.
  ///
  /// Invalidates the trend chart + profile (current weight_kg field on /me
  /// can also be updated by the backend trigger).
  Future<void> logWeight({
    required double weightKg,
    DateTime? loggedAt,
    String? note,
  }) async {
    final dio = ref.read(authedDioProvider);
    await dio.post(
      '/weight/logs',
      data: {
        'weight_kg': weightKg,
        'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    ref.invalidate(weightTrendProvider);
    ref.invalidate(weightGoalProvider); // progress_percent recalculated server-side
    ref.invalidate(profileProvider); // weight_kg field can be auto-updated
  }

  /// `PATCH /me` — partial update of profile (height, activity level, etc.).
  ///
  /// `patch` is a sparse map; backend updates only provided fields.
  Future<void> updateProfile(Map<String, dynamic> patch) async {
    if (patch.isEmpty) return;
    final dio = ref.read(authedDioProvider);
    await dio.patch('/me', data: patch);
    ref.invalidate(profileProvider);
  }

  /// Convenience: update only the daily calorie target.
  Future<void> updateCalorieTarget(int newTarget) async {
    await updateProfile({'daily_calorie_target': newTarget});
  }

  /// `DELETE /weight/goal` — cancel the active goal.
  /// (Not yet shown in Chat 6 UI but provided for completeness.)
  Future<void> cancelWeightGoal() async {
    final dio = ref.read(authedDioProvider);
    await dio.delete('/weight/goal');
    ref.invalidate(weightGoalProvider);
  }
}
