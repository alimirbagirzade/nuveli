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

  @override
  String get onboardingMoreMeasures => 'A few more measurements';

  @override
  String get onboardingActivityLevel => 'Your activity level';

  @override
  String get onboardingFirstMeal => 'Let\'s add my first meal';

  @override
  String get onboardingGoToHome => 'Go to home screen';

  @override
  String get onboardingBirthYear => 'Birth year';

  @override
  String get onboardingGender => 'Gender';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportEmailSubject => 'Nuveli Support';

  @override
  String get howAiTitle => 'How AI Works';

  @override
  String get privacyTitle => 'Privacy & Safety';

  @override
  String get aboutTitle => 'About Nuveli';

  @override
  String get coachToneUpdated => 'Coach tone updated';

  @override
  String get supportHowHelp => 'How can we help you?';

  @override
  String get supportEmailCard => 'Contact by email';

  @override
  String get supportFaq => 'FAQ';

  @override
  String get supportFaqDesc => 'Frequently asked questions and answers';

  @override
  String get aiBlockFood => 'Food Recognition';

  @override
  String get aiBlockFoodBody =>
      'I analyze your photo and estimate calories/nutrients. This is not an exact measurement — you can always edit.';

  @override
  String get aiBlockCoach => 'Coach Responses';

  @override
  String get aiBlockCoachBody =>
      'I generate short, non-judgmental, supportive messages. I don\'t provide medical advice or diet plans.';

  @override
  String get aiBlockSafety => 'Safety';

  @override
  String get aiBlockSafetyBody =>
      'In risky situations, I show professional support resources. In crisis moments, fixed safety text appears.';

  @override
  String get aiBlockData => 'Your Data';

  @override
  String get aiBlockDataBody =>
      'Your data is transmitted encrypted and only you can access it. You can delete everything via Settings > Delete Account.';

  @override
  String get privacyHeading => 'Your safety is our priority';

  @override
  String get privacyBody =>
      'Nuveli is a wellness app. It does not provide medical diagnosis, treatment, or clinical diet plans. If you\'re going through a difficult time, please seek professional support.';

  @override
  String get privacyEmergency => 'Emergency Support';

  @override
  String get privacyHotline => 'ALO 182 — Psychological Support Line (24/7)';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get privacyTermsLink => 'Terms of Use';

  @override
  String get privacyDownload => 'Download My Data';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutLinks => 'Links';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutTechnical => 'Technical';

  @override
  String get aboutEnv => 'Environment';

  @override
  String get aboutCopyright => '© 2026 Nuveli. All rights reserved.';

  @override
  String get aboutCopied => 'copied';

  @override
  String get aboutVersion => 'Version';

  @override
  String get streakDay => 'day';

  @override
  String get streakDays => 'day streak';

  @override
  String get streakLongest => 'Longest streak';

  @override
  String get streakTodayDone => 'You did it today too';

  @override
  String streakSummary(int current) {
    return '$current day streak';
  }

  @override
  String get streakExplanation =>
      'Your streak is the number of consecutive days you\'ve added meals.';

  @override
  String get weeklyTitle => 'Weekly Summary';

  @override
  String get weeklyLoadFailed => 'Could not load';

  @override
  String get weeklyChartLoadFailed => 'Could not load data';

  @override
  String get commonRetryLow => 'Try again';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get dayDetailMeals => 'Meals';

  @override
  String get dayDetailMealsLoadFailed => 'Could not load meals';

  @override
  String get dayDetailNoMeals => 'No meals logged for this day';

  @override
  String dayDetailWaterMl(int ml) {
    return '$ml ml water';
  }

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get mealTypeOther => 'Meal';

  @override
  String get weeklyMacroDist => 'Macro Distribution';

  @override
  String get weeklyDailyDetail => 'Daily Detail';

  @override
  String get weeklyCoachComment => 'COACH COMMENT';

  @override
  String get weeklyCoachCommentLocked => 'Coach comment';

  @override
  String get weeklyCoachCommentLockedDesc =>
      'Personal weekly pattern comments with Premium';

  @override
  String streakLastLog(String date) {
    return 'Last log: $date';
  }

  @override
  String get streakNow => 'Current';

  @override
  String get streakLongestShort => 'Longest';

  @override
  String get streakAddMealNow => 'Add Meal Now';

  @override
  String get streakAtRisk =>
      'You haven\'t logged a meal today and it\'s evening. Add one now to keep your streak; otherwise it resets tomorrow.';

  @override
  String get streakNotStarted =>
      'Your streak hasn\'t started yet. Add your first meal to begin.';

  @override
  String get streakTodayLogged =>
      'You did it today too! Add a meal tomorrow to keep your streak going.';

  @override
  String get streakExplanationDefault =>
      'Your streak is the number of consecutive days you\'ve logged meals.';

  @override
  String get weeklyAvgKcal => 'kcal/day average';

  @override
  String get weeklyTotal => 'Total';

  @override
  String get weeklyMeals => 'Meals';

  @override
  String get weeklyLogged => 'Logged';

  @override
  String get coachChatTitle => 'Coach';

  @override
  String get coachChatPlaceholder => 'Ask your coach...';

  @override
  String get coachChatSend => 'Send';

  @override
  String get waterHowMuch => 'How much did you drink?';

  @override
  String get waterHistory => 'History';

  @override
  String get weightInvalid => 'Enter a valid weight (1-500 kg).';

  @override
  String get weightKg => 'kg';

  @override
  String get moodHowToday => 'How are you today?';

  @override
  String get mealCameraNotAvailable =>
      'This feature works on real devices. You can pick from gallery.';

  @override
  String get mealGallery => 'Gallery';

  @override
  String weeklyDaysLogged(int n) {
    return 'You logged $n days. Good progress.';
  }

  @override
  String get coachWelcome => 'Hi! How are you feeling today?';

  @override
  String get coachInputPlaceholder => 'Type your message...';

  @override
  String get coachLoadFailed => 'Could not load.';

  @override
  String get coachSendFailed => 'Could not send message.';

  @override
  String get coachLimitTitle => 'Daily message limit reached';

  @override
  String coachLimitBody(String reason) {
    return '$reason\n\nWith Premium, get unlimited coach chat + voice replies.';
  }

  @override
  String get coachLater => 'Later';

  @override
  String get coachSeePremium => 'See Premium';

  @override
  String get coachCrisisTitle => 'You are not alone';

  @override
  String get coachDistressTitle => 'You may be having a tough moment';

  @override
  String get coachCrisisBody =>
      'We want to be there for you, but reaching a professional for proper support is very important.';

  @override
  String get coachDistressBody =>
      'Your coach can\'t help in these situations. Reaching out to someone who cares about you is always an option.';

  @override
  String get mealAddTitle => 'Add Meal';

  @override
  String get mealPhotoOrDesc => 'Photo or description';

  @override
  String get mealNoPhoto => 'No photo added';

  @override
  String get mealCamera => 'Camera';

  @override
  String get mealGalleryBtn => 'Gallery';

  @override
  String get mealSimulatorWarn => 'No camera in Simulator. Use Gallery.';

  @override
  String get mealDescHint =>
      'Describe your meal:\n• What? (e.g. grilled chicken)\n• How much? (e.g. 200g, 1 portion)\n• Sides? (e.g. bread, rice)';

  @override
  String get mealAnalyze => 'Analyze';

  @override
  String get mealManualEntry => 'Manual entry';

  @override
  String get mealAnalyzeFailed => 'Could not analyze.';

  @override
  String get mealLimitTitle => 'Daily limit reached';

  @override
  String mealLimitBody(String reason) {
    return '$reason\n\nWith Premium, get unlimited photo analysis.';
  }

  @override
  String get waterHistoryTitle => 'Water History';

  @override
  String get weightHistoryTitle => 'Weight History';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get personaGentle => 'Gentle';

  @override
  String get personaGentleDesc => 'Soft, no pressure, empathy first';

  @override
  String get personaGentleSample =>
      '\"I see today is a bit tough. Even if you skip a meal, don\'t be harsh on yourself.\"';

  @override
  String get personaFunny => 'Funny';

  @override
  String get personaFunnyDesc => 'Light, smiling, balanced in serious moments';

  @override
  String get personaFunnySample =>
      '\"Pizza night, got it. Life is balance — salad tomorrow, happiness tonight.\"';

  @override
  String get personaDirect => 'Direct';

  @override
  String get personaDirectDesc => 'Short, clear, realistic feedback';

  @override
  String get personaDirectSample =>
      '\"Protein is low today. Aim for 25-30g at dinner to balance the week.\"';

  @override
  String get personaCalm => 'Calm';

  @override
  String get personaCalmDesc => 'Non-judgmental, patient, measured';

  @override
  String get personaCalmSample =>
      '\"Sometimes we eat without thinking. What matters is awareness. Let\'s focus on the next meal.\"';

  @override
  String get coachToneQuestion => 'How should your coach talk to you?';

  @override
  String get coachToneSubtitle => 'You can change anytime.';

  @override
  String get coachToneSaving => 'Saving...';

  @override
  String get coachToneSaveError =>
      'Couldn\'t save. Check your connection and try again?';

  @override
  String get coachToneSaveErrorGeneric => 'Unexpected issue. Try again?';

  @override
  String waterLastDays(int n) {
    return 'Last $n days';
  }

  @override
  String get waterLitresTotal => 'L total';

  @override
  String get waterToday => 'Today';

  @override
  String get waterAverage => 'Average';

  @override
  String get waterLast7 => 'Last 7 Days';

  @override
  String waterGoalMl(int ml) {
    return 'Goal: $ml ml/day';
  }

  @override
  String get waterAllDays => 'All Days';

  @override
  String get waterNoRecord => 'No record';

  @override
  String waterDaysCount(int n) {
    return '$n days';
  }

  @override
  String get weightCurrent => 'Current weight';

  @override
  String get weightFirstRecord => 'First record';

  @override
  String weightTrend(int n) {
    return 'Trend ($n entries)';
  }

  @override
  String get weightRecords => 'Records';

  @override
  String weightEntryCount(int n) {
    return '$n entries';
  }

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mar';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get monthShortJul => 'Jul';

  @override
  String get monthShortAug => 'Aug';

  @override
  String get monthShortSep => 'Sep';

  @override
  String get monthShortOct => 'Oct';

  @override
  String get monthShortNov => 'Nov';

  @override
  String get monthShortDec => 'Dec';

  @override
  String get todayBadge => 'TODAY';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadFailed => 'Could not load profile.';

  @override
  String get profileAccount => 'Account';

  @override
  String get profilePersonalInfo => 'Personal information';

  @override
  String get profilePersonalInfoSub => 'Name, goals, body info';

  @override
  String get profileGoals => 'Goals';

  @override
  String get profileGoalsSub => 'Your calorie and macro targets';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotifPrefs => 'Notification preferences';

  @override
  String get profileNotifPrefsSub => 'Reminders and quiet hours';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileDarkTheme => 'Dark theme';

  @override
  String get profileDarkThemeSub => 'Currently active (default)';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profilePremiumSub => 'Plan, billing and features';

  @override
  String get profilePremiumMy => 'My premium subscription';

  @override
  String get profileHelpSafety => 'Help & Safety';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileSupportSub => 'Questions and feedback';

  @override
  String get profileHowAi => 'How AI works';

  @override
  String get profilePrivacy => 'Privacy & safety';

  @override
  String get profileAbout => 'About Nuveli';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get homeGreetingNoonTime => 'Good afternoon';

  @override
  String get profileStreakNow => 'Current';

  @override
  String get profileStreakLongest => 'Longest';

  @override
  String get profileStreakDay => 'day';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get personalInfoEdit => 'Edit';

  @override
  String get personalInfoSaved => 'Information saved';

  @override
  String get personalInfoSaveFailed => 'Could not save';

  @override
  String get personalInfoLoadFailed => 'Could not load';

  @override
  String get personalInfoSecAccount => 'Account';

  @override
  String get personalInfoSecBody => 'Body information';

  @override
  String get personalInfoSecActivity => 'Activity';

  @override
  String get personalInfoName => 'Name';

  @override
  String get personalInfoEmail => 'Email';

  @override
  String get personalInfoBirthYear => 'Birth year';

  @override
  String get personalInfoGender => 'Gender';

  @override
  String get personalInfoHeight => 'Height';

  @override
  String get personalInfoHeightCm => 'Height (cm)';

  @override
  String get personalInfoWeight => 'Weight';

  @override
  String get personalInfoWeightKg => 'Weight (kg)';

  @override
  String get personalInfoActivityLevel => 'Daily activity level';

  @override
  String get personalInfoActivityLevelLabel => 'Activity level';

  @override
  String get personalInfoCancel => 'Cancel';

  @override
  String get personalInfoSave => 'Save';

  @override
  String get personalInfoSaving => 'Saving...';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryFull => 'Sedentary (desk job)';

  @override
  String get activityLight => 'Lightly active';

  @override
  String get activityLightFull => 'Lightly active (1-3 days)';

  @override
  String get activityModerate => 'Moderately active';

  @override
  String get activityModerateFull => 'Moderately active (3-5 days)';

  @override
  String get activityActive => 'Active';

  @override
  String get activityActiveFull => 'Active (6-7 days)';

  @override
  String get activityVeryActive => 'Very active';

  @override
  String get activityVeryActiveFull => 'Very active (athlete)';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsUpdated => 'Goals updated';

  @override
  String get goalsLoadFailed => 'Could not load';

  @override
  String get goalsSaveFailed => 'Could not save';

  @override
  String get goalsSecPurpose => 'Purpose';

  @override
  String get goalsSecDailyCalorie => 'Daily calorie target';

  @override
  String get goalsSecMacroDist => 'Recommended macro distribution';

  @override
  String get goalsLoseWeight => 'Lose weight';

  @override
  String get goalsLoseWeightDesc => 'Gradual decrease with calorie deficit';

  @override
  String get goalsMaintain => 'Maintain weight';

  @override
  String get goalsMaintainDesc => 'Keep current weight';

  @override
  String get goalsGainMuscle => 'Gain muscle';

  @override
  String get goalsGainMuscleDesc => 'Build with calorie surplus';

  @override
  String get goalsMacroNote =>
      'This recommendation is based on 25% protein, 50% carbs, 25% fat. Your coach can customize it for you.';

  @override
  String get goalsSave => 'Save';

  @override
  String get premiumComingTitle => 'Premium coming soon! 🚀';

  @override
  String get premiumComingDesc =>
      'We\'re putting the finishing touches on unlimited AI meal analysis, voice coach, and weekly insights. We\'ll let you know when it\'s ready.';

  @override
  String get premiumFeatureCharts => 'Advanced charts and trends';

  @override
  String get premiumGotIt => 'Got it';

  @override
  String todayMealsCount(int n) {
    return '$n meals';
  }

  @override
  String get todayMealDeleteTitle => 'Delete meal?';

  @override
  String todayMealDeleteMessage(String name) {
    return '\"$name\" will be deleted. This cannot be undone.';
  }

  @override
  String get todayMealDeleteConfirm => 'Delete';

  @override
  String get todayMealDeleteCancel => 'Cancel';

  @override
  String get todayMealDeleted => 'Meal deleted.';

  @override
  String get todayMealDeleteFailed => 'Could not delete.';

  @override
  String get mealTypeBreakfastShort => 'Breakfast';

  @override
  String get mealTypeLunchShort => 'Lunch';

  @override
  String get mealTypeDinnerShort => 'Dinner';

  @override
  String get mealTypeSnackShort => 'Snack';

  @override
  String streakLongestNeverActive(int longest) {
    return 'Longest streak: $longest days';
  }

  @override
  String streakTodayDoneSubtitle(int longest) {
    return 'You did it today · Longest: $longest days';
  }

  @override
  String streakTodayMissedSubtitle(int longest) {
    return 'Don\'t forget today · Longest: $longest';
  }

  @override
  String get waterAllDaysList => 'All Days';

  @override
  String get waterTodayBadge => 'TODAY';

  @override
  String get waterNoEntry => 'No entry';

  @override
  String get weightRecordsList => 'Records';

  @override
  String weightEntriesCount(int n) {
    return '$n entries';
  }

  @override
  String historyDaysSuffix(int n) {
    return '$n days';
  }

  @override
  String get moodGreat => 'Great';

  @override
  String get moodGood => 'Good';

  @override
  String get moodNeutral => 'Okay';

  @override
  String get moodBad => 'Tough';

  @override
  String get moodRough => 'Very tough';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'We sent a verification link to $email. Tap the link to continue automatically.';
  }

  @override
  String get verifyEmailWaitingTitle => 'Waiting for email...';

  @override
  String get verifyEmailWaitingBody =>
      'You cannot continue without clicking the link in your email. Check your spam folder too.';

  @override
  String get verifyEmailResend => 'Resend';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get verifyEmailResent => 'New verification email sent.';

  @override
  String get verifyEmailSignOut => 'Use different email / Sign out';

  @override
  String get coachBubbleGentleMealUnder =>
      'Logged with care. You\'ve still got room today — no rush.';

  @override
  String get coachBubbleGentleMealOver =>
      'Logged. One meal doesn\'t define your day. Be kind to yourself.';

  @override
  String get coachBubbleGentleMealOnTrack =>
      'Lovely balance today. You\'re listening to your body.';

  @override
  String get coachBubbleGentleWaterLow =>
      'A little water would feel nice right now, whenever you\'re ready.';

  @override
  String get coachBubbleGentleStreakMilestone =>
      'You keep showing up, gently, every day. That\'s real.';

  @override
  String get coachBubbleGentleFirstMeal =>
      'First meal in. A soft, steady start to the day.';

  @override
  String get coachBubbleFunnyMealUnder =>
      'Logged! Plenty of runway left — your fork is cleared for takeoff.';

  @override
  String get coachBubbleFunnyMealOver =>
      'Big meal, big joy. Tomorrow\'s another tasty chapter.';

  @override
  String get coachBubbleFunnyMealOnTrack =>
      'Chef\'s kiss. You and balance are basically best friends now.';

  @override
  String get coachBubbleFunnyWaterLow =>
      'Your water bottle is feeling a little ignored. Just saying.';

  @override
  String get coachBubbleFunnyStreakMilestone =>
      'Streak going strong — someone\'s officially on a roll!';

  @override
  String get coachBubbleFunnyFirstMeal =>
      'Breakfast club, checking in. Day\'s off to a tasty start.';

  @override
  String get coachBubbleDirectMealUnder =>
      'Logged. Room left for the rest of the day — plan it well.';

  @override
  String get coachBubbleDirectMealOver =>
      'Logged, a bit over. No drama — adjust the next meals.';

  @override
  String get coachBubbleDirectMealOnTrack =>
      'Logged. Right on track. Keep it steady.';

  @override
  String get coachBubbleDirectWaterLow =>
      'Water\'s behind today. Grab a glass.';

  @override
  String get coachBubbleDirectStreakMilestone =>
      'Streak holding. Consistency is doing the work.';

  @override
  String get coachBubbleDirectFirstMeal =>
      'First meal logged. Good — set the tone for today.';

  @override
  String get coachBubbleCalmMealUnder =>
      'Noted. There\'s space ahead. Move at your own pace.';

  @override
  String get coachBubbleCalmMealOver =>
      'Noted. Awareness is what matters. The next meal is yours.';

  @override
  String get coachBubbleCalmMealOnTrack =>
      'Noted. Steady and even — a calm kind of progress.';

  @override
  String get coachBubbleCalmWaterLow =>
      'Water\'s a little low. No pressure — sip when it suits you.';

  @override
  String get coachBubbleCalmStreakMilestone =>
      'Quiet consistency, day after day. That counts.';

  @override
  String get coachBubbleCalmFirstMeal =>
      'First meal noted. A calm beginning to the day.';

  @override
  String get mealHistoryTitle => 'Meal History';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get mealHistoryEmptyTitle => 'No meals logged yet';

  @override
  String get mealHistoryEmptyBody =>
      'Your logged meals will show up here, grouped by day.';

  @override
  String get settingsCoachSection => 'Coach';

  @override
  String get settingsYourData => 'Your data';

  @override
  String get settingsExportData => 'Export My Data';

  @override
  String get settingsExportDataDesc =>
      'Download every meal, water log, weight entry, habit, and insight as a JSON file. Right to data portability (GDPR Art. 20).';

  @override
  String get settingsExportFailed => 'Could not export your data.';

  @override
  String get settingsDeleteDesc =>
      'Permanently removes your profile, meals, and all data.';

  @override
  String get settingsDeleteTitle => 'Delete account?';

  @override
  String get settingsDeleteConfirmBody =>
      'This permanently deletes your profile, all meal logs, water logs, weight history, habits, and subscriptions. This cannot be undone.';

  @override
  String get settingsDeleteType => 'Type DELETE to confirm:';

  @override
  String get settingsDeleteFailed => 'Could not delete account.';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get coachTodaysTips => 'Today\'s tips';

  @override
  String get coachNutritionScore => 'Nutrition score';

  @override
  String get coachScoreHigh => 'Solid day — keep doing what you\'re doing.';

  @override
  String get coachScoreMid => 'Mostly on track. A small tweak goes a long way.';

  @override
  String get coachScoreMixed =>
      'Mixed signals — let\'s focus on one thing today.';

  @override
  String get coachScoreReset =>
      'A gentle reset would help. Pick one tip below.';

  @override
  String get coachOfflineTitle => 'Coach is offline';

  @override
  String get coachRegenerate => 'Regenerate';

  @override
  String get coachRegenerateUpgrade => 'Upgrade to regenerate';

  @override
  String get coachRegenerateFree => 'Regenerate (1 free / day)';

  @override
  String get coachScoreExcellent => 'Excellent';

  @override
  String get coachScoreOnTrack => 'On track';

  @override
  String get coachScoreImprove => 'Could improve';

  @override
  String get coachScoreNeedsCare => 'Needs care';

  @override
  String get coachRecommendedStep => 'Recommended next step';

  @override
  String get coachActionHabitAdded => 'Habit added';

  @override
  String get coachActionWaterLogged => 'Water logged';

  @override
  String get coachActionReminderSet => 'Reminder set';

  @override
  String get coachActionTargetUpdated => 'Target updated';

  @override
  String get coachActionDone => 'Done';

  @override
  String get homeOpenSettings => 'Open settings';

  @override
  String get homeAddFood => 'Add Food';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeMealNameQuestion => 'What did you eat?';

  @override
  String get homeCaloriesKcal => 'Calories (kcal)';

  @override
  String get macroProteinG => 'Protein (g)';

  @override
  String get macroCarbsG => 'Carbs (g)';

  @override
  String get macroFatG => 'Fat (g)';

  @override
  String get homeSaveMeal => 'Save meal';

  @override
  String get homeFoodNameRequired => 'Food name is required';

  @override
  String get homeCaloriesRequired => 'Enter a calorie value (> 0)';

  @override
  String get homeSaveFailed => 'Could not save your meal.';

  @override
  String get homeWaterLogFailed => 'Could not log water. Tap to retry.';

  @override
  String get homePlannerCtaTitle => 'Plan your week';

  @override
  String get homePlannerCtaSubtitle => 'See planned meals + grocery list';

  @override
  String get homeNoMealsScanHint =>
      'Tap \"Add Food\" below to log your first meal';

  @override
  String get mealScanScreenTitle => 'AI Meal Scan';

  @override
  String get mealScanIdleTitle => 'Snap your meal';

  @override
  String get mealScanIdleSubtitle =>
      'Point your camera at your plate. Nuveli\'s AI will estimate calories and macros in a few seconds.';

  @override
  String get mealScanTakePhoto => 'Take photo';

  @override
  String get mealScanChooseGallery => 'Choose from gallery';

  @override
  String get mealScanAnalyzingStep1 => 'Analyzing your meal...';

  @override
  String get mealScanAnalyzingStep2 => 'Identifying foods...';

  @override
  String get mealScanAnalyzingStep3 => 'Estimating portions...';

  @override
  String get mealScanAnalyzingStep4 => 'Calculating macros...';

  @override
  String get mealScanAnalyzingStep5 => 'Almost there...';

  @override
  String get mealScanSaving => 'Saving meal...';

  @override
  String get mealScanRateLimitTitle => 'Too many scans, too fast';

  @override
  String get mealScanErrorTitle => 'Scan failed';

  @override
  String get mealScanAddManuallyInstead => 'Add manually instead';

  @override
  String get mealScanNotFoodTitle => 'Hmm, I couldn\'t see food';

  @override
  String get mealScanNotFoodHint =>
      'Try a clearer shot of your plate, or log this meal manually.';

  @override
  String get mealScanTryAnotherPhoto => 'Try another photo';

  @override
  String get mealScanAddManually => 'Add manually';

  @override
  String get mealScanRetake => 'Retake';

  @override
  String mealScanConfidentScore(int score) {
    return '$score% confident';
  }

  @override
  String get mealScanDetectedFoods => 'Detected foods';

  @override
  String get mealScanPortionSize => 'Portion size';

  @override
  String get mealScanDiscard => 'Discard';

  @override
  String get mealScanAiTip => 'AI tip';

  @override
  String get mealScanRemoveTooltip => 'Remove';

  @override
  String get mealScanImageLoadError => 'Could not load image';

  @override
  String get mealScanEditFood => 'Edit food';

  @override
  String get mealScanSaveChanges => 'Save changes';

  @override
  String get mealScanFieldName => 'Name';

  @override
  String get plannerScreenTitle => 'Meal Plan';

  @override
  String get plannerGroceryListTooltip => 'Grocery list';

  @override
  String get plannerThisWeek => 'This week';

  @override
  String get plannerNextWeek => 'Next week';

  @override
  String get plannerLastWeek => 'Last week';

  @override
  String plannerInWeeks(int n) {
    return 'In $n weeks';
  }

  @override
  String plannerWeeksAgo(int n) {
    return '$n weeks ago';
  }

  @override
  String get plannerPrevWeekTooltip => 'Previous week';

  @override
  String get plannerNextWeekTooltip => 'Next week';

  @override
  String plannerTotalsBanner(int kcal, int days) {
    return '$kcal kcal planned across $days days';
  }

  @override
  String get plannerEmptyTitle => 'No plan for this week yet';

  @override
  String get plannerEmptyAiHint =>
      'Let your AI coach draft a full week in seconds.';

  @override
  String get plannerEmptyPremiumHint =>
      'AI weekly plans are part of Premium. Upgrade to unlock.';

  @override
  String get plannerAddMealManually => 'Add a meal manually';

  @override
  String get plannerGenerateAiPlan => 'Generate AI plan';

  @override
  String get plannerUnlockAiPlan => 'Unlock AI plan generation';

  @override
  String get plannerPremiumFeature => 'Premium feature';

  @override
  String get plannerPaywallTitle => 'See and plan beyond this week';

  @override
  String get plannerPaywallBody =>
      'Free plans cover the current week. Upgrade to look ahead, draft repeating plans, and let AI generate a full week for you.';

  @override
  String get plannerSeePremium => 'See Premium';

  @override
  String get plannerBackToThisWeek => 'Back to this week';

  @override
  String get plannerLoadError => 'Could not load your plan';

  @override
  String get plannerEditNameNote => 'Edit name / note';

  @override
  String get plannerRemoveFromPlan => 'Remove from plan';

  @override
  String get plannerRemoveEntryTitle => 'Remove entry?';

  @override
  String plannerRemoveEntryBody(String name) {
    return 'Remove \"$name\" from this plan?';
  }

  @override
  String get plannerRemove => 'Remove';

  @override
  String get plannerToday => 'Today';

  @override
  String plannerDayStats(int meals, int kcal) {
    return '$meals planned · $kcal kcal';
  }

  @override
  String get plannerAddMealTooltip => 'Add meal';

  @override
  String plannerServingsCount(String n) {
    return '$n servings';
  }

  @override
  String get plannerAddToPlan => 'Add to plan';

  @override
  String get plannerMealName => 'Meal name';

  @override
  String get plannerServings => 'Servings';

  @override
  String get plannerNoteOptional => 'Note (optional)';

  @override
  String get plannerMealNameRequired => 'Meal name is required';

  @override
  String get plannerServingsError => 'Servings must be greater than 0';

  @override
  String get plannerEditEntry => 'Edit entry';

  @override
  String get plannerEditCaloriesHint =>
      'To change calories or servings, delete this entry and add it again.';

  @override
  String get plannerGenerateSubtitle =>
      'Your coach drafts a full week. Tweak the details below — all optional.';

  @override
  String get plannerDietaryPref => 'Dietary preference (optional)';

  @override
  String get plannerAvoidIngredients => 'Avoid ingredients (comma-separated)';

  @override
  String get plannerDailyCalorieTarget => 'Daily calorie target (optional)';

  @override
  String get plannerMealsPerDay => 'Meals per day';

  @override
  String get plannerAnythingElse => 'Anything else? (optional)';

  @override
  String get plannerCalorieTargetError => 'Calorie target must be 800–6000';

  @override
  String get plannerGenerating => 'Generating…';

  @override
  String get plannerGeneratePlan => 'Generate plan';

  @override
  String plannerMealsCreated(int n) {
    return '$n meals planned for your week.';
  }

  @override
  String get plannerGroceryList => 'Grocery list';

  @override
  String get plannerGroceryLoadError => 'Could not load groceries';

  @override
  String get plannerGroceryEmpty =>
      'No groceries yet — add a recipe to the plan.';

  @override
  String plannerGroceryUsedIn(int n) {
    return 'Used in $n recipes';
  }

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsSubtitle => 'Your week at a glance';

  @override
  String get analyticsErrorWeeklyBars => 'Could not load weekly bars';

  @override
  String get analyticsErrorMacroBreakdown => 'Could not load macro breakdown';

  @override
  String get analyticsErrorWeightTrend => 'Could not load weight trend';

  @override
  String get analyticsLast7Days => 'Last 7 days';

  @override
  String analyticsDaysOnTarget(int n) {
    return '$n/7 days on target';
  }

  @override
  String analyticsKcalAvg(String avg) {
    return '$avg kcal avg';
  }

  @override
  String analyticsTarget(int target) {
    return '· target $target';
  }

  @override
  String get analyticsWeeklyEmpty => 'Log a few meals to see your weekly trend';

  @override
  String get analyticsMacroBreakdown => 'Macro breakdown';

  @override
  String get analytics7DayAverage => '7-day average';

  @override
  String get analyticsMacroEmpty =>
      'Macro breakdown shows up once you log a meal';

  @override
  String get analyticsMacroProtein => 'Protein';

  @override
  String get analyticsMacroCarbs => 'Carbs';

  @override
  String get analyticsMacroFat => 'Fat';

  @override
  String get analyticsWeightTrend => 'Weight trend';

  @override
  String analyticsWeightTrendDays(int n) {
    return '$n days';
  }

  @override
  String get analyticsWeightTrendEmpty => 'Log your weight to see the trend';

  @override
  String profileGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get profileYourGoals => 'Your Goals';

  @override
  String get profileCouldNotLoad => 'Couldn\'t load';

  @override
  String get profileCouldNotLoadSection => 'Couldn\'t load this section';

  @override
  String get profileLogWeight => 'Log weight';

  @override
  String get profileDailyTarget => 'Daily Target';

  @override
  String profileKcalLeftToday(String n) {
    return '$n kcal left today';
  }

  @override
  String get profileDailyTargetReached => 'Daily target reached';

  @override
  String get profileStreak => 'Streak';

  @override
  String get profileStreakDays => ' days';

  @override
  String get profileStreakKeepGoing => 'Keep it going!';

  @override
  String get profileStreakStartToday => 'Log a meal today to start';

  @override
  String get profileCaloriesVsTarget => 'Calories vs Target';

  @override
  String get profileProgressLast7Days => 'Last 7 days';

  @override
  String get profileAvg => 'Avg';

  @override
  String get profileWithinTarget => 'Within target';

  @override
  String get profileOffTarget => 'Off target';

  @override
  String profileDaysHit(int n) {
    return '$n/7 days hit';
  }

  @override
  String get profileProgressNoData => 'No data yet';

  @override
  String get profileProgressNoDataHint =>
      'Log meals for a few days and your trend will appear here.';

  @override
  String get profileRecommendedTitle => 'Recommended for You';

  @override
  String get profileRecommendedSubtitle =>
      'Personalized tips to help you reach your goals';

  @override
  String get profileRec1Title => 'Drink water before meals';

  @override
  String get profileRec1Desc => 'Helps with portion control and hydration.';

  @override
  String get profileRec2Title => 'Add a 30-min walk';

  @override
  String get profileRec2Desc => 'Easy way to hit your daily TDEE.';

  @override
  String get profileRec3Title => 'Sleep 7–8 hours';

  @override
  String get profileRec3Desc => 'Better recovery, better hunger control.';

  @override
  String get profileWeightGoal => 'Weight Goal';

  @override
  String get profileLogWeightToSeeTrend => 'Log weight to see trend';

  @override
  String profileProgressPercent(String n) {
    return '$n% complete';
  }

  @override
  String get profileSetWeightGoal => 'Set your\nweight goal';

  @override
  String get profileTapToStartTracking => 'Tap to start tracking';

  @override
  String get profileSetWeightGoalTitle => 'Set your weight goal';

  @override
  String get profileSetWeightGoalSubtitle =>
      'We\'ll track your progress and adjust suggestions.';

  @override
  String get profileGoalType => 'GOAL TYPE';

  @override
  String get profileGoalLose => 'Lose';

  @override
  String get profileGoalMaintain => 'Maintain';

  @override
  String get profileGoalGain => 'Gain';

  @override
  String get profileStartingWeight => 'Starting weight';

  @override
  String get profileTargetWeight => 'Target weight';

  @override
  String get profileMaintainWeightAt => 'Maintain weight at';

  @override
  String get profileTargetDate => 'Target date';

  @override
  String get profileChooseDate => 'Choose a date';

  @override
  String get profileSaveGoal => 'Save goal';

  @override
  String get profileGoalErrorTarget =>
      'Enter a target weight between 20 and 400 kg';

  @override
  String get profileGoalErrorStart =>
      'Enter a starting weight between 20 and 400 kg';

  @override
  String get profileGoalErrorLoseLower =>
      'Target should be lower than starting weight';

  @override
  String get profileGoalErrorGainHigher =>
      'Target should be higher than starting weight';

  @override
  String get profileGoalSaveError =>
      'Could not save. Check your connection and try again.';

  @override
  String get profileLogWeightTitle => 'Log your weight';

  @override
  String get profileLogWeightSubtitle => 'Track your progress toward your goal';

  @override
  String get profileWeightLabel => 'Weight';

  @override
  String get profileWeightNoteOptional => 'Note (optional)';

  @override
  String get profileWeightNoteHint => 'After workout, morning, etc.';

  @override
  String get profileWeightError => 'Enter a weight between 20 and 400 kg';

  @override
  String get profileSaveWeight => 'Save weight';

  @override
  String profileWeightSaving(String kg) {
    return 'Saving $kg kg...';
  }

  @override
  String profileWeightSaved(String kg) {
    return 'Weight saved ($kg kg)';
  }

  @override
  String profileWeightSaveFailed(String kg) {
    return 'Could not save $kg kg';
  }

  @override
  String get profileWeightSavedShort => 'Weight saved';

  @override
  String get profileWeightStillFailed => 'Still could not save';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditName => 'Name';

  @override
  String get profileEditNameHint => 'Your name';

  @override
  String get profileEditSex => 'Sex';

  @override
  String get profileEditDob => 'Date of birth';

  @override
  String get profileEditSelectDate => 'Select date';

  @override
  String get profileEditHeightCm => 'Height (cm)';

  @override
  String get profileEditWeightKg => 'Weight (kg)';

  @override
  String get profileEditActivityLevel => 'Activity level';

  @override
  String get profileEditDietaryPref => 'Dietary preference';

  @override
  String get profileEditUpdated => 'Profile updated';

  @override
  String get welcomeGetStarted => 'Get Started';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue your journey';

  @override
  String get loginForgotPasswordFull => 'Forgot password?';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginDontHaveAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get signupCreateAccount => 'Create account';

  @override
  String get signupNutritionJourney => 'Let\'s start your nutrition journey';

  @override
  String get signupConfirmPassword => 'Confirm password';

  @override
  String get signupTermsAgree => 'I agree to the ';

  @override
  String get signupTermsOfService => 'Terms of Service';

  @override
  String get signupTermsAnd => ' and ';

  @override
  String get signupPrivacyPolicy => 'Privacy Policy';

  @override
  String get signupAcceptTermsError => 'Please accept the Terms to continue.';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get signupSignIn => 'Sign in';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordSendLink => 'Send reset link';

  @override
  String get forgotPasswordRemember => 'Remember your password?';

  @override
  String get forgotPasswordCheckEmail => 'Check your email';

  @override
  String forgotPasswordSentLink(String email) {
    return 'We\'ve sent a password reset link to\n$email';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Back to sign in';

  @override
  String get verifyEmailSentLinkTo => 'We\'ve sent a verification link to';

  @override
  String get verifyEmailOpenOnDevice => 'Open it on this device to continue.';

  @override
  String get verifyEmailResendEmail => 'Resend email';

  @override
  String verifyEmailResendInSeconds(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get verifyEmailWrongEmail => 'Wrong email?';

  @override
  String get verifyEmailGoBack => 'Go back';

  @override
  String get resetPasswordTitle => 'Set new password';

  @override
  String get resetPasswordSubtitle =>
      'Choose a strong password for your account.';

  @override
  String get resetPasswordNewPassword => 'New password';

  @override
  String get resetPasswordConfirmPassword => 'Confirm password';

  @override
  String get resetPasswordUpdate => 'Update password';

  @override
  String get resetPasswordUpdated => 'Password updated';

  @override
  String get resetPasswordCanNowSignIn =>
      'You can now sign in with your new password.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingSignOutTooltip => 'Sign out';

  @override
  String get onboardingSignOutTitle => 'Sign out?';

  @override
  String get onboardingSignOutBody =>
      'Your progress will be saved. You can continue setup later.';

  @override
  String get onboardingCompleteStepsError =>
      'Please complete all steps before continuing.';

  @override
  String get onboardingSaveError =>
      'Could not save your profile. Please try again.';

  @override
  String get onboardingStep1Title => 'Hi! Let\'s get to know you';

  @override
  String get onboardingStep1Body =>
      'We\'ll personalize your nutrition coaching based on your body, lifestyle, and goals. It only takes a minute.';

  @override
  String get onboardingStep2Title => 'Tell us about yourself';

  @override
  String get onboardingStep2Subtitle =>
      'This helps us calculate your daily needs.';

  @override
  String get onboardingYourName => 'Your name';

  @override
  String get onboardingNameHint => 'How should we call you?';

  @override
  String get onboardingNameRequired => 'Name is required';

  @override
  String get onboardingDateOfBirth => 'Date of birth';

  @override
  String get onboardingSelectDate => 'Select date';

  @override
  String get onboardingSelectDob => 'Please select your date of birth';

  @override
  String get onboardingSelectGender => 'Please select your gender';

  @override
  String get onboardingStep3Title => 'Your body metrics';

  @override
  String get onboardingStep3Subtitle =>
      'Don\'t worry, you can update these anytime.';

  @override
  String get onboardingHeight => 'Height';

  @override
  String get onboardingCurrentWeight => 'Current weight';

  @override
  String get onboardingStep4Title => 'Your goals';

  @override
  String get onboardingStep4Subtitle =>
      'We\'ll tailor your daily targets accordingly.';

  @override
  String get onboardingActivityLevelLabel => 'Activity level';

  @override
  String get onboardingYourGoalLabel => 'Your goal';

  @override
  String get onboardingTargetWeight => 'Target weight';

  @override
  String get onboardingToLose => 'to lose';

  @override
  String get onboardingToGain => 'to gain';

  @override
  String get onboardingSelectActivityError =>
      'Please select your activity level';

  @override
  String get onboardingSelectGoalError => 'Please select a goal';

  @override
  String get onboardingStep5Title => 'Your daily targets';

  @override
  String get onboardingStep5Subtitle =>
      'Personalized to your body, lifestyle, and goal.';

  @override
  String get onboardingDailyCalories => 'DAILY CALORIES';

  @override
  String get onboardingMacros => 'Macros';

  @override
  String get onboardingProtein => 'Protein';

  @override
  String get onboardingCarbs => 'Carbs';

  @override
  String get onboardingFat => 'Fat';

  @override
  String get onboardingDailyWater => 'Daily water';

  @override
  String get onboardingCompleteSetup => 'Complete Setup';

  @override
  String get onboardingAdjustAnytime =>
      'You can adjust these anytime in Settings.';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authValidatorEmailRequired => 'Email is required';

  @override
  String get authValidatorEmailInvalid => 'Enter a valid email';

  @override
  String get authValidatorPasswordRequired => 'Password is required';

  @override
  String get authValidatorPasswordLength => 'At least 8 characters';

  @override
  String get authValidatorPasswordNumber => 'Include at least one number';

  @override
  String get authValidatorPasswordSimpleLength => 'At least 6 characters';

  @override
  String get authValidatorConfirmRequired => 'Please confirm password';

  @override
  String get authValidatorPasswordsNoMatch => 'Passwords do not match';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get passwordStrengthVeryStrong => 'Very strong';

  @override
  String get passwordStrengthSuggestLength => 'Use at least 8 characters';

  @override
  String get passwordStrengthSuggestNumber => 'Add a number';

  @override
  String get passwordStrengthSuggestCase => 'Mix uppercase & lowercase';

  @override
  String get passwordStrengthSuggestSymbol => 'Add a symbol (!@#\\\$%)';

  @override
  String get authOrDivider => 'or';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navScan => 'Scan';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get homeTodaySummary => 'Today\'s Summary';

  @override
  String homeKcalRemaining(String count) {
    return '$count kcal remaining';
  }

  @override
  String homeKcalOver(String count) {
    return '$count kcal over';
  }

  @override
  String homeOfKcalTarget(String count) {
    return 'of $count kcal';
  }

  @override
  String homeOfGlasses(String count) {
    return 'of $count glasses';
  }
}
