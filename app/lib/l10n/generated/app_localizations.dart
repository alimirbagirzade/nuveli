import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli App'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In tr, this message translates to:
  /// **'AI Kalori Koçu'**
  String get appTagline;

  /// No description provided for @loginEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get loginPassword;

  /// No description provided for @loginPasswordRepeat.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get loginPasswordRepeat;

  /// No description provided for @loginForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In tr, this message translates to:
  /// **'Kaydol'**
  String get loginRegisterLink;

  /// No description provided for @signupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli ile sağlıklı beslenme yolculuğuna başla'**
  String get signupSubtitle;

  /// No description provided for @signupButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydol'**
  String get signupButton;

  /// No description provided for @signupHasAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get signupHasAccount;

  /// No description provided for @signupLoginLink.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signupLoginLink;

  /// No description provided for @signupTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kaydolarak Kullanım Koşulları ve Gizlilik Politikası\'nı kabul etmiş olursun.'**
  String get signupTerms;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre yanlış. Lütfen tekrar dene.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı henüz doğrulamadın. Gelen kutunu kontrol et.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile kayıtlı kullanıcı bulunamadı.'**
  String get authUserNotFound;

  /// No description provided for @authUserAlreadyRegistered.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.'**
  String get authUserAlreadyRegistered;

  /// No description provided for @authWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf. En az 6 karakter olmalı.'**
  String get authWeakPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta formatı geçersiz.'**
  String get authInvalidEmail;

  /// No description provided for @authRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Çok hızlı denedin. Lütfen birkaç saniye bekle.'**
  String get authRateLimit;

  /// No description provided for @authNetworkError.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantını kontrol et.'**
  String get authNetworkError;

  /// No description provided for @authSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun süresi doldu. Lütfen tekrar giriş yap.'**
  String get authSessionExpired;

  /// No description provided for @authGenericError.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Lütfen tekrar dene.'**
  String get authGenericError;

  /// No description provided for @ageGateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Önce yaşını öğrenelim'**
  String get ageGateTitle;

  /// No description provided for @ageGateSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Önerileri yaşına göre uyarlıyoruz.'**
  String get ageGateSubtitle;

  /// No description provided for @ageGateBirthYear.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yılı'**
  String get ageGateBirthYear;

  /// No description provided for @ageGateUnderageError.
  ///
  /// In tr, this message translates to:
  /// **'Üzgünüm, Nuveli 13 yaşından küçükler için uygun değil.'**
  String get ageGateUnderageError;

  /// No description provided for @ageGateContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get ageGateContinue;

  /// No description provided for @acceptanceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get acceptanceTitle;

  /// No description provided for @acceptanceHeader.
  ///
  /// In tr, this message translates to:
  /// **'Başlamadan önce'**
  String get acceptanceHeader;

  /// No description provided for @acceptanceSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli\'yi güvenli kullanman için 4 önemli not. Hepsini onaylaman gerekiyor.'**
  String get acceptanceSubtitle;

  /// No description provided for @acceptanceWellnessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli wellness uygulamasıdır'**
  String get acceptanceWellnessTitle;

  /// No description provided for @acceptanceWellnessBody.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. Özel sağlık durumların için doktorundan destek alman önemli.'**
  String get acceptanceWellnessBody;

  /// No description provided for @acceptanceWellnessCheck.
  ///
  /// In tr, this message translates to:
  /// **'Anladım. Nuveli doktorumun yerini almaz.'**
  String get acceptanceWellnessCheck;

  /// No description provided for @acceptanceAiTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI tahminleri yaklaşıktır'**
  String get acceptanceAiTitle;

  /// No description provided for @acceptanceAiBody.
  ///
  /// In tr, this message translates to:
  /// **'Yemek fotoğraflarından yaptığımız kalori ve besin değeri tahminleri yaklaşık sonuçlardır. Her zaman düzenleyebilirsin.'**
  String get acceptanceAiBody;

  /// No description provided for @acceptanceAiCheck.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçların yaklaşık olabileceğini biliyorum.'**
  String get acceptanceAiCheck;

  /// No description provided for @acceptanceSpecialTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel durumlarda dikkat'**
  String get acceptanceSpecialTitle;

  /// No description provided for @acceptanceSpecialBody.
  ///
  /// In tr, this message translates to:
  /// **'Hamilelik, emzirme, yeme bozukluğu geçmişi veya kronik hastalığın varsa, kalori önerilerini uygulamadan önce sağlık uzmanına danış.'**
  String get acceptanceSpecialBody;

  /// No description provided for @acceptanceSpecialCheck.
  ///
  /// In tr, this message translates to:
  /// **'Özel durumumda uzmana danışacağım.'**
  String get acceptanceSpecialCheck;

  /// No description provided for @acceptanceTermsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şartlar ve gizlilik'**
  String get acceptanceTermsTitle;

  /// No description provided for @acceptanceTermsBody.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları ve Gizlilik Politikası\'nı okuyup kabul etmelisin. Verilerin güvende tutulur ve ayarlar ekranından her zaman silebilirsin.'**
  String get acceptanceTermsBody;

  /// No description provided for @acceptanceTermsCheck.
  ///
  /// In tr, this message translates to:
  /// **'Şartları ve Gizlilik Politikası\'nı kabul ediyorum.'**
  String get acceptanceTermsCheck;

  /// No description provided for @acceptanceContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get acceptanceContinue;

  /// No description provided for @acceptanceCheckAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kutuları işaretle'**
  String get acceptanceCheckAll;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedefin ne?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalLose.
  ///
  /// In tr, this message translates to:
  /// **'Kilo vermek'**
  String get onboardingGoalLose;

  /// No description provided for @onboardingGoalMaintain.
  ///
  /// In tr, this message translates to:
  /// **'Kiloyu korumak'**
  String get onboardingGoalMaintain;

  /// No description provided for @onboardingGoalGain.
  ///
  /// In tr, this message translates to:
  /// **'Kas kazanmak'**
  String get onboardingGoalGain;

  /// No description provided for @onboardingSensitivityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hassasiyet'**
  String get onboardingSensitivityTitle;

  /// No description provided for @onboardingSensitivityQ1.
  ///
  /// In tr, this message translates to:
  /// **'1. Geçmişte yeme alışkanlıklarınla zorlandığın bir dönem oldu mu?'**
  String get onboardingSensitivityQ1;

  /// No description provided for @onboardingSensitivityQ1A1.
  ///
  /// In tr, this message translates to:
  /// **'Hayır, böyle bir dönem olmadı'**
  String get onboardingSensitivityQ1A1;

  /// No description provided for @onboardingSensitivityQ1A2.
  ///
  /// In tr, this message translates to:
  /// **'Eskiden vardı, şimdi iyiyim'**
  String get onboardingSensitivityQ1A2;

  /// No description provided for @onboardingSensitivityQ1A3.
  ///
  /// In tr, this message translates to:
  /// **'Evet, hâlâ zaman zaman zorlanıyorum'**
  String get onboardingSensitivityQ1A3;

  /// No description provided for @onboardingSensitivityQ1A4.
  ///
  /// In tr, this message translates to:
  /// **'Söylemek istemiyorum'**
  String get onboardingSensitivityQ1A4;

  /// No description provided for @onboardingSensitivityQ2.
  ///
  /// In tr, this message translates to:
  /// **'2. Şu an yiyecekle ilişkini nasıl tarif edersin?'**
  String get onboardingSensitivityQ2;

  /// No description provided for @onboardingSensitivityQ2A1.
  ///
  /// In tr, this message translates to:
  /// **'Rahat, kontrolüm var'**
  String get onboardingSensitivityQ2A1;

  /// No description provided for @onboardingSensitivityQ2A2.
  ///
  /// In tr, this message translates to:
  /// **'Karışık günlerim oluyor'**
  String get onboardingSensitivityQ2A2;

  /// No description provided for @onboardingSensitivityQ2A3.
  ///
  /// In tr, this message translates to:
  /// **'Çoğu zaman zorluyor'**
  String get onboardingSensitivityQ2A3;

  /// No description provided for @onboardingSensitivityQ2A4.
  ///
  /// In tr, this message translates to:
  /// **'Söylemek istemiyorum'**
  String get onboardingSensitivityQ2A4;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Senden biraz bahset'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileGender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get onboardingProfileGender;

  /// No description provided for @onboardingProfileGenderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get onboardingProfileGenderMale;

  /// No description provided for @onboardingProfileGenderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get onboardingProfileGenderFemale;

  /// No description provided for @onboardingProfileGenderOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer / Belirtmek istemiyorum'**
  String get onboardingProfileGenderOther;

  /// No description provided for @onboardingProfileHeight.
  ///
  /// In tr, this message translates to:
  /// **'Boy (cm)'**
  String get onboardingProfileHeight;

  /// No description provided for @onboardingProfileWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo (kg)'**
  String get onboardingProfileWeight;

  /// No description provided for @onboardingProfileActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite seviyesi'**
  String get onboardingProfileActivity;

  /// No description provided for @onboardingProfileActivitySedentary.
  ///
  /// In tr, this message translates to:
  /// **'Hareketsiz (masa başı)'**
  String get onboardingProfileActivitySedentary;

  /// No description provided for @onboardingProfileActivityLight.
  ///
  /// In tr, this message translates to:
  /// **'Hafif aktif'**
  String get onboardingProfileActivityLight;

  /// No description provided for @onboardingProfileActivityModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta aktif'**
  String get onboardingProfileActivityModerate;

  /// No description provided for @onboardingProfileActivityActive.
  ///
  /// In tr, this message translates to:
  /// **'Çok aktif'**
  String get onboardingProfileActivityActive;

  /// No description provided for @onboardingDietTitle.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme'**
  String get onboardingDietTitle;

  /// No description provided for @onboardingDietAllergies.
  ///
  /// In tr, this message translates to:
  /// **'Alerjiler'**
  String get onboardingDietAllergies;

  /// No description provided for @onboardingDietPreference.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme tercihi'**
  String get onboardingDietPreference;

  /// No description provided for @onboardingDietAllergyLactose.
  ///
  /// In tr, this message translates to:
  /// **'Laktoz'**
  String get onboardingDietAllergyLactose;

  /// No description provided for @onboardingDietAllergyGluten.
  ///
  /// In tr, this message translates to:
  /// **'Gluten içeren'**
  String get onboardingDietAllergyGluten;

  /// No description provided for @onboardingDietAllergyPeanut.
  ///
  /// In tr, this message translates to:
  /// **'Yer fıstığı'**
  String get onboardingDietAllergyPeanut;

  /// No description provided for @onboardingDietAllergyNut.
  ///
  /// In tr, this message translates to:
  /// **'Kuruyemiş'**
  String get onboardingDietAllergyNut;

  /// No description provided for @onboardingDietAllergyEgg.
  ///
  /// In tr, this message translates to:
  /// **'Yumurta'**
  String get onboardingDietAllergyEgg;

  /// No description provided for @onboardingDietAllergyShellfish.
  ///
  /// In tr, this message translates to:
  /// **'Kabuklu deniz ürünü'**
  String get onboardingDietAllergyShellfish;

  /// No description provided for @onboardingDietAllergySoy.
  ///
  /// In tr, this message translates to:
  /// **'Soya'**
  String get onboardingDietAllergySoy;

  /// No description provided for @onboardingDietAllergySesame.
  ///
  /// In tr, this message translates to:
  /// **'Susam'**
  String get onboardingDietAllergySesame;

  /// No description provided for @onboardingDietAllergyFish.
  ///
  /// In tr, this message translates to:
  /// **'Balık'**
  String get onboardingDietAllergyFish;

  /// No description provided for @onboardingDietPrefNone.
  ///
  /// In tr, this message translates to:
  /// **'Belirli bir tercih yok'**
  String get onboardingDietPrefNone;

  /// No description provided for @onboardingDietPrefVegetarian.
  ///
  /// In tr, this message translates to:
  /// **'Vejetaryen'**
  String get onboardingDietPrefVegetarian;

  /// No description provided for @onboardingDietPrefVegan.
  ///
  /// In tr, this message translates to:
  /// **'Vegan beslenme'**
  String get onboardingDietPrefVegan;

  /// No description provided for @onboardingDietPrefPescatarian.
  ///
  /// In tr, this message translates to:
  /// **'Peskatarian (sadece balık)'**
  String get onboardingDietPrefPescatarian;

  /// No description provided for @onboardingDietPrefHalal.
  ///
  /// In tr, this message translates to:
  /// **'Helal'**
  String get onboardingDietPrefHalal;

  /// No description provided for @onboardingDietPrefKosher.
  ///
  /// In tr, this message translates to:
  /// **'Koşer'**
  String get onboardingDietPrefKosher;

  /// No description provided for @onboardingDietPrefOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get onboardingDietPrefOther;

  /// No description provided for @onboardingCoachTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koçun'**
  String get onboardingCoachTitle;

  /// No description provided for @onboardingCoachQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Koçun nasıl konuşsun?'**
  String get onboardingCoachQuestion;

  /// No description provided for @onboardingCoachSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin zaman değiştirebilirsin.'**
  String get onboardingCoachSubtitle;

  /// No description provided for @onboardingCoachKind.
  ///
  /// In tr, this message translates to:
  /// **'Nazik'**
  String get onboardingCoachKind;

  /// No description provided for @onboardingCoachKindDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yumuşak, baskısız, empati önce'**
  String get onboardingCoachKindDesc;

  /// No description provided for @onboardingCoachWitty.
  ///
  /// In tr, this message translates to:
  /// **'Esprili'**
  String get onboardingCoachWitty;

  /// No description provided for @onboardingCoachWittyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hafif, gülümseten, ciddi anlarda dengeli'**
  String get onboardingCoachWittyDesc;

  /// No description provided for @onboardingCoachDirect.
  ///
  /// In tr, this message translates to:
  /// **'Doğrudan'**
  String get onboardingCoachDirect;

  /// No description provided for @onboardingCoachDirectDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kısa, net, gerçekçi geri bildirim'**
  String get onboardingCoachDirectDesc;

  /// No description provided for @onboardingCoachCalm.
  ///
  /// In tr, this message translates to:
  /// **'Sakin'**
  String get onboardingCoachCalm;

  /// No description provided for @onboardingCoachCalmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yargılamayan, sabırlı, ölçülü'**
  String get onboardingCoachCalmDesc;

  /// No description provided for @onboardingCalorieTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kalori'**
  String get onboardingCalorieTitle;

  /// No description provided for @onboardingCalorieReady.
  ///
  /// In tr, this message translates to:
  /// **'Senin için günlük hedefin hazır'**
  String get onboardingCalorieReady;

  /// No description provided for @onboardingCalorieDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu sayı verdiğin bilgilere göre. Sabit değil — senin günlerine göre birlikte ayarlayacağız.'**
  String get onboardingCalorieDescription;

  /// No description provided for @onboardingCalorieDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kalori'**
  String get onboardingCalorieDaily;

  /// No description provided for @onboardingCalorieKcal.
  ///
  /// In tr, this message translates to:
  /// **'kalori'**
  String get onboardingCalorieKcal;

  /// No description provided for @onboardingCalorieNote.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite, hedef ve duruma göre hesaplandı. Her ay yeniden gözden geçirilir.'**
  String get onboardingCalorieNote;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hafif hatırlatmalar ister misin?'**
  String get onboardingNotificationQuestion;

  /// No description provided for @onboardingNotificationDescription.
  ///
  /// In tr, this message translates to:
  /// **'Koçundan kısa destek ve öğün hatırlatmaları. Sessiz saatlere saygı duyarız.'**
  String get onboardingNotificationDescription;

  /// No description provided for @onboardingNotificationYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet, istiyorum'**
  String get onboardingNotificationYes;

  /// No description provided for @onboardingNotificationNo.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik hayır'**
  String get onboardingNotificationNo;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazırız.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In tr, this message translates to:
  /// **'Baskı yok, yargı yok — sadece sen ve yanında bir koç.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeFirstStep.
  ///
  /// In tr, this message translates to:
  /// **'İlk adım fikri'**
  String get onboardingWelcomeFirstStep;

  /// No description provided for @onboardingWelcomeFirstStepDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bugün ne yediğini bir öğünle başlat. Fotoğraf çek ya da yaz — koçun gerisini hatırlasın.'**
  String get onboardingWelcomeFirstStepDesc;

  /// No description provided for @onboardingWelcomeStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım'**
  String get onboardingWelcomeStart;

  /// No description provided for @onboardingWelcomePreparing.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlanıyor...'**
  String get onboardingWelcomePreparing;

  /// No description provided for @onboardingWelcomeError.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir sorun oldu, tekrar dener misin?'**
  String get onboardingWelcomeError;

  /// No description provided for @onboardingContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingContinue;

  /// No description provided for @homeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get homeTitle;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Tünaydın'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar'**
  String get homeGreetingEvening;

  /// No description provided for @homeTodayCalories.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü kalori'**
  String get homeTodayCalories;

  /// No description provided for @homeRemainingCalories.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get homeRemainingCalories;

  /// No description provided for @homeAddMeal.
  ///
  /// In tr, this message translates to:
  /// **'Öğün ekle'**
  String get homeAddMeal;

  /// No description provided for @homeChat.
  ///
  /// In tr, this message translates to:
  /// **'Koç ile konuş'**
  String get homeChat;

  /// No description provided for @homeNoMeals.
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğün eklemedin'**
  String get homeNoMeals;

  /// No description provided for @homeNoMealsHint.
  ///
  /// In tr, this message translates to:
  /// **'Yemeğinin fotoğrafını çek ya da yaz'**
  String get homeNoMealsHint;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get navHome;

  /// No description provided for @navMeals.
  ///
  /// In tr, this message translates to:
  /// **'Öğünler'**
  String get navMeals;

  /// No description provided for @navCoach.
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get navCoach;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get settingsAccount;

  /// No description provided for @settingsProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem dili'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'🇹🇷 Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageGerman.
  ///
  /// In tr, this message translates to:
  /// **'Almanca'**
  String get settingsLanguageGerman;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In tr, this message translates to:
  /// **'Fransızca'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In tr, this message translates to:
  /// **'İspanyolca'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get settingsThemeSystem;

  /// No description provided for @settingsPremium.
  ///
  /// In tr, this message translates to:
  /// **'PREMİUM'**
  String get settingsPremium;

  /// No description provided for @settingsPremiumComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'YAKINDA'**
  String get settingsPremiumComingSoon;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get settingsPrivacy;

  /// No description provided for @settingsSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get settingsSupport;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get settingsVersion;

  /// No description provided for @premiumTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium yakında'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an Nuveli\'yi tamamen ücretsiz kullanabilirsin.'**
  String get premiumSubtitle;

  /// No description provided for @premiumFeatureUnlimited.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız öğün analizi'**
  String get premiumFeatureUnlimited;

  /// No description provided for @premiumFeatureCoach.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş AI koç'**
  String get premiumFeatureCoach;

  /// No description provided for @premiumFeatureReports.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı haftalık raporlar'**
  String get premiumFeatureReports;

  /// No description provided for @premiumFeatureExport.
  ///
  /// In tr, this message translates to:
  /// **'Veri dışa aktarma'**
  String get premiumFeatureExport;

  /// No description provided for @premiumNotifyMe.
  ///
  /// In tr, this message translates to:
  /// **'Hazır olunca haberim olsun'**
  String get premiumNotifyMe;

  /// No description provided for @commonContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get commonSuccess;

  /// No description provided for @commonYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// No description provided for @settingsCoachTone.
  ///
  /// In tr, this message translates to:
  /// **'Koçun tonu'**
  String get settingsCoachTone;

  /// No description provided for @settingsSupportSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Destek ve Güvenlik'**
  String get settingsSupportSecurity;

  /// No description provided for @settingsHowAiWorks.
  ///
  /// In tr, this message translates to:
  /// **'AI nasıl çalışır'**
  String get settingsHowAiWorks;

  /// No description provided for @settingsPrivacySafety.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get settingsPrivacySafety;

  /// No description provided for @settingsAboutNuveli.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli Hakkında'**
  String get settingsAboutNuveli;

  /// No description provided for @settingsSubscription.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik'**
  String get settingsSubscription;

  /// No description provided for @settingsSession.
  ///
  /// In tr, this message translates to:
  /// **'Oturum'**
  String get settingsSession;

  /// No description provided for @settingsDangerZone.
  ///
  /// In tr, this message translates to:
  /// **'Tehlikeli Bölge'**
  String get settingsDangerZone;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapan'**
  String get settingsSignedInAs;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar giriş yapmak için email ve şifren gerekecek.'**
  String get settingsLogoutBody;

  /// No description provided for @settingsLogoutCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get settingsLogoutCancel;

  /// No description provided for @settingsLogoutFailed.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılamadı.'**
  String get settingsLogoutFailed;

  /// No description provided for @premiumModalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium çok yakında!'**
  String get premiumModalTitle;

  /// No description provided for @premiumModalBody.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız AI öğün analizi, gelişmiş koç ve haftalık içgörüler için son hazırlıkları yapıyoruz.'**
  String get premiumModalBody;

  /// No description provided for @premiumFeatureVoice.
  ///
  /// In tr, this message translates to:
  /// **'Sesli koç + 3 persona'**
  String get premiumFeatureVoice;

  /// No description provided for @premiumFeatureInsights.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık + aylık içgörü'**
  String get premiumFeatureInsights;

  /// No description provided for @premiumUnderstood.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get premiumUnderstood;

  /// No description provided for @passwordVeryWeak.
  ///
  /// In tr, this message translates to:
  /// **'Çok zayıf'**
  String get passwordVeryWeak;

  /// No description provided for @passwordWeak.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü'**
  String get passwordStrong;

  /// No description provided for @passwordVeryStrong.
  ///
  /// In tr, this message translates to:
  /// **'Çok güçlü'**
  String get passwordVeryStrong;

  /// No description provided for @homeErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get homeErrorGeneric;

  /// No description provided for @homeCoachLabel.
  ///
  /// In tr, this message translates to:
  /// **'Koçun'**
  String get homeCoachLabel;

  /// No description provided for @homeToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get homeToday;

  /// No description provided for @homeRemaining.
  ///
  /// In tr, this message translates to:
  /// **'kaldı'**
  String get homeRemaining;

  /// No description provided for @homeThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get homeThisWeek;

  /// No description provided for @homeMiniGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Mini Hedef'**
  String get homeMiniGoalTitle;

  /// No description provided for @homeMiniGoalDefault.
  ///
  /// In tr, this message translates to:
  /// **'Bir öğüne protein ekle'**
  String get homeMiniGoalDefault;

  /// No description provided for @homeAddMealLabel.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Ekle'**
  String get homeAddMealLabel;

  /// No description provided for @homeWater.
  ///
  /// In tr, this message translates to:
  /// **'Su'**
  String get homeWater;

  /// No description provided for @homeWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get homeWeight;

  /// No description provided for @homeMood.
  ///
  /// In tr, this message translates to:
  /// **'Mod'**
  String get homeMood;

  /// No description provided for @homeAddWater.
  ///
  /// In tr, this message translates to:
  /// **'Su Ekle'**
  String get homeAddWater;

  /// No description provided for @homeEnterWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilonu Girin'**
  String get homeEnterWeight;

  /// No description provided for @homeMoodGreat.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get homeMoodGreat;

  /// No description provided for @homeMoodGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get homeMoodGood;

  /// No description provided for @homeMoodNeutral.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get homeMoodNeutral;

  /// No description provided for @homeMoodBad.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get homeMoodBad;

  /// No description provided for @homeMoodRough.
  ///
  /// In tr, this message translates to:
  /// **'Çok Zor'**
  String get homeMoodRough;

  /// No description provided for @homeMoodPickOne.
  ///
  /// In tr, this message translates to:
  /// **'Bir tane seç'**
  String get homeMoodPickOne;

  /// No description provided for @homeNoMealsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğün eklenmedi'**
  String get homeNoMealsTitle;

  /// No description provided for @homeNoMealsMessage.
  ///
  /// In tr, this message translates to:
  /// **'İlk öğününü ekleyerek günü başlat'**
  String get homeNoMealsMessage;

  /// No description provided for @homeTodayMeals.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü öğünler'**
  String get homeTodayMeals;

  /// No description provided for @homeMealBreakfast.
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı'**
  String get homeMealBreakfast;

  /// No description provided for @homeMealLunch.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get homeMealLunch;

  /// No description provided for @homeMealDinner.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get homeMealDinner;

  /// No description provided for @homeMealSnack.
  ///
  /// In tr, this message translates to:
  /// **'Atıştırmalık'**
  String get homeMealSnack;

  /// No description provided for @homeCalorieTarget.
  ///
  /// In tr, this message translates to:
  /// **'hedefi'**
  String get homeCalorieTarget;

  /// No description provided for @homeCalorieTargetLine.
  ///
  /// In tr, this message translates to:
  /// **'/ {target} kcal hedefi'**
  String homeCalorieTargetLine(int target);

  /// No description provided for @macroProtein.
  ///
  /// In tr, this message translates to:
  /// **'Proteinler'**
  String get macroProtein;

  /// No description provided for @macroCarb.
  ///
  /// In tr, this message translates to:
  /// **'Karb'**
  String get macroCarb;

  /// No description provided for @macroFat.
  ///
  /// In tr, this message translates to:
  /// **'Yağ'**
  String get macroFat;

  /// No description provided for @homeCravingText.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeye canın çekiyor mu? 60 saniye dur, derin nefes al.'**
  String get homeCravingText;

  /// No description provided for @notifMealReminders.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Hatırlatıcıları'**
  String get notifMealReminders;

  /// No description provided for @notifMealRemindersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı, öğle, akşam zamanı nazik hatırlatma'**
  String get notifMealRemindersDesc;

  /// No description provided for @notifCoachNudges.
  ///
  /// In tr, this message translates to:
  /// **'Koç Nüdgleri'**
  String get notifCoachNudges;

  /// No description provided for @notifCoachNudgesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel destek ve motivasyon mesajları'**
  String get notifCoachNudgesDesc;

  /// No description provided for @notifWeeklySummary.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Özet'**
  String get notifWeeklySummary;

  /// No description provided for @notifWeeklySummaryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Pazartesi sabahı geçen haftanın özeti'**
  String get notifWeeklySummaryDesc;

  /// No description provided for @notifQuietHours.
  ///
  /// In tr, this message translates to:
  /// **'SESSİZ SAATLER'**
  String get notifQuietHours;

  /// No description provided for @notifQuietHoursDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu saatler arasında hiçbir bildirim gelmez.'**
  String get notifQuietHoursDesc;

  /// No description provided for @notifQuietStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get notifQuietStart;

  /// No description provided for @notifQuietEnd.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get notifQuietEnd;

  /// No description provided for @notifSaved.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler kaydedildi.'**
  String get notifSaved;

  /// No description provided for @notifSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi.'**
  String get notifSaveFailed;

  /// No description provided for @notifLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi.'**
  String get notifLoadFailed;

  /// No description provided for @coachSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koçun'**
  String get coachSettingsTitle;

  /// No description provided for @coachSettingsQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Koçun seninle nasıl konuşsun?'**
  String get coachSettingsQuestion;

  /// No description provided for @coachSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin zaman değiştirebilirsin.'**
  String get coachSettingsSubtitle;

  /// No description provided for @onboardingMoreMeasures.
  ///
  /// In tr, this message translates to:
  /// **'Birkaç ölçüm daha'**
  String get onboardingMoreMeasures;

  /// No description provided for @onboardingActivityLevel.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite düzeyin'**
  String get onboardingActivityLevel;

  /// No description provided for @onboardingFirstMeal.
  ///
  /// In tr, this message translates to:
  /// **'İlk öğünümü ekleyelim'**
  String get onboardingFirstMeal;

  /// No description provided for @onboardingGoToHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana ekrana geç'**
  String get onboardingGoToHome;

  /// No description provided for @onboardingBirthYear.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yılı'**
  String get onboardingBirthYear;

  /// No description provided for @onboardingGender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get onboardingGender;

  /// No description provided for @settingsAppearance.
  ///
  /// In tr, this message translates to:
  /// **'GÖRÜNÜM'**
  String get settingsAppearance;

  /// No description provided for @supportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get supportTitle;

  /// No description provided for @supportEmailSubject.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli Destek'**
  String get supportEmailSubject;

  /// No description provided for @howAiTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI Nasıl Çalışır'**
  String get howAiTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get privacyTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli Hakkında'**
  String get aboutTitle;

  /// No description provided for @coachToneUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Koç tonun güncellendi'**
  String get coachToneUpdated;

  /// No description provided for @supportHowHelp.
  ///
  /// In tr, this message translates to:
  /// **'Size nasıl yardım edebiliriz?'**
  String get supportHowHelp;

  /// No description provided for @supportEmailCard.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile ulaş'**
  String get supportEmailCard;

  /// No description provided for @supportFaq.
  ///
  /// In tr, this message translates to:
  /// **'SSS'**
  String get supportFaq;

  /// No description provided for @supportFaqDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça sorulan sorular ve cevaplar'**
  String get supportFaqDesc;

  /// No description provided for @aiBlockFood.
  ///
  /// In tr, this message translates to:
  /// **'Yemek Tanıma'**
  String get aiBlockFood;

  /// No description provided for @aiBlockFoodBody.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafını incelerim ve yaklaşık kalori/besin tahmini yaparım. Bu kesin bir ölçüm değildir — gerekirse düzeltebilirsin.'**
  String get aiBlockFoodBody;

  /// No description provided for @aiBlockCoach.
  ///
  /// In tr, this message translates to:
  /// **'Koç Yanıtları'**
  String get aiBlockCoach;

  /// No description provided for @aiBlockCoachBody.
  ///
  /// In tr, this message translates to:
  /// **'Kısa, yargısız ve destekleyici mesajlar üretirim. Tıbbi tavsiye ya da diyet planı sunmam.'**
  String get aiBlockCoachBody;

  /// No description provided for @aiBlockSafety.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get aiBlockSafety;

  /// No description provided for @aiBlockSafetyBody.
  ///
  /// In tr, this message translates to:
  /// **'Riskli durumlarda profesyonel destek kaynaklarını gösteririm. Kriz anında doğrudan sabit güvenlik metni gelir.'**
  String get aiBlockSafetyBody;

  /// No description provided for @aiBlockData.
  ///
  /// In tr, this message translates to:
  /// **'Verilerin'**
  String get aiBlockData;

  /// No description provided for @aiBlockDataBody.
  ///
  /// In tr, this message translates to:
  /// **'Verilerin şifreli iletilir ve sadece sen erişirsin. Ayarlar > Hesabı Sil ile tamamen silebilirsin.'**
  String get aiBlockDataBody;

  /// No description provided for @privacyHeading.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğin bizim önceliğimiz'**
  String get privacyHeading;

  /// No description provided for @privacyBody.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli bir wellness uygulamasıdır. Tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. Zor bir dönemden geçiyorsan lütfen profesyonel destek al.'**
  String get privacyBody;

  /// No description provided for @privacyEmergency.
  ///
  /// In tr, this message translates to:
  /// **'Acil Destek'**
  String get privacyEmergency;

  /// No description provided for @privacyHotline.
  ///
  /// In tr, this message translates to:
  /// **'ALO 182 — Psikolojik Destek Hattı (7/24)'**
  String get privacyHotline;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyLink;

  /// No description provided for @privacyTermsLink.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get privacyTermsLink;

  /// No description provided for @privacyDownload.
  ///
  /// In tr, this message translates to:
  /// **'Verimi İndir'**
  String get privacyDownload;

  /// No description provided for @aboutApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama'**
  String get aboutApp;

  /// No description provided for @aboutLinks.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar'**
  String get aboutLinks;

  /// No description provided for @aboutWebsite.
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi'**
  String get aboutWebsite;

  /// No description provided for @aboutTechnical.
  ///
  /// In tr, this message translates to:
  /// **'Teknik'**
  String get aboutTechnical;

  /// No description provided for @aboutEnv.
  ///
  /// In tr, this message translates to:
  /// **'Ortam'**
  String get aboutEnv;

  /// No description provided for @aboutCopyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2026 Nuveli. Tüm hakları saklıdır.'**
  String get aboutCopyright;

  /// No description provided for @aboutCopied.
  ///
  /// In tr, this message translates to:
  /// **'kopyalandı'**
  String get aboutCopied;

  /// No description provided for @aboutVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get aboutVersion;

  /// No description provided for @streakDay.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get streakDay;

  /// No description provided for @streakDays.
  ///
  /// In tr, this message translates to:
  /// **'günlük seri'**
  String get streakDays;

  /// No description provided for @streakLongest.
  ///
  /// In tr, this message translates to:
  /// **'En uzun serin'**
  String get streakLongest;

  /// No description provided for @streakTodayDone.
  ///
  /// In tr, this message translates to:
  /// **'Bugün de hallettin'**
  String get streakTodayDone;

  /// No description provided for @streakSummary.
  ///
  /// In tr, this message translates to:
  /// **'{current} günlük seri'**
  String streakSummary(int current);

  /// No description provided for @streakExplanation.
  ///
  /// In tr, this message translates to:
  /// **'Streak\'in arka arkaya öğün eklediğin gün sayısıdır.'**
  String get streakExplanation;

  /// No description provided for @weeklyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Özet'**
  String get weeklyTitle;

  /// No description provided for @weeklyLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get weeklyLoadFailed;

  /// No description provided for @weeklyChartLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi'**
  String get weeklyChartLoadFailed;

  /// No description provided for @commonRetryLow.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get commonRetryLow;

  /// No description provided for @dayMon.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get daySun;

  /// No description provided for @dayDetailMeals.
  ///
  /// In tr, this message translates to:
  /// **'Öğünler'**
  String get dayDetailMeals;

  /// No description provided for @dayDetailMealsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Öğünler yüklenemedi'**
  String get dayDetailMealsLoadFailed;

  /// No description provided for @dayDetailNoMeals.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için öğün kaydı yok'**
  String get dayDetailNoMeals;

  /// No description provided for @dayDetailWaterMl.
  ///
  /// In tr, this message translates to:
  /// **'{ml} ml su'**
  String dayDetailWaterMl(int ml);

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In tr, this message translates to:
  /// **'Atıştırmalık'**
  String get mealTypeSnack;

  /// No description provided for @mealTypeOther.
  ///
  /// In tr, this message translates to:
  /// **'Öğün'**
  String get mealTypeOther;

  /// No description provided for @weeklyMacroDist.
  ///
  /// In tr, this message translates to:
  /// **'Makro Dağılımı'**
  String get weeklyMacroDist;

  /// No description provided for @weeklyDailyDetail.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Detay'**
  String get weeklyDailyDetail;

  /// No description provided for @weeklyCoachComment.
  ///
  /// In tr, this message translates to:
  /// **'KOÇUN YORUMU'**
  String get weeklyCoachComment;

  /// No description provided for @weeklyCoachCommentLocked.
  ///
  /// In tr, this message translates to:
  /// **'Koçun yorumu'**
  String get weeklyCoachCommentLocked;

  /// No description provided for @weeklyCoachCommentLockedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Premium ile haftalık örüntülerin için kişisel yorum'**
  String get weeklyCoachCommentLockedDesc;

  /// No description provided for @streakLastLog.
  ///
  /// In tr, this message translates to:
  /// **'Son kayıt: {date}'**
  String streakLastLog(String date);

  /// No description provided for @streakNow.
  ///
  /// In tr, this message translates to:
  /// **'Şu an'**
  String get streakNow;

  /// No description provided for @streakLongestShort.
  ///
  /// In tr, this message translates to:
  /// **'En uzun'**
  String get streakLongestShort;

  /// No description provided for @streakAddMealNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Öğün Ekle'**
  String get streakAddMealNow;

  /// No description provided for @streakAtRisk.
  ///
  /// In tr, this message translates to:
  /// **'Bugün öğün eklemedin ve akşam oldu. Şimdi bir öğün eklersen serin devam eder; aksi halde yarın sıfırdan başlayacak.'**
  String get streakAtRisk;

  /// No description provided for @streakNotStarted.
  ///
  /// In tr, this message translates to:
  /// **'Streak henüz başlamadı. İlk öğününü ekle ve serin başlasın.'**
  String get streakNotStarted;

  /// No description provided for @streakTodayLogged.
  ///
  /// In tr, this message translates to:
  /// **'Bugünü de hallettin! Yarın da bir öğün eklersen seri devam eder.'**
  String get streakTodayLogged;

  /// No description provided for @streakExplanationDefault.
  ///
  /// In tr, this message translates to:
  /// **'Streak\'in arka arkaya öğün eklediğin gün sayısıdır.'**
  String get streakExplanationDefault;

  /// No description provided for @weeklyAvgKcal.
  ///
  /// In tr, this message translates to:
  /// **'kcal/gün ortalama'**
  String get weeklyAvgKcal;

  /// No description provided for @weeklyTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get weeklyTotal;

  /// No description provided for @weeklyMeals.
  ///
  /// In tr, this message translates to:
  /// **'Öğün'**
  String get weeklyMeals;

  /// No description provided for @weeklyLogged.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt'**
  String get weeklyLogged;

  /// No description provided for @coachChatTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get coachChatTitle;

  /// No description provided for @coachChatPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Koçuna bir şey sor...'**
  String get coachChatPlaceholder;

  /// No description provided for @coachChatSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get coachChatSend;

  /// No description provided for @waterHowMuch.
  ///
  /// In tr, this message translates to:
  /// **'Ne kadar içtin?'**
  String get waterHowMuch;

  /// No description provided for @waterHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get waterHistory;

  /// No description provided for @weightInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir kilo girin (1-500 kg).'**
  String get weightInvalid;

  /// No description provided for @weightKg.
  ///
  /// In tr, this message translates to:
  /// **'Kilogram'**
  String get weightKg;

  /// No description provided for @moodHowToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün nasılsın?'**
  String get moodHowToday;

  /// No description provided for @mealCameraNotAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik gerçek cihazda çalışır. Galeriden seçebilirsin.'**
  String get mealCameraNotAvailable;

  /// No description provided for @mealGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get mealGallery;

  /// No description provided for @weeklyDaysLogged.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün kayıt yaptın. İyi bir ilerleme.'**
  String weeklyDaysLogged(int n);

  /// No description provided for @coachWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba! Bugün nasıl hissediyorsun?'**
  String get coachWelcome;

  /// No description provided for @coachInputPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Mesajını yaz...'**
  String get coachInputPlaceholder;

  /// No description provided for @coachLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi.'**
  String get coachLoadFailed;

  /// No description provided for @coachSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönderilemedi.'**
  String get coachSendFailed;

  /// No description provided for @coachLimitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük mesaj limiti doldu'**
  String get coachLimitTitle;

  /// No description provided for @coachLimitBody.
  ///
  /// In tr, this message translates to:
  /// **'{reason}\n\nPremium ile sınırsız koç sohbeti + sesli yanıtlara erişebilirsin.'**
  String coachLimitBody(String reason);

  /// No description provided for @coachLater.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get coachLater;

  /// No description provided for @coachSeePremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a bak'**
  String get coachSeePremium;

  /// No description provided for @coachCrisisTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an yalnız değilsin'**
  String get coachCrisisTitle;

  /// No description provided for @coachDistressTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zor bir an geçiriyor olabilirsin'**
  String get coachDistressTitle;

  /// No description provided for @coachCrisisBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu konuda seninle olmak istiyoruz ama doğru destek için bir uzmana ulaşman çok önemli.'**
  String get coachCrisisBody;

  /// No description provided for @coachDistressBody.
  ///
  /// In tr, this message translates to:
  /// **'Koçun bu tür durumlarda yardımcı olamaz. Seninle ilgilenen birine ulaşmak her zaman bir seçenek.'**
  String get coachDistressBody;

  /// No description provided for @mealAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Ekle'**
  String get mealAddTitle;

  /// No description provided for @mealPhotoOrDesc.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf veya açıklama'**
  String get mealPhotoOrDesc;

  /// No description provided for @mealNoPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf eklenmedi'**
  String get mealNoPhoto;

  /// No description provided for @mealCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get mealCamera;

  /// No description provided for @mealGalleryBtn.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get mealGalleryBtn;

  /// No description provided for @mealSimulatorWarn.
  ///
  /// In tr, this message translates to:
  /// **'Simulator\'de kamera yok. Galeri\'yi kullan.'**
  String get mealSimulatorWarn;

  /// No description provided for @mealDescHint.
  ///
  /// In tr, this message translates to:
  /// **'Yemeğini açıkla:\n• Ne? (örn. Adana kebap)\n• Ne kadar? (örn. 200g, 1 porsiyon)\n• Yanında? (örn. lavaş, pilav)'**
  String get mealDescHint;

  /// No description provided for @mealAnalyze.
  ///
  /// In tr, this message translates to:
  /// **'Analiz Et'**
  String get mealAnalyze;

  /// No description provided for @mealManualEntry.
  ///
  /// In tr, this message translates to:
  /// **'Elle gir'**
  String get mealManualEntry;

  /// No description provided for @mealAnalyzeFailed.
  ///
  /// In tr, this message translates to:
  /// **'Analiz yapılamadı.'**
  String get mealAnalyzeFailed;

  /// No description provided for @mealLimitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük limit doldu'**
  String get mealLimitTitle;

  /// No description provided for @mealLimitBody.
  ///
  /// In tr, this message translates to:
  /// **'{reason}\n\nPremium ile sınırsız fotoğraf analizi yapabilirsin.'**
  String mealLimitBody(String reason);

  /// No description provided for @waterHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Su Geçmişi'**
  String get waterHistoryTitle;

  /// No description provided for @weightHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kilo Geçmişi'**
  String get weightHistoryTitle;

  /// No description provided for @monthJan.
  ///
  /// In tr, this message translates to:
  /// **'Ocak'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In tr, this message translates to:
  /// **'Şubat'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In tr, this message translates to:
  /// **'Mart'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In tr, this message translates to:
  /// **'Nisan'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In tr, this message translates to:
  /// **'Mayıs'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In tr, this message translates to:
  /// **'Haziran'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In tr, this message translates to:
  /// **'Temmuz'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In tr, this message translates to:
  /// **'Ağustos'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In tr, this message translates to:
  /// **'Eylül'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In tr, this message translates to:
  /// **'Ekim'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In tr, this message translates to:
  /// **'Kasım'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In tr, this message translates to:
  /// **'Aralık'**
  String get monthDec;

  /// No description provided for @weekdayMon.
  ///
  /// In tr, this message translates to:
  /// **'Pazartesi'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In tr, this message translates to:
  /// **'Salı'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In tr, this message translates to:
  /// **'Çarşamba'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In tr, this message translates to:
  /// **'Perşembe'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In tr, this message translates to:
  /// **'Cuma'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In tr, this message translates to:
  /// **'Cumartesi'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In tr, this message translates to:
  /// **'Pazar'**
  String get weekdaySun;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu (Gece)'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık (Gündüz)'**
  String get themeLight;

  /// No description provided for @personaGentle.
  ///
  /// In tr, this message translates to:
  /// **'Nazik'**
  String get personaGentle;

  /// No description provided for @personaGentleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yumuşak, baskısız, empati önce'**
  String get personaGentleDesc;

  /// No description provided for @personaGentleSample.
  ///
  /// In tr, this message translates to:
  /// **'\"Bugün biraz zor olduğunu görüyorum. Bir öğün eksik kalsa da kendine sert davranma.\"'**
  String get personaGentleSample;

  /// No description provided for @personaFunny.
  ///
  /// In tr, this message translates to:
  /// **'Esprili'**
  String get personaFunny;

  /// No description provided for @personaFunnyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hafif, gülümseten, ciddi anlarda dengeli'**
  String get personaFunnyDesc;

  /// No description provided for @personaFunnySample.
  ///
  /// In tr, this message translates to:
  /// **'\"Pizza akşamı, anladım. Hayat zaten bir denge işi — yarın salata, bu akşam mutluluk.\"'**
  String get personaFunnySample;

  /// No description provided for @personaDirect.
  ///
  /// In tr, this message translates to:
  /// **'Doğrudan'**
  String get personaDirect;

  /// No description provided for @personaDirectDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kısa, net, gerçekçi geri bildirim'**
  String get personaDirectDesc;

  /// No description provided for @personaDirectSample.
  ///
  /// In tr, this message translates to:
  /// **'\"Bugün protein az. Akşam yemekte 25-30g hedefle, hafta dengesi tutar.\"'**
  String get personaDirectSample;

  /// No description provided for @personaCalm.
  ///
  /// In tr, this message translates to:
  /// **'Sakin'**
  String get personaCalm;

  /// No description provided for @personaCalmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yargılamayan, sabırlı, ölçülü'**
  String get personaCalmDesc;

  /// No description provided for @personaCalmSample.
  ///
  /// In tr, this message translates to:
  /// **'\"Düşünmeden yedik bazen. Önemli olan farkına varmak. Sonraki öğüne odaklanalım.\"'**
  String get personaCalmSample;

  /// No description provided for @coachToneQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Koçun seninle nasıl konuşsun?'**
  String get coachToneQuestion;

  /// No description provided for @coachToneSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin zaman değiştirebilirsin.'**
  String get coachToneSubtitle;

  /// No description provided for @coachToneSaving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get coachToneSaving;

  /// No description provided for @coachToneSaveError.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedemedim. Bağlantını kontrol edip tekrar dener misin?'**
  String get coachToneSaveError;

  /// No description provided for @coachToneSaveErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir sorun oldu, tekrar dener misin?'**
  String get coachToneSaveErrorGeneric;

  /// No description provided for @waterLastDays.
  ///
  /// In tr, this message translates to:
  /// **'Son {n} gün'**
  String waterLastDays(int n);

  /// No description provided for @waterLitresTotal.
  ///
  /// In tr, this message translates to:
  /// **'L toplam'**
  String get waterLitresTotal;

  /// No description provided for @waterToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get waterToday;

  /// No description provided for @waterAverage.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama'**
  String get waterAverage;

  /// No description provided for @waterLast7.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Gün'**
  String get waterLast7;

  /// No description provided for @waterGoalMl.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {ml} ml/gün'**
  String waterGoalMl(int ml);

  /// No description provided for @waterAllDays.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Günler'**
  String get waterAllDays;

  /// No description provided for @waterNoRecord.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt yok'**
  String get waterNoRecord;

  /// No description provided for @waterDaysCount.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün'**
  String waterDaysCount(int n);

  /// No description provided for @weightCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Güncel kilo'**
  String get weightCurrent;

  /// No description provided for @weightFirstRecord.
  ///
  /// In tr, this message translates to:
  /// **'İlk kayıt'**
  String get weightFirstRecord;

  /// No description provided for @weightTrend.
  ///
  /// In tr, this message translates to:
  /// **'Trend ({n} kayıt)'**
  String weightTrend(int n);

  /// No description provided for @weightRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlar'**
  String get weightRecords;

  /// No description provided for @weightEntryCount.
  ///
  /// In tr, this message translates to:
  /// **'{n} giriş'**
  String weightEntryCount(int n);

  /// No description provided for @monthShortJan.
  ///
  /// In tr, this message translates to:
  /// **'Oca'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In tr, this message translates to:
  /// **'Şub'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In tr, this message translates to:
  /// **'Mart'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In tr, this message translates to:
  /// **'Nis'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In tr, this message translates to:
  /// **'Mayıs'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In tr, this message translates to:
  /// **'Haz'**
  String get monthShortJun;

  /// No description provided for @monthShortJul.
  ///
  /// In tr, this message translates to:
  /// **'Tem'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In tr, this message translates to:
  /// **'Ağu'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In tr, this message translates to:
  /// **'Eyl'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In tr, this message translates to:
  /// **'Eki'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In tr, this message translates to:
  /// **'Kas'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get monthShortDec;

  /// No description provided for @todayBadge.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜN'**
  String get todayBadge;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil yüklenemedi.'**
  String get profileLoadFailed;

  /// No description provided for @profileAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get profileAccount;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel bilgiler'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSub.
  ///
  /// In tr, this message translates to:
  /// **'İsim, hedefler, vücut bilgileri'**
  String get profilePersonalInfoSub;

  /// No description provided for @profileGoals.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get profileGoals;

  /// No description provided for @profileGoalsSub.
  ///
  /// In tr, this message translates to:
  /// **'Kalori ve makro hedefin'**
  String get profileGoalsSub;

  /// No description provided for @profileNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get profileNotifications;

  /// No description provided for @profileNotifPrefs.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihleri'**
  String get profileNotifPrefs;

  /// No description provided for @profileNotifPrefsSub.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcılar ve sessiz saatler'**
  String get profileNotifPrefsSub;

  /// No description provided for @profileTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get profileTheme;

  /// No description provided for @profileDarkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık tema'**
  String get profileDarkTheme;

  /// No description provided for @profileDarkThemeSub.
  ///
  /// In tr, this message translates to:
  /// **'Şu an aktif (varsayılan)'**
  String get profileDarkThemeSub;

  /// No description provided for @profilePremium.
  ///
  /// In tr, this message translates to:
  /// **'PREMİUM'**
  String get profilePremium;

  /// No description provided for @profilePremiumSub.
  ///
  /// In tr, this message translates to:
  /// **'Plan, fatura ve özellikler'**
  String get profilePremiumSub;

  /// No description provided for @profilePremiumMy.
  ///
  /// In tr, this message translates to:
  /// **'Premium aboneliğim'**
  String get profilePremiumMy;

  /// No description provided for @profileHelpSafety.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve güvenlik'**
  String get profileHelpSafety;

  /// No description provided for @profileSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get profileSupport;

  /// No description provided for @profileSupportSub.
  ///
  /// In tr, this message translates to:
  /// **'Sorular ve geri bildirim'**
  String get profileSupportSub;

  /// No description provided for @profileHowAi.
  ///
  /// In tr, this message translates to:
  /// **'AI nasıl çalışır'**
  String get profileHowAi;

  /// No description provided for @profilePrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve güvenlik'**
  String get profilePrivacy;

  /// No description provided for @profileAbout.
  ///
  /// In tr, this message translates to:
  /// **'Nuveli hakkında'**
  String get profileAbout;

  /// No description provided for @profileLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get profileLogout;

  /// No description provided for @profileSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get profileDeleteAccount;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabından çıkmak istediğine emin misin?'**
  String get profileSignOutConfirm;

  /// No description provided for @homeGreetingNoonTime.
  ///
  /// In tr, this message translates to:
  /// **'Tünaydın'**
  String get homeGreetingNoonTime;

  /// No description provided for @profileStreakNow.
  ///
  /// In tr, this message translates to:
  /// **'Şu an'**
  String get profileStreakNow;

  /// No description provided for @profileStreakLongest.
  ///
  /// In tr, this message translates to:
  /// **'En uzun'**
  String get profileStreakLongest;

  /// No description provided for @profileStreakDay.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get profileStreakDay;

  /// No description provided for @personalInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bilgiler'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get personalInfoEdit;

  /// No description provided for @personalInfoSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler kaydedildi'**
  String get personalInfoSaved;

  /// No description provided for @personalInfoSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi'**
  String get personalInfoSaveFailed;

  /// No description provided for @personalInfoLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get personalInfoLoadFailed;

  /// No description provided for @personalInfoSecAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get personalInfoSecAccount;

  /// No description provided for @personalInfoSecBody.
  ///
  /// In tr, this message translates to:
  /// **'Vücut bilgileri'**
  String get personalInfoSecBody;

  /// No description provided for @personalInfoSecActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite'**
  String get personalInfoSecActivity;

  /// No description provided for @personalInfoName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get personalInfoName;

  /// No description provided for @personalInfoEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get personalInfoEmail;

  /// No description provided for @personalInfoBirthYear.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yılı'**
  String get personalInfoBirthYear;

  /// No description provided for @personalInfoGender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get personalInfoGender;

  /// No description provided for @personalInfoHeight.
  ///
  /// In tr, this message translates to:
  /// **'Boy'**
  String get personalInfoHeight;

  /// No description provided for @personalInfoHeightCm.
  ///
  /// In tr, this message translates to:
  /// **'Boy (cm)'**
  String get personalInfoHeightCm;

  /// No description provided for @personalInfoWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get personalInfoWeight;

  /// No description provided for @personalInfoWeightKg.
  ///
  /// In tr, this message translates to:
  /// **'Kilo (kg)'**
  String get personalInfoWeightKg;

  /// No description provided for @personalInfoActivityLevel.
  ///
  /// In tr, this message translates to:
  /// **'Günlük aktivite seviyesi'**
  String get personalInfoActivityLevel;

  /// No description provided for @personalInfoActivityLevelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite seviyesi'**
  String get personalInfoActivityLevelLabel;

  /// No description provided for @personalInfoCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get personalInfoCancel;

  /// No description provided for @personalInfoSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get personalInfoSave;

  /// No description provided for @personalInfoSaving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get personalInfoSaving;

  /// No description provided for @genderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get genderOther;

  /// No description provided for @activitySedentary.
  ///
  /// In tr, this message translates to:
  /// **'Hareketsiz'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryFull.
  ///
  /// In tr, this message translates to:
  /// **'Hareketsiz (masa başı)'**
  String get activitySedentaryFull;

  /// No description provided for @activityLight.
  ///
  /// In tr, this message translates to:
  /// **'Hafif aktif'**
  String get activityLight;

  /// No description provided for @activityLightFull.
  ///
  /// In tr, this message translates to:
  /// **'Hafif aktif (1-3 gün)'**
  String get activityLightFull;

  /// No description provided for @activityModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta aktif'**
  String get activityModerate;

  /// No description provided for @activityModerateFull.
  ///
  /// In tr, this message translates to:
  /// **'Orta aktif (3-5 gün)'**
  String get activityModerateFull;

  /// No description provided for @activityActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get activityActive;

  /// No description provided for @activityActiveFull.
  ///
  /// In tr, this message translates to:
  /// **'Aktif (6-7 gün)'**
  String get activityActiveFull;

  /// No description provided for @activityVeryActive.
  ///
  /// In tr, this message translates to:
  /// **'Çok aktif'**
  String get activityVeryActive;

  /// No description provided for @activityVeryActiveFull.
  ///
  /// In tr, this message translates to:
  /// **'Çok aktif (sporcu)'**
  String get activityVeryActiveFull;

  /// No description provided for @goalsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get goalsTitle;

  /// No description provided for @goalsUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler güncellendi'**
  String get goalsUpdated;

  /// No description provided for @goalsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get goalsLoadFailed;

  /// No description provided for @goalsSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi'**
  String get goalsSaveFailed;

  /// No description provided for @goalsSecPurpose.
  ///
  /// In tr, this message translates to:
  /// **'Amaç'**
  String get goalsSecPurpose;

  /// No description provided for @goalsSecDailyCalorie.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kalori hedefi'**
  String get goalsSecDailyCalorie;

  /// No description provided for @goalsSecMacroDist.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen makro dağılımı'**
  String get goalsSecMacroDist;

  /// No description provided for @goalsLoseWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo vermek'**
  String get goalsLoseWeight;

  /// No description provided for @goalsLoseWeightDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kalori açığıyla tedrici düşüş'**
  String get goalsLoseWeightDesc;

  /// No description provided for @goalsMaintain.
  ///
  /// In tr, this message translates to:
  /// **'Kiloyu korumak'**
  String get goalsMaintain;

  /// No description provided for @goalsMaintainDesc.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut kiloyu sürdürmek'**
  String get goalsMaintainDesc;

  /// No description provided for @goalsGainMuscle.
  ///
  /// In tr, this message translates to:
  /// **'Kas almak'**
  String get goalsGainMuscle;

  /// No description provided for @goalsGainMuscleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kalori fazlasıyla yapı kazanmak'**
  String get goalsGainMuscleDesc;

  /// No description provided for @goalsMacroNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu öneri 25% protein, 50% karbonhidrat, 25% yağ dağılımına göredir. Koçun sana özel olarak ayarlayabilir.'**
  String get goalsMacroNote;

  /// No description provided for @goalsSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get goalsSave;

  /// No description provided for @premiumComingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium çok yakında! 🚀'**
  String get premiumComingTitle;

  /// No description provided for @premiumComingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız AI öğün analizi, sesli koç ve haftalık içgörüler için son hazırlıkları yapıyoruz. Hazır olduğumuzda bildiririz.'**
  String get premiumComingDesc;

  /// No description provided for @premiumFeatureCharts.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş grafikler ve eğilimler'**
  String get premiumFeatureCharts;

  /// No description provided for @premiumGotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get premiumGotIt;

  /// No description provided for @todayMealsCount.
  ///
  /// In tr, this message translates to:
  /// **'{n} öğün'**
  String todayMealsCount(int n);

  /// No description provided for @todayMealDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öğünü sil?'**
  String get todayMealDeleteTitle;

  /// No description provided for @todayMealDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" silinecek. Bu işlem geri alınamaz.'**
  String todayMealDeleteMessage(String name);

  /// No description provided for @todayMealDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get todayMealDeleteConfirm;

  /// No description provided for @todayMealDeleteCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get todayMealDeleteCancel;

  /// No description provided for @todayMealDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Öğün silindi.'**
  String get todayMealDeleted;

  /// No description provided for @todayMealDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Silinemedi.'**
  String get todayMealDeleteFailed;

  /// No description provided for @mealTypeBreakfastShort.
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı'**
  String get mealTypeBreakfastShort;

  /// No description provided for @mealTypeLunchShort.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get mealTypeLunchShort;

  /// No description provided for @mealTypeDinnerShort.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get mealTypeDinnerShort;

  /// No description provided for @mealTypeSnackShort.
  ///
  /// In tr, this message translates to:
  /// **'Atıştırma'**
  String get mealTypeSnackShort;

  /// No description provided for @streakLongestNeverActive.
  ///
  /// In tr, this message translates to:
  /// **'En uzun serin: {longest} gün'**
  String streakLongestNeverActive(int longest);

  /// No description provided for @streakTodayDoneSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün de hallettin · En uzun: {longest} gün'**
  String streakTodayDoneSubtitle(int longest);

  /// No description provided for @streakTodayMissedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünü de eklemeyi unutma · En uzun: {longest}'**
  String streakTodayMissedSubtitle(int longest);

  /// No description provided for @waterAllDaysList.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Günler'**
  String get waterAllDaysList;

  /// No description provided for @waterTodayBadge.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜN'**
  String get waterTodayBadge;

  /// No description provided for @waterNoEntry.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt yok'**
  String get waterNoEntry;

  /// No description provided for @weightRecordsList.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlar'**
  String get weightRecordsList;

  /// No description provided for @weightEntriesCount.
  ///
  /// In tr, this message translates to:
  /// **'{n} giriş'**
  String weightEntriesCount(int n);

  /// No description provided for @historyDaysSuffix.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün'**
  String historyDaysSuffix(int n);

  /// No description provided for @moodGreat.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get moodGreat;

  /// No description provided for @moodGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get moodGood;

  /// No description provided for @moodNeutral.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get moodNeutral;

  /// No description provided for @moodBad.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get moodBad;

  /// No description provided for @moodRough.
  ///
  /// In tr, this message translates to:
  /// **'Çok Zor'**
  String get moodRough;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı Doğrula'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine bir doğrulama linki gönderdik. Linke tıkladığında otomatik olarak devam edeceksin.'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @verifyEmailWaitingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Email bekleniyor...'**
  String get verifyEmailWaitingTitle;

  /// No description provided for @verifyEmailWaitingBody.
  ///
  /// In tr, this message translates to:
  /// **'E-postandaki linke tıklamadan ilerleyemezsin. Spam klasörünü de kontrol et.'**
  String get verifyEmailWaitingBody;

  /// No description provided for @verifyEmailResend.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder ({seconds}sn)'**
  String verifyEmailResendIn(String seconds);

  /// No description provided for @verifyEmailResent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni doğrulama emaili gönderildi.'**
  String get verifyEmailResent;

  /// No description provided for @verifyEmailSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Farklı email kullan / Çıkış'**
  String get verifyEmailSignOut;

  /// Mood bubble after logging a meal while still under the daily calorie target.
  ///
  /// In tr, this message translates to:
  /// **'Özenle kaydedildi. Bugün hâlâ alanın var, acelesi yok.'**
  String get coachBubbleGentleMealUnder;

  /// Mood bubble after logging a meal that puts the day over target. Must be non-judgmental, no shame, no compensation.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi. Tek bir öğün gününü tanımlamaz. Kendine nazik ol.'**
  String get coachBubbleGentleMealOver;

  /// Mood bubble after logging a meal that leaves the day near target (balanced).
  ///
  /// In tr, this message translates to:
  /// **'Bugün güzel bir denge. Bedenini dinliyorsun.'**
  String get coachBubbleGentleMealOnTrack;

  /// Mood bubble nudging the user when water intake is behind for the time of day.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi biraz su iyi gelirdi, hazır olduğunda.'**
  String get coachBubbleGentleWaterLow;

  /// Mood bubble celebrating a logging-streak milestone.
  ///
  /// In tr, this message translates to:
  /// **'Her gün usulca buradasın. İşte bu gerçek.'**
  String get coachBubbleGentleStreakMilestone;

  /// Mood bubble after the first meal of the day is logged (fresh-start framing).
  ///
  /// In tr, this message translates to:
  /// **'İlk öğün girildi. Güne yumuşak, sakin bir başlangıç.'**
  String get coachBubbleGentleFirstMeal;

  /// Mood bubble after logging a meal while still under the daily calorie target.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi! Daha çok yerin var — çatal kalkışa hazır.'**
  String get coachBubbleFunnyMealUnder;

  /// Mood bubble after logging a meal that puts the day over target. Must be non-judgmental, no shame, no compensation.
  ///
  /// In tr, this message translates to:
  /// **'Bol öğün, bol keyif. Yarın yine lezzetli bir sayfa.'**
  String get coachBubbleFunnyMealOver;

  /// Mood bubble after logging a meal that leaves the day near target (balanced).
  ///
  /// In tr, this message translates to:
  /// **'Şefin öpücüğü. Dengeyle artık can ciğersiniz.'**
  String get coachBubbleFunnyMealOnTrack;

  /// Mood bubble nudging the user when water intake is behind for the time of day.
  ///
  /// In tr, this message translates to:
  /// **'Su şişen biraz küsmüş gibi. Söylemeden geçmeyeyim.'**
  String get coachBubbleFunnyWaterLow;

  /// Mood bubble celebrating a logging-streak milestone.
  ///
  /// In tr, this message translates to:
  /// **'Seri sağlam gidiyor — birileri formda!'**
  String get coachBubbleFunnyStreakMilestone;

  /// Mood bubble after the first meal of the day is logged (fresh-start framing).
  ///
  /// In tr, this message translates to:
  /// **'Kahvaltı kulübü bildiriyor. Güne lezzetli bir başlangıç.'**
  String get coachBubbleFunnyFirstMeal;

  /// Mood bubble after logging a meal while still under the daily calorie target.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi. Günün kalanına yer var — iyi planla.'**
  String get coachBubbleDirectMealUnder;

  /// Mood bubble after logging a meal that puts the day over target. Must be non-judgmental, no shame, no compensation.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi, biraz fazla. Dert değil — sonraki öğünleri ayarla.'**
  String get coachBubbleDirectMealOver;

  /// Mood bubble after logging a meal that leaves the day near target (balanced).
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi. Tam yolunda. Böyle devam.'**
  String get coachBubbleDirectMealOnTrack;

  /// Mood bubble nudging the user when water intake is behind for the time of day.
  ///
  /// In tr, this message translates to:
  /// **'Su bugün geride. Bir bardak al.'**
  String get coachBubbleDirectWaterLow;

  /// Mood bubble celebrating a logging-streak milestone.
  ///
  /// In tr, this message translates to:
  /// **'Seri tutuyor. İşi yapan istikrar.'**
  String get coachBubbleDirectStreakMilestone;

  /// Mood bubble after the first meal of the day is logged (fresh-start framing).
  ///
  /// In tr, this message translates to:
  /// **'İlk öğün girildi. Güzel — günün tonunu belirle.'**
  String get coachBubbleDirectFirstMeal;

  /// Mood bubble after logging a meal while still under the daily calorie target.
  ///
  /// In tr, this message translates to:
  /// **'Not edildi. İlerisi açık. Kendi temponla ilerle.'**
  String get coachBubbleCalmMealUnder;

  /// Mood bubble after logging a meal that puts the day over target. Must be non-judgmental, no shame, no compensation.
  ///
  /// In tr, this message translates to:
  /// **'Not edildi. Önemli olan farkındalık. Sonraki öğün senin.'**
  String get coachBubbleCalmMealOver;

  /// Mood bubble after logging a meal that leaves the day near target (balanced).
  ///
  /// In tr, this message translates to:
  /// **'Not edildi. Dengeli ve sakin — huzurlu bir ilerleme.'**
  String get coachBubbleCalmMealOnTrack;

  /// Mood bubble nudging the user when water intake is behind for the time of day.
  ///
  /// In tr, this message translates to:
  /// **'Su biraz az. Baskı yok — uygun olduğunda yudumla.'**
  String get coachBubbleCalmWaterLow;

  /// Mood bubble celebrating a logging-streak milestone.
  ///
  /// In tr, this message translates to:
  /// **'Her gün sessiz bir istikrar. Bu sayılır.'**
  String get coachBubbleCalmStreakMilestone;

  /// Mood bubble after the first meal of the day is logged (fresh-start framing).
  ///
  /// In tr, this message translates to:
  /// **'İlk öğün not edildi. Güne sakin bir başlangıç.'**
  String get coachBubbleCalmFirstMeal;

  /// Meal history screen app-bar title.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Geçmişi'**
  String get mealHistoryTitle;

  /// Day-group header for the previous day in meal history.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get historyYesterday;

  /// Empty-state title on the meal history screen.
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğün eklenmedi'**
  String get mealHistoryEmptyTitle;

  /// Empty-state body on the meal history screen.
  ///
  /// In tr, this message translates to:
  /// **'Eklediğin öğünler burada güne göre gruplanır.'**
  String get mealHistoryEmptyBody;

  /// Settings: settingsCoachSection
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get settingsCoachSection;

  /// Settings: settingsYourData
  ///
  /// In tr, this message translates to:
  /// **'Verilerin'**
  String get settingsYourData;

  /// Settings: settingsExportData
  ///
  /// In tr, this message translates to:
  /// **'Verilerimi Dışa Aktar'**
  String get settingsExportData;

  /// Settings: settingsExportDataDesc
  ///
  /// In tr, this message translates to:
  /// **'Tüm öğün, su, kilo, alışkanlık ve içgörü kayıtlarını JSON olarak indir. Veri taşınabilirliği hakkı (KVKK / GDPR Mad. 20).'**
  String get settingsExportDataDesc;

  /// Settings: settingsExportFailed
  ///
  /// In tr, this message translates to:
  /// **'Verilerin dışa aktarılamadı.'**
  String get settingsExportFailed;

  /// Settings: settingsDeleteDesc
  ///
  /// In tr, this message translates to:
  /// **'Profilini, öğünlerini ve tüm verilerini kalıcı olarak siler.'**
  String get settingsDeleteDesc;

  /// Settings: settingsDeleteTitle
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinsin mi?'**
  String get settingsDeleteTitle;

  /// Settings: settingsDeleteConfirmBody
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem profilini, tüm öğün, su, kilo geçmişini, alışkanlıkları ve abonelikleri kalıcı olarak siler. Geri alınamaz.'**
  String get settingsDeleteConfirmBody;

  /// Settings: settingsDeleteType
  ///
  /// In tr, this message translates to:
  /// **'Onaylamak için DELETE yaz:'**
  String get settingsDeleteType;

  /// Settings: settingsDeleteFailed
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinemedi.'**
  String get settingsDeleteFailed;

  /// Settings: settingsLanguageItalian
  ///
  /// In tr, this message translates to:
  /// **'İtalyanca'**
  String get settingsLanguageItalian;

  /// Settings: settingsLanguageRussian
  ///
  /// In tr, this message translates to:
  /// **'Rusça'**
  String get settingsLanguageRussian;

  /// Coach: coachTodaysTips
  ///
  /// In tr, this message translates to:
  /// **'Bugünün ipuçları'**
  String get coachTodaysTips;

  /// Coach: coachNutritionScore
  ///
  /// In tr, this message translates to:
  /// **'Beslenme puanı'**
  String get coachNutritionScore;

  /// Coach: coachScoreHigh
  ///
  /// In tr, this message translates to:
  /// **'Sağlam bir gün — böyle devam.'**
  String get coachScoreHigh;

  /// Coach: coachScoreMid
  ///
  /// In tr, this message translates to:
  /// **'Çoğunlukla yolunda. Küçük bir ayar çok şey değiştirir.'**
  String get coachScoreMid;

  /// Coach: coachScoreMixed
  ///
  /// In tr, this message translates to:
  /// **'Karışık sinyaller — bugün tek bir şeye odaklanalım.'**
  String get coachScoreMixed;

  /// Coach: coachScoreReset
  ///
  /// In tr, this message translates to:
  /// **'Nazik bir sıfırlama iyi gelir. Aşağıdan bir ipucu seç.'**
  String get coachScoreReset;

  /// Coach: coachOfflineTitle
  ///
  /// In tr, this message translates to:
  /// **'Koç çevrimdışı'**
  String get coachOfflineTitle;

  /// Coach: coachRegenerate
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get coachRegenerate;

  /// Coach: coachRegenerateUpgrade
  ///
  /// In tr, this message translates to:
  /// **'Yenilemek için yükselt'**
  String get coachRegenerateUpgrade;

  /// Coach: coachRegenerateFree
  ///
  /// In tr, this message translates to:
  /// **'Yenile (günde 1 ücretsiz)'**
  String get coachRegenerateFree;

  /// Coach: coachScoreExcellent
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel'**
  String get coachScoreExcellent;

  /// Coach: coachScoreOnTrack
  ///
  /// In tr, this message translates to:
  /// **'Yolunda'**
  String get coachScoreOnTrack;

  /// Coach: coachScoreImprove
  ///
  /// In tr, this message translates to:
  /// **'Gelişebilir'**
  String get coachScoreImprove;

  /// Coach: coachScoreNeedsCare
  ///
  /// In tr, this message translates to:
  /// **'Özen gerek'**
  String get coachScoreNeedsCare;

  /// Coach: coachRecommendedStep
  ///
  /// In tr, this message translates to:
  /// **'Önerilen sonraki adım'**
  String get coachRecommendedStep;

  /// Coach: coachActionHabitAdded
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık eklendi'**
  String get coachActionHabitAdded;

  /// Coach: coachActionWaterLogged
  ///
  /// In tr, this message translates to:
  /// **'Su eklendi'**
  String get coachActionWaterLogged;

  /// Coach: coachActionReminderSet
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı ayarlandı'**
  String get coachActionReminderSet;

  /// Coach: coachActionTargetUpdated
  ///
  /// In tr, this message translates to:
  /// **'Hedef güncellendi'**
  String get coachActionTargetUpdated;

  /// Coach: coachActionDone
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get coachActionDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ru',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
