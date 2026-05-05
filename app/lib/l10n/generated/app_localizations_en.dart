// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nuveli';

  @override
  String get appTagline => 'AI Calorie Coach';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginPasswordRepeat => 'Repeat Password';

  @override
  String get loginForgotPassword => 'Forgot password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginNoAccount => 'No account yet?';

  @override
  String get loginRegisterLink => 'Sign Up';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupSubtitle => 'Start your healthy eating journey with Nuveli';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get signupHasAccount => 'Already have an account?';

  @override
  String get signupLoginLink => 'Sign In';

  @override
  String get signupTerms =>
      'By signing up you accept the Terms of Use and Privacy Policy.';

  @override
  String get authInvalidCredentials =>
      'Email or password is incorrect. Please try again.';

  @override
  String get authEmailNotConfirmed =>
      'You haven\'t confirmed your email yet. Check your inbox.';

  @override
  String get authUserNotFound => 'No user registered with this email.';

  @override
  String get authUserAlreadyRegistered =>
      'This email is already registered. Try signing in.';

  @override
  String get authWeakPassword =>
      'Password is too weak. Must be at least 6 characters.';

  @override
  String get authInvalidEmail => 'Invalid email format.';

  @override
  String get authRateLimit =>
      'You tried too quickly. Please wait a few seconds.';

  @override
  String get authNetworkError => 'Check your internet connection.';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authGenericError => 'Something went wrong. Please try again.';

  @override
  String get ageGateTitle => 'Let\'s start with your age';

  @override
  String get ageGateSubtitle => 'We tailor recommendations to your age.';

  @override
  String get ageGateBirthYear => 'Birth year';

  @override
  String get ageGateUnderageError =>
      'Sorry, Nuveli is not suitable for under 13.';

  @override
  String get ageGateContinue => 'Continue';

  @override
  String get acceptanceTitle => 'Information';

  @override
  String get acceptanceHeader => 'Before we start';

  @override
  String get acceptanceSubtitle =>
      '4 important notes for safe use of Nuveli. You need to confirm all of them.';

  @override
  String get acceptanceWellnessTitle => 'Nuveli is a wellness app';

  @override
  String get acceptanceWellnessBody =>
      'Nuveli does not provide medical diagnosis, treatment, or clinical diet plans. For special health conditions, support from your doctor is important.';

  @override
  String get acceptanceWellnessCheck =>
      'I understand. Nuveli does not replace my doctor.';

  @override
  String get acceptanceAiTitle => 'AI estimates are approximate';

  @override
  String get acceptanceAiBody =>
      'The calorie and nutritional value estimates we make from food photos are approximate results. You can always edit them.';

  @override
  String get acceptanceAiCheck => 'I know the results may be approximate.';

  @override
  String get acceptanceSpecialTitle => 'Special situations require attention';

  @override
  String get acceptanceSpecialBody =>
      'If you have pregnancy, breastfeeding, eating disorder history or chronic illness, consult a health professional before applying calorie suggestions.';

  @override
  String get acceptanceSpecialCheck =>
      'I\'ll consult an expert in my special situation.';

  @override
  String get acceptanceTermsTitle => 'Terms and privacy';

  @override
  String get acceptanceTermsBody =>
      'You must read and accept the Terms of Use and Privacy Policy. Your data is kept safe and you can delete it anytime from settings.';

  @override
  String get acceptanceTermsCheck => 'I accept the Terms and Privacy Policy.';

  @override
  String get acceptanceContinue => 'Continue';

  @override
  String get acceptanceCheckAll => 'Check all boxes';

  @override
  String get onboardingGoalTitle => 'What\'s your goal?';

  @override
  String get onboardingGoalLose => 'Lose weight';

  @override
  String get onboardingGoalMaintain => 'Maintain weight';

  @override
  String get onboardingGoalGain => 'Gain muscle';

  @override
  String get onboardingSensitivityTitle => 'Sensitivity';

  @override
  String get onboardingSensitivityQ1 =>
      '1. Have you ever struggled with eating habits in the past?';

  @override
  String get onboardingSensitivityQ1A1 => 'No, never had such a period';

  @override
  String get onboardingSensitivityQ1A2 => 'Used to, but I\'m fine now';

  @override
  String get onboardingSensitivityQ1A3 => 'Yes, still struggling sometimes';

  @override
  String get onboardingSensitivityQ1A4 => 'Prefer not to say';

  @override
  String get onboardingSensitivityQ2 =>
      '2. How would you describe your relationship with food right now?';

  @override
  String get onboardingSensitivityQ2A1 => 'Comfortable, in control';

  @override
  String get onboardingSensitivityQ2A2 => 'Mixed days happen';

  @override
  String get onboardingSensitivityQ2A3 => 'It\'s hard most of the time';

  @override
  String get onboardingSensitivityQ2A4 => 'Prefer not to say';

  @override
  String get onboardingProfileTitle => 'Tell us about yourself';

  @override
  String get onboardingProfileGender => 'Gender';

  @override
  String get onboardingProfileGenderMale => 'Male';

  @override
  String get onboardingProfileGenderFemale => 'Female';

  @override
  String get onboardingProfileGenderOther => 'Other / Prefer not to say';

  @override
  String get onboardingProfileHeight => 'Height (cm)';

  @override
  String get onboardingProfileWeight => 'Weight (kg)';

  @override
  String get onboardingProfileActivity => 'Activity level';

  @override
  String get onboardingProfileActivitySedentary => 'Sedentary (desk job)';

  @override
  String get onboardingProfileActivityLight => 'Lightly active';

  @override
  String get onboardingProfileActivityModerate => 'Moderately active';

  @override
  String get onboardingProfileActivityActive => 'Very active';

  @override
  String get onboardingDietTitle => 'Diet';

  @override
  String get onboardingDietAllergies => 'Allergies';

  @override
  String get onboardingDietPreference => 'Diet preference';

  @override
  String get onboardingDietAllergyLactose => 'Lactose';

  @override
  String get onboardingDietAllergyGluten => 'Gluten';

  @override
  String get onboardingDietAllergyPeanut => 'Peanut';

  @override
  String get onboardingDietAllergyNut => 'Nuts';

  @override
  String get onboardingDietAllergyEgg => 'Egg';

  @override
  String get onboardingDietAllergyShellfish => 'Shellfish';

  @override
  String get onboardingDietAllergySoy => 'Soy';

  @override
  String get onboardingDietAllergySesame => 'Sesame';

  @override
  String get onboardingDietAllergyFish => 'Fish';

  @override
  String get onboardingDietPrefNone => 'No specific preference';

  @override
  String get onboardingDietPrefVegetarian => 'Vegetarian';

  @override
  String get onboardingDietPrefVegan => 'Vegan';

  @override
  String get onboardingDietPrefPescatarian => 'Pescatarian (fish only)';

  @override
  String get onboardingDietPrefHalal => 'Halal';

  @override
  String get onboardingDietPrefKosher => 'Kosher';

  @override
  String get onboardingDietPrefOther => 'Other';

  @override
  String get onboardingCoachTitle => 'Your coach';

  @override
  String get onboardingCoachQuestion => 'How should your coach speak?';

  @override
  String get onboardingCoachSubtitle => 'You can change anytime.';

  @override
  String get onboardingCoachKind => 'Kind';

  @override
  String get onboardingCoachKindDesc => 'Soft, no pressure, empathy first';

  @override
  String get onboardingCoachWitty => 'Witty';

  @override
  String get onboardingCoachWittyDesc =>
      'Light, smiling, balanced when serious';

  @override
  String get onboardingCoachDirect => 'Direct';

  @override
  String get onboardingCoachDirectDesc => 'Short, clear, realistic feedback';

  @override
  String get onboardingCoachCalm => 'Calm';

  @override
  String get onboardingCoachCalmDesc => 'Non-judgmental, patient, measured';

  @override
  String get onboardingCalorieTitle => 'Calorie';

  @override
  String get onboardingCalorieReady => 'Your daily target is ready';

  @override
  String get onboardingCalorieDescription =>
      'This number is based on your info. Not fixed — we\'ll adjust together based on your days.';

  @override
  String get onboardingCalorieDaily => 'Daily calories';

  @override
  String get onboardingCalorieKcal => 'kcal';

  @override
  String get onboardingCalorieNote =>
      'Calculated based on activity, goal, and situation. Reviewed monthly.';

  @override
  String get onboardingNotificationTitle => 'Notifications';

  @override
  String get onboardingNotificationQuestion => 'Want gentle reminders?';

  @override
  String get onboardingNotificationDescription =>
      'Brief support and meal reminders from your coach. We respect quiet hours.';

  @override
  String get onboardingNotificationYes => 'Yes, I do';

  @override
  String get onboardingNotificationNo => 'Not now';

  @override
  String get onboardingWelcomeTitle => 'Welcome.';

  @override
  String get onboardingWelcomeSubtitle => 'We\'re ready.';

  @override
  String get onboardingWelcomeBody =>
      'No pressure, no judgment — just you and a coach by your side.';

  @override
  String get onboardingWelcomeFirstStep => 'First step idea';

  @override
  String get onboardingWelcomeFirstStepDesc =>
      'Start with one meal you ate today. Take a photo or write — your coach remembers the rest.';

  @override
  String get onboardingWelcomeStart => 'Let\'s begin';

  @override
  String get onboardingWelcomePreparing => 'Preparing...';

  @override
  String get onboardingWelcomeError =>
      'An unexpected issue occurred, want to try again?';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeTodayCalories => 'Today\'s calories';

  @override
  String get homeRemainingCalories => 'Remaining';

  @override
  String get homeAddMeal => 'Add meal';

  @override
  String get homeChat => 'Talk to coach';

  @override
  String get homeNoMeals => 'No meals added yet';

  @override
  String get homeNoMealsHint => 'Take a photo of your food or write';

  @override
  String get navHome => 'Home';

  @override
  String get navMeals => 'Meals';

  @override
  String get navCoach => 'Coach';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumComingSoon => 'COMING SOON';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsDeleteAccount => 'Delete My Account';

  @override
  String get settingsVersion => 'Version';

  @override
  String get premiumTitle => 'Premium coming soon';

  @override
  String get premiumSubtitle => 'You can use Nuveli completely free for now.';

  @override
  String get premiumFeatureUnlimited => 'Unlimited meal analysis';

  @override
  String get premiumFeatureCoach => 'Advanced AI coach';

  @override
  String get premiumFeatureReports => 'Detailed weekly reports';

  @override
  String get premiumFeatureExport => 'Data export';

  @override
  String get premiumNotifyMe => 'Notify me when ready';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get settingsCoachTone => 'Coach tone';

  @override
  String get settingsSupportSecurity => 'Support & Security';

  @override
  String get settingsHowAiWorks => 'How AI works';

  @override
  String get settingsPrivacySafety => 'Privacy & Safety';

  @override
  String get settingsAboutNuveli => 'About Nuveli';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsSession => 'Session';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsSignedInAs => 'Signed in as';

  @override
  String get settingsLogoutTitle => 'Sign out?';

  @override
  String get settingsLogoutBody =>
      'You\'ll need your email and password to sign in again.';

  @override
  String get settingsLogoutCancel => 'Cancel';

  @override
  String get settingsLogoutFailed => 'Failed to sign out.';

  @override
  String get premiumModalTitle => 'Premium coming soon!';

  @override
  String get premiumModalBody =>
      'We\'re preparing unlimited AI meal analysis, advanced coaching, and weekly insights.';

  @override
  String get premiumFeatureVoice => 'Voice coach + 3 personas';

  @override
  String get premiumFeatureInsights => 'Weekly + monthly insights';

  @override
  String get premiumUnderstood => 'Got it';

  @override
  String get passwordVeryWeak => 'Very weak';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordVeryStrong => 'Very strong';

  @override
  String get homeErrorGeneric => 'Something went wrong';

  @override
  String get homeCoachLabel => 'Your coach';

  @override
  String get homeToday => 'Today';

  @override
  String get homeRemaining => 'remaining';

  @override
  String get homeThisWeek => 'This Week';

  @override
  String get homeMiniGoalTitle => 'Today\'s Mini Goal';

  @override
  String get homeMiniGoalDefault => 'Add protein to a meal';

  @override
  String get homeAddMealLabel => 'Add Meal';

  @override
  String get homeWater => 'Water';

  @override
  String get homeWeight => 'Weight';

  @override
  String get homeMood => 'Mood';

  @override
  String get homeAddWater => 'Add Water';

  @override
  String get homeEnterWeight => 'Enter Weight';

  @override
  String get homeMoodGreat => 'Great';

  @override
  String get homeMoodGood => 'Good';

  @override
  String get homeMoodNeutral => 'Neutral';

  @override
  String get homeMoodBad => 'Tough';

  @override
  String get homeMoodRough => 'Very Tough';

  @override
  String get homeMoodPickOne => 'Pick one';

  @override
  String get homeNoMealsTitle => 'No meals added yet';

  @override
  String get homeNoMealsMessage => 'Start the day by adding your first meal';

  @override
  String get homeTodayMeals => 'Today\'s meals';

  @override
  String get homeMealBreakfast => 'Breakfast';

  @override
  String get homeMealLunch => 'Lunch';

  @override
  String get homeMealDinner => 'Dinner';

  @override
  String get homeMealSnack => 'Snack';

  @override
  String get homeCalorieTarget => 'target';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target kcal target';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarb => 'Carbs';

  @override
  String get macroFat => 'Fat';

  @override
  String get homeCravingText =>
      'Craving something? Pause 60 seconds, take a deep breath.';

  @override
  String get notifMealReminders => 'Meal Reminders';

  @override
  String get notifMealRemindersDesc =>
      'Gentle reminder at breakfast, lunch, dinner time';

  @override
  String get notifCoachNudges => 'Coach Nudges';

  @override
  String get notifCoachNudgesDesc => 'Personal support and motivation messages';

  @override
  String get notifWeeklySummary => 'Weekly Summary';

  @override
  String get notifWeeklySummaryDesc => 'Monday morning summary of last week';

  @override
  String get notifQuietHours => 'QUIET HOURS';

  @override
  String get notifQuietHoursDesc => 'No notifications during these hours.';

  @override
  String get notifQuietStart => 'Start';

  @override
  String get notifQuietEnd => 'End';

  @override
  String get notifSaved => 'Preferences saved.';

  @override
  String get notifSaveFailed => 'Could not save.';

  @override
  String get notifLoadFailed => 'Could not load.';

  @override
  String get coachSettingsTitle => 'Your Coach';

  @override
  String get coachSettingsQuestion => 'How should your coach speak to you?';

  @override
  String get coachSettingsSubtitle => 'You can change anytime.';
}
