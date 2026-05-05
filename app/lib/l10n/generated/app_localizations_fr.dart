// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Nuveli';

  @override
  String get appTagline => 'Coach Calorique IA';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginPasswordRepeat => 'Répéter le mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas encore de compte?';

  @override
  String get loginRegisterLink => 'S\'inscrire';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get signupSubtitle =>
      'Commence ton parcours d\'alimentation saine avec Nuveli';

  @override
  String get signupButton => 'S\'inscrire';

  @override
  String get signupHasAccount => 'Déjà un compte?';

  @override
  String get signupLoginLink => 'Se connecter';

  @override
  String get signupTerms =>
      'En t\'inscrivant, tu acceptes les Conditions d\'utilisation et la Politique de confidentialité.';

  @override
  String get authInvalidCredentials =>
      'E-mail ou mot de passe incorrect. Veuillez réessayer.';

  @override
  String get authEmailNotConfirmed =>
      'Tu n\'as pas encore confirmé ton e-mail. Vérifie ta boîte de réception.';

  @override
  String get authUserNotFound =>
      'Aucun utilisateur enregistré avec cet e-mail.';

  @override
  String get authUserAlreadyRegistered =>
      'Cet e-mail est déjà enregistré. Essaie de te connecter.';

  @override
  String get authWeakPassword =>
      'Mot de passe trop faible. Au moins 6 caractères requis.';

  @override
  String get authInvalidEmail => 'Format d\'e-mail invalide.';

  @override
  String get authRateLimit =>
      'Tu as essayé trop rapidement. Attends quelques secondes.';

  @override
  String get authNetworkError => 'Vérifie ta connexion Internet.';

  @override
  String get authSessionExpired =>
      'Ta session a expiré. Connecte-toi à nouveau.';

  @override
  String get authGenericError =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get ageGateTitle => 'Commençons par ton âge';

  @override
  String get ageGateSubtitle => 'Nous adaptons les recommandations à ton âge.';

  @override
  String get ageGateBirthYear => 'Année de naissance';

  @override
  String get ageGateUnderageError =>
      'Désolé, Nuveli ne convient pas aux moins de 13 ans.';

  @override
  String get ageGateContinue => 'Continuer';

  @override
  String get acceptanceTitle => 'Information';

  @override
  String get acceptanceHeader => 'Avant de commencer';

  @override
  String get acceptanceSubtitle =>
      '4 notes importantes pour une utilisation sûre de Nuveli. Tu dois toutes les confirmer.';

  @override
  String get acceptanceWellnessTitle =>
      'Nuveli est une application de bien-être';

  @override
  String get acceptanceWellnessBody =>
      'Nuveli ne fournit pas de diagnostic médical, traitement ou plan diététique clinique. Pour des conditions de santé particulières, le soutien de ton médecin est important.';

  @override
  String get acceptanceWellnessCheck =>
      'Compris. Nuveli ne remplace pas mon médecin.';

  @override
  String get acceptanceAiTitle => 'Les estimations IA sont approximatives';

  @override
  String get acceptanceAiBody =>
      'Les estimations de calories et de valeurs nutritionnelles à partir des photos de nourriture sont des résultats approximatifs. Tu peux toujours les modifier.';

  @override
  String get acceptanceAiCheck =>
      'Je sais que les résultats peuvent être approximatifs.';

  @override
  String get acceptanceSpecialTitle =>
      'Les situations spéciales nécessitent de l\'attention';

  @override
  String get acceptanceSpecialBody =>
      'Si tu as une grossesse, allaitement, antécédents de troubles alimentaires ou maladies chroniques, consulte un professionnel de santé avant d\'appliquer des suggestions caloriques.';

  @override
  String get acceptanceSpecialCheck =>
      'Je consulterai un expert dans ma situation particulière.';

  @override
  String get acceptanceTermsTitle => 'Conditions et confidentialité';

  @override
  String get acceptanceTermsBody =>
      'Tu dois lire et accepter les Conditions d\'utilisation et la Politique de confidentialité. Tes données sont conservées en sécurité et tu peux les supprimer à tout moment depuis les paramètres.';

  @override
  String get acceptanceTermsCheck =>
      'J\'accepte les Conditions et la Politique de confidentialité.';

  @override
  String get acceptanceContinue => 'Continuer';

  @override
  String get acceptanceCheckAll => 'Coche toutes les cases';

  @override
  String get onboardingGoalTitle => 'Quel est ton objectif?';

  @override
  String get onboardingGoalLose => 'Perdre du poids';

  @override
  String get onboardingGoalMaintain => 'Maintenir le poids';

  @override
  String get onboardingGoalGain => 'Prendre du muscle';

  @override
  String get onboardingSensitivityTitle => 'Sensibilité';

  @override
  String get onboardingSensitivityQ1 =>
      '1. As-tu déjà eu des difficultés avec les habitudes alimentaires?';

  @override
  String get onboardingSensitivityQ1A1 => 'Non, jamais eu cette période';

  @override
  String get onboardingSensitivityQ1A2 => 'Avant oui, je vais bien maintenant';

  @override
  String get onboardingSensitivityQ1A3 => 'Oui, je lutte encore parfois';

  @override
  String get onboardingSensitivityQ1A4 => 'Préfère ne pas dire';

  @override
  String get onboardingSensitivityQ2 =>
      '2. Comment décrirais-tu ta relation actuelle avec la nourriture?';

  @override
  String get onboardingSensitivityQ2A1 => 'À l\'aise, en contrôle';

  @override
  String get onboardingSensitivityQ2A2 => 'Des journées mitigées arrivent';

  @override
  String get onboardingSensitivityQ2A3 =>
      'C\'est difficile la plupart du temps';

  @override
  String get onboardingSensitivityQ2A4 => 'Préfère ne pas dire';

  @override
  String get onboardingProfileTitle => 'Parle-nous de toi';

  @override
  String get onboardingProfileGender => 'Genre';

  @override
  String get onboardingProfileGenderMale => 'Homme';

  @override
  String get onboardingProfileGenderFemale => 'Femme';

  @override
  String get onboardingProfileGenderOther => 'Autre / Préfère ne pas dire';

  @override
  String get onboardingProfileHeight => 'Taille (cm)';

  @override
  String get onboardingProfileWeight => 'Poids (kg)';

  @override
  String get onboardingProfileActivity => 'Niveau d\'activité';

  @override
  String get onboardingProfileActivitySedentary =>
      'Sédentaire (travail de bureau)';

  @override
  String get onboardingProfileActivityLight => 'Légèrement actif';

  @override
  String get onboardingProfileActivityModerate => 'Modérément actif';

  @override
  String get onboardingProfileActivityActive => 'Très actif';

  @override
  String get onboardingDietTitle => 'Régime';

  @override
  String get onboardingDietAllergies => 'Allergies';

  @override
  String get onboardingDietPreference => 'Préférence alimentaire';

  @override
  String get onboardingDietAllergyLactose => 'Lactose';

  @override
  String get onboardingDietAllergyGluten => 'Gluten';

  @override
  String get onboardingDietAllergyPeanut => 'Arachide';

  @override
  String get onboardingDietAllergyNut => 'Noix';

  @override
  String get onboardingDietAllergyEgg => 'Œuf';

  @override
  String get onboardingDietAllergyShellfish => 'Crustacés';

  @override
  String get onboardingDietAllergySoy => 'Soja';

  @override
  String get onboardingDietAllergySesame => 'Sésame';

  @override
  String get onboardingDietAllergyFish => 'Poisson';

  @override
  String get onboardingDietPrefNone => 'Pas de préférence particulière';

  @override
  String get onboardingDietPrefVegetarian => 'Végétarien';

  @override
  String get onboardingDietPrefVegan => 'Végan';

  @override
  String get onboardingDietPrefPescatarian => 'Pescatarien (poisson seulement)';

  @override
  String get onboardingDietPrefHalal => 'Halal';

  @override
  String get onboardingDietPrefKosher => 'Casher';

  @override
  String get onboardingDietPrefOther => 'Autre';

  @override
  String get onboardingCoachTitle => 'Ton coach';

  @override
  String get onboardingCoachQuestion => 'Comment ton coach devrait parler?';

  @override
  String get onboardingCoachSubtitle => 'Tu peux changer à tout moment.';

  @override
  String get onboardingCoachKind => 'Gentil';

  @override
  String get onboardingCoachKindDesc =>
      'Doux, sans pression, empathie d\'abord';

  @override
  String get onboardingCoachWitty => 'Spirituel';

  @override
  String get onboardingCoachWittyDesc =>
      'Léger, souriant, équilibré quand sérieux';

  @override
  String get onboardingCoachDirect => 'Direct';

  @override
  String get onboardingCoachDirectDesc => 'Court, clair, retours réalistes';

  @override
  String get onboardingCoachCalm => 'Calme';

  @override
  String get onboardingCoachCalmDesc => 'Sans jugement, patient, mesuré';

  @override
  String get onboardingCalorieTitle => 'Calories';

  @override
  String get onboardingCalorieReady => 'Ton objectif quotidien est prêt';

  @override
  String get onboardingCalorieDescription =>
      'Ce nombre est basé sur tes infos. Pas fixe — nous ajusterons ensemble selon tes journées.';

  @override
  String get onboardingCalorieDaily => 'Calories quotidiennes';

  @override
  String get onboardingCalorieKcal => 'kcal';

  @override
  String get onboardingCalorieNote =>
      'Calculé en fonction de l\'activité, l\'objectif et la situation. Révisé chaque mois.';

  @override
  String get onboardingNotificationTitle => 'Notifications';

  @override
  String get onboardingNotificationQuestion => 'Veux-tu des rappels doux?';

  @override
  String get onboardingNotificationDescription =>
      'Court soutien et rappels de repas de ton coach. Nous respectons les heures de silence.';

  @override
  String get onboardingNotificationYes => 'Oui, je veux';

  @override
  String get onboardingNotificationNo => 'Pas maintenant';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue.';

  @override
  String get onboardingWelcomeSubtitle => 'Nous sommes prêts.';

  @override
  String get onboardingWelcomeBody =>
      'Pas de pression, pas de jugement — juste toi et un coach à tes côtés.';

  @override
  String get onboardingWelcomeFirstStep => 'Idée première étape';

  @override
  String get onboardingWelcomeFirstStepDesc =>
      'Commence par un repas que tu as mangé aujourd\'hui. Prends une photo ou écris — ton coach se souvient du reste.';

  @override
  String get onboardingWelcomeStart => 'Commençons';

  @override
  String get onboardingWelcomePreparing => 'Préparation...';

  @override
  String get onboardingWelcomeError =>
      'Un problème inattendu est survenu, veux-tu réessayer?';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get homeGreetingMorning => 'Bonjour';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi';

  @override
  String get homeGreetingEvening => 'Bonsoir';

  @override
  String get homeTodayCalories => 'Calories d\'aujourd\'hui';

  @override
  String get homeRemainingCalories => 'Restant';

  @override
  String get homeAddMeal => 'Ajouter un repas';

  @override
  String get homeChat => 'Parler au coach';

  @override
  String get homeNoMeals => 'Aucun repas ajouté pour le moment';

  @override
  String get homeNoMealsHint => 'Prends une photo de ta nourriture ou écris';

  @override
  String get navHome => 'Accueil';

  @override
  String get navMeals => 'Repas';

  @override
  String get navCoach => 'Coach';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue système';

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
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumComingSoon => 'BIENTÔT';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsLogout => 'Déconnexion';

  @override
  String get settingsDeleteAccount => 'Supprimer mon compte';

  @override
  String get settingsVersion => 'Version';

  @override
  String get premiumTitle => 'Premium bientôt';

  @override
  String get premiumSubtitle =>
      'Tu peux utiliser Nuveli entièrement gratuitement pour le moment.';

  @override
  String get premiumFeatureUnlimited => 'Analyse de repas illimitée';

  @override
  String get premiumFeatureCoach => 'Coach IA avancé';

  @override
  String get premiumFeatureReports => 'Rapports hebdomadaires détaillés';

  @override
  String get premiumFeatureExport => 'Export de données';

  @override
  String get premiumNotifyMe => 'Me notifier quand prêt';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonError => 'Une erreur s\'est produite';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonOk => 'OK';

  @override
  String get settingsCoachTone => 'Ton du coach';

  @override
  String get settingsSupportSecurity => 'Support et sécurité';

  @override
  String get settingsHowAiWorks => 'Comment l\'IA fonctionne';

  @override
  String get settingsPrivacySafety => 'Confidentialité et sécurité';

  @override
  String get settingsAboutNuveli => 'À propos de Nuveli';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsSession => 'Session';

  @override
  String get settingsDangerZone => 'Zone dangereuse';

  @override
  String get settingsSignedInAs => 'Connecté en tant que';

  @override
  String get settingsLogoutTitle => 'Se déconnecter?';

  @override
  String get settingsLogoutBody =>
      'Tu auras besoin de ton e-mail et mot de passe pour te reconnecter.';

  @override
  String get settingsLogoutCancel => 'Annuler';

  @override
  String get settingsLogoutFailed => 'Déconnexion échouée.';

  @override
  String get premiumModalTitle => 'Premium bientôt!';

  @override
  String get premiumModalBody =>
      'Nous préparons l\'analyse illimitée des repas, le coaching avancé et les aperçus hebdomadaires.';

  @override
  String get premiumFeatureVoice => 'Coach vocal + 3 personas';

  @override
  String get premiumFeatureInsights => 'Aperçus hebdomadaires + mensuels';

  @override
  String get premiumUnderstood => 'Compris';

  @override
  String get passwordVeryWeak => 'Très faible';

  @override
  String get passwordWeak => 'Faible';

  @override
  String get passwordMedium => 'Moyen';

  @override
  String get passwordStrong => 'Fort';

  @override
  String get passwordVeryStrong => 'Très fort';

  @override
  String get homeErrorGeneric => 'Quelque chose s\'est mal passé';

  @override
  String get homeCoachLabel => 'Ton coach';

  @override
  String get homeToday => 'Aujourd\'hui';

  @override
  String get homeRemaining => 'restant';

  @override
  String get homeThisWeek => 'Cette semaine';

  @override
  String get homeMiniGoalTitle => 'Mini objectif du jour';

  @override
  String get homeMiniGoalDefault => 'Ajoute des protéines à un repas';

  @override
  String get homeAddMealLabel => 'Ajouter un repas';

  @override
  String get homeWater => 'Eau';

  @override
  String get homeWeight => 'Poids';

  @override
  String get homeMood => 'Humeur';

  @override
  String get homeAddWater => 'Ajouter de l\'eau';

  @override
  String get homeEnterWeight => 'Entrer le poids';

  @override
  String get homeMoodGreat => 'Super';

  @override
  String get homeMoodGood => 'Bien';

  @override
  String get homeMoodNeutral => 'Normal';

  @override
  String get homeMoodBad => 'Difficile';

  @override
  String get homeMoodRough => 'Très difficile';

  @override
  String get homeMoodPickOne => 'Choisis-en un';

  @override
  String get homeNoMealsTitle => 'Aucun repas ajouté';

  @override
  String get homeNoMealsMessage =>
      'Commence la journée en ajoutant ton premier repas';

  @override
  String get homeTodayMeals => 'Repas d\'aujourd\'hui';

  @override
  String get homeMealBreakfast => 'Petit-déjeuner';

  @override
  String get homeMealLunch => 'Déjeuner';

  @override
  String get homeMealDinner => 'Dîner';

  @override
  String get homeMealSnack => 'Collation';

  @override
  String get homeCalorieTarget => 'objectif';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target kcal objectif';
  }

  @override
  String get macroProtein => 'Protéines';

  @override
  String get macroCarb => 'Glucides';

  @override
  String get macroFat => 'Lipides';

  @override
  String get homeCravingText =>
      'Une envie? Pause 60 secondes, respire profondément.';

  @override
  String get notifMealReminders => 'Rappels de repas';

  @override
  String get notifMealRemindersDesc =>
      'Rappel doux au petit-déjeuner, déjeuner, dîner';

  @override
  String get notifCoachNudges => 'Coups de pouce du coach';

  @override
  String get notifCoachNudgesDesc =>
      'Messages de soutien et motivation personnels';

  @override
  String get notifWeeklySummary => 'Résumé hebdomadaire';

  @override
  String get notifWeeklySummaryDesc =>
      'Résumé du lundi matin de la semaine dernière';

  @override
  String get notifQuietHours => 'HEURES DE SILENCE';

  @override
  String get notifQuietHoursDesc => 'Aucune notification pendant ces heures.';

  @override
  String get notifQuietStart => 'Début';

  @override
  String get notifQuietEnd => 'Fin';

  @override
  String get notifSaved => 'Préférences enregistrées.';

  @override
  String get notifSaveFailed => 'Impossible d\'enregistrer.';

  @override
  String get notifLoadFailed => 'Impossible de charger.';

  @override
  String get coachSettingsTitle => 'Ton coach';

  @override
  String get coachSettingsQuestion => 'Comment ton coach devrait te parler?';

  @override
  String get coachSettingsSubtitle => 'Tu peux changer à tout moment.';
}
