/// Centralized API endpoint constants.
///
/// All HTTP paths are defined here so repositories don't hard-code URLs.
/// If the backend renames or restructures a route, this is the only file
/// that needs to change.
///
/// Base URL points to the Render production deployment. For local dev,
/// override via `--dart-define=API_BASE_URL=http://localhost:8000` and
/// read it in `ApiClient` if/when env-based config is needed.
class ApiEndpoints {
  ApiEndpoints._(); // No instances.

  /// Production backend (Render free tier — can cold-start ~30s).
  static const String baseUrl = 'https://nuveli-api.onrender.com';

  // ---------------------------------------------------------------
  // Profile / Auth
  // ---------------------------------------------------------------
  static const String me = '/me';
  static const String profile = '/profile';
  static const String onboarding = '/profile/onboarding';

  // ---------------------------------------------------------------
  // Meals
  // ---------------------------------------------------------------
  static const String meals = '/meals';
  static const String mealsScan = '/meals/scan';
  static const String mealsTodaySummary = '/meals/today/summary';
  static String mealById(String id) => '/meals/$id';

  // ---------------------------------------------------------------
  // Water
  // ---------------------------------------------------------------
  static const String waterLogs = '/water/logs';
  static const String waterTodaySummary = '/water/today/summary';
  static const String waterReminders = '/water/reminders';
  static const String waterInsight = '/water/insight';
  static String waterReminderById(String id) => '/water/reminders/$id';

  // ---------------------------------------------------------------
  // Habits
  // ---------------------------------------------------------------
  static const String habits = '/habits';
  static const String habitsToday = '/habits/today';
  static const String habitCompletions = '/habits/completions';
  static const String habitsStreak = '/habits/streak';
  static const String habitsConsistency = '/habits/consistency';
  static String habitById(String id) => '/habits/$id';
  static String habitToggle(String id) => '/habits/$id/toggle';

  // ---------------------------------------------------------------
  // Weight & Goals
  // ---------------------------------------------------------------
  static const String weightLogs = '/weight/logs';
  static const String weightGoal = '/weight/goal';
  static const String weightTrend = '/weight/trend';

  // ---------------------------------------------------------------
  // Meal Planner
  // ---------------------------------------------------------------
  static const String mealPlans = '/meal-plans';
  static const String mealPlansGenerate = '/meal-plans/generate';
  static const String mealPlansGrocery = '/meal-plans/grocery';
  static const String recipes = '/recipes';
  static String recipeById(String id) => '/recipes/$id';

  // ---------------------------------------------------------------
  // AI Coach
  // ---------------------------------------------------------------
  static const String coachToday = '/coach/today';
  static const String coachApplyTip = '/coach/apply-tip';
  static const String coachRefresh = '/coach/refresh';

  // ---------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------
  static const String analyticsWeekly = '/analytics/weekly';
  static const String analyticsMacros = '/analytics/macros';
  static const String analyticsWeight = '/analytics/weight';
  static const String analyticsAchievements = '/analytics/achievements';

  // ---------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------
  static const String achievements = '/achievements';

  // ---------------------------------------------------------------
  // Premium
  // ---------------------------------------------------------------
  static const String premiumStatus = '/premium/status';
  static const String premiumWebhook = '/premium/webhook';

  // ---------------------------------------------------------------
  // Health-check (debug / cold-start warm-up)
  // ---------------------------------------------------------------
  static const String health = '/health';
}
