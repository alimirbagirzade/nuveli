// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Nuveli App';

  @override
  String get appTagline => 'KI-Kalorien-Coach';

  @override
  String get loginEmail => 'E-Mail';

  @override
  String get loginPassword => 'Passwort';

  @override
  String get loginPasswordRepeat => 'Passwort wiederholen';

  @override
  String get loginForgotPassword => 'Passwort vergessen';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get loginNoAccount => 'Noch kein Konto?';

  @override
  String get loginRegisterLink => 'Registrieren';

  @override
  String get signupTitle => 'Konto erstellen';

  @override
  String get signupSubtitle =>
      'Beginne deine gesunde Ernährungsreise mit Nuveli';

  @override
  String get signupButton => 'Registrieren';

  @override
  String get signupHasAccount => 'Schon ein Konto?';

  @override
  String get signupLoginLink => 'Anmelden';

  @override
  String get signupTerms =>
      'Mit der Registrierung akzeptierst du die Nutzungsbedingungen und Datenschutzerklärung.';

  @override
  String get authInvalidCredentials =>
      'E-Mail oder Passwort ist falsch. Bitte versuche es erneut.';

  @override
  String get authEmailNotConfirmed =>
      'Du hast deine E-Mail noch nicht bestätigt. Prüfe deinen Posteingang.';

  @override
  String get authUserNotFound => 'Kein Benutzer mit dieser E-Mail registriert.';

  @override
  String get authUserAlreadyRegistered =>
      'Diese E-Mail ist bereits registriert. Versuche dich anzumelden.';

  @override
  String get authWeakPassword =>
      'Passwort zu schwach. Mindestens 6 Zeichen erforderlich.';

  @override
  String get authInvalidEmail => 'Ungültiges E-Mail-Format.';

  @override
  String get authRateLimit =>
      'Zu schnell versucht. Bitte warte einige Sekunden.';

  @override
  String get authNetworkError => 'Überprüfe deine Internetverbindung.';

  @override
  String get authSessionExpired =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get authGenericError =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get ageGateTitle => 'Beginnen wir mit deinem Alter';

  @override
  String get ageGateSubtitle => 'Wir passen Empfehlungen an dein Alter an.';

  @override
  String get ageGateBirthYear => 'Geburtsjahr';

  @override
  String get ageGateUnderageError =>
      'Entschuldigung, Nuveli ist nicht für unter 13-Jährige geeignet.';

  @override
  String get ageGateContinue => 'Weiter';

  @override
  String get acceptanceTitle => 'Informationen';

  @override
  String get acceptanceHeader => 'Bevor wir beginnen';

  @override
  String get acceptanceSubtitle =>
      '4 wichtige Hinweise für die sichere Nutzung von Nuveli. Du musst alle bestätigen.';

  @override
  String get acceptanceWellnessTitle => 'Nuveli ist eine Wellness-App';

  @override
  String get acceptanceWellnessBody =>
      'Nuveli bietet keine medizinische Diagnose, Behandlung oder klinische Diätpläne. Bei besonderen Gesundheitszuständen ist die Unterstützung deines Arztes wichtig.';

  @override
  String get acceptanceWellnessCheck =>
      'Verstanden. Nuveli ersetzt nicht meinen Arzt.';

  @override
  String get acceptanceAiTitle => 'KI-Schätzungen sind ungefähr';

  @override
  String get acceptanceAiBody =>
      'Die Kalorien- und Nährwertschätzungen aus Lebensmittelfotos sind ungefähre Ergebnisse. Du kannst sie immer bearbeiten.';

  @override
  String get acceptanceAiCheck =>
      'Ich weiß, dass die Ergebnisse ungefähr sein können.';

  @override
  String get acceptanceSpecialTitle =>
      'Besondere Situationen erfordern Aufmerksamkeit';

  @override
  String get acceptanceSpecialBody =>
      'Bei Schwangerschaft, Stillzeit, Vorgeschichte von Essstörungen oder chronischen Krankheiten konsultiere einen Gesundheitsexperten, bevor du Kalorienempfehlungen umsetzt.';

  @override
  String get acceptanceSpecialCheck =>
      'Ich werde in meiner besonderen Situation einen Experten konsultieren.';

  @override
  String get acceptanceTermsTitle => 'Bedingungen und Datenschutz';

  @override
  String get acceptanceTermsBody =>
      'Du musst die Nutzungsbedingungen und Datenschutzerklärung lesen und akzeptieren. Deine Daten werden sicher aufbewahrt und du kannst sie jederzeit in den Einstellungen löschen.';

  @override
  String get acceptanceTermsCheck =>
      'Ich akzeptiere die Bedingungen und Datenschutzerklärung.';

  @override
  String get acceptanceContinue => 'Weiter';

  @override
  String get acceptanceCheckAll => 'Alle Kästchen ankreuzen';

  @override
  String get onboardingGoalTitle => 'Was ist dein Ziel?';

  @override
  String get onboardingGoalLose => 'Abnehmen';

  @override
  String get onboardingGoalMaintain => 'Gewicht halten';

  @override
  String get onboardingGoalGain => 'Muskeln aufbauen';

  @override
  String get onboardingSensitivityTitle => 'Sensibilität';

  @override
  String get onboardingSensitivityQ1 =>
      '1. Hattest du in der Vergangenheit Schwierigkeiten mit Essgewohnheiten?';

  @override
  String get onboardingSensitivityQ1A1 => 'Nein, hatte nie so eine Phase';

  @override
  String get onboardingSensitivityQ1A2 => 'Früher ja, jetzt geht\'s mir gut';

  @override
  String get onboardingSensitivityQ1A3 => 'Ja, kämpfe manchmal noch';

  @override
  String get onboardingSensitivityQ1A4 => 'Möchte nicht sagen';

  @override
  String get onboardingSensitivityQ2 =>
      '2. Wie würdest du deine Beziehung zu Essen beschreiben?';

  @override
  String get onboardingSensitivityQ2A1 => 'Entspannt, unter Kontrolle';

  @override
  String get onboardingSensitivityQ2A2 => 'Es gibt gemischte Tage';

  @override
  String get onboardingSensitivityQ2A3 => 'Meistens schwierig';

  @override
  String get onboardingSensitivityQ2A4 => 'Möchte nicht sagen';

  @override
  String get onboardingProfileTitle => 'Erzähl uns von dir';

  @override
  String get onboardingProfileGender => 'Geschlecht';

  @override
  String get onboardingProfileGenderMale => 'Männlich';

  @override
  String get onboardingProfileGenderFemale => 'Weiblich';

  @override
  String get onboardingProfileGenderOther => 'Andere / Möchte nicht sagen';

  @override
  String get onboardingProfileHeight => 'Größe (cm)';

  @override
  String get onboardingProfileWeight => 'Gewicht (kg)';

  @override
  String get onboardingProfileActivity => 'Aktivitätsniveau';

  @override
  String get onboardingProfileActivitySedentary => 'Sitzend (Bürojob)';

  @override
  String get onboardingProfileActivityLight => 'Leicht aktiv';

  @override
  String get onboardingProfileActivityModerate => 'Mäßig aktiv';

  @override
  String get onboardingProfileActivityActive => 'Sehr aktiv';

  @override
  String get onboardingDietTitle => 'Ernährung';

  @override
  String get onboardingDietAllergies => 'Allergien';

  @override
  String get onboardingDietPreference => 'Ernährungspräferenz';

  @override
  String get onboardingDietAllergyLactose => 'Laktose';

  @override
  String get onboardingDietAllergyGluten => 'Gluten-Allergie';

  @override
  String get onboardingDietAllergyPeanut => 'Erdnuss';

  @override
  String get onboardingDietAllergyNut => 'Nüsse';

  @override
  String get onboardingDietAllergyEgg => 'Ei';

  @override
  String get onboardingDietAllergyShellfish => 'Schalentiere';

  @override
  String get onboardingDietAllergySoy => 'Soja';

  @override
  String get onboardingDietAllergySesame => 'Sesam';

  @override
  String get onboardingDietAllergyFish => 'Fisch';

  @override
  String get onboardingDietPrefNone => 'Keine besondere Präferenz';

  @override
  String get onboardingDietPrefVegetarian => 'Vegetarisch';

  @override
  String get onboardingDietPrefVegan => 'Veganisch';

  @override
  String get onboardingDietPrefPescatarian => 'Pescetarisch (nur Fisch)';

  @override
  String get onboardingDietPrefHalal => 'Halal-zertifiziert';

  @override
  String get onboardingDietPrefKosher => 'Koscher';

  @override
  String get onboardingDietPrefOther => 'Andere';

  @override
  String get onboardingCoachTitle => 'Dein Coach';

  @override
  String get onboardingCoachQuestion => 'Wie soll dein Coach sprechen?';

  @override
  String get onboardingCoachSubtitle => 'Du kannst es jederzeit ändern.';

  @override
  String get onboardingCoachKind => 'Freundlich';

  @override
  String get onboardingCoachKindDesc => 'Sanft, ohne Druck, Empathie zuerst';

  @override
  String get onboardingCoachWitty => 'Witzig';

  @override
  String get onboardingCoachWittyDesc =>
      'Leicht, lächelnd, ausgewogen wenn ernst';

  @override
  String get onboardingCoachDirect => 'Direkt';

  @override
  String get onboardingCoachDirectDesc => 'Kurz, klar, realistisches Feedback';

  @override
  String get onboardingCoachCalm => 'Ruhig';

  @override
  String get onboardingCoachCalmDesc => 'Nicht wertend, geduldig, gemessen';

  @override
  String get onboardingCalorieTitle => 'Kalorien';

  @override
  String get onboardingCalorieReady => 'Dein tägliches Ziel ist bereit';

  @override
  String get onboardingCalorieDescription =>
      'Diese Zahl basiert auf deinen Angaben. Nicht fix — wir passen sie gemeinsam an.';

  @override
  String get onboardingCalorieDaily => 'Tägliche Kalorien';

  @override
  String get onboardingCalorieKcal => 'Kilokalorien';

  @override
  String get onboardingCalorieNote =>
      'Berechnet basierend auf Aktivität, Ziel und Situation. Monatlich überprüft.';

  @override
  String get onboardingNotificationTitle => 'Benachrichtigungen';

  @override
  String get onboardingNotificationQuestion =>
      'Möchtest du sanfte Erinnerungen?';

  @override
  String get onboardingNotificationDescription =>
      'Kurze Unterstützung und Mahlzeiten-Erinnerungen von deinem Coach. Wir respektieren Ruhezeiten.';

  @override
  String get onboardingNotificationYes => 'Ja, gerne';

  @override
  String get onboardingNotificationNo => 'Jetzt nicht';

  @override
  String get onboardingWelcomeTitle => 'Willkommen.';

  @override
  String get onboardingWelcomeSubtitle => 'Wir sind bereit.';

  @override
  String get onboardingWelcomeBody =>
      'Kein Druck, kein Urteil — nur du und ein Coach an deiner Seite.';

  @override
  String get onboardingWelcomeFirstStep => 'Erste Schritt-Idee';

  @override
  String get onboardingWelcomeFirstStepDesc =>
      'Beginne mit einer Mahlzeit, die du heute gegessen hast. Mache ein Foto oder schreibe — dein Coach erinnert sich an den Rest.';

  @override
  String get onboardingWelcomeStart => 'Los geht\'s';

  @override
  String get onboardingWelcomePreparing => 'Wird vorbereitet...';

  @override
  String get onboardingWelcomeError =>
      'Ein unerwartetes Problem ist aufgetreten, möchtest du es erneut versuchen?';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get homeTitle => 'Start';

  @override
  String get homeGreetingMorning => 'Guten Morgen';

  @override
  String get homeGreetingAfternoon => 'Guten Tag';

  @override
  String get homeGreetingEvening => 'Guten Abend';

  @override
  String get homeTodayCalories => 'Heutige Kalorien';

  @override
  String get homeRemainingCalories => 'Verbleibend';

  @override
  String get homeAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get homeChat => 'Mit Coach sprechen';

  @override
  String get homeNoMeals => 'Noch keine Mahlzeiten hinzugefügt';

  @override
  String get homeNoMealsHint => 'Mache ein Foto deines Essens oder schreibe';

  @override
  String get navHome => 'Start';

  @override
  String get navMeals => 'Mahlzeiten';

  @override
  String get navCoach => 'Trainer';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemsprache';

  @override
  String get settingsLanguageTurkish => 'Türkisch';

  @override
  String get settingsLanguageEnglish => 'Englisch';

  @override
  String get settingsLanguageGerman => '🇩🇪 Deutsch';

  @override
  String get settingsLanguageFrench => 'Französisch';

  @override
  String get settingsLanguageSpanish => 'Spanisch';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsPremium => 'PREMIUM';

  @override
  String get settingsPremiumComingSoon => 'BALD';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsTerms => 'Nutzungsbedingungen';

  @override
  String get settingsPrivacy => 'Datenschutzerklärung';

  @override
  String get settingsSupport => 'Hilfe';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get settingsVersion => 'App-Version';

  @override
  String get premiumTitle => 'Premium kommt bald';

  @override
  String get premiumSubtitle =>
      'Du kannst Nuveli vorerst komplett kostenlos nutzen.';

  @override
  String get premiumFeatureUnlimited => 'Unbegrenzte Mahlzeitenanalyse';

  @override
  String get premiumFeatureCoach => 'Erweiterter KI-Coach';

  @override
  String get premiumFeatureReports => 'Detaillierte Wochenberichte';

  @override
  String get premiumFeatureExport => 'Datenexport';

  @override
  String get premiumNotifyMe => 'Benachrichtigen wenn bereit';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonLoading => 'Wird geladen...';

  @override
  String get commonError => 'Ein Fehler ist aufgetreten';

  @override
  String get commonSuccess => 'Erfolg';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nein';

  @override
  String get commonOk => 'Bestätigen';

  @override
  String get settingsCoachTone => 'Coach-Ton';

  @override
  String get settingsSupportSecurity => 'Support & Sicherheit';

  @override
  String get settingsHowAiWorks => 'Wie KI funktioniert';

  @override
  String get settingsPrivacySafety => 'Datenschutz & Sicherheit';

  @override
  String get settingsAboutNuveli => 'Über Nuveli';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsSession => 'Sitzung';

  @override
  String get settingsDangerZone => 'Gefahrenzone';

  @override
  String get settingsSignedInAs => 'Angemeldet als';

  @override
  String get settingsLogoutTitle => 'Abmelden?';

  @override
  String get settingsLogoutBody =>
      'Du brauchst deine E-Mail und dein Passwort um dich wieder anzumelden.';

  @override
  String get settingsLogoutCancel => 'Abbrechen';

  @override
  String get settingsLogoutFailed => 'Abmeldung fehlgeschlagen.';

  @override
  String get premiumModalTitle => 'Premium kommt bald!';

  @override
  String get premiumModalBody =>
      'Wir bereiten unbegrenzte KI-Mahlzeitenanalyse, erweitertes Coaching und wöchentliche Einblicke vor.';

  @override
  String get premiumFeatureVoice => 'Sprach-Coach + 3 Personas';

  @override
  String get premiumFeatureInsights => 'Wöchentliche + monatliche Einblicke';

  @override
  String get premiumUnderstood => 'Verstanden';

  @override
  String get passwordVeryWeak => 'Sehr schwach';

  @override
  String get passwordWeak => 'Schwach';

  @override
  String get passwordMedium => 'Mittel';

  @override
  String get passwordStrong => 'Stark';

  @override
  String get passwordVeryStrong => 'Sehr stark';

  @override
  String get homeErrorGeneric => 'Etwas ist schiefgelaufen';

  @override
  String get homeCoachLabel => 'Dein Coach';

  @override
  String get homeToday => 'Heute';

  @override
  String get homeRemaining => 'übrig';

  @override
  String get homeThisWeek => 'Diese Woche';

  @override
  String get homeMiniGoalTitle => 'Heutiges Mini-Ziel';

  @override
  String get homeMiniGoalDefault => 'Füge einer Mahlzeit Protein hinzu';

  @override
  String get homeAddMealLabel => 'Mahlzeit hinzufügen';

  @override
  String get homeWater => 'Wasser';

  @override
  String get homeWeight => 'Gewicht';

  @override
  String get homeMood => 'Stimmung';

  @override
  String get homeAddWater => 'Wasser hinzufügen';

  @override
  String get homeEnterWeight => 'Gewicht eingeben';

  @override
  String get homeMoodGreat => 'Super';

  @override
  String get homeMoodGood => 'Gut';

  @override
  String get homeMoodNeutral => 'Normal';

  @override
  String get homeMoodBad => 'Schwierig';

  @override
  String get homeMoodRough => 'Sehr schwierig';

  @override
  String get homeMoodPickOne => 'Wähle eine';

  @override
  String get homeNoMealsTitle => 'Noch keine Mahlzeiten';

  @override
  String get homeNoMealsMessage => 'Starte den Tag mit deiner ersten Mahlzeit';

  @override
  String get homeTodayMeals => 'Heutige Mahlzeiten';

  @override
  String get homeMealBreakfast => 'Frühstück';

  @override
  String get homeMealLunch => 'Mittagessen';

  @override
  String get homeMealDinner => 'Abendessen';

  @override
  String get homeMealSnack => 'Zwischenmahlzeit';

  @override
  String get homeCalorieTarget => 'Ziel';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target kcal Ziel';
  }

  @override
  String get macroProtein => 'Eiweiß';

  @override
  String get macroCarb => 'Kohlenh.';

  @override
  String get macroFat => 'Fett';

  @override
  String get homeCravingText => 'Gelüste? 60 Sekunden Pause, tief durchatmen.';

  @override
  String get notifMealReminders => 'Mahlzeiten-Erinnerungen';

  @override
  String get notifMealRemindersDesc =>
      'Sanfte Erinnerung zur Frühstücks-, Mittags-, Abendessenszeit';

  @override
  String get notifCoachNudges => 'Coach-Impulse';

  @override
  String get notifCoachNudgesDesc =>
      'Persönliche Unterstützung und Motivationsnachrichten';

  @override
  String get notifWeeklySummary => 'Wochenübersicht';

  @override
  String get notifWeeklySummaryDesc =>
      'Montag morgens Zusammenfassung der letzten Woche';

  @override
  String get notifQuietHours => 'RUHEZEITEN';

  @override
  String get notifQuietHoursDesc =>
      'Während dieser Stunden keine Benachrichtigungen.';

  @override
  String get notifQuietStart => 'Beginn';

  @override
  String get notifQuietEnd => 'Ende';

  @override
  String get notifSaved => 'Einstellungen gespeichert.';

  @override
  String get notifSaveFailed => 'Konnte nicht gespeichert werden.';

  @override
  String get notifLoadFailed => 'Konnte nicht geladen werden.';

  @override
  String get coachSettingsTitle => 'Dein Coach';

  @override
  String get coachSettingsQuestion => 'Wie soll dein Coach mit dir sprechen?';

  @override
  String get coachSettingsSubtitle => 'Du kannst es jederzeit ändern.';

  @override
  String get onboardingMoreMeasures => 'Noch ein paar Maße';

  @override
  String get onboardingActivityLevel => 'Dein Aktivitätsniveau';

  @override
  String get onboardingFirstMeal => 'Erste Mahlzeit hinzufügen';

  @override
  String get onboardingGoToHome => 'Zum Startbildschirm';

  @override
  String get onboardingBirthYear => 'Geburtsjahr';

  @override
  String get onboardingGender => 'Geschlecht';

  @override
  String get settingsAppearance => 'DARSTELLUNG';

  @override
  String get supportTitle => 'Hilfe';

  @override
  String get supportEmailSubject => 'Nuveli Hilfe';

  @override
  String get howAiTitle => 'Wie KI funktioniert';

  @override
  String get privacyTitle => 'Datenschutz & Sicherheit';

  @override
  String get aboutTitle => 'Über Nuveli';

  @override
  String get coachToneUpdated => 'Coach-Ton aktualisiert';

  @override
  String get supportHowHelp => 'Wie können wir helfen?';

  @override
  String get supportEmailCard => 'Per E-Mail kontaktieren';

  @override
  String get supportFaq => 'Häufige Fragen';

  @override
  String get supportFaqDesc => 'Häufig gestellte Fragen und Antworten';

  @override
  String get aiBlockFood => 'Lebensmittelerkennung';

  @override
  String get aiBlockFoodBody =>
      'Ich analysiere dein Foto und schätze Kalorien. Das ist keine exakte Messung — du kannst bearbeiten.';

  @override
  String get aiBlockCoach => 'Coach-Antworten';

  @override
  String get aiBlockCoachBody =>
      'Kurze, nicht wertende, unterstützende Nachrichten. Keine medizinischen Ratschläge.';

  @override
  String get aiBlockSafety => 'Sicherheit';

  @override
  String get aiBlockSafetyBody =>
      'In Risikosituationen zeige ich Unterstützungsressourcen.';

  @override
  String get aiBlockData => 'Deine Daten';

  @override
  String get aiBlockDataBody =>
      'Deine Daten werden verschlüsselt übertragen und nur du kannst zugreifen.';

  @override
  String get privacyHeading => 'Deine Sicherheit hat Priorität';

  @override
  String get privacyBody =>
      'Nuveli ist eine Wellness-App. Keine medizinische Diagnose oder Diätpläne.';

  @override
  String get privacyEmergency => 'Notfall-Unterstützung';

  @override
  String get privacyHotline => 'ALO 182 — Psychologische Hilfe (24/7)';

  @override
  String get privacyPolicyLink => 'Datenschutzerklärung';

  @override
  String get privacyTermsLink => 'Nutzungsbedingungen';

  @override
  String get privacyDownload => 'Meine Daten herunterladen';

  @override
  String get aboutApp => 'Anwendung';

  @override
  String get aboutLinks => 'Verweise';

  @override
  String get aboutWebsite => 'Webseite';

  @override
  String get aboutTechnical => 'Technisch';

  @override
  String get aboutEnv => 'Umgebung';

  @override
  String get aboutCopyright => '© 2026 Nuveli. Alle Rechte vorbehalten.';

  @override
  String get aboutCopied => 'kopiert';

  @override
  String get aboutVersion => 'App-Version';

  @override
  String get streakDay => 'Tag';

  @override
  String get streakDays => 'Tage in Folge';

  @override
  String get streakLongest => 'Längste Serie';

  @override
  String get streakTodayDone => 'Heute auch geschafft';

  @override
  String streakSummary(int current) {
    return '$current Tage in Folge';
  }

  @override
  String get streakExplanation =>
      'Deine Serie zeigt aufeinanderfolgende Tage mit Mahlzeiten.';

  @override
  String get weeklyTitle => 'Wochenübersicht';

  @override
  String get weeklyLoadFailed => 'Konnte nicht geladen werden';

  @override
  String get weeklyChartLoadFailed => 'Daten konnten nicht geladen werden';

  @override
  String get commonRetryLow => 'Erneut versuchen';

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get dayDetailMeals => 'Mahlzeiten';

  @override
  String get dayDetailMealsLoadFailed =>
      'Mahlzeiten konnten nicht geladen werden';

  @override
  String get dayDetailNoMeals => 'Keine Mahlzeiten für diesen Tag';

  @override
  String dayDetailWaterMl(int ml) {
    return '$ml ml Wasser';
  }

  @override
  String get mealTypeBreakfast => 'Frühstück';

  @override
  String get mealTypeLunch => 'Mittagessen';

  @override
  String get mealTypeDinner => 'Abendessen';

  @override
  String get mealTypeSnack => 'Zwischenmahlzeit';

  @override
  String get mealTypeOther => 'Mahlzeit';

  @override
  String get weeklyMacroDist => 'Makro-Verteilung';

  @override
  String get weeklyDailyDetail => 'Tägliches Detail';

  @override
  String get weeklyCoachComment => 'COACH-KOMMENTAR';

  @override
  String get weeklyCoachCommentLocked => 'Coach-Kommentar';

  @override
  String get weeklyCoachCommentLockedDesc =>
      'Wöchentliche Mustererkennung mit Premium';

  @override
  String streakLastLog(String date) {
    return 'Letzter Eintrag: $date';
  }

  @override
  String get streakNow => 'Aktuell';

  @override
  String get streakLongestShort => 'Längste';

  @override
  String get streakAddMealNow => 'Mahlzeit hinzufügen';

  @override
  String get streakAtRisk =>
      'Du hast heute noch keine Mahlzeit eingetragen und es ist Abend. Füge jetzt eine hinzu.';

  @override
  String get streakNotStarted =>
      'Deine Serie hat noch nicht begonnen. Füge deine erste Mahlzeit hinzu.';

  @override
  String get streakTodayLogged => 'Heute auch geschafft! Mache morgen weiter.';

  @override
  String get streakExplanationDefault =>
      'Deine Serie zeigt aufeinanderfolgende Tage mit Mahlzeiten.';

  @override
  String get weeklyAvgKcal => 'kcal/Tag Durchschnitt';

  @override
  String get weeklyTotal => 'Gesamt';

  @override
  String get weeklyMeals => 'Mahlzeiten';

  @override
  String get weeklyLogged => 'Eingetragen';

  @override
  String get coachChatTitle => 'Trainer';

  @override
  String get coachChatPlaceholder => 'Frag deinen Coach...';

  @override
  String get coachChatSend => 'Senden';

  @override
  String get waterHowMuch => 'Wie viel hast du getrunken?';

  @override
  String get waterHistory => 'Verlauf';

  @override
  String get weightInvalid => 'Gib ein gültiges Gewicht ein (1-500 kg).';

  @override
  String get weightKg => 'Kilogramm';

  @override
  String get moodHowToday => 'Wie geht\'s dir heute?';

  @override
  String get mealCameraNotAvailable =>
      'Funktioniert auf echten Geräten. Wähle aus Galerie.';

  @override
  String get mealGallery => 'Galerie';

  @override
  String weeklyDaysLogged(int n) {
    return '$n Tage eingetragen. Guter Fortschritt.';
  }

  @override
  String get coachWelcome => 'Hallo! Wie fühlst du dich heute?';

  @override
  String get coachInputPlaceholder => 'Nachricht schreiben...';

  @override
  String get coachLoadFailed => 'Konnte nicht geladen werden.';

  @override
  String get coachSendFailed => 'Nachricht konnte nicht gesendet werden.';

  @override
  String get coachLimitTitle => 'Tägliches Nachrichtenlimit erreicht';

  @override
  String coachLimitBody(String reason) {
    return '$reason\n\nMit Premium unbegrenzter Coach-Chat + Sprachantworten.';
  }

  @override
  String get coachLater => 'Später';

  @override
  String get coachSeePremium => 'Premium ansehen';

  @override
  String get coachCrisisTitle => 'Du bist nicht allein';

  @override
  String get coachDistressTitle => 'Du hast vielleicht einen schweren Moment';

  @override
  String get coachCrisisBody =>
      'Wir möchten für dich da sein, aber professionelle Unterstützung ist sehr wichtig.';

  @override
  String get coachDistressBody =>
      'Dein Coach kann in solchen Situationen nicht helfen. Sich an jemanden zu wenden, der sich um dich kümmert, ist immer eine Option.';

  @override
  String get mealAddTitle => 'Mahlzeit hinzufügen';

  @override
  String get mealPhotoOrDesc => 'Foto oder Beschreibung';

  @override
  String get mealNoPhoto => 'Kein Foto hinzugefügt';

  @override
  String get mealCamera => 'Kamera';

  @override
  String get mealGalleryBtn => 'Galerie';

  @override
  String get mealSimulatorWarn =>
      'Keine Kamera im Simulator. Galerie verwenden.';

  @override
  String get mealDescHint =>
      'Beschreibe deine Mahlzeit:\n• Was? (z.B. Hähnchenbrust)\n• Wie viel? (z.B. 200g, 1 Portion)\n• Dazu? (z.B. Brot, Reis)';

  @override
  String get mealAnalyze => 'Analysieren';

  @override
  String get mealManualEntry => 'Manuell eingeben';

  @override
  String get mealAnalyzeFailed => 'Analyse fehlgeschlagen.';

  @override
  String get mealLimitTitle => 'Tageslimit erreicht';

  @override
  String mealLimitBody(String reason) {
    return '$reason\n\nMit Premium unbegrenzte Fotoanalyse.';
  }

  @override
  String get waterHistoryTitle => 'Wasser-Verlauf';

  @override
  String get weightHistoryTitle => 'Gewichts-Verlauf';

  @override
  String get monthJan => 'Januar';

  @override
  String get monthFeb => 'Februar';

  @override
  String get monthMar => 'März';

  @override
  String get monthApr => 'April-Monat';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Juni';

  @override
  String get monthJul => 'Juli';

  @override
  String get monthAug => 'August-Monat';

  @override
  String get monthSep => 'September-Monat';

  @override
  String get monthOct => 'Oktober';

  @override
  String get monthNov => 'November-Monat';

  @override
  String get monthDec => 'Dezember';

  @override
  String get weekdayMon => 'Montag';

  @override
  String get weekdayTue => 'Dienstag';

  @override
  String get weekdayWed => 'Mittwoch';

  @override
  String get weekdayThu => 'Donnerstag';

  @override
  String get weekdayFri => 'Freitag';

  @override
  String get weekdaySat => 'Samstag';

  @override
  String get weekdaySun => 'Sonntag';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get personaGentle => 'Sanft';

  @override
  String get personaGentleDesc => 'Sanft, kein Druck, Empathie zuerst';

  @override
  String get personaGentleSample =>
      '\"Ich sehe, dass heute schwierig ist. Sei nicht streng zu dir selbst.\"';

  @override
  String get personaFunny => 'Witzig';

  @override
  String get personaFunnyDesc => 'Leicht, lächelnd, ausgeglichen';

  @override
  String get personaFunnySample =>
      '\"Pizza-Abend, verstanden. Das Leben ist Balance — morgen Salat, heute Glück.\"';

  @override
  String get personaDirect => 'Direkt';

  @override
  String get personaDirectDesc => 'Kurz, klar, realistisches Feedback';

  @override
  String get personaDirectSample =>
      '\"Heute wenig Protein. Ziel: 25-30g zum Abendessen.\"';

  @override
  String get personaCalm => 'Ruhig';

  @override
  String get personaCalmDesc => 'Nicht urteilend, geduldig';

  @override
  String get personaCalmSample =>
      '\"Manchmal essen wir ohne nachzudenken. Wichtig ist das Bewusstsein.\"';

  @override
  String get coachToneQuestion => 'Wie soll dein Coach mit dir sprechen?';

  @override
  String get coachToneSubtitle => 'Du kannst jederzeit ändern.';

  @override
  String get coachToneSaving => 'Speichern...';

  @override
  String get coachToneSaveError => 'Konnte nicht speichern. Versuch es erneut?';

  @override
  String get coachToneSaveErrorGeneric =>
      'Unerwarteter Fehler. Erneut versuchen?';

  @override
  String waterLastDays(int n) {
    return 'Letzte $n Tage';
  }

  @override
  String get waterLitresTotal => 'L gesamt';

  @override
  String get waterToday => 'Heute';

  @override
  String get waterAverage => 'Durchschnitt';

  @override
  String get waterLast7 => 'Letzte 7 Tage';

  @override
  String waterGoalMl(int ml) {
    return 'Ziel: $ml ml/Tag';
  }

  @override
  String get waterAllDays => 'Alle Tage';

  @override
  String get waterNoRecord => 'Kein Eintrag';

  @override
  String waterDaysCount(int n) {
    return '$n Tage';
  }

  @override
  String get weightCurrent => 'Aktuelles Gewicht';

  @override
  String get weightFirstRecord => 'Erster Eintrag';

  @override
  String weightTrend(int n) {
    return 'Trend ($n Einträge)';
  }

  @override
  String get weightRecords => 'Einträge';

  @override
  String weightEntryCount(int n) {
    return '$n Einträge';
  }

  @override
  String get monthShortJan => 'Januar';

  @override
  String get monthShortFeb => 'Februar';

  @override
  String get monthShortMar => 'März';

  @override
  String get monthShortApr => 'April';

  @override
  String get monthShortMay => 'Mai';

  @override
  String get monthShortJun => 'Juni';

  @override
  String get monthShortJul => 'Juli';

  @override
  String get monthShortAug => 'August';

  @override
  String get monthShortSep => 'September';

  @override
  String get monthShortOct => 'Okt';

  @override
  String get monthShortNov => 'November';

  @override
  String get monthShortDec => 'Dez';

  @override
  String get todayBadge => 'HEUTE';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLoadFailed => 'Profil konnte nicht geladen werden.';

  @override
  String get profileAccount => 'Konto';

  @override
  String get profilePersonalInfo => 'Persönliche Informationen';

  @override
  String get profilePersonalInfoSub => 'Name, Ziele, Körperdaten';

  @override
  String get profileGoals => 'Ziele';

  @override
  String get profileGoalsSub => 'Deine Kalorien- und Makroziele';

  @override
  String get profileNotifications => 'Benachrichtigungen';

  @override
  String get profileNotifPrefs => 'Benachrichtigungseinstellungen';

  @override
  String get profileNotifPrefsSub => 'Erinnerungen und Ruhezeiten';

  @override
  String get profileTheme => 'Design';

  @override
  String get profileDarkTheme => 'Dunkles Design';

  @override
  String get profileDarkThemeSub => 'Derzeit aktiv (Standard)';

  @override
  String get profilePremium => 'PREMIUM';

  @override
  String get profilePremiumSub => 'Plan, Abrechnung und Funktionen';

  @override
  String get profilePremiumMy => 'Mein Premium-Abo';

  @override
  String get profileHelpSafety => 'Hilfe & Sicherheit';

  @override
  String get profileSupport => 'Hilfe';

  @override
  String get profileSupportSub => 'Fragen und Feedback';

  @override
  String get profileHowAi => 'Wie KI funktioniert';

  @override
  String get profilePrivacy => 'Datenschutz';

  @override
  String get profileAbout => 'Über Nuveli';

  @override
  String get profileLogout => 'Abmelden';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileSignOutConfirm => 'Möchtest du dich wirklich abmelden?';

  @override
  String get homeGreetingNoonTime => 'Guten Tag';

  @override
  String get profileStreakNow => 'Aktuell';

  @override
  String get profileStreakLongest => 'Längste';

  @override
  String get profileStreakDay => 'Tag';

  @override
  String get personalInfoTitle => 'Persönliche Informationen';

  @override
  String get personalInfoEdit => 'Bearbeiten';

  @override
  String get personalInfoSaved => 'Informationen gespeichert';

  @override
  String get personalInfoSaveFailed => 'Konnte nicht gespeichert werden';

  @override
  String get personalInfoLoadFailed => 'Konnte nicht geladen werden';

  @override
  String get personalInfoSecAccount => 'Konto';

  @override
  String get personalInfoSecBody => 'Körperdaten';

  @override
  String get personalInfoSecActivity => 'Aktivität';

  @override
  String get personalInfoName => 'Vorname';

  @override
  String get personalInfoEmail => 'E-Mail';

  @override
  String get personalInfoBirthYear => 'Geburtsjahr';

  @override
  String get personalInfoGender => 'Geschlecht';

  @override
  String get personalInfoHeight => 'Größe';

  @override
  String get personalInfoHeightCm => 'Größe (cm)';

  @override
  String get personalInfoWeight => 'Gewicht';

  @override
  String get personalInfoWeightKg => 'Gewicht (kg)';

  @override
  String get personalInfoActivityLevel => 'Tägliches Aktivitätsniveau';

  @override
  String get personalInfoActivityLevelLabel => 'Aktivitätsniveau';

  @override
  String get personalInfoCancel => 'Abbrechen';

  @override
  String get personalInfoSave => 'Speichern';

  @override
  String get personalInfoSaving => 'Speichern...';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderOther => 'Andere';

  @override
  String get activitySedentary => 'Sitzend';

  @override
  String get activitySedentaryFull => 'Sitzend (Bürojob)';

  @override
  String get activityLight => 'Leicht aktiv';

  @override
  String get activityLightFull => 'Leicht aktiv (1-3 Tage)';

  @override
  String get activityModerate => 'Mäßig aktiv';

  @override
  String get activityModerateFull => 'Mäßig aktiv (3-5 Tage)';

  @override
  String get activityActive => 'Aktiv';

  @override
  String get activityActiveFull => 'Aktiv (6-7 Tage)';

  @override
  String get activityVeryActive => 'Sehr aktiv';

  @override
  String get activityVeryActiveFull => 'Sehr aktiv (Sportler)';

  @override
  String get goalsTitle => 'Ziele';

  @override
  String get goalsUpdated => 'Ziele aktualisiert';

  @override
  String get goalsLoadFailed => 'Konnte nicht geladen werden';

  @override
  String get goalsSaveFailed => 'Konnte nicht gespeichert werden';

  @override
  String get goalsSecPurpose => 'Zweck';

  @override
  String get goalsSecDailyCalorie => 'Tägliches Kalorienziel';

  @override
  String get goalsSecMacroDist => 'Empfohlene Makro-Verteilung';

  @override
  String get goalsLoseWeight => 'Abnehmen';

  @override
  String get goalsLoseWeightDesc => 'Allmähliche Abnahme mit Kaloriendefizit';

  @override
  String get goalsMaintain => 'Gewicht halten';

  @override
  String get goalsMaintainDesc => 'Aktuelles Gewicht beibehalten';

  @override
  String get goalsGainMuscle => 'Muskeln aufbauen';

  @override
  String get goalsGainMuscleDesc => 'Aufbau mit Kalorienüberschuss';

  @override
  String get goalsMacroNote =>
      'Diese Empfehlung basiert auf 25% Protein, 50% Kohlenhydrate, 25% Fett. Dein Coach kann es anpassen.';

  @override
  String get goalsSave => 'Speichern';

  @override
  String get premiumComingTitle => 'Premium kommt bald! 🚀';

  @override
  String get premiumComingDesc =>
      'Wir arbeiten an unbegrenzten KI-Mahlzeitenanalysen, Sprach-Coach und wöchentlichen Einblicken. Wir benachrichtigen dich, wenn es bereit ist.';

  @override
  String get premiumFeatureCharts => 'Erweiterte Diagramme und Trends';

  @override
  String get premiumGotIt => 'Verstanden';

  @override
  String todayMealsCount(int n) {
    return '$n Mahlzeiten';
  }

  @override
  String get todayMealDeleteTitle => 'Mahlzeit löschen?';

  @override
  String todayMealDeleteMessage(String name) {
    return '\"$name\" wird gelöscht. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get todayMealDeleteConfirm => 'Löschen';

  @override
  String get todayMealDeleteCancel => 'Abbrechen';

  @override
  String get todayMealDeleted => 'Mahlzeit gelöscht.';

  @override
  String get todayMealDeleteFailed => 'Konnte nicht gelöscht werden.';

  @override
  String get mealTypeBreakfastShort => 'Frühstück';

  @override
  String get mealTypeLunchShort => 'Mittagessen';

  @override
  String get mealTypeDinnerShort => 'Abendessen';

  @override
  String get mealTypeSnackShort => 'Zwischenmahlzeit';

  @override
  String streakLongestNeverActive(int longest) {
    return 'Längste Serie: $longest Tage';
  }

  @override
  String streakTodayDoneSubtitle(int longest) {
    return 'Heute geschafft · Längste: $longest Tage';
  }

  @override
  String streakTodayMissedSubtitle(int longest) {
    return 'Vergiss heute nicht · Längste: $longest';
  }

  @override
  String get waterAllDaysList => 'Alle Tage';

  @override
  String get waterTodayBadge => 'HEUTE';

  @override
  String get waterNoEntry => 'Kein Eintrag';

  @override
  String get weightRecordsList => 'Einträge';

  @override
  String weightEntriesCount(int n) {
    return '$n Einträge';
  }

  @override
  String historyDaysSuffix(int n) {
    return '$n Tage';
  }

  @override
  String get moodGreat => 'Großartig';

  @override
  String get moodGood => 'Gut';

  @override
  String get moodNeutral => 'Geht so';

  @override
  String get moodBad => 'Schwer';

  @override
  String get moodRough => 'Sehr schwer';

  @override
  String get verifyEmailTitle => 'E-Mail Bestätigen';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Wir haben einen Bestätigungslink an $email gesendet. Tippe auf den Link, um automatisch fortzufahren.';
  }

  @override
  String get verifyEmailWaitingTitle => 'Warte auf E-Mail...';

  @override
  String get verifyEmailWaitingBody =>
      'Du kannst nicht fortfahren, ohne auf den Link in deiner E-Mail zu klicken. Überprüfe auch deinen Spam-Ordner.';

  @override
  String get verifyEmailResend => 'Erneut senden';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Erneut senden (${seconds}s)';
  }

  @override
  String get verifyEmailResent => 'Neue Bestätigungs-E-Mail gesendet.';

  @override
  String get verifyEmailSignOut => 'Andere E-Mail / Abmelden';

  @override
  String get coachBubbleGentleMealUnder =>
      'Achtsam eingetragen. Du hast heute noch Spielraum, ganz ohne Eile.';

  @override
  String get coachBubbleGentleMealOver =>
      'Eingetragen. Eine Mahlzeit bestimmt nicht deinen Tag. Sei gut zu dir.';

  @override
  String get coachBubbleGentleMealOnTrack =>
      'Schöne Balance heute. Du hörst auf deinen Körper.';

  @override
  String get coachBubbleGentleWaterLow =>
      'Ein Schluck Wasser würde jetzt guttun, wann immer du magst.';

  @override
  String get coachBubbleGentleStreakMilestone =>
      'Du bist jeden Tag sanft dabei. Das ist echt.';

  @override
  String get coachBubbleGentleFirstMeal =>
      'Erste Mahlzeit drin. Ein sanfter, ruhiger Start in den Tag.';

  @override
  String get coachBubbleFunnyMealUnder =>
      'Eingetragen! Noch viel Startbahn frei — die Gabel darf abheben.';

  @override
  String get coachBubbleFunnyMealOver =>
      'Große Mahlzeit, große Freude. Morgen wartet das nächste leckere Kapitel.';

  @override
  String get coachBubbleFunnyMealOnTrack =>
      'Chef\'s Kiss. Du und Balance seid jetzt quasi beste Freunde.';

  @override
  String get coachBubbleFunnyWaterLow =>
      'Deine Wasserflasche fühlt sich etwas ignoriert. Nur so.';

  @override
  String get coachBubbleFunnyStreakMilestone =>
      'Serie läuft stark — da ist jemand in Fahrt!';

  @override
  String get coachBubbleFunnyFirstMeal =>
      'Frühstücks-Club meldet sich. Der Tag startet lecker.';

  @override
  String get coachBubbleDirectMealUnder =>
      'Eingetragen. Noch Platz für den Rest des Tages — plane gut.';

  @override
  String get coachBubbleDirectMealOver =>
      'Eingetragen, etwas drüber. Kein Drama — passe die nächsten Mahlzeiten an.';

  @override
  String get coachBubbleDirectMealOnTrack =>
      'Eingetragen. Genau im Plan. Bleib dran.';

  @override
  String get coachBubbleDirectWaterLow =>
      'Wasser hängt heute hinterher. Hol dir ein Glas.';

  @override
  String get coachBubbleDirectStreakMilestone =>
      'Serie hält. Konstanz macht die Arbeit.';

  @override
  String get coachBubbleDirectFirstMeal =>
      'Erste Mahlzeit eingetragen. Gut — gib dem Tag den Ton vor.';

  @override
  String get coachBubbleCalmMealUnder =>
      'Notiert. Es liegt noch Raum vor dir. Geh dein eigenes Tempo.';

  @override
  String get coachBubbleCalmMealOver =>
      'Notiert. Bewusstsein zählt. Die nächste Mahlzeit gehört dir.';

  @override
  String get coachBubbleCalmMealOnTrack =>
      'Notiert. Ruhig und gleichmäßig — ein gelassener Fortschritt.';

  @override
  String get coachBubbleCalmWaterLow =>
      'Wasser ist etwas niedrig. Kein Druck — trink, wenn es passt.';

  @override
  String get coachBubbleCalmStreakMilestone =>
      'Stille Konstanz, Tag für Tag. Das zählt.';

  @override
  String get coachBubbleCalmFirstMeal =>
      'Erste Mahlzeit notiert. Ein ruhiger Beginn des Tages.';

  @override
  String get mealHistoryTitle => 'Mahlzeiten-Verlauf';

  @override
  String get historyYesterday => 'Gestern';

  @override
  String get mealHistoryEmptyTitle => 'Noch keine Mahlzeiten erfasst';

  @override
  String get mealHistoryEmptyBody =>
      'Deine erfassten Mahlzeiten erscheinen hier, nach Tag gruppiert.';
}
