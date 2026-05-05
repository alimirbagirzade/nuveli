// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Nuveli';

  @override
  String get appTagline => 'ИИ-тренер по калориям';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginPasswordRepeat => 'Повторите пароль';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginNoAccount => 'Нет аккаунта?';

  @override
  String get loginRegisterLink => 'Зарегистрироваться';

  @override
  String get signupTitle => 'Создать аккаунт';

  @override
  String get signupSubtitle => 'Начните путь к здоровому питанию с Nuveli';

  @override
  String get signupButton => 'Зарегистрироваться';

  @override
  String get signupHasAccount => 'Уже есть аккаунт?';

  @override
  String get signupLoginLink => 'Войти';

  @override
  String get signupTerms =>
      'Регистрируясь, вы принимаете Условия использования и Политику конфиденциальности.';

  @override
  String get authInvalidCredentials =>
      'Неверный e-mail или пароль. Попробуйте снова.';

  @override
  String get authEmailNotConfirmed =>
      'Вы ещё не подтвердили e-mail. Проверьте почту.';

  @override
  String get authUserNotFound =>
      'Пользователь с таким e-mail не зарегистрирован.';

  @override
  String get authUserAlreadyRegistered =>
      'Этот e-mail уже зарегистрирован. Попробуйте войти.';

  @override
  String get authWeakPassword => 'Пароль слишком слабый. Минимум 6 символов.';

  @override
  String get authInvalidEmail => 'Неверный формат e-mail.';

  @override
  String get authRateLimit =>
      'Вы пытались слишком быстро. Подождите несколько секунд.';

  @override
  String get authNetworkError => 'Проверьте интернет-соединение.';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authGenericError => 'Что-то пошло не так. Попробуйте снова.';

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
  String get homeGreetingMorning => 'Доброе утро';

  @override
  String get homeGreetingAfternoon => 'Добрый день';

  @override
  String get homeGreetingEvening => 'Добрый вечер';

  @override
  String get homeTodayCalories => 'Today\'s calories';

  @override
  String get homeRemainingCalories => 'Remaining';

  @override
  String get homeAddMeal => 'Добавить';

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
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'АККАУНТ';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsLanguage => 'Язык';

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
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsPremium => 'ПРЕМИУМ';

  @override
  String get settingsPremiumComingSoon => 'COMING SOON';

  @override
  String get settingsAbout => 'О Nuveli';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsPrivacy => 'Конфиденциальность и безопасность';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Delete My Account';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get premiumTitle => 'Премиум';

  @override
  String get premiumSubtitle => 'Раскройте весь потенциал';

  @override
  String get premiumFeatureUnlimited => 'Безлимитный анализ блюд ИИ';

  @override
  String get premiumFeatureCoach => 'Advanced AI coach';

  @override
  String get premiumFeatureReports => 'Detailed weekly reports';

  @override
  String get premiumFeatureExport => 'Data export';

  @override
  String get premiumNotifyMe => 'Notify me when ready';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonOk => 'OK';

  @override
  String get settingsCoachTone => 'Тон тренера';

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
  String get premiumFeatureVoice => 'Голосовой тренер + 3 персоны';

  @override
  String get premiumFeatureInsights => 'Еженедельные + ежемесячные инсайты';

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
  String get homeAddWater => 'Вода';

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
  String get macroProtein => 'Белок';

  @override
  String get macroCarb => 'Углеводы';

  @override
  String get macroFat => 'Жиры';

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
  String get coachSettingsTitle => 'Тренер';

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
  String get settingsAppearance => 'ВНЕШНИЙ ВИД';

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get supportEmailSubject => 'Поддержка Nuveli';

  @override
  String get howAiTitle => 'Как работает ИИ';

  @override
  String get privacyTitle => 'Конфиденциальность и безопасность';

  @override
  String get aboutTitle => 'О Nuveli';

  @override
  String get coachToneUpdated => 'Тон тренера обновлён';

  @override
  String get supportHowHelp => 'How can we help you?';

  @override
  String get supportEmailCard => 'Contact by email';

  @override
  String get supportFaq => 'Часто задаваемые вопросы';

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
  String get aboutWebsite => 'Веб-сайт';

  @override
  String get aboutTechnical => 'Technical';

  @override
  String get aboutEnv => 'Environment';

  @override
  String get aboutCopyright => '© 2026 Nuveli. All rights reserved.';

  @override
  String get aboutCopied => 'copied';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get streakDay => 'день';

  @override
  String get streakDays => 'дней';

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
  String get weeklyTitle => 'Недельный обзор';

  @override
  String get weeklyLoadFailed => 'Could not load';

  @override
  String get weeklyChartLoadFailed => 'Could not load data';

  @override
  String get commonRetryLow => 'Try again';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Вс';

  @override
  String get dayDetailMeals => 'Приёмы пищи';

  @override
  String get dayDetailMealsLoadFailed => 'Could not load meals';

  @override
  String get dayDetailNoMeals => 'В этот день не было приёмов пищи';

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
  String get weeklyDailyDetail => 'По дням';

  @override
  String get weeklyCoachComment => 'COACH COMMENT';

  @override
  String get weeklyCoachCommentLocked => 'Coach comment';

  @override
  String get weeklyCoachCommentLockedDesc =>
      'Personal weekly pattern comments with Premium';

  @override
  String streakLastLog(String date) {
    return 'Последняя запись: $date';
  }

  @override
  String get streakNow => 'Текущая';

  @override
  String get streakLongestShort => 'Самая длинная';

  @override
  String get streakAddMealNow => 'Добавить приём пищи';

  @override
  String get streakAtRisk =>
      'Сегодня вы не добавили приём пищи, и уже вечер. Добавьте сейчас, чтобы сохранить серию.';

  @override
  String get streakNotStarted =>
      'Ваша серия ещё не началась. Добавьте первый приём пищи, чтобы начать.';

  @override
  String get streakTodayLogged =>
      'Сегодня тоже сделали! Добавьте завтра приём пищи, чтобы продолжить серию.';

  @override
  String get streakExplanationDefault =>
      'Серия — это количество дней подряд с записями приёмов пищи.';

  @override
  String get weeklyAvgKcal => 'ккал/день в среднем';

  @override
  String get weeklyTotal => 'Всего';

  @override
  String get weeklyMeals => 'Приёмов пищи';

  @override
  String get weeklyLogged => 'Записано';

  @override
  String get coachChatTitle => 'Тренер';

  @override
  String get coachChatPlaceholder => 'Задайте вопрос тренеру...';

  @override
  String get coachChatSend => 'Отправить';

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
      'Or describe the meal (e.g. chicken breast, rice, salad)';

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
  String get weekdayMon => 'Понедельник';

  @override
  String get weekdayTue => 'Вторник';

  @override
  String get weekdayWed => 'Среда';

  @override
  String get weekdayThu => 'Четверг';

  @override
  String get weekdayFri => 'Пятница';

  @override
  String get weekdaySat => 'Суббота';

  @override
  String get weekdaySun => 'Воскресенье';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get personaGentle => 'Мягкий';

  @override
  String get personaGentleDesc => 'Мягкий, без давления, эмпатия превыше всего';

  @override
  String get personaGentleSample =>
      '\"Вижу, сегодня было немного тяжело. Не суди себя строго, даже если пропустил приём пищи.\"';

  @override
  String get personaFunny => 'Весёлый';

  @override
  String get personaFunnyDesc =>
      'Лёгкий, улыбающийся, сбалансированный в серьёзных моментах';

  @override
  String get personaFunnySample =>
      '\"Вечер пиццы, понял. Жизнь — это игра баланса — салат завтра, счастье сегодня.\"';

  @override
  String get personaDirect => 'Прямой';

  @override
  String get personaDirectDesc => 'Короткий, чёткий, реалистичный фидбек';

  @override
  String get personaDirectSample =>
      '\"Сегодня мало белка. На ужин 25-30г, баланс недели сохранится.\"';

  @override
  String get personaCalm => 'Спокойный';

  @override
  String get personaCalmDesc => 'Без осуждения, терпеливый, размеренный';

  @override
  String get personaCalmSample =>
      '\"День не всегда идёт идеально. Ты сейчас здесь, и этого достаточно.\"';

  @override
  String get coachToneQuestion => 'Как должен говорить с вами тренер?';

  @override
  String get coachToneSubtitle => 'Можете изменить в любое время.';

  @override
  String get coachToneSaving => 'Сохранение...';

  @override
  String get coachToneSaveError =>
      'Не удалось сохранить. Проверьте соединение и попробуйте снова?';

  @override
  String get coachToneSaveErrorGeneric =>
      'Неожиданная ошибка. Попробовать снова?';

  @override
  String waterLastDays(int n) {
    return 'Последние $n дней';
  }

  @override
  String get waterLitresTotal => 'л всего';

  @override
  String get waterToday => 'Сегодня';

  @override
  String get waterAverage => 'Среднее';

  @override
  String get waterLast7 => 'Последние 7 дней';

  @override
  String waterGoalMl(int ml) {
    return 'Цель: $ml мл/день';
  }

  @override
  String get waterAllDays => 'Все дни';

  @override
  String get waterNoRecord => 'Нет записи';

  @override
  String waterDaysCount(int n) {
    return '$n дней';
  }

  @override
  String get weightCurrent => 'Текущий вес';

  @override
  String get weightFirstRecord => 'Первая запись';

  @override
  String weightTrend(int n) {
    return 'Тренд ($n записей)';
  }

  @override
  String get weightRecords => 'Записи';

  @override
  String weightEntryCount(int n) {
    return '$n записей';
  }

  @override
  String get monthShortJan => 'Янв';

  @override
  String get monthShortFeb => 'Фев';

  @override
  String get monthShortMar => 'Мар';

  @override
  String get monthShortApr => 'Апр';

  @override
  String get monthShortMay => 'Май';

  @override
  String get monthShortJun => 'Июн';

  @override
  String get monthShortJul => 'Июл';

  @override
  String get monthShortAug => 'Авг';

  @override
  String get monthShortSep => 'Сен';

  @override
  String get monthShortOct => 'Окт';

  @override
  String get monthShortNov => 'Ноя';

  @override
  String get monthShortDec => 'Дек';

  @override
  String get todayBadge => 'СЕГОДНЯ';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileLoadFailed => 'Could not load profile.';

  @override
  String get profileAccount => 'АККАУНТ';

  @override
  String get profilePersonalInfo => 'Личная информация';

  @override
  String get profilePersonalInfoSub => 'Name, goals, body info';

  @override
  String get profileGoals => 'Цели';

  @override
  String get profileGoalsSub => 'Your calorie and macro targets';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotifPrefs => 'Notification preferences';

  @override
  String get profileNotifPrefsSub => 'Reminders and quiet hours';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileDarkTheme => 'Dark theme';

  @override
  String get profileDarkThemeSub => 'Currently active (default)';

  @override
  String get profilePremium => 'ПРЕМИУМ';

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
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileSignOutConfirm => 'Выйти';

  @override
  String get homeGreetingNoonTime => 'Good afternoon';

  @override
  String get profileStreakNow => 'Current';

  @override
  String get profileStreakLongest => 'Самая длинная';

  @override
  String get profileStreakDay => 'day';

  @override
  String get personalInfoTitle => 'Личная информация';

  @override
  String get personalInfoEdit => 'Edit';

  @override
  String get personalInfoSaved => 'Сохранено';

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
  String get personalInfoName => 'Имя';

  @override
  String get personalInfoEmail => 'E-mail';

  @override
  String get personalInfoBirthYear => 'Год рождения';

  @override
  String get personalInfoGender => 'Пол';

  @override
  String get personalInfoHeight => 'Рост';

  @override
  String get personalInfoHeightCm => 'Height (cm)';

  @override
  String get personalInfoWeight => 'Вес';

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
  String get genderFemale => 'Женский';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderOther => 'Другой';

  @override
  String get activitySedentary => 'Малоподвижный';

  @override
  String get activitySedentaryFull => 'Sedentary (desk job)';

  @override
  String get activityLight => 'Лёгкая активность';

  @override
  String get activityLightFull => 'Lightly active (1-3 days)';

  @override
  String get activityModerate => 'Умеренная активность';

  @override
  String get activityModerateFull => 'Moderately active (3-5 days)';

  @override
  String get activityActive => 'Активный';

  @override
  String get activityActiveFull => 'Active (6-7 days)';

  @override
  String get activityVeryActive => 'Очень активный';

  @override
  String get activityVeryActiveFull => 'Very active (athlete)';

  @override
  String get goalsTitle => 'Цели';

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
  String get goalsMaintain => 'Поддерживать вес';

  @override
  String get goalsMaintainDesc => 'Поддержание текущего веса';

  @override
  String get goalsGainMuscle => 'Gain muscle';

  @override
  String get goalsGainMuscleDesc => 'Build with calorie surplus';

  @override
  String get goalsMacroNote => 'Макронутриенты рассчитываются автоматически';

  @override
  String get goalsSave => 'Save';

  @override
  String get premiumComingTitle => 'Премиум скоро! 🚀';

  @override
  String get premiumComingDesc =>
      'Заканчиваем безлимитный анализ блюд ИИ, голосовой тренер и еженедельные инсайты. Сообщим, когда будет готово.';

  @override
  String get premiumFeatureCharts => 'Расширенные графики и тренды';

  @override
  String get premiumGotIt => 'Понятно';

  @override
  String todayMealsCount(int n) {
    return '$n приёмов пищи';
  }

  @override
  String get todayMealDeleteTitle => 'Удалить приём пищи?';

  @override
  String todayMealDeleteMessage(String name) {
    return '\"$name\" будет удалён. Это нельзя отменить.';
  }

  @override
  String get todayMealDeleteConfirm => 'Удалить';

  @override
  String get todayMealDeleteCancel => 'Отмена';

  @override
  String get todayMealDeleted => 'Приём пищи удалён.';

  @override
  String get todayMealDeleteFailed => 'Не удалось удалить.';

  @override
  String get mealTypeBreakfastShort => 'Завтрак';

  @override
  String get mealTypeLunchShort => 'Обед';

  @override
  String get mealTypeDinnerShort => 'Ужин';

  @override
  String get mealTypeSnackShort => 'Перекус';

  @override
  String streakLongestNeverActive(int longest) {
    return 'Самая длинная серия: $longest дней';
  }

  @override
  String streakTodayDoneSubtitle(int longest) {
    return 'Сделали сегодня · Самая длинная: $longest дней';
  }

  @override
  String streakTodayMissedSubtitle(int longest) {
    return 'Не забудьте сегодня · Самая длинная: $longest';
  }

  @override
  String get waterAllDaysList => 'Все дни';

  @override
  String get waterTodayBadge => 'СЕГОДНЯ';

  @override
  String get waterNoEntry => 'Нет записи';

  @override
  String get weightRecordsList => 'Записи';

  @override
  String weightEntriesCount(int n) {
    return '$n записей';
  }

  @override
  String historyDaysSuffix(int n) {
    return '$n дней';
  }

  @override
  String get moodGreat => 'Отлично';

  @override
  String get moodGood => 'Хорошо';

  @override
  String get moodNeutral => 'Нормально';

  @override
  String get moodBad => 'Тяжело';

  @override
  String get moodRough => 'Очень тяжело';
}
