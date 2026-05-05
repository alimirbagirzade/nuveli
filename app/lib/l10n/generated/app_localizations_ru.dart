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
  String get commonOk => 'OK';

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
      'Или опишите блюдо (например, куриная грудка, рис, салат)';

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
}
