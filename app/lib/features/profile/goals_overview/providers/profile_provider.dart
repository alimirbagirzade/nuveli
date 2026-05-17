import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_profile_data.dart';
import '../models/user_goals.dart';

/// Loads the user's goals data.
///
/// Currently returns mock data after a small artificial delay so the UI can
/// exercise its loading / error states. In Chat 15 this provider will be
/// rewired to a repository that talks to Supabase (`user_profiles`,
/// `weight_logs`, `meals`, `ai_insights`).
final profileProvider = FutureProvider<UserGoals>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return mockUserGoals;
});
