// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Nuveli App';

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
      'Ваша сессия истекла. Пожалуйста, войдите снова.';

  @override
  String get authGenericError => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get ageGateTitle => 'Начнём с возраста';

  @override
  String get ageGateSubtitle => 'Мы адаптируем рекомендации под ваш возраст.';

  @override
  String get ageGateBirthYear => 'Год рождения';

  @override
  String get ageGateUnderageError =>
      'Извините, Nuveli не подходит для лиц до 13 лет.';

  @override
  String get ageGateContinue => 'Продолжить';

  @override
  String get acceptanceTitle => 'Информация';

  @override
  String get acceptanceHeader => 'Перед началом';

  @override
  String get acceptanceSubtitle =>
      '4 важных пункта для безопасного использования Nuveli. Подтвердите все.';

  @override
  String get acceptanceWellnessTitle => 'Nuveli — приложение велнеса';

  @override
  String get acceptanceWellnessBody =>
      'Nuveli не предоставляет медицинскую диагностику, лечение или клинические диеты. Это приложение для здоровых привычек.';

  @override
  String get acceptanceWellnessCheck =>
      'Я понимаю. Nuveli не заменяет моего врача.';

  @override
  String get acceptanceAiTitle => 'Оценки ИИ приблизительны';

  @override
  String get acceptanceAiBody =>
      'Калории и пищевая ценность, которые мы оцениваем по фото, являются приблизительными. Используйте как ориентир, а не как точную меру.';

  @override
  String get acceptanceAiCheck =>
      'Я понимаю, что результаты могут быть приблизительными.';

  @override
  String get acceptanceSpecialTitle => 'Особые ситуации требуют внимания';

  @override
  String get acceptanceSpecialBody =>
      'Если у вас беременность, кормление грудью, история расстройства пищевого поведения или хроническое заболевание — проконсультируйтесь со специалистом.';

  @override
  String get acceptanceSpecialCheck =>
      'Я проконсультируюсь со специалистом в моей особой ситуации.';

  @override
  String get acceptanceTermsTitle => 'Условия и конфиденциальность';

  @override
  String get acceptanceTermsBody =>
      'Вы должны прочитать и принять Условия использования и Политику конфиденциальности. Ваши данные защищены.';

  @override
  String get acceptanceTermsCheck =>
      'Я принимаю Условия и Политику конфиденциальности.';

  @override
  String get acceptanceContinue => 'Продолжить';

  @override
  String get acceptanceCheckAll => 'Отметьте все';

  @override
  String get onboardingGoalTitle => 'Какая ваша цель?';

  @override
  String get onboardingGoalLose => 'Похудеть';

  @override
  String get onboardingGoalMaintain => 'Поддерживать вес';

  @override
  String get onboardingGoalGain => 'Набрать мышечную массу';

  @override
  String get onboardingSensitivityTitle => 'Чувствительность';

  @override
  String get onboardingSensitivityQ1 =>
      '1. Были ли у вас в прошлом проблемы с пищевыми привычками?';

  @override
  String get onboardingSensitivityQ1A1 => 'Нет, никогда не было такого периода';

  @override
  String get onboardingSensitivityQ1A2 => 'Раньше было, сейчас всё в порядке';

  @override
  String get onboardingSensitivityQ1A3 => 'Сейчас иногда сложно';

  @override
  String get onboardingSensitivityQ1A4 => 'Предпочитаю не отвечать';

  @override
  String get onboardingSensitivityQ2 =>
      '2. Как вы относитесь к подсчёту калорий?';

  @override
  String get onboardingSensitivityQ2A1 => 'Чувствую себя комфортно';

  @override
  String get onboardingSensitivityQ2A2 => 'Нейтрально';

  @override
  String get onboardingSensitivityQ2A3 => 'Может вызывать стресс';

  @override
  String get onboardingSensitivityQ2A4 => 'Предпочитаю не отвечать';

  @override
  String get onboardingProfileTitle => 'Расскажите о себе';

  @override
  String get onboardingProfileGender => 'Пол';

  @override
  String get onboardingProfileGenderMale => 'Мужской';

  @override
  String get onboardingProfileGenderFemale => 'Женский';

  @override
  String get onboardingProfileGenderOther => 'Другой / Не указывать';

  @override
  String get onboardingProfileHeight => 'Рост (см)';

  @override
  String get onboardingProfileWeight => 'Вес (кг)';

  @override
  String get onboardingProfileActivity => 'Уровень активности';

  @override
  String get onboardingProfileActivitySedentary =>
      'Малоподвижный (сидячая работа)';

  @override
  String get onboardingProfileActivityLight => 'Лёгкая активность';

  @override
  String get onboardingProfileActivityModerate => 'Умеренная активность';

  @override
  String get onboardingProfileActivityActive => 'Очень активный';

  @override
  String get onboardingDietTitle => 'Диета';

  @override
  String get onboardingDietAllergies => 'Аллергии';

  @override
  String get onboardingDietPreference => 'Предпочтения в диете';

  @override
  String get onboardingDietAllergyLactose => 'Лактоза';

  @override
  String get onboardingDietAllergyGluten => 'Глютен';

  @override
  String get onboardingDietAllergyPeanut => 'Арахис';

  @override
  String get onboardingDietAllergyNut => 'Орехи';

  @override
  String get onboardingDietAllergyEgg => 'Яйца';

  @override
  String get onboardingDietAllergyShellfish => 'Моллюски';

  @override
  String get onboardingDietAllergySoy => 'Соя';

  @override
  String get onboardingDietAllergySesame => 'Кунжут';

  @override
  String get onboardingDietAllergyFish => 'Рыба';

  @override
  String get onboardingDietPrefNone => 'Без особых предпочтений';

  @override
  String get onboardingDietPrefVegetarian => 'Вегетарианец';

  @override
  String get onboardingDietPrefVegan => 'Веган';

  @override
  String get onboardingDietPrefPescatarian => 'Пескетарианец (только рыба)';

  @override
  String get onboardingDietPrefHalal => 'Халяль';

  @override
  String get onboardingDietPrefKosher => 'Кошер';

  @override
  String get onboardingDietPrefOther => 'Другое';

  @override
  String get onboardingCoachTitle => 'Ваш тренер';

  @override
  String get onboardingCoachQuestion => 'Как должен говорить тренер?';

  @override
  String get onboardingCoachSubtitle => 'Можете изменить в любое время.';

  @override
  String get onboardingCoachKind => 'Мягкий';

  @override
  String get onboardingCoachKindDesc =>
      'Мягкий, без давления, эмпатия превыше всего';

  @override
  String get onboardingCoachWitty => 'Весёлый';

  @override
  String get onboardingCoachWittyDesc =>
      'Лёгкий, улыбающийся, сбалансированный';

  @override
  String get onboardingCoachDirect => 'Прямой';

  @override
  String get onboardingCoachDirectDesc =>
      'Короткий, чёткий, реалистичный фидбек';

  @override
  String get onboardingCoachCalm => 'Спокойный';

  @override
  String get onboardingCoachCalmDesc =>
      'Без осуждения, терпеливый, размеренный';

  @override
  String get onboardingCalorieTitle => 'Дневная цель калорий';

  @override
  String get onboardingCalorieReady => 'Ваша дневная цель готова';

  @override
  String get onboardingCalorieDescription =>
      'Это число основано на ваших данных. Не фиксированное — мы будем корректировать вместе.';

  @override
  String get onboardingCalorieDaily => 'Дневная норма калорий';

  @override
  String get onboardingCalorieKcal => 'ккал';

  @override
  String get onboardingCalorieNote =>
      'Рассчитано на основе активности, цели и ситуации. Пересматривается ежемесячно.';

  @override
  String get onboardingNotificationTitle => 'Уведомления';

  @override
  String get onboardingNotificationQuestion => 'Хотите мягкие напоминания?';

  @override
  String get onboardingNotificationDescription =>
      'Краткая поддержка и напоминания о приёмах пищи от тренера. Мы уважаем тихие часы.';

  @override
  String get onboardingNotificationYes => 'Да, хочу';

  @override
  String get onboardingNotificationNo => 'Не сейчас';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать.';

  @override
  String get onboardingWelcomeSubtitle => 'Мы готовы.';

  @override
  String get onboardingWelcomeBody =>
      'Без давления, без осуждения — только вы и тренер рядом.';

  @override
  String get onboardingWelcomeFirstStep => 'Идея для первого шага';

  @override
  String get onboardingWelcomeFirstStepDesc =>
      'Начните с одного приёма пищи, который съели сегодня. Сделайте фото или напишите — ваш тренер вас встретит.';

  @override
  String get onboardingWelcomeStart => 'Начнём';

  @override
  String get onboardingWelcomePreparing => 'Подготовка...';

  @override
  String get onboardingWelcomeError =>
      'Произошла неожиданная проблема, попробуем снова?';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeGreetingMorning => 'Доброе утро';

  @override
  String get homeGreetingAfternoon => 'Добрый день';

  @override
  String get homeGreetingEvening => 'Добрый вечер';

  @override
  String get homeTodayCalories => 'Калории сегодня';

  @override
  String get homeRemainingCalories => 'Осталось';

  @override
  String get homeAddMeal => 'Добавить';

  @override
  String get homeChat => 'Поговорить с тренером';

  @override
  String get homeNoMeals => 'Ещё не добавлено приёмов пищи';

  @override
  String get homeNoMealsHint => 'Сфотографируйте еду или напишите';

  @override
  String get navHome => 'Главная';

  @override
  String get navMeals => 'Питание';

  @override
  String get navCoach => 'Тренер';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'АККАУНТ';

  @override
  String get settingsProfile => 'Профиль';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный язык';

  @override
  String get settingsLanguageTurkish => 'Турецкий';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageGerman => 'Немецкий';

  @override
  String get settingsLanguageFrench => 'Французский';

  @override
  String get settingsLanguageSpanish => 'Испанский';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsPremium => 'ПРЕМИУМ';

  @override
  String get settingsPremiumComingSoon => 'СКОРО';

  @override
  String get settingsAbout => 'О Nuveli';

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get settingsPrivacy => 'Конфиденциальность и безопасность';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get premiumTitle => 'Премиум';

  @override
  String get premiumSubtitle => 'Раскройте весь потенциал';

  @override
  String get premiumFeatureUnlimited => 'Безлимитный анализ блюд ИИ';

  @override
  String get premiumFeatureCoach => 'Расширенный ИИ-тренер';

  @override
  String get premiumFeatureReports => 'Подробные еженедельные отчёты';

  @override
  String get premiumFeatureExport => 'Экспорт данных';

  @override
  String get premiumNotifyMe => 'Уведомить меня, когда будет готово';

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
  String get commonSuccess => 'Успех';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonOk => 'Принять';

  @override
  String get settingsCoachTone => 'Тон тренера';

  @override
  String get settingsSupportSecurity => 'Поддержка и безопасность';

  @override
  String get settingsHowAiWorks => 'Как работает ИИ';

  @override
  String get settingsPrivacySafety => 'Конфиденциальность и безопасность';

  @override
  String get settingsAboutNuveli => 'О Nuveli';

  @override
  String get settingsSubscription => 'Подписка';

  @override
  String get settingsSession => 'Сессия';

  @override
  String get settingsDangerZone => 'Опасная зона';

  @override
  String get settingsSignedInAs => 'Вы вошли как';

  @override
  String get settingsLogoutTitle => 'Выйти?';

  @override
  String get settingsLogoutBody =>
      'Вам понадобится e-mail и пароль, чтобы войти снова.';

  @override
  String get settingsLogoutCancel => 'Отмена';

  @override
  String get settingsLogoutFailed => 'Не удалось выйти.';

  @override
  String get premiumModalTitle => 'Премиум скоро!';

  @override
  String get premiumModalBody =>
      'Мы готовим безлимитный анализ ИИ, расширенного тренера и многое другое. Скоро будет!';

  @override
  String get premiumFeatureVoice => 'Голосовой тренер + 3 персоны';

  @override
  String get premiumFeatureInsights => 'Еженедельные + ежемесячные инсайты';

  @override
  String get premiumUnderstood => 'Понятно';

  @override
  String get passwordVeryWeak => 'Очень слабый';

  @override
  String get passwordWeak => 'Слабый';

  @override
  String get passwordMedium => 'Средний';

  @override
  String get passwordStrong => 'Сильный';

  @override
  String get passwordVeryStrong => 'Очень сильный';

  @override
  String get homeErrorGeneric => 'Что-то пошло не так';

  @override
  String get homeCoachLabel => 'Ваш тренер';

  @override
  String get homeToday => 'Сегодня';

  @override
  String get homeRemaining => 'осталось';

  @override
  String get homeThisWeek => 'На этой неделе';

  @override
  String homeDaysOnTarget(int count) {
    return '$count/7 дней в цели';
  }

  @override
  String get habitsEmptyDefaults =>
      'Пока нет привычек — стандартные появятся при первом входе.';

  @override
  String get homeMiniGoalTitle => 'Мини-цель сегодня';

  @override
  String get homeMiniGoalDefault => 'Добавьте белок к приёму пищи';

  @override
  String get homeAddMealLabel => 'Добавить блюдо';

  @override
  String get homeWater => 'Вода';

  @override
  String get homeWeight => 'Вес';

  @override
  String get homeMood => 'Настроение';

  @override
  String get homeAddWater => 'Вода';

  @override
  String get homeEnterWeight => 'Ввести вес';

  @override
  String get homeMoodGreat => 'Отлично';

  @override
  String get homeMoodGood => 'Хорошо';

  @override
  String get homeMoodNeutral => 'Нормально';

  @override
  String get homeMoodBad => 'Тяжело';

  @override
  String get homeMoodRough => 'Очень тяжело';

  @override
  String get homeMoodPickOne => 'Выберите';

  @override
  String get homeNoMealsTitle => 'Ещё не добавлено приёмов пищи';

  @override
  String get homeNoMealsMessage => 'Начните день, добавив первый приём пищи';

  @override
  String get homeTodayMeals => 'Сегодняшние приёмы пищи';

  @override
  String get homeMealBreakfast => 'Завтрак';

  @override
  String get homeMealLunch => 'Обед';

  @override
  String get homeMealDinner => 'Ужин';

  @override
  String get homeMealSnack => 'Перекус';

  @override
  String get homeCalorieTarget => 'цель';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target ккал цель';
  }

  @override
  String get macroProtein => 'Белок';

  @override
  String get macroCarb => 'Углеводы';

  @override
  String get macroFat => 'Жиры';

  @override
  String get homeCravingText =>
      'Тяга к чему-то? Подождите 60 секунд, сделайте глубокий вдох.';

  @override
  String get notifMealReminders => 'Напоминания о еде';

  @override
  String get notifMealRemindersDesc =>
      'Мягкое напоминание утром, в обед и вечером';

  @override
  String get notifCoachNudges => 'Подсказки тренера';

  @override
  String get notifCoachNudgesDesc =>
      'Личная поддержка и мотивационные сообщения';

  @override
  String get notifWeeklySummary => 'Недельный обзор';

  @override
  String get notifWeeklySummaryDesc =>
      'Сводка прошедшей недели в понедельник утром';

  @override
  String get notifQuietHours => 'ТИХИЕ ЧАСЫ';

  @override
  String get notifQuietHoursDesc => 'Никаких уведомлений в эти часы.';

  @override
  String get notifQuietStart => 'Начало';

  @override
  String get notifQuietEnd => 'Конец';

  @override
  String get notifSaved => 'Настройки сохранены.';

  @override
  String get notifSaveFailed => 'Не удалось сохранить.';

  @override
  String get notifLoadFailed => 'Не удалось загрузить.';

  @override
  String get coachSettingsTitle => 'Тренер';

  @override
  String get coachSettingsQuestion => 'Как должен говорить с вами тренер?';

  @override
  String get coachSettingsSubtitle => 'Можете изменить в любое время.';

  @override
  String get onboardingMoreMeasures => 'Ещё несколько измерений';

  @override
  String get onboardingActivityLevel => 'Ваш уровень активности';

  @override
  String get onboardingFirstMeal => 'Добавим первый приём пищи';

  @override
  String get onboardingGoToHome => 'Перейти на главную';

  @override
  String get onboardingBirthYear => 'Год рождения';

  @override
  String get onboardingGender => 'Пол';

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
  String get supportHowHelp => 'Чем мы можем помочь?';

  @override
  String get supportEmailCard => 'Связаться по e-mail';

  @override
  String get supportFaq => 'Частые вопросы';

  @override
  String get supportFaqDesc => 'Часто задаваемые вопросы и ответы';

  @override
  String get aiBlockFood => 'Распознавание еды';

  @override
  String get aiBlockFoodBody =>
      'Я анализирую ваше фото и оцениваю калории/нутриенты. Это не точное измерение.';

  @override
  String get aiBlockCoach => 'Ответы тренера';

  @override
  String get aiBlockCoachBody =>
      'Я генерирую короткие, без осуждения, поддерживающие сообщения. Я не предоставляю медицинских советов.';

  @override
  String get aiBlockSafety => 'Безопасность';

  @override
  String get aiBlockSafetyBody =>
      'В рискованных ситуациях я показываю ресурсы профессиональной поддержки. В кризисе — направляю к специалистам.';

  @override
  String get aiBlockData => 'Ваши данные';

  @override
  String get aiBlockDataBody =>
      'Ваши данные передаются зашифрованно, доступ только у вас. Вы можете удалить их в любой момент.';

  @override
  String get privacyHeading => 'Ваша безопасность — наш приоритет';

  @override
  String get privacyBody =>
      'Nuveli — приложение велнеса. Не предоставляет медицинскую диагностику или лечение.';

  @override
  String get privacyEmergency => 'Экстренная поддержка';

  @override
  String get privacyHotline =>
      'ALO 182 — Линия психологической поддержки (24/7)';

  @override
  String get privacyPolicyLink => 'Политика конфиденциальности';

  @override
  String get privacyTermsLink => 'Условия использования';

  @override
  String get privacyDownload => 'Скачать мои данные';

  @override
  String get aboutApp => 'Приложение';

  @override
  String get aboutLinks => 'Ссылки';

  @override
  String get aboutWebsite => 'Веб-сайт';

  @override
  String get aboutTechnical => 'Технические';

  @override
  String get aboutEnv => 'Среда';

  @override
  String get aboutCopyright => '© 2026 Nuveli. Все права защищены.';

  @override
  String get aboutCopied => 'скопировано';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get streakDay => 'день';

  @override
  String get streakDays => 'дней';

  @override
  String get streakLongest => 'Самая длинная серия';

  @override
  String get streakTodayDone => 'Вы сделали это сегодня';

  @override
  String streakSummary(int current) {
    return '$current день подряд';
  }

  @override
  String get streakExplanation =>
      'Ваша серия — это количество дней подряд с записями приёмов пищи.';

  @override
  String get weeklyTitle => 'Недельный обзор';

  @override
  String get weeklyLoadFailed => 'Не удалось загрузить';

  @override
  String get weeklyChartLoadFailed => 'Не удалось загрузить данные';

  @override
  String get commonRetryLow => 'Попробовать снова';

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
  String get dayDetailMealsLoadFailed => 'Не удалось загрузить приёмы пищи';

  @override
  String get dayDetailNoMeals => 'В этот день не было приёмов пищи';

  @override
  String dayDetailWaterMl(int ml) {
    return '$ml мл воды';
  }

  @override
  String get mealTypeBreakfast => 'Завтрак';

  @override
  String get mealTypeLunch => 'Обед';

  @override
  String get mealTypeDinner => 'Ужин';

  @override
  String get mealTypeSnack => 'Перекус';

  @override
  String get mealTypeOther => 'Приём пищи';

  @override
  String get weeklyMacroDist => 'Распределение макронутриентов';

  @override
  String get weeklyDailyDetail => 'По дням';

  @override
  String get weeklyCoachComment => 'КОММЕНТАРИЙ ТРЕНЕРА';

  @override
  String get weeklyCoachCommentLocked => 'Комментарий тренера';

  @override
  String get weeklyCoachCommentLockedDesc =>
      'Персональные комментарии о неделе с Премиум';

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
  String get waterHowMuch => 'Сколько вы выпили?';

  @override
  String get waterHistory => 'История';

  @override
  String get weightInvalid => 'Введите корректный вес (1-500 кг).';

  @override
  String get weightKg => 'кг';

  @override
  String get moodHowToday => 'Как вы сегодня?';

  @override
  String get mealCameraNotAvailable =>
      'Эта функция работает на реальных устройствах. Можно выбрать из галереи.';

  @override
  String get mealGallery => 'Галерея';

  @override
  String weeklyDaysLogged(int n) {
    return 'Вы записали $n дней. Хороший прогресс.';
  }

  @override
  String get coachWelcome => 'Привет! Как ты себя чувствуешь сегодня?';

  @override
  String get coachInputPlaceholder => 'Введите сообщение...';

  @override
  String get coachLoadFailed => 'Не удалось загрузить.';

  @override
  String get coachSendFailed => 'Не удалось отправить сообщение.';

  @override
  String get coachLimitTitle => 'Дневной лимит';

  @override
  String coachLimitBody(String reason) {
    return '$reason\n\nС Премиум — безлимитный чат с тренером и голосовые ответы.';
  }

  @override
  String get coachLater => 'Позже';

  @override
  String get coachSeePremium => 'Смотреть Премиум';

  @override
  String get coachCrisisTitle => 'Вы не одни';

  @override
  String get coachDistressTitle => 'У вас может быть тяжёлый момент';

  @override
  String get coachCrisisBody =>
      'Мы хотим быть рядом, но обращение к специалисту для надлежащей поддержки — лучший шаг.';

  @override
  String get coachDistressBody =>
      'Ваш тренер не может помочь в таких ситуациях. Обратиться к кому-то, кому доверяете, — важно.';

  @override
  String get mealAddTitle => 'Добавить блюдо';

  @override
  String get mealPhotoOrDesc => 'Фото или описание';

  @override
  String get mealNoPhoto => 'Фото не добавлено';

  @override
  String get mealCamera => 'Камера';

  @override
  String get mealGalleryBtn => 'Галерея';

  @override
  String get mealSimulatorWarn =>
      'Нет камеры в Симуляторе. Используйте Галерею.';

  @override
  String get mealDescHint =>
      'Опишите еду:\n• Что? (напр. куриная грудка)\n• Сколько? (напр. 200г, 1 порция)\n• С чем? (напр. хлеб, рис)';

  @override
  String get mealAnalyze => 'Анализировать';

  @override
  String get mealManualEntry => 'Ввести вручную';

  @override
  String get mealAnalyzeFailed => 'Не удалось проанализировать.';

  @override
  String get mealLimitTitle => 'Дневной лимит достигнут';

  @override
  String mealLimitBody(String reason) {
    return '$reason\n\nС Премиум — безлимитный анализ фото.';
  }

  @override
  String get waterHistoryTitle => 'История воды';

  @override
  String get weightHistoryTitle => 'История веса';

  @override
  String get monthJan => 'Январь';

  @override
  String get monthFeb => 'Февраль';

  @override
  String get monthMar => 'Март';

  @override
  String get monthApr => 'Апрель';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJun => 'Июнь';

  @override
  String get monthJul => 'Июль';

  @override
  String get monthAug => 'Август';

  @override
  String get monthSep => 'Сентябрь';

  @override
  String get monthOct => 'Октябрь';

  @override
  String get monthNov => 'Ноябрь';

  @override
  String get monthDec => 'Декабрь';

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
  String get profileLoadFailed => 'Не удалось загрузить профиль.';

  @override
  String get profileAccount => 'АККАУНТ';

  @override
  String get profilePersonalInfo => 'Личная информация';

  @override
  String get profilePersonalInfoSub => 'Имя, цели, информация о теле';

  @override
  String get profileGoals => 'Цели';

  @override
  String get profileGoalsSub => 'Цели по калориям и макронутриентам';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileNotifPrefs => 'Настройки уведомлений';

  @override
  String get profileNotifPrefsSub => 'Напоминания и тихие часы';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileDarkTheme => 'Тёмная тема';

  @override
  String get profileDarkThemeSub => 'Активна (по умолчанию)';

  @override
  String get profilePremium => 'ПРЕМИУМ';

  @override
  String get profilePremiumSub => 'План, оплата и функции';

  @override
  String get profilePremiumMy => 'Моя Премиум-подписка';

  @override
  String get profileHelpSafety => 'Помощь и безопасность';

  @override
  String get profileSupport => 'Поддержка';

  @override
  String get profileSupportSub => 'Вопросы и обратная связь';

  @override
  String get profileHowAi => 'Как работает ИИ';

  @override
  String get profilePrivacy => 'Конфиденциальность и безопасность';

  @override
  String get profileAbout => 'О Nuveli';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileSignOutConfirm => 'Выйти';

  @override
  String get homeGreetingNoonTime => 'Добрый день';

  @override
  String get profileStreakNow => 'Текущая';

  @override
  String get profileStreakLongest => 'Самая длинная';

  @override
  String get profileStreakDay => 'день';

  @override
  String get personalInfoTitle => 'Личная информация';

  @override
  String get personalInfoEdit => 'Редактировать';

  @override
  String get personalInfoSaved => 'Сохранено';

  @override
  String get personalInfoSaveFailed => 'Не удалось сохранить';

  @override
  String get personalInfoLoadFailed => 'Не удалось загрузить';

  @override
  String get personalInfoSecAccount => 'Аккаунт';

  @override
  String get personalInfoSecBody => 'Информация о теле';

  @override
  String get personalInfoSecActivity => 'Активность';

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
  String get personalInfoHeightCm => 'Рост (см)';

  @override
  String get personalInfoWeight => 'Вес';

  @override
  String get personalInfoWeightKg => 'Вес (кг)';

  @override
  String get personalInfoActivityLevel => 'Дневной уровень активности';

  @override
  String get personalInfoActivityLevelLabel => 'Уровень активности';

  @override
  String get personalInfoCancel => 'Отмена';

  @override
  String get personalInfoSave => 'Сохранить';

  @override
  String get personalInfoSaving => 'Сохранение...';

  @override
  String get genderFemale => 'Женский';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderOther => 'Другой';

  @override
  String get activitySedentary => 'Малоподвижный';

  @override
  String get activitySedentaryFull => 'Малоподвижный (сидячая работа)';

  @override
  String get activityLight => 'Лёгкая активность';

  @override
  String get activityLightFull => 'Лёгкая активность (1-3 дня)';

  @override
  String get activityModerate => 'Умеренная активность';

  @override
  String get activityModerateFull => 'Умеренная активность (3-5 дней)';

  @override
  String get activityActive => 'Активный';

  @override
  String get activityActiveFull => 'Активный (6-7 дней)';

  @override
  String get activityVeryActive => 'Очень активный';

  @override
  String get activityVeryActiveFull => 'Очень активный (атлет)';

  @override
  String get goalsTitle => 'Цели';

  @override
  String get goalsUpdated => 'Цели обновлены';

  @override
  String get goalsLoadFailed => 'Не удалось загрузить';

  @override
  String get goalsSaveFailed => 'Не удалось сохранить';

  @override
  String get goalsSecPurpose => 'Цель';

  @override
  String get goalsSecDailyCalorie => 'Дневная цель калорий';

  @override
  String get goalsSecMacroDist => 'Рекомендуемое распределение макронутриентов';

  @override
  String get goalsLoseWeight => 'Похудеть';

  @override
  String get goalsLoseWeightDesc => 'Постепенное снижение с дефицитом калорий';

  @override
  String get goalsMaintain => 'Поддерживать вес';

  @override
  String get goalsMaintainDesc => 'Поддержание текущего веса';

  @override
  String get goalsGainMuscle => 'Набрать мышечную массу';

  @override
  String get goalsGainMuscleDesc => 'Набор с профицитом калорий';

  @override
  String get goalsMacroNote => 'Макронутриенты рассчитываются автоматически';

  @override
  String get goalsSave => 'Сохранить';

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

  @override
  String get verifyEmailTitle => 'Подтверди Email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Мы отправили ссылку подтверждения на $email. Нажми на ссылку, чтобы продолжить автоматически.';
  }

  @override
  String get verifyEmailWaitingTitle => 'Ожидание email...';

  @override
  String get verifyEmailWaitingBody =>
      'Ты не можешь продолжить без нажатия на ссылку в письме. Проверь также папку спам.';

  @override
  String get verifyEmailResend => 'Отправить снова';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Отправить снова ($secondsс)';
  }

  @override
  String get verifyEmailResent => 'Новое письмо подтверждения отправлено.';

  @override
  String get verifyEmailSignOut => 'Другой email / Выйти';

  @override
  String get coachBubbleGentleMealUnder =>
      'Бережно записано. На сегодня ещё есть запас, без спешки.';

  @override
  String get coachBubbleGentleMealOver =>
      'Записано. Один приём пищи не определяет твой день. Будь добр к себе.';

  @override
  String get coachBubbleGentleMealOnTrack =>
      'Сегодня хороший баланс. Ты слышишь своё тело.';

  @override
  String get coachBubbleGentleWaterLow =>
      'Немного воды сейчас было бы кстати, когда будешь готов.';

  @override
  String get coachBubbleGentleStreakMilestone =>
      'Ты мягко появляешься каждый день. Это дорогого стоит.';

  @override
  String get coachBubbleGentleFirstMeal =>
      'Первый приём пищи внесён. Мягкое, спокойное начало дня.';

  @override
  String get coachBubbleFunnyMealUnder =>
      'Записано! Полоса ещё свободна — вилка готова к взлёту.';

  @override
  String get coachBubbleFunnyMealOver =>
      'Большая еда — большая радость. Завтра новая вкусная глава.';

  @override
  String get coachBubbleFunnyMealOnTrack =>
      'Поцелуй шефа. Ты и баланс теперь лучшие друзья.';

  @override
  String get coachBubbleFunnyWaterLow =>
      'Твоя бутылка с водой чувствует себя забытой. Просто говорю.';

  @override
  String get coachBubbleFunnyStreakMilestone =>
      'Серия держится крепко — кто-то на ходу!';

  @override
  String get coachBubbleFunnyFirstMeal =>
      'Клуб завтраков на связи. День начинается вкусно.';

  @override
  String get coachBubbleDirectMealUnder =>
      'Записано. Есть запас на остаток дня — спланируй с умом.';

  @override
  String get coachBubbleDirectMealOver =>
      'Записано, немного больше. Без драмы — поправь следующие приёмы пищи.';

  @override
  String get coachBubbleDirectMealOnTrack =>
      'Записано. Точно в графике. Держи ритм.';

  @override
  String get coachBubbleDirectWaterLow =>
      'Вода сегодня отстаёт. Возьми стакан.';

  @override
  String get coachBubbleDirectStreakMilestone =>
      'Серия держится. Работает постоянство.';

  @override
  String get coachBubbleDirectFirstMeal =>
      'Первый приём пищи записан. Хорошо — задай тон дню.';

  @override
  String get coachBubbleCalmMealUnder =>
      'Отмечено. Впереди есть пространство. Двигайся в своём темпе.';

  @override
  String get coachBubbleCalmMealOver =>
      'Отмечено. Важна осознанность. Следующий приём пищи — твой.';

  @override
  String get coachBubbleCalmMealOnTrack =>
      'Отмечено. Ровно и спокойно — неспешный прогресс.';

  @override
  String get coachBubbleCalmWaterLow =>
      'Воды немного мало. Без давления — пей, когда удобно.';

  @override
  String get coachBubbleCalmStreakMilestone =>
      'Тихое постоянство, день за днём. Это важно.';

  @override
  String get coachBubbleCalmFirstMeal =>
      'Первый приём пищи отмечен. Спокойное начало дня.';

  @override
  String get mealHistoryTitle => 'История приёмов пищи';

  @override
  String get historyYesterday => 'Вчера';

  @override
  String get mealHistoryEmptyTitle => 'Пока нет записей о приёмах пищи';

  @override
  String get mealHistoryEmptyBody =>
      'Записанные приёмы пищи появятся здесь, сгруппированные по дням.';

  @override
  String get settingsCoachSection => 'Тренер';

  @override
  String get settingsYourData => 'Твои данные';

  @override
  String get settingsExportData => 'Экспортировать мои данные';

  @override
  String get settingsExportDataDesc =>
      'Скачай все приёмы пищи, воду, вес, привычки и инсайты в JSON. Право на переносимость данных (GDPR ст. 20).';

  @override
  String get settingsExportFailed => 'Не удалось экспортировать данные.';

  @override
  String get settingsDeleteDesc =>
      'Безвозвратно удаляет профиль, приёмы пищи и все данные.';

  @override
  String get settingsDeleteTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteConfirmBody =>
      'Это безвозвратно удалит профиль, все приёмы пищи, воду, историю веса, привычки и подписки. Отменить нельзя.';

  @override
  String get settingsDeleteType => 'Введите DELETE для подтверждения:';

  @override
  String get settingsDeleteFailed => 'Не удалось удалить аккаунт.';

  @override
  String get settingsLanguageItalian => 'Итальянский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get coachTodaysTips => 'Советы на сегодня';

  @override
  String get coachNutritionScore => 'Оценка питания';

  @override
  String get coachScoreHigh => 'Отличный день — продолжай в том же духе.';

  @override
  String get coachScoreMid =>
      'В целом по плану. Небольшая поправка многое изменит.';

  @override
  String get coachScoreMixed =>
      'Смешанные сигналы — сосредоточимся сегодня на одном.';

  @override
  String get coachScoreReset =>
      'Поможет мягкая перезагрузка. Выбери совет ниже.';

  @override
  String get coachOfflineTitle => 'Тренер офлайн';

  @override
  String get coachRegenerate => 'Обновить';

  @override
  String get coachRegenerateUpgrade => 'Перейдите на Premium для обновления';

  @override
  String get coachRegenerateFree => 'Обновить (1 бесплатно/день)';

  @override
  String get coachEmptyTitle => 'Ваш коуч готовится';

  @override
  String get coachEmptyBody =>
      'Добавьте первый приём пищи сегодня, и коуч подготовит для вас ежедневные советы и аналитику.';

  @override
  String get paywallNoPackages =>
      'Сейчас нет доступных пакетов подписки. Проверьте соединение и попробуйте снова.';

  @override
  String get coachScoreExcellent => 'Отлично';

  @override
  String get coachScoreOnTrack => 'По плану';

  @override
  String get coachScoreImprove => 'Можно лучше';

  @override
  String get coachScoreNeedsCare => 'Нужна забота';

  @override
  String get coachRecommendedStep => 'Рекомендуемый следующий шаг';

  @override
  String get coachActionHabitAdded => 'Привычка добавлена';

  @override
  String get coachActionWaterLogged => 'Вода записана';

  @override
  String get coachActionReminderSet => 'Напоминание установлено';

  @override
  String get coachActionTargetUpdated => 'Цель обновлена';

  @override
  String get coachActionDone => 'Готово';

  @override
  String get homeOpenSettings => 'Открыть настройки';

  @override
  String get homeAddFood => 'Добавить еду';

  @override
  String get homeSeeAll => 'Показать все';

  @override
  String get homeMealNameQuestion => 'Что ты ел(а)?';

  @override
  String get homeMealNameHint => 'напр. греческий йогурт с ягодами';

  @override
  String get homeCaloriesHint => 'напр. 180';

  @override
  String get homeCaloriesKcal => 'Калории (ккал)';

  @override
  String get macroProteinG => 'Белки (г)';

  @override
  String get macroCarbsG => 'Углеводы (г)';

  @override
  String get macroFatG => 'Жиры (г)';

  @override
  String get homeSaveMeal => 'Сохранить приём пищи';

  @override
  String get homeFoodNameRequired => 'Укажите название еды';

  @override
  String get homeCaloriesRequired => 'Введите значение калорий (> 0)';

  @override
  String get homeSaveFailed => 'Не удалось сохранить приём пищи.';

  @override
  String get homeWaterLogFailed =>
      'Не удалось записать воду. Нажми, чтобы повторить.';

  @override
  String get homePlannerCtaTitle => 'Спланируй неделю';

  @override
  String get homePlannerCtaSubtitle => 'Планы питания + список покупок';

  @override
  String get homeNoMealsScanHint =>
      'Нажми \"Добавить еду\" ниже, чтобы записать первый приём пищи';

  @override
  String get mealScanScreenTitle => 'ИИ-сканер блюд';

  @override
  String get mealScanIdleTitle => 'Сфотографируйте блюдо';

  @override
  String get mealScanIdleSubtitle =>
      'Направьте камеру на тарелку. ИИ Nuveli оценит калории и макросы за несколько секунд.';

  @override
  String get mealScanTakePhoto => 'Сделать фото';

  @override
  String get mealScanChooseGallery => 'Выбрать из галереи';

  @override
  String mealScanScansLeft(int remaining, int total) {
    return '$remaining/$total сканов сегодня';
  }

  @override
  String get mealScanUnlimited => 'Безлимит';

  @override
  String get mealScanNameLabel => 'Название приёма пищи';

  @override
  String get mealScanAnalyzingStep1 => 'Анализируем блюдо...';

  @override
  String get mealScanAnalyzingStep2 => 'Распознаём продукты...';

  @override
  String get mealScanAnalyzingStep3 => 'Оцениваем порции...';

  @override
  String get mealScanAnalyzingStep4 => 'Рассчитываем макросы...';

  @override
  String get mealScanAnalyzingStep5 => 'Почти готово...';

  @override
  String get mealScanSaving => 'Сохранение блюда...';

  @override
  String get mealScanRateLimitTitle =>
      'Слишком много сканирований, слишком быстро';

  @override
  String get mealScanErrorTitle => 'Ошибка сканирования';

  @override
  String get mealScanAddManuallyInstead => 'Добавить вручную';

  @override
  String get mealScanNotFoodTitle => 'Хмм, еду не вижу';

  @override
  String get mealScanNotFoodHint =>
      'Попробуйте сделать более чёткое фото тарелки или введите блюдо вручную.';

  @override
  String get mealScanTryAnotherPhoto => 'Попробовать другое фото';

  @override
  String get mealScanAddManually => 'Добавить вручную';

  @override
  String get mealScanRetake => 'Переснять';

  @override
  String mealScanConfidentScore(int score) {
    return '$score% уверенности';
  }

  @override
  String get mealScanDetectedFoods => 'Обнаруженные продукты';

  @override
  String get mealScanPortionSize => 'Размер порции';

  @override
  String get mealScanDiscard => 'Отменить';

  @override
  String get mealScanAiTip => 'Совет ИИ';

  @override
  String get mealScanRemoveTooltip => 'Удалить';

  @override
  String get mealScanImageLoadError => 'Не удалось загрузить изображение';

  @override
  String get mealScanEditFood => 'Редактировать продукт';

  @override
  String get mealScanSaveChanges => 'Сохранить изменения';

  @override
  String get mealScanFieldName => 'Название';

  @override
  String get plannerScreenTitle => 'План питания';

  @override
  String get plannerGroceryListTooltip => 'Список покупок';

  @override
  String get plannerThisWeek => 'На этой неделе';

  @override
  String get plannerNextWeek => 'На следующей неделе';

  @override
  String get plannerLastWeek => 'На прошлой неделе';

  @override
  String plannerInWeeks(int n) {
    return 'Через $n недели';
  }

  @override
  String plannerWeeksAgo(int n) {
    return '$n недели назад';
  }

  @override
  String get plannerPrevWeekTooltip => 'Предыдущая неделя';

  @override
  String get plannerNextWeekTooltip => 'Следующая неделя';

  @override
  String plannerTotalsBanner(int kcal, int days) {
    return '$kcal ккал запланировано на $days дней';
  }

  @override
  String get plannerEmptyTitle => 'Пока нет плана на эту неделю';

  @override
  String get plannerEmptyAiHint =>
      'Ваш ИИ-тренер составит план на всю неделю за секунды.';

  @override
  String get plannerEmptyPremiumHint =>
      'Недельные ИИ-планы входят в Premium. Обновитесь для разблокировки.';

  @override
  String get plannerAddMealManually => 'Добавить блюдо вручную';

  @override
  String get plannerGenerateAiPlan => 'Создать план с ИИ';

  @override
  String get plannerUnlockAiPlan => 'Разблокировать создание плана с ИИ';

  @override
  String get plannerPremiumFeature => 'Функция Premium';

  @override
  String get plannerPaywallTitle => 'Смотрите и планируйте дальше этой недели';

  @override
  String get plannerPaywallBody =>
      'Бесплатные планы охватывают текущую неделю. Обновитесь, чтобы планировать наперёд, создавать повторяющиеся планы и позволить ИИ составить целую неделю.';

  @override
  String get plannerSeePremium => 'Посмотреть Premium';

  @override
  String get plannerBackToThisWeek => 'Вернуться к этой неделе';

  @override
  String get plannerLoadError => 'Не удалось загрузить план';

  @override
  String get plannerEditNameNote => 'Изменить название / заметку';

  @override
  String get plannerRemoveFromPlan => 'Удалить из плана';

  @override
  String get plannerRemoveEntryTitle => 'Удалить запись?';

  @override
  String plannerRemoveEntryBody(String name) {
    return 'Удалить \"$name\" из этого плана?';
  }

  @override
  String get plannerRemove => 'Удалить';

  @override
  String get plannerToday => 'Сегодня';

  @override
  String plannerDayStats(int meals, int kcal) {
    return '$meals запланировано · $kcal ккал';
  }

  @override
  String get plannerAddMealTooltip => 'Добавить блюдо';

  @override
  String plannerServingsCount(String n) {
    return '$n порций';
  }

  @override
  String get plannerAddToPlan => 'Добавить в план';

  @override
  String get plannerMealName => 'Название блюда';

  @override
  String get plannerServings => 'Порции';

  @override
  String get plannerNoteOptional => 'Заметка (необязательно)';

  @override
  String get plannerMealNameRequired => 'Название блюда обязательно';

  @override
  String get plannerServingsError => 'Порции должны быть больше 0';

  @override
  String get plannerEditEntry => 'Редактировать запись';

  @override
  String get plannerEditCaloriesHint =>
      'Чтобы изменить калории или порции, удалите эту запись и добавьте снова.';

  @override
  String get plannerGenerateSubtitle =>
      'Ваш тренер составляет план на всю неделю. Настройте детали ниже — всё необязательно.';

  @override
  String get plannerDietaryPref => 'Диетические предпочтения (необязательно)';

  @override
  String get plannerAvoidIngredients => 'Избегать ингредиентов (через запятую)';

  @override
  String get plannerDailyCalorieTarget =>
      'Дневная цель по калориям (необязательно)';

  @override
  String get plannerMealsPerDay => 'Блюд в день';

  @override
  String get plannerAnythingElse => 'Что-то ещё? (необязательно)';

  @override
  String get plannerHintMealName => 'напр. Салат с курицей гриль';

  @override
  String get plannerHintCalories => 'напр. 450';

  @override
  String get plannerHintNote => 'напр. готовка на неделю в воскресенье';

  @override
  String get plannerHintEditNote => 'напр. заменить на остатки';

  @override
  String get generatePlanHintStyle =>
      'напр. высокобелковая, вегетарианская, средиземноморская';

  @override
  String get generatePlanHintAllergies => 'напр. арахис, морепродукты';

  @override
  String get generatePlanHintCalories => 'напр. 2000';

  @override
  String get generatePlanHintGoals =>
      'напр. быстрые завтраки, ужины для готовки впрок';

  @override
  String get plannerCalorieTargetError =>
      'Цель по калориям должна быть от 800 до 6000';

  @override
  String get plannerGenerating => 'Создание…';

  @override
  String get plannerGeneratePlan => 'Создать план';

  @override
  String plannerMealsCreated(int n) {
    return '$n блюд запланировано на вашу неделю.';
  }

  @override
  String get plannerGroceryList => 'Список покупок';

  @override
  String get plannerGroceryLoadError => 'Не удалось загрузить список покупок';

  @override
  String get plannerGroceryEmpty =>
      'Пока нет покупок — добавьте рецепт в план.';

  @override
  String plannerGroceryUsedIn(int n) {
    return 'Используется в $n рецептах';
  }

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsSubtitle => 'Твоя неделя с первого взгляда';

  @override
  String get analyticsErrorWeeklyBars =>
      'Не удалось загрузить недельные столбцы';

  @override
  String get analyticsErrorMacroBreakdown =>
      'Не удалось загрузить разбивку по макронутриентам';

  @override
  String get analyticsErrorWeightTrend => 'Не удалось загрузить динамику веса';

  @override
  String get analyticsLast7Days => 'Последние 7 дней';

  @override
  String analyticsDaysOnTarget(int n) {
    return '$n/7 дней в цели';
  }

  @override
  String analyticsKcalAvg(String avg) {
    return '$avg ккал среднее';
  }

  @override
  String analyticsTarget(int target) {
    return '· цель $target';
  }

  @override
  String get analyticsWeeklyEmpty =>
      'Внеси несколько приёмов пищи, чтобы увидеть недельный тренд';

  @override
  String get analyticsMacroBreakdown => 'Разбивка по макронутриентам';

  @override
  String get analytics7DayAverage => 'Среднее за 7 дней';

  @override
  String get analyticsMacroEmpty =>
      'Разбивка по макронутриентам появится после регистрации приёма пищи';

  @override
  String get analyticsMacroProtein => 'Белки';

  @override
  String get analyticsMacroCarbs => 'Углеводы';

  @override
  String get analyticsMacroFat => 'Жиры';

  @override
  String get analyticsWeightTrend => 'Динамика веса';

  @override
  String analyticsWeightTrendDays(int n) {
    return '$n дней';
  }

  @override
  String get analyticsWeightTrendEmpty =>
      'Внеси свой вес, чтобы увидеть динамику';

  @override
  String profileGreeting(String name) {
    return 'Привет, $name';
  }

  @override
  String get profileYourGoals => 'Твои цели';

  @override
  String get profileCouldNotLoad => 'Не удалось загрузить';

  @override
  String get profileCouldNotLoadSection => 'Не удалось загрузить этот раздел';

  @override
  String get profileLogWeight => 'Записать вес';

  @override
  String get profileDailyTarget => 'Дневная цель';

  @override
  String profileKcalLeftToday(String n) {
    return 'Осталось $n ккал на сегодня';
  }

  @override
  String get profileDailyTargetReached => 'Дневная цель достигнута';

  @override
  String get profileStreak => 'Серия';

  @override
  String get profileStreakDays => ' дней';

  @override
  String get profileStreakKeepGoing => 'Продолжай в том же духе!';

  @override
  String get profileStreakStartToday =>
      'Внеси приём пищи сегодня, чтобы начать';

  @override
  String get profileCaloriesVsTarget => 'Калории и цель';

  @override
  String get profileProgressLast7Days => 'Последние 7 дней';

  @override
  String get profileAvg => 'Среднее';

  @override
  String get profileWithinTarget => 'В пределах цели';

  @override
  String get profileOffTarget => 'Вне цели';

  @override
  String profileDaysHit(int n) {
    return '$n/7 дней в цели';
  }

  @override
  String get profileProgressNoData => 'Данных пока нет';

  @override
  String get profileProgressNoDataHint =>
      'Вноси приёмы пищи несколько дней — тренд появится здесь.';

  @override
  String get profileRecommendedTitle => 'Рекомендовано для тебя';

  @override
  String get profileRecommendedSubtitle =>
      'Персонализированные советы для достижения твоих целей';

  @override
  String get profileRec1Title => 'Пей воду перед едой';

  @override
  String get profileRec1Desc =>
      'Помогает контролировать порции и поддерживать гидратацию.';

  @override
  String get profileRec2Title => 'Добавь 30-минутную прогулку';

  @override
  String get profileRec2Desc => 'Простой способ достичь своего дневного TDEE.';

  @override
  String get profileRec3Title => 'Спи 7–8 часов';

  @override
  String get profileRec3Desc =>
      'Лучшее восстановление, лучший контроль аппетита.';

  @override
  String get profileWeightGoal => 'Цель по весу';

  @override
  String get profileLogWeightToSeeTrend => 'Запиши вес, чтобы увидеть динамику';

  @override
  String profileProgressPercent(String n) {
    return '$n% выполнено';
  }

  @override
  String get profileSetWeightGoal => 'Установи\nцель по весу';

  @override
  String get profileTapToStartTracking => 'Нажми, чтобы начать отслеживание';

  @override
  String get profileSetWeightGoalTitle => 'Установи цель по весу';

  @override
  String get profileSetWeightGoalSubtitle =>
      'Мы будем отслеживать твой прогресс и корректировать рекомендации.';

  @override
  String get profileGoalType => 'ТИП ЦЕЛИ';

  @override
  String get profileGoalLose => 'Похудеть';

  @override
  String get profileGoalMaintain => 'Удержать';

  @override
  String get profileGoalGain => 'Набрать';

  @override
  String get profileStartingWeight => 'Начальный вес';

  @override
  String get profileTargetWeight => 'Целевой вес';

  @override
  String get profileMaintainWeightAt => 'Удерживать вес на уровне';

  @override
  String get profileTargetDate => 'Целевая дата';

  @override
  String get profileChooseDate => 'Выбери дату';

  @override
  String get profileSaveGoal => 'Сохранить цель';

  @override
  String get profileGoalErrorTarget => 'Введи целевой вес от 20 до 400 кг';

  @override
  String get profileGoalErrorStart => 'Введи начальный вес от 20 до 400 кг';

  @override
  String get profileGoalErrorLoseLower =>
      'Целевой вес должен быть ниже начального';

  @override
  String get profileGoalErrorGainHigher =>
      'Целевой вес должен быть выше начального';

  @override
  String get profileGoalSaveError =>
      'Не удалось сохранить. Проверь соединение и попробуй снова.';

  @override
  String get profileLogWeightTitle => 'Записать свой вес';

  @override
  String get profileLogWeightSubtitle => 'Отслеживай свой прогресс к цели';

  @override
  String get profileWeightLabel => 'Вес';

  @override
  String get profileWeightNoteOptional => 'Заметка (необязательно)';

  @override
  String get profileWeightNoteHint => 'После тренировки, утром и т.д.';

  @override
  String get profileWeightError => 'Введи вес от 20 до 400 кг';

  @override
  String get profileSaveWeight => 'Сохранить вес';

  @override
  String profileWeightSaving(String kg) {
    return 'Сохранение $kg кг...';
  }

  @override
  String profileWeightSaved(String kg) {
    return 'Вес сохранён ($kg кг)';
  }

  @override
  String profileWeightSaveFailed(String kg) {
    return 'Не удалось сохранить $kg кг';
  }

  @override
  String get profileWeightSavedShort => 'Вес сохранён';

  @override
  String get profileWeightStillFailed => 'По-прежнему не удаётся сохранить';

  @override
  String get profileEditTitle => 'Редактировать профиль';

  @override
  String get profileEditName => 'Имя';

  @override
  String get profileEditNameHint => 'Твоё имя';

  @override
  String get profileEditSex => 'Пол';

  @override
  String get profileEditDob => 'Дата рождения';

  @override
  String get profileEditSelectDate => 'Выбрать дату';

  @override
  String get profileEditHeightCm => 'Рост (см)';

  @override
  String get profileEditWeightKg => 'Вес (кг)';

  @override
  String get profileEditActivityLevel => 'Уровень активности';

  @override
  String get profileEditDietaryPref => 'Пищевые предпочтения';

  @override
  String get profileEditUpdated => 'Профиль обновлён';

  @override
  String get welcomeGetStarted => 'Начать';

  @override
  String get loginWelcomeBack => 'С возвращением';

  @override
  String get loginSubtitle => 'Войди, чтобы продолжить путь';

  @override
  String get loginForgotPasswordFull => 'Забыли пароль?';

  @override
  String get loginSignIn => 'Войти';

  @override
  String get loginDontHaveAccount => 'Нет аккаунта?';

  @override
  String get loginSignUp => 'Зарегистрироваться';

  @override
  String get signupCreateAccount => 'Создать аккаунт';

  @override
  String get signupNutritionJourney => 'Начнём твой путь к правильному питанию';

  @override
  String get signupConfirmPassword => 'Подтвердите пароль';

  @override
  String get signupTermsAgree => 'Я принимаю ';

  @override
  String get signupTermsOfService => 'Условия использования';

  @override
  String get signupTermsAnd => ' и ';

  @override
  String get signupPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get signupAcceptTermsError => 'Примите условия, чтобы продолжить.';

  @override
  String get signupAlreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signupSignIn => 'Войти';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Введите email, и мы отправим ссылку для сброса пароля.';

  @override
  String get forgotPasswordSendLink => 'Отправить ссылку для сброса';

  @override
  String get forgotPasswordRemember => 'Вспомнили пароль?';

  @override
  String get forgotPasswordCheckEmail => 'Проверьте почту';

  @override
  String forgotPasswordSentLink(String email) {
    return 'Ссылка для сброса пароля отправлена на\n$email';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Вернуться ко входу';

  @override
  String get verifyEmailSentLinkTo => 'Ссылка для подтверждения отправлена на:';

  @override
  String get verifyEmailOpenOnDevice =>
      'Откройте на этом устройстве, чтобы продолжить.';

  @override
  String get verifyEmailResendEmail => 'Отправить снова';

  @override
  String verifyEmailResendInSeconds(int seconds) {
    return 'Отправить снова через $seconds с';
  }

  @override
  String get verifyEmailWrongEmail => 'Неверный email?';

  @override
  String get verifyEmailGoBack => 'Назад';

  @override
  String get resetPasswordTitle => 'Установить новый пароль';

  @override
  String get resetPasswordSubtitle =>
      'Выберите надёжный пароль для своего аккаунта.';

  @override
  String get resetPasswordNewPassword => 'Новый пароль';

  @override
  String get resetPasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get resetPasswordUpdate => 'Обновить пароль';

  @override
  String get resetPasswordUpdated => 'Пароль обновлён';

  @override
  String get resetPasswordCanNowSignIn => 'Теперь можно войти с новым паролем.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingSignOutTooltip => 'Выйти';

  @override
  String get onboardingSignOutTitle => 'Выйти?';

  @override
  String get onboardingSignOutBody =>
      'Прогресс сохранён. Настройку можно продолжить позже.';

  @override
  String get onboardingCompleteStepsError =>
      'Выполните все шаги перед продолжением.';

  @override
  String get onboardingSaveError =>
      'Не удалось сохранить профиль. Попробуйте ещё раз.';

  @override
  String get onboardingStep1Title => 'Привет! Давайте познакомимся';

  @override
  String get onboardingStep1Body =>
      'Мы настроим ваш нутриционный коучинг с учётом вашего тела, образа жизни и целей. Это займёт всего минуту.';

  @override
  String get onboardingStep2Title => 'Расскажите о себе';

  @override
  String get onboardingStep2Subtitle =>
      'Это поможет рассчитать ваши ежедневные потребности.';

  @override
  String get onboardingYourName => 'Ваше имя';

  @override
  String get onboardingNameHint => 'Как нам вас называть?';

  @override
  String get onboardingNameRequired => 'Имя обязательно';

  @override
  String get onboardingDateOfBirth => 'Дата рождения';

  @override
  String get onboardingSelectDate => 'Выберите дату';

  @override
  String get onboardingSelectDob => 'Выберите дату рождения';

  @override
  String get onboardingSelectGender => 'Выберите пол';

  @override
  String get onboardingStep3Title => 'Параметры тела';

  @override
  String get onboardingStep3Subtitle =>
      'Не волнуйтесь, их можно обновить в любое время.';

  @override
  String get onboardingHeight => 'Рост';

  @override
  String get onboardingCurrentWeight => 'Текущий вес';

  @override
  String get onboardingStep4Title => 'Ваши цели';

  @override
  String get onboardingStep4Subtitle =>
      'Мы настроим ваши ежедневные цели соответственно.';

  @override
  String get onboardingActivityLevelLabel => 'Уровень активности';

  @override
  String get onboardingYourGoalLabel => 'Ваша цель';

  @override
  String get onboardingTargetWeight => 'Целевой вес';

  @override
  String get onboardingTargetDateLabel => 'Целевая дата';

  @override
  String get onboardingTargetDatePick => 'Выбрать дату';

  @override
  String get onboardingPaceHealthy => 'Здоровый, устойчивый темп 👍';

  @override
  String onboardingPaceAggressive(int weeks) {
    return 'Это быстрый темп. Для более стойкого результата советуем около $weeks недель.';
  }

  @override
  String get onboardingPaceUseSuggested => 'Использовать предложенную дату';

  @override
  String get onboardingToLose => 'сбросить';

  @override
  String get onboardingToGain => 'набрать';

  @override
  String get onboardingSelectActivityError => 'Выберите уровень активности';

  @override
  String get onboardingSelectGoalError => 'Выберите цель';

  @override
  String get onboardingStep5Title => 'Ваши ежедневные цели';

  @override
  String get onboardingStep5Subtitle =>
      'Персонализировано под ваше тело, образ жизни и цель.';

  @override
  String get onboardingDailyCalories => 'ДНЕВНЫЕ КАЛОРИИ';

  @override
  String get onboardingMacros => 'Макросы';

  @override
  String get onboardingProtein => 'Белок';

  @override
  String get onboardingCarbs => 'Углеводы';

  @override
  String get onboardingFat => 'Жиры';

  @override
  String get onboardingDailyWater => 'Ежедневная вода';

  @override
  String get onboardingCompleteSetup => 'Завершить настройку';

  @override
  String get onboardingAdjustAnytime =>
      'Их можно изменить в любое время в Настройках.';

  @override
  String get authContinueWithApple => 'Продолжить с Apple';

  @override
  String get authContinueWithGoogle => 'Продолжить с Google';

  @override
  String get authValidatorEmailRequired => 'Email обязателен';

  @override
  String get authValidatorEmailInvalid => 'Введите корректный email';

  @override
  String get authValidatorPasswordRequired => 'Пароль обязателен';

  @override
  String get authValidatorPasswordLength => 'Не менее 8 символов';

  @override
  String get authValidatorPasswordNumber => 'Включите хотя бы одну цифру';

  @override
  String get authValidatorPasswordSimpleLength => 'Не менее 6 символов';

  @override
  String get authValidatorConfirmRequired => 'Подтвердите пароль';

  @override
  String get authValidatorPasswordsNoMatch => 'Пароли не совпадают';

  @override
  String get passwordStrengthWeak => 'Слабый';

  @override
  String get passwordStrengthFair => 'Средний';

  @override
  String get passwordStrengthStrong => 'Надёжный';

  @override
  String get passwordStrengthVeryStrong => 'Очень надёжный';

  @override
  String get passwordStrengthSuggestLength => 'Используйте не менее 8 символов';

  @override
  String get passwordStrengthSuggestNumber => 'Добавьте цифру';

  @override
  String get passwordStrengthSuggestCase =>
      'Используйте заглавные и строчные буквы';

  @override
  String get passwordStrengthSuggestSymbol => 'Добавьте символ (!@#\\\$%)';

  @override
  String get authOrDivider => 'или';

  @override
  String get navDashboard => 'Главная';

  @override
  String get navScan => 'Скан';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get homeTodaySummary => 'Сводка за сегодня';

  @override
  String homeKcalRemaining(String count) {
    return 'осталось $count ккал';
  }

  @override
  String homeKcalOver(String count) {
    return '$count ккал сверх';
  }

  @override
  String homeOfKcalTarget(String count) {
    return 'из $count ккал';
  }

  @override
  String homeOfGlasses(String count) {
    return 'из $count стаканов';
  }

  @override
  String get recipeBrowserTitle => 'Просмотр рецептов';

  @override
  String get recipeBrowserSearchHint => 'Поиск рецептов…';

  @override
  String get recipeBrowserEmpty => 'Рецепты не найдены';

  @override
  String get recipeBrowserEmptyHint =>
      'Библиотека рецептов скоро пополнится. Вы можете добавлять блюда вручную.';

  @override
  String get recipeBrowserLoadError => 'Не удалось загрузить рецепты';

  @override
  String recipeBrowserCaloriesPerServing(int n) {
    return '$n ккал / порция';
  }

  @override
  String get recipeBrowserProtein => 'Белки';

  @override
  String get recipeBrowserCarbs => 'Углеводы';

  @override
  String get recipeBrowserFat => 'Жиры';

  @override
  String get recipeBrowserAddToPlan => 'Добавить в план';

  @override
  String get recipeBrowserServingsLabel => 'Порции';

  @override
  String get recipeBrowserMealType => 'Тип приёма пищи';

  @override
  String get recipeBrowserDay => 'День';

  @override
  String get recipeBrowserAdded => 'Добавлено в план';

  @override
  String get recipeBrowserAddFailed => 'Не удалось добавить в план';

  @override
  String get habitUpdateFailed => 'Не удалось обновить привычку';

  @override
  String get notifScreenTitle => 'Уведомления';

  @override
  String get notifOpenSystemSettingsTitle => 'Открыть системные настройки?';

  @override
  String get notifOpenSystemSettingsBody =>
      'Вы отклонили уведомления. Откройте Настройки, чтобы включить их снова.';

  @override
  String get notifOpenSettings => 'Открыть Настройки';

  @override
  String get notifAllNotifications => 'Все уведомления';

  @override
  String get notifMasterSwitch => 'Включить уведомления Nuveli';

  @override
  String get notifMasterSwitchDesc => 'Главный переключатель для всего ниже.';

  @override
  String get notifWaterSection => 'Вода';

  @override
  String get notifWaterMorning => 'Утро · 9:00';

  @override
  String get notifWaterMorningDesc => 'Начните гидратацию.';

  @override
  String get notifWaterAfternoon => 'День · 13:00';

  @override
  String get notifWaterAfternoonDesc => 'Напоминание в середине дня.';

  @override
  String get notifWaterEvening => 'Вечер · 18:30';

  @override
  String get notifWaterEveningDesc => 'Вечерний глоток.';

  @override
  String get notifMealsSection => 'Приёмы пищи';

  @override
  String get notifMealsTitle => 'Напоминания об обеде и ужине';

  @override
  String get notifMealsDesc => 'Напоминания в 12:30 и 19:00.';

  @override
  String get notifHabitsSection => 'Привычки';

  @override
  String get notifHabitsTitle => 'Напоминания о привычках';

  @override
  String get notifHabitsDesc =>
      'Напоминания в выбранное время для каждой привычки.';

  @override
  String get notifSleepSection => 'Сон';

  @override
  String get notifSleepTitle => 'Напоминание перед сном';

  @override
  String get notifSleepDesc => 'За 30 минут до времени сна.';

  @override
  String get notifBedtime => 'Время сна';

  @override
  String get notifCoachingSection => 'Коучинг';

  @override
  String get notifStreakTitle => 'Предупреждение о серии';

  @override
  String get notifStreakDesc =>
      'Напоминание в 21:00, если вы не записали сегодня.';

  @override
  String get notifAiInsightTitle => 'Совет ИИ готов';

  @override
  String get notifAiInsightDesc =>
      'Утреннее уведомление, когда коучинг обновлён.';

  @override
  String get notifWeeklyRecapTitle => 'Еженедельная сводка';

  @override
  String get notifWeeklyRecapDesc => 'Сводка в воскресенье в 20:00.';

  @override
  String get notifPermissionOff => 'Уведомления отключены';

  @override
  String get notifPermissionDenied => 'Включите их в системных настройках.';

  @override
  String get notifPermissionNotAsked =>
      'Мы отправим только то, что вы выберете ниже.';

  @override
  String get notifPermissionAllow => 'Разрешить';

  @override
  String get notifPermissionSettings => 'Настройки';

  @override
  String get notifTestButton => 'Отправить тестовое уведомление (10с)';

  @override
  String get notifTestScheduled =>
      'Тестовое уведомление запланировано через 10 с.';

  @override
  String get coachActionAddMeal => 'Добавить приём пищи';

  @override
  String get coachActionSetReminder => 'Установить напоминание';

  @override
  String get coachActionAddHabit => 'Добавить привычку';

  @override
  String get coachActionLogWater => 'Записать воду';

  @override
  String get coachActionUpdateTarget => 'Обновить цель';

  @override
  String get coachActionApply => 'Применить';

  @override
  String get exercise => 'Activity';

  @override
  String exerciseTodayActive(int minutes) {
    return 'You were active for $minutes min today 💪';
  }

  @override
  String get exerciseGreatMoving => 'Moving feels great!';

  @override
  String get exerciseNoneToday => 'How about a little movement today?';

  @override
  String exerciseSessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get exerciseLogTitle => 'Добавить активность';

  @override
  String get exerciseActivityType => 'Тип активности';

  @override
  String get exerciseDurationMinutes => 'Длительность (мин)';

  @override
  String get exerciseDurationHint => 'напр. 30';

  @override
  String get exerciseIntensityOptional => 'Интенсивность (необязательно)';

  @override
  String get exerciseNoteOptional => 'Заметка (необязательно)';

  @override
  String get exerciseNoteHint => 'напр. прогулка в парке';

  @override
  String get exerciseSave => 'Сохранить активность';

  @override
  String get exerciseDurationRequired => 'Укажи длительность (больше 0 минут)';

  @override
  String get exerciseSaveFailed =>
      'Не удалось сохранить активность. Нажми, чтобы повторить.';

  @override
  String get exerciseSaved => 'Отличная работа! Твоя активность записана 💪';

  @override
  String get exerciseTypeWalking => 'Ходьба';

  @override
  String get exerciseTypeRunning => 'Бег';

  @override
  String get exerciseTypeCycling => 'Велосипед';

  @override
  String get exerciseTypeHiking => 'Пеший поход';

  @override
  String get exerciseTypeSwimming => 'Плавание';

  @override
  String get exerciseTypeGym => 'Спортзал';

  @override
  String get exerciseTypeYoga => 'Йога';

  @override
  String get exerciseTypePilates => 'Пилатес';

  @override
  String get exerciseTypeDancing => 'Танцы';

  @override
  String get exerciseTypeHiit => 'HIIT';

  @override
  String get exerciseTypeJumpRope => 'Скакалка';

  @override
  String get exerciseTypeRowing => 'Гребля';

  @override
  String get exerciseTypeSports => 'Спорт';

  @override
  String get exerciseTypeOther => 'Другое';

  @override
  String get exerciseIntensityLight => 'Лёгкая';

  @override
  String get exerciseIntensityModerate => 'Средняя';

  @override
  String get exerciseIntensityVigorous => 'Интенсивная';

  @override
  String exerciseCalorieBadge(int kcal) {
    return '≈$kcal ккал';
  }

  @override
  String exerciseSavedWithCalories(int kcal) {
    return 'Отличная работа! Твоя активность записана 💪 (≈$kcal ккал)';
  }

  @override
  String get exerciseTodayActivities => 'Сегодня';

  @override
  String exerciseDurationLabel(int minutes) {
    return '$minutes мин';
  }

  @override
  String get exerciseDeleted => 'Активность удалена';

  @override
  String get exerciseDeleteFailed =>
      'Не удалось удалить активность. Попробуй ещё раз.';

  @override
  String get exerciseThisWeek => 'На этой неделе';

  @override
  String exerciseWeekTotalMinutes(int minutes) {
    return 'Всего $minutes мин';
  }

  @override
  String get exerciseWeekCaloriesNote => 'Примерная энергия за неделю';

  @override
  String get exerciseSourceHealth => 'Из приложения здоровья';

  @override
  String get settingsHealthSection => 'Здоровье';

  @override
  String get settingsHealthConnect => 'Подключить данные здоровья телефона';

  @override
  String get settingsHealthConnectDesc =>
      'Импортируй последние тренировки из приложения здоровья телефона в журнал активности. Необязательно и только для чтения.';

  @override
  String get settingsHealthSyncNow => 'Синхронизировать сейчас';

  @override
  String settingsHealthImported(int count) {
    return 'Импортировано активностей: $count';
  }

  @override
  String get settingsHealthUnavailable =>
      'Health Connect недоступен на этом устройстве.';

  @override
  String get settingsHealthDenied =>
      'Доступ отклонён. Вы можете включить его в любое время.';

  @override
  String get settingsHealthError =>
      'Не удалось синхронизировать данные здоровья. Попробуйте снова.';
}
