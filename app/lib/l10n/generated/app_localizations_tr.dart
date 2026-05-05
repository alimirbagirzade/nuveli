// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nuveli';

  @override
  String get appTagline => 'AI Kalori Koçu';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginPasswordRepeat => 'Şifre Tekrar';

  @override
  String get loginForgotPassword => 'Şifremi unuttum';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginNoAccount => 'Hesabın yok mu?';

  @override
  String get loginRegisterLink => 'Kaydol';

  @override
  String get signupTitle => 'Hesap Oluştur';

  @override
  String get signupSubtitle => 'Nuveli ile sağlıklı beslenme yolculuğuna başla';

  @override
  String get signupButton => 'Kaydol';

  @override
  String get signupHasAccount => 'Zaten hesabın var mı?';

  @override
  String get signupLoginLink => 'Giriş Yap';

  @override
  String get signupTerms =>
      'Kaydolarak Kullanım Koşulları ve Gizlilik Politikası\'nı kabul etmiş olursun.';

  @override
  String get authInvalidCredentials =>
      'E-posta veya şifre yanlış. Lütfen tekrar dene.';

  @override
  String get authEmailNotConfirmed =>
      'E-postanı henüz doğrulamadın. Gelen kutunu kontrol et.';

  @override
  String get authUserNotFound => 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';

  @override
  String get authUserAlreadyRegistered =>
      'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.';

  @override
  String get authWeakPassword => 'Şifre çok zayıf. En az 6 karakter olmalı.';

  @override
  String get authInvalidEmail => 'E-posta formatı geçersiz.';

  @override
  String get authRateLimit => 'Çok hızlı denedin. Lütfen birkaç saniye bekle.';

  @override
  String get authNetworkError => 'İnternet bağlantını kontrol et.';

  @override
  String get authSessionExpired =>
      'Oturumun süresi doldu. Lütfen tekrar giriş yap.';

  @override
  String get authGenericError => 'Bir sorun oluştu. Lütfen tekrar dene.';

  @override
  String get ageGateTitle => 'Önce yaşını öğrenelim';

  @override
  String get ageGateSubtitle => 'Önerileri yaşına göre uyarlıyoruz.';

  @override
  String get ageGateBirthYear => 'Doğum yılı';

  @override
  String get ageGateUnderageError =>
      'Üzgünüm, Nuveli 13 yaşından küçükler için uygun değil.';

  @override
  String get ageGateContinue => 'Devam et';

  @override
  String get acceptanceTitle => 'Bilgilendirme';

  @override
  String get acceptanceHeader => 'Başlamadan önce';

  @override
  String get acceptanceSubtitle =>
      'Nuveli\'yi güvenli kullanman için 4 önemli not. Hepsini onaylaman gerekiyor.';

  @override
  String get acceptanceWellnessTitle => 'Nuveli wellness uygulamasıdır';

  @override
  String get acceptanceWellnessBody =>
      'Nuveli tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. Özel sağlık durumların için doktorundan destek alman önemli.';

  @override
  String get acceptanceWellnessCheck =>
      'Anladım. Nuveli doktorumun yerini almaz.';

  @override
  String get acceptanceAiTitle => 'AI tahminleri yaklaşıktır';

  @override
  String get acceptanceAiBody =>
      'Yemek fotoğraflarından yaptığımız kalori ve besin değeri tahminleri yaklaşık sonuçlardır. Her zaman düzenleyebilirsin.';

  @override
  String get acceptanceAiCheck =>
      'Sonuçların yaklaşık olabileceğini biliyorum.';

  @override
  String get acceptanceSpecialTitle => 'Özel durumlarda dikkat';

  @override
  String get acceptanceSpecialBody =>
      'Hamilelik, emzirme, yeme bozukluğu geçmişi veya kronik hastalığın varsa, kalori önerilerini uygulamadan önce sağlık uzmanına danış.';

  @override
  String get acceptanceSpecialCheck => 'Özel durumumda uzmana danışacağım.';

  @override
  String get acceptanceTermsTitle => 'Şartlar ve gizlilik';

  @override
  String get acceptanceTermsBody =>
      'Kullanım Şartları ve Gizlilik Politikası\'nı okuyup kabul etmelisin. Verilerin güvende tutulur ve ayarlar ekranından her zaman silebilirsin.';

  @override
  String get acceptanceTermsCheck =>
      'Şartları ve Gizlilik Politikası\'nı kabul ediyorum.';

  @override
  String get acceptanceContinue => 'Devam et';

  @override
  String get acceptanceCheckAll => 'Tüm kutuları işaretle';

  @override
  String get onboardingGoalTitle => 'Hedefin ne?';

  @override
  String get onboardingGoalLose => 'Kilo vermek';

  @override
  String get onboardingGoalMaintain => 'Kiloyu korumak';

  @override
  String get onboardingGoalGain => 'Kas kazanmak';

  @override
  String get onboardingSensitivityTitle => 'Hassasiyet';

  @override
  String get onboardingSensitivityQ1 =>
      '1. Geçmişte yeme alışkanlıklarınla zorlandığın bir dönem oldu mu?';

  @override
  String get onboardingSensitivityQ1A1 => 'Hayır, böyle bir dönem olmadı';

  @override
  String get onboardingSensitivityQ1A2 => 'Eskiden vardı, şimdi iyiyim';

  @override
  String get onboardingSensitivityQ1A3 => 'Evet, hâlâ zaman zaman zorlanıyorum';

  @override
  String get onboardingSensitivityQ1A4 => 'Söylemek istemiyorum';

  @override
  String get onboardingSensitivityQ2 =>
      '2. Şu an yiyecekle ilişkini nasıl tarif edersin?';

  @override
  String get onboardingSensitivityQ2A1 => 'Rahat, kontrolüm var';

  @override
  String get onboardingSensitivityQ2A2 => 'Karışık günlerim oluyor';

  @override
  String get onboardingSensitivityQ2A3 => 'Çoğu zaman zorluyor';

  @override
  String get onboardingSensitivityQ2A4 => 'Söylemek istemiyorum';

  @override
  String get onboardingProfileTitle => 'Senden biraz bahset';

  @override
  String get onboardingProfileGender => 'Cinsiyet';

  @override
  String get onboardingProfileGenderMale => 'Erkek';

  @override
  String get onboardingProfileGenderFemale => 'Kadın';

  @override
  String get onboardingProfileGenderOther => 'Diğer / Belirtmek istemiyorum';

  @override
  String get onboardingProfileHeight => 'Boy (cm)';

  @override
  String get onboardingProfileWeight => 'Kilo (kg)';

  @override
  String get onboardingProfileActivity => 'Aktivite seviyesi';

  @override
  String get onboardingProfileActivitySedentary => 'Hareketsiz (masa başı)';

  @override
  String get onboardingProfileActivityLight => 'Hafif aktif';

  @override
  String get onboardingProfileActivityModerate => 'Orta aktif';

  @override
  String get onboardingProfileActivityActive => 'Çok aktif';

  @override
  String get onboardingDietTitle => 'Beslenme';

  @override
  String get onboardingDietAllergies => 'Alerjiler';

  @override
  String get onboardingDietPreference => 'Beslenme tercihi';

  @override
  String get onboardingDietAllergyLactose => 'Laktoz';

  @override
  String get onboardingDietAllergyGluten => 'Gluten';

  @override
  String get onboardingDietAllergyPeanut => 'Yer fıstığı';

  @override
  String get onboardingDietAllergyNut => 'Kuruyemiş';

  @override
  String get onboardingDietAllergyEgg => 'Yumurta';

  @override
  String get onboardingDietAllergyShellfish => 'Kabuklu deniz ürünü';

  @override
  String get onboardingDietAllergySoy => 'Soya';

  @override
  String get onboardingDietAllergySesame => 'Susam';

  @override
  String get onboardingDietAllergyFish => 'Balık';

  @override
  String get onboardingDietPrefNone => 'Belirli bir tercih yok';

  @override
  String get onboardingDietPrefVegetarian => 'Vejetaryen';

  @override
  String get onboardingDietPrefVegan => 'Vegan';

  @override
  String get onboardingDietPrefPescatarian => 'Peskatarian (sadece balık)';

  @override
  String get onboardingDietPrefHalal => 'Helal';

  @override
  String get onboardingDietPrefKosher => 'Koşer';

  @override
  String get onboardingDietPrefOther => 'Diğer';

  @override
  String get onboardingCoachTitle => 'Koçun';

  @override
  String get onboardingCoachQuestion => 'Koçun nasıl konuşsun?';

  @override
  String get onboardingCoachSubtitle => 'İstediğin zaman değiştirebilirsin.';

  @override
  String get onboardingCoachKind => 'Nazik';

  @override
  String get onboardingCoachKindDesc => 'Yumuşak, baskısız, empati önce';

  @override
  String get onboardingCoachWitty => 'Esprili';

  @override
  String get onboardingCoachWittyDesc =>
      'Hafif, gülümseten, ciddi anlarda dengeli';

  @override
  String get onboardingCoachDirect => 'Doğrudan';

  @override
  String get onboardingCoachDirectDesc => 'Kısa, net, gerçekçi geri bildirim';

  @override
  String get onboardingCoachCalm => 'Sakin';

  @override
  String get onboardingCoachCalmDesc => 'Yargılamayan, sabırlı, ölçülü';

  @override
  String get onboardingCalorieTitle => 'Kalori';

  @override
  String get onboardingCalorieReady => 'Senin için günlük hedefin hazır';

  @override
  String get onboardingCalorieDescription =>
      'Bu sayı verdiğin bilgilere göre. Sabit değil — senin günlerine göre birlikte ayarlayacağız.';

  @override
  String get onboardingCalorieDaily => 'Günlük kalori';

  @override
  String get onboardingCalorieKcal => 'kcal';

  @override
  String get onboardingCalorieNote =>
      'Aktivite, hedef ve duruma göre hesaplandı. Her ay yeniden gözden geçirilir.';

  @override
  String get onboardingNotificationTitle => 'Bildirimler';

  @override
  String get onboardingNotificationQuestion =>
      'Hafif hatırlatmalar ister misin?';

  @override
  String get onboardingNotificationDescription =>
      'Koçundan kısa destek ve öğün hatırlatmaları. Sessiz saatlere saygı duyarız.';

  @override
  String get onboardingNotificationYes => 'Evet, istiyorum';

  @override
  String get onboardingNotificationNo => 'Şimdilik hayır';

  @override
  String get onboardingWelcomeTitle => 'Hoş geldin.';

  @override
  String get onboardingWelcomeSubtitle => 'Hazırız.';

  @override
  String get onboardingWelcomeBody =>
      'Baskı yok, yargı yok — sadece sen ve yanında bir koç.';

  @override
  String get onboardingWelcomeFirstStep => 'İlk adım fikri';

  @override
  String get onboardingWelcomeFirstStepDesc =>
      'Bugün ne yediğini bir öğünle başlat. Fotoğraf çek ya da yaz — koçun gerisini hatırlasın.';

  @override
  String get onboardingWelcomeStart => 'Başlayalım';

  @override
  String get onboardingWelcomePreparing => 'Hazırlanıyor...';

  @override
  String get onboardingWelcomeError =>
      'Beklenmedik bir sorun oldu, tekrar dener misin?';

  @override
  String get onboardingContinue => 'Devam Et';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get homeGreetingMorning => 'Günaydın';

  @override
  String get homeGreetingAfternoon => 'İyi günler';

  @override
  String get homeGreetingEvening => 'İyi akşamlar';

  @override
  String get homeTodayCalories => 'Bugünkü kalori';

  @override
  String get homeRemainingCalories => 'Kalan';

  @override
  String get homeAddMeal => 'Öğün ekle';

  @override
  String get homeChat => 'Koç ile konuş';

  @override
  String get homeNoMeals => 'Henüz öğün eklemedin';

  @override
  String get homeNoMealsHint => 'Yemeğinin fotoğrafını çek ya da yaz';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navMeals => 'Öğünler';

  @override
  String get navCoach => 'Koç';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystem => 'Sistem dili';

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
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Karanlık';

  @override
  String get settingsThemeLight => 'Aydınlık';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumComingSoon => 'YAKINDA';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsTerms => 'Kullanım Şartları';

  @override
  String get settingsPrivacy => 'Gizlilik Politikası';

  @override
  String get settingsSupport => 'Destek';

  @override
  String get settingsLogout => 'Çıkış Yap';

  @override
  String get settingsDeleteAccount => 'Hesabımı Sil';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get premiumTitle => 'Premium yakında';

  @override
  String get premiumSubtitle =>
      'Şu an Nuveli\'yi tamamen ücretsiz kullanabilirsin.';

  @override
  String get premiumFeatureUnlimited => 'Sınırsız öğün analizi';

  @override
  String get premiumFeatureCoach => 'Gelişmiş AI koç';

  @override
  String get premiumFeatureReports => 'Detaylı haftalık raporlar';

  @override
  String get premiumFeatureExport => 'Veri dışa aktarma';

  @override
  String get premiumNotifyMe => 'Hazır olunca haberim olsun';

  @override
  String get commonContinue => 'Devam et';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonError => 'Bir hata oluştu';

  @override
  String get commonSuccess => 'Başarılı';

  @override
  String get commonYes => 'Evet';

  @override
  String get commonNo => 'Hayır';

  @override
  String get commonOk => 'Tamam';

  @override
  String get settingsCoachTone => 'Koçun tonu';

  @override
  String get settingsSupportSecurity => 'Destek ve Güvenlik';

  @override
  String get settingsHowAiWorks => 'AI nasıl çalışır';

  @override
  String get settingsPrivacySafety => 'Gizlilik ve Güvenlik';

  @override
  String get settingsAboutNuveli => 'Nuveli Hakkında';

  @override
  String get settingsSubscription => 'Abonelik';

  @override
  String get settingsSession => 'Oturum';

  @override
  String get settingsDangerZone => 'Tehlikeli Bölge';

  @override
  String get settingsSignedInAs => 'Giriş yapan';

  @override
  String get settingsLogoutTitle => 'Çıkış yap?';

  @override
  String get settingsLogoutBody =>
      'Tekrar giriş yapmak için email ve şifren gerekecek.';

  @override
  String get settingsLogoutCancel => 'Vazgeç';

  @override
  String get settingsLogoutFailed => 'Çıkış yapılamadı.';

  @override
  String get premiumModalTitle => 'Premium çok yakında!';

  @override
  String get premiumModalBody =>
      'Sınırsız AI öğün analizi, gelişmiş koç ve haftalık içgörüler için son hazırlıkları yapıyoruz.';

  @override
  String get premiumFeatureVoice => 'Sesli koç + 3 persona';

  @override
  String get premiumFeatureInsights => 'Haftalık + aylık içgörü';

  @override
  String get premiumUnderstood => 'Anladım';

  @override
  String get passwordVeryWeak => 'Çok zayıf';

  @override
  String get passwordWeak => 'Zayıf';

  @override
  String get passwordMedium => 'Orta';

  @override
  String get passwordStrong => 'Güçlü';

  @override
  String get passwordVeryStrong => 'Çok güçlü';

  @override
  String get homeErrorGeneric => 'Bir şeyler ters gitti';

  @override
  String get homeCoachLabel => 'Koçun';

  @override
  String get homeToday => 'Bugün';

  @override
  String get homeRemaining => 'kaldı';

  @override
  String get homeThisWeek => 'Bu Hafta';

  @override
  String get homeMiniGoalTitle => 'Bugünkü Mini Hedef';

  @override
  String get homeMiniGoalDefault => 'Bir öğüne protein ekle';

  @override
  String get homeAddMealLabel => 'Öğün Ekle';

  @override
  String get homeWater => 'Su';

  @override
  String get homeWeight => 'Kilo';

  @override
  String get homeMood => 'Mod';

  @override
  String get homeAddWater => 'Su Ekle';

  @override
  String get homeEnterWeight => 'Kilonu Girin';

  @override
  String get homeMoodGreat => 'Harika';

  @override
  String get homeMoodGood => 'İyi';

  @override
  String get homeMoodNeutral => 'Normal';

  @override
  String get homeMoodBad => 'Zor';

  @override
  String get homeMoodRough => 'Çok Zor';

  @override
  String get homeMoodPickOne => 'Bir tane seç';

  @override
  String get homeNoMealsTitle => 'Henüz öğün eklenmedi';

  @override
  String get homeNoMealsMessage => 'İlk öğününü ekleyerek günü başlat';

  @override
  String get homeTodayMeals => 'Bugünkü öğünler';

  @override
  String get homeMealBreakfast => 'Kahvaltı';

  @override
  String get homeMealLunch => 'Öğle';

  @override
  String get homeMealDinner => 'Akşam';

  @override
  String get homeMealSnack => 'Ara öğün';

  @override
  String get homeCalorieTarget => 'hedefi';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target kcal hedefi';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarb => 'Karb';

  @override
  String get macroFat => 'Yağ';

  @override
  String get homeCravingText =>
      'Bir şeye canın çekiyor mu? 60 saniye dur, derin nefes al.';
}
