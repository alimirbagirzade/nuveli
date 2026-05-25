// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Nuveli App';

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
  String get acceptanceTitle => 'Bilgi';

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
  String get onboardingDietAllergyGluten => 'Gluten içeren';

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
  String get onboardingDietPrefVegan => 'Vegan beslenme';

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
  String get onboardingCalorieKcal => 'kalori';

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
  String get homeTitle => 'Ana sayfa';

  @override
  String get homeGreetingMorning => 'Günaydın';

  @override
  String get homeGreetingAfternoon => 'Tünaydın';

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
  String get navHome => 'Ana sayfa';

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
  String get settingsLanguageTurkish => '🇹🇷 Türkçe';

  @override
  String get settingsLanguageEnglish => 'İngilizce';

  @override
  String get settingsLanguageGerman => 'Almanca';

  @override
  String get settingsLanguageFrench => 'Fransızca';

  @override
  String get settingsLanguageSpanish => 'İspanyolca';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Karanlık';

  @override
  String get settingsThemeLight => 'Aydınlık';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsPremium => 'PREMİUM';

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
  String get settingsDeleteAccount => 'Hesabı sil';

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
  String homeDaysOnTarget(int count) {
    return '$count/7 gün hedefte';
  }

  @override
  String get habitsEmptyDefaults =>
      'Henüz alışkanlık yok — varsayılanlar ilk girişte gelir.';

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
  String get homeMealSnack => 'Atıştırmalık';

  @override
  String get homeCalorieTarget => 'hedefi';

  @override
  String homeCalorieTargetLine(int target) {
    return '/ $target kcal hedefi';
  }

  @override
  String get macroProtein => 'Proteinler';

  @override
  String get macroCarb => 'Karb';

  @override
  String get macroFat => 'Yağ';

  @override
  String get homeCravingText =>
      'Bir şeye canın çekiyor mu? 60 saniye dur, derin nefes al.';

  @override
  String get notifMealReminders => 'Öğün Hatırlatıcıları';

  @override
  String get notifMealRemindersDesc =>
      'Kahvaltı, öğle, akşam zamanı nazik hatırlatma';

  @override
  String get notifCoachNudges => 'Koç Nüdgleri';

  @override
  String get notifCoachNudgesDesc => 'Kişisel destek ve motivasyon mesajları';

  @override
  String get notifWeeklySummary => 'Haftalık Özet';

  @override
  String get notifWeeklySummaryDesc => 'Pazartesi sabahı geçen haftanın özeti';

  @override
  String get notifQuietHours => 'SESSİZ SAATLER';

  @override
  String get notifQuietHoursDesc =>
      'Bu saatler arasında hiçbir bildirim gelmez.';

  @override
  String get notifQuietStart => 'Başlangıç';

  @override
  String get notifQuietEnd => 'Bitiş';

  @override
  String get notifSaved => 'Tercihler kaydedildi.';

  @override
  String get notifSaveFailed => 'Kaydedilemedi.';

  @override
  String get notifLoadFailed => 'Yüklenemedi.';

  @override
  String get coachSettingsTitle => 'Koçun';

  @override
  String get coachSettingsQuestion => 'Koçun seninle nasıl konuşsun?';

  @override
  String get coachSettingsSubtitle => 'İstediğin zaman değiştirebilirsin.';

  @override
  String get onboardingMoreMeasures => 'Birkaç ölçüm daha';

  @override
  String get onboardingActivityLevel => 'Aktivite düzeyin';

  @override
  String get onboardingFirstMeal => 'İlk öğünümü ekleyelim';

  @override
  String get onboardingGoToHome => 'Ana ekrana geç';

  @override
  String get onboardingBirthYear => 'Doğum yılı';

  @override
  String get onboardingGender => 'Cinsiyet';

  @override
  String get settingsAppearance => 'GÖRÜNÜM';

  @override
  String get supportTitle => 'Destek';

  @override
  String get supportEmailSubject => 'Nuveli Destek';

  @override
  String get howAiTitle => 'AI Nasıl Çalışır';

  @override
  String get privacyTitle => 'Gizlilik ve Güvenlik';

  @override
  String get aboutTitle => 'Nuveli Hakkında';

  @override
  String get coachToneUpdated => 'Koç tonun güncellendi';

  @override
  String get supportHowHelp => 'Size nasıl yardım edebiliriz?';

  @override
  String get supportEmailCard => 'E-posta ile ulaş';

  @override
  String get supportFaq => 'SSS';

  @override
  String get supportFaqDesc => 'Sıkça sorulan sorular ve cevaplar';

  @override
  String get aiBlockFood => 'Yemek Tanıma';

  @override
  String get aiBlockFoodBody =>
      'Fotoğrafını incelerim ve yaklaşık kalori/besin tahmini yaparım. Bu kesin bir ölçüm değildir — gerekirse düzeltebilirsin.';

  @override
  String get aiBlockCoach => 'Koç Yanıtları';

  @override
  String get aiBlockCoachBody =>
      'Kısa, yargısız ve destekleyici mesajlar üretirim. Tıbbi tavsiye ya da diyet planı sunmam.';

  @override
  String get aiBlockSafety => 'Güvenlik';

  @override
  String get aiBlockSafetyBody =>
      'Riskli durumlarda profesyonel destek kaynaklarını gösteririm. Kriz anında doğrudan sabit güvenlik metni gelir.';

  @override
  String get aiBlockData => 'Verilerin';

  @override
  String get aiBlockDataBody =>
      'Verilerin şifreli iletilir ve sadece sen erişirsin. Ayarlar > Hesabı Sil ile tamamen silebilirsin.';

  @override
  String get privacyHeading => 'Güvenliğin bizim önceliğimiz';

  @override
  String get privacyBody =>
      'Nuveli bir wellness uygulamasıdır. Tıbbi teşhis, tedavi veya klinik diyet planı sunmaz. Zor bir dönemden geçiyorsan lütfen profesyonel destek al.';

  @override
  String get privacyEmergency => 'Acil Destek';

  @override
  String get privacyHotline => 'ALO 182 — Psikolojik Destek Hattı (7/24)';

  @override
  String get privacyPolicyLink => 'Gizlilik Politikası';

  @override
  String get privacyTermsLink => 'Kullanım Şartları';

  @override
  String get privacyDownload => 'Verimi İndir';

  @override
  String get aboutApp => 'Uygulama';

  @override
  String get aboutLinks => 'Bağlantılar';

  @override
  String get aboutWebsite => 'Web sitesi';

  @override
  String get aboutTechnical => 'Teknik';

  @override
  String get aboutEnv => 'Ortam';

  @override
  String get aboutCopyright => '© 2026 Nuveli. Tüm hakları saklıdır.';

  @override
  String get aboutCopied => 'kopyalandı';

  @override
  String get aboutVersion => 'Sürüm';

  @override
  String get streakDay => 'gün';

  @override
  String get streakDays => 'günlük seri';

  @override
  String get streakLongest => 'En uzun serin';

  @override
  String get streakTodayDone => 'Bugün de hallettin';

  @override
  String streakSummary(int current) {
    return '$current günlük seri';
  }

  @override
  String get streakExplanation =>
      'Streak\'in arka arkaya öğün eklediğin gün sayısıdır.';

  @override
  String get weeklyTitle => 'Haftalık Özet';

  @override
  String get weeklyLoadFailed => 'Yüklenemedi';

  @override
  String get weeklyChartLoadFailed => 'Veriler yüklenemedi';

  @override
  String get commonRetryLow => 'Tekrar dene';

  @override
  String get dayMon => 'Pzt';

  @override
  String get dayTue => 'Sal';

  @override
  String get dayWed => 'Çar';

  @override
  String get dayThu => 'Per';

  @override
  String get dayFri => 'Cum';

  @override
  String get daySat => 'Cmt';

  @override
  String get daySun => 'Paz';

  @override
  String get dayDetailMeals => 'Öğünler';

  @override
  String get dayDetailMealsLoadFailed => 'Öğünler yüklenemedi';

  @override
  String get dayDetailNoMeals => 'Bu gün için öğün kaydı yok';

  @override
  String dayDetailWaterMl(int ml) {
    return '$ml ml su';
  }

  @override
  String get mealTypeBreakfast => 'Kahvaltı';

  @override
  String get mealTypeLunch => 'Öğle';

  @override
  String get mealTypeDinner => 'Akşam';

  @override
  String get mealTypeSnack => 'Atıştırmalık';

  @override
  String get mealTypeOther => 'Öğün';

  @override
  String get weeklyMacroDist => 'Makro Dağılımı';

  @override
  String get weeklyDailyDetail => 'Günlük Detay';

  @override
  String get weeklyCoachComment => 'KOÇUN YORUMU';

  @override
  String get weeklyCoachCommentLocked => 'Koçun yorumu';

  @override
  String get weeklyCoachCommentLockedDesc =>
      'Premium ile haftalık örüntülerin için kişisel yorum';

  @override
  String streakLastLog(String date) {
    return 'Son kayıt: $date';
  }

  @override
  String get streakNow => 'Şu an';

  @override
  String get streakLongestShort => 'En uzun';

  @override
  String get streakAddMealNow => 'Şimdi Öğün Ekle';

  @override
  String get streakAtRisk =>
      'Bugün öğün eklemedin ve akşam oldu. Şimdi bir öğün eklersen serin devam eder; aksi halde yarın sıfırdan başlayacak.';

  @override
  String get streakNotStarted =>
      'Streak henüz başlamadı. İlk öğününü ekle ve serin başlasın.';

  @override
  String get streakTodayLogged =>
      'Bugünü de hallettin! Yarın da bir öğün eklersen seri devam eder.';

  @override
  String get streakExplanationDefault =>
      'Streak\'in arka arkaya öğün eklediğin gün sayısıdır.';

  @override
  String get weeklyAvgKcal => 'kcal/gün ortalama';

  @override
  String get weeklyTotal => 'Toplam';

  @override
  String get weeklyMeals => 'Öğün';

  @override
  String get weeklyLogged => 'Kayıt';

  @override
  String get coachChatTitle => 'Koç';

  @override
  String get coachChatPlaceholder => 'Koçuna bir şey sor...';

  @override
  String get coachChatSend => 'Gönder';

  @override
  String get waterHowMuch => 'Ne kadar içtin?';

  @override
  String get waterHistory => 'Geçmiş';

  @override
  String get weightInvalid => 'Geçerli bir kilo girin (1-500 kg).';

  @override
  String get weightKg => 'Kilogram';

  @override
  String get moodHowToday => 'Bugün nasılsın?';

  @override
  String get mealCameraNotAvailable =>
      'Bu özellik gerçek cihazda çalışır. Galeriden seçebilirsin.';

  @override
  String get mealGallery => 'Galeri';

  @override
  String weeklyDaysLogged(int n) {
    return '$n gün kayıt yaptın. İyi bir ilerleme.';
  }

  @override
  String get coachWelcome => 'Merhaba! Bugün nasıl hissediyorsun?';

  @override
  String get coachInputPlaceholder => 'Mesajını yaz...';

  @override
  String get coachLoadFailed => 'Yüklenemedi.';

  @override
  String get coachSendFailed => 'Mesaj gönderilemedi.';

  @override
  String get coachLimitTitle => 'Günlük mesaj limiti doldu';

  @override
  String coachLimitBody(String reason) {
    return '$reason\n\nPremium ile sınırsız koç sohbeti + sesli yanıtlara erişebilirsin.';
  }

  @override
  String get coachLater => 'Sonra';

  @override
  String get coachSeePremium => 'Premium\'a bak';

  @override
  String get coachCrisisTitle => 'Şu an yalnız değilsin';

  @override
  String get coachDistressTitle => 'Zor bir an geçiriyor olabilirsin';

  @override
  String get coachCrisisBody =>
      'Bu konuda seninle olmak istiyoruz ama doğru destek için bir uzmana ulaşman çok önemli.';

  @override
  String get coachDistressBody =>
      'Koçun bu tür durumlarda yardımcı olamaz. Seninle ilgilenen birine ulaşmak her zaman bir seçenek.';

  @override
  String get mealAddTitle => 'Öğün Ekle';

  @override
  String get mealPhotoOrDesc => 'Fotoğraf veya açıklama';

  @override
  String get mealNoPhoto => 'Fotoğraf eklenmedi';

  @override
  String get mealCamera => 'Kamera';

  @override
  String get mealGalleryBtn => 'Galeri';

  @override
  String get mealSimulatorWarn =>
      'Simulator\'de kamera yok. Galeri\'yi kullan.';

  @override
  String get mealDescHint =>
      'Yemeğini açıkla:\n• Ne? (örn. Adana kebap)\n• Ne kadar? (örn. 200g, 1 porsiyon)\n• Yanında? (örn. lavaş, pilav)';

  @override
  String get mealAnalyze => 'Analiz Et';

  @override
  String get mealManualEntry => 'Elle gir';

  @override
  String get mealAnalyzeFailed => 'Analiz yapılamadı.';

  @override
  String get mealLimitTitle => 'Günlük limit doldu';

  @override
  String mealLimitBody(String reason) {
    return '$reason\n\nPremium ile sınırsız fotoğraf analizi yapabilirsin.';
  }

  @override
  String get waterHistoryTitle => 'Su Geçmişi';

  @override
  String get weightHistoryTitle => 'Kilo Geçmişi';

  @override
  String get monthJan => 'Ocak';

  @override
  String get monthFeb => 'Şubat';

  @override
  String get monthMar => 'Mart';

  @override
  String get monthApr => 'Nisan';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthJun => 'Haziran';

  @override
  String get monthJul => 'Temmuz';

  @override
  String get monthAug => 'Ağustos';

  @override
  String get monthSep => 'Eylül';

  @override
  String get monthOct => 'Ekim';

  @override
  String get monthNov => 'Kasım';

  @override
  String get monthDec => 'Aralık';

  @override
  String get weekdayMon => 'Pazartesi';

  @override
  String get weekdayTue => 'Salı';

  @override
  String get weekdayWed => 'Çarşamba';

  @override
  String get weekdayThu => 'Perşembe';

  @override
  String get weekdayFri => 'Cuma';

  @override
  String get weekdaySat => 'Cumartesi';

  @override
  String get weekdaySun => 'Pazar';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Koyu (Gece)';

  @override
  String get themeLight => 'Açık (Gündüz)';

  @override
  String get personaGentle => 'Nazik';

  @override
  String get personaGentleDesc => 'Yumuşak, baskısız, empati önce';

  @override
  String get personaGentleSample =>
      '\"Bugün biraz zor olduğunu görüyorum. Bir öğün eksik kalsa da kendine sert davranma.\"';

  @override
  String get personaFunny => 'Esprili';

  @override
  String get personaFunnyDesc => 'Hafif, gülümseten, ciddi anlarda dengeli';

  @override
  String get personaFunnySample =>
      '\"Pizza akşamı, anladım. Hayat zaten bir denge işi — yarın salata, bu akşam mutluluk.\"';

  @override
  String get personaDirect => 'Doğrudan';

  @override
  String get personaDirectDesc => 'Kısa, net, gerçekçi geri bildirim';

  @override
  String get personaDirectSample =>
      '\"Bugün protein az. Akşam yemekte 25-30g hedefle, hafta dengesi tutar.\"';

  @override
  String get personaCalm => 'Sakin';

  @override
  String get personaCalmDesc => 'Yargılamayan, sabırlı, ölçülü';

  @override
  String get personaCalmSample =>
      '\"Düşünmeden yedik bazen. Önemli olan farkına varmak. Sonraki öğüne odaklanalım.\"';

  @override
  String get coachToneQuestion => 'Koçun seninle nasıl konuşsun?';

  @override
  String get coachToneSubtitle => 'İstediğin zaman değiştirebilirsin.';

  @override
  String get coachToneSaving => 'Kaydediliyor...';

  @override
  String get coachToneSaveError =>
      'Kaydedemedim. Bağlantını kontrol edip tekrar dener misin?';

  @override
  String get coachToneSaveErrorGeneric =>
      'Beklenmedik bir sorun oldu, tekrar dener misin?';

  @override
  String waterLastDays(int n) {
    return 'Son $n gün';
  }

  @override
  String get waterLitresTotal => 'L toplam';

  @override
  String get waterToday => 'Bugün';

  @override
  String get waterAverage => 'Ortalama';

  @override
  String get waterLast7 => 'Son 7 Gün';

  @override
  String waterGoalMl(int ml) {
    return 'Hedef: $ml ml/gün';
  }

  @override
  String get waterAllDays => 'Tüm Günler';

  @override
  String get waterNoRecord => 'Kayıt yok';

  @override
  String waterDaysCount(int n) {
    return '$n gün';
  }

  @override
  String get weightCurrent => 'Güncel kilo';

  @override
  String get weightFirstRecord => 'İlk kayıt';

  @override
  String weightTrend(int n) {
    return 'Trend ($n kayıt)';
  }

  @override
  String get weightRecords => 'Kayıtlar';

  @override
  String weightEntryCount(int n) {
    return '$n giriş';
  }

  @override
  String get monthShortJan => 'Oca';

  @override
  String get monthShortFeb => 'Şub';

  @override
  String get monthShortMar => 'Mart';

  @override
  String get monthShortApr => 'Nis';

  @override
  String get monthShortMay => 'Mayıs';

  @override
  String get monthShortJun => 'Haz';

  @override
  String get monthShortJul => 'Tem';

  @override
  String get monthShortAug => 'Ağu';

  @override
  String get monthShortSep => 'Eyl';

  @override
  String get monthShortOct => 'Eki';

  @override
  String get monthShortNov => 'Kas';

  @override
  String get monthShortDec => 'Ara';

  @override
  String get todayBadge => 'BUGÜN';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLoadFailed => 'Profil yüklenemedi.';

  @override
  String get profileAccount => 'Hesap';

  @override
  String get profilePersonalInfo => 'Kişisel bilgiler';

  @override
  String get profilePersonalInfoSub => 'İsim, hedefler, vücut bilgileri';

  @override
  String get profileGoals => 'Hedefler';

  @override
  String get profileGoalsSub => 'Kalori ve makro hedefin';

  @override
  String get profileNotifications => 'Bildirimler';

  @override
  String get profileNotifPrefs => 'Bildirim tercihleri';

  @override
  String get profileNotifPrefsSub => 'Hatırlatıcılar ve sessiz saatler';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileDarkTheme => 'Karanlık tema';

  @override
  String get profileDarkThemeSub => 'Şu an aktif (varsayılan)';

  @override
  String get profilePremium => 'PREMİUM';

  @override
  String get profilePremiumSub => 'Plan, fatura ve özellikler';

  @override
  String get profilePremiumMy => 'Premium aboneliğim';

  @override
  String get profileHelpSafety => 'Yardım ve güvenlik';

  @override
  String get profileSupport => 'Destek';

  @override
  String get profileSupportSub => 'Sorular ve geri bildirim';

  @override
  String get profileHowAi => 'AI nasıl çalışır';

  @override
  String get profilePrivacy => 'Gizlilik ve güvenlik';

  @override
  String get profileAbout => 'Nuveli hakkında';

  @override
  String get profileLogout => 'Çıkış';

  @override
  String get profileSignOut => 'Çıkış yap';

  @override
  String get profileDeleteAccount => 'Hesabı sil';

  @override
  String get profileSignOutConfirm =>
      'Hesabından çıkmak istediğine emin misin?';

  @override
  String get homeGreetingNoonTime => 'Tünaydın';

  @override
  String get profileStreakNow => 'Şu an';

  @override
  String get profileStreakLongest => 'En uzun';

  @override
  String get profileStreakDay => 'gün';

  @override
  String get personalInfoTitle => 'Kişisel Bilgiler';

  @override
  String get personalInfoEdit => 'Düzenle';

  @override
  String get personalInfoSaved => 'Bilgiler kaydedildi';

  @override
  String get personalInfoSaveFailed => 'Kaydedilemedi';

  @override
  String get personalInfoLoadFailed => 'Yüklenemedi';

  @override
  String get personalInfoSecAccount => 'Hesap';

  @override
  String get personalInfoSecBody => 'Vücut bilgileri';

  @override
  String get personalInfoSecActivity => 'Aktivite';

  @override
  String get personalInfoName => 'İsim';

  @override
  String get personalInfoEmail => 'E-posta';

  @override
  String get personalInfoBirthYear => 'Doğum yılı';

  @override
  String get personalInfoGender => 'Cinsiyet';

  @override
  String get personalInfoHeight => 'Boy';

  @override
  String get personalInfoHeightCm => 'Boy (cm)';

  @override
  String get personalInfoWeight => 'Kilo';

  @override
  String get personalInfoWeightKg => 'Kilo (kg)';

  @override
  String get personalInfoActivityLevel => 'Günlük aktivite seviyesi';

  @override
  String get personalInfoActivityLevelLabel => 'Aktivite seviyesi';

  @override
  String get personalInfoCancel => 'Vazgeç';

  @override
  String get personalInfoSave => 'Kaydet';

  @override
  String get personalInfoSaving => 'Kaydediliyor...';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderOther => 'Diğer';

  @override
  String get activitySedentary => 'Hareketsiz';

  @override
  String get activitySedentaryFull => 'Hareketsiz (masa başı)';

  @override
  String get activityLight => 'Hafif aktif';

  @override
  String get activityLightFull => 'Hafif aktif (1-3 gün)';

  @override
  String get activityModerate => 'Orta aktif';

  @override
  String get activityModerateFull => 'Orta aktif (3-5 gün)';

  @override
  String get activityActive => 'Aktif';

  @override
  String get activityActiveFull => 'Aktif (6-7 gün)';

  @override
  String get activityVeryActive => 'Çok aktif';

  @override
  String get activityVeryActiveFull => 'Çok aktif (sporcu)';

  @override
  String get goalsTitle => 'Hedefler';

  @override
  String get goalsUpdated => 'Hedefler güncellendi';

  @override
  String get goalsLoadFailed => 'Yüklenemedi';

  @override
  String get goalsSaveFailed => 'Kaydedilemedi';

  @override
  String get goalsSecPurpose => 'Amaç';

  @override
  String get goalsSecDailyCalorie => 'Günlük kalori hedefi';

  @override
  String get goalsSecMacroDist => 'Önerilen makro dağılımı';

  @override
  String get goalsLoseWeight => 'Kilo vermek';

  @override
  String get goalsLoseWeightDesc => 'Kalori açığıyla tedrici düşüş';

  @override
  String get goalsMaintain => 'Kiloyu korumak';

  @override
  String get goalsMaintainDesc => 'Mevcut kiloyu sürdürmek';

  @override
  String get goalsGainMuscle => 'Kas almak';

  @override
  String get goalsGainMuscleDesc => 'Kalori fazlasıyla yapı kazanmak';

  @override
  String get goalsMacroNote =>
      'Bu öneri 25% protein, 50% karbonhidrat, 25% yağ dağılımına göredir. Koçun sana özel olarak ayarlayabilir.';

  @override
  String get goalsSave => 'Kaydet';

  @override
  String get premiumComingTitle => 'Premium çok yakında! 🚀';

  @override
  String get premiumComingDesc =>
      'Sınırsız AI öğün analizi, sesli koç ve haftalık içgörüler için son hazırlıkları yapıyoruz. Hazır olduğumuzda bildiririz.';

  @override
  String get premiumFeatureCharts => 'Gelişmiş grafikler ve eğilimler';

  @override
  String get premiumGotIt => 'Anladım';

  @override
  String todayMealsCount(int n) {
    return '$n öğün';
  }

  @override
  String get todayMealDeleteTitle => 'Öğünü sil?';

  @override
  String todayMealDeleteMessage(String name) {
    return '\"$name\" silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get todayMealDeleteConfirm => 'Sil';

  @override
  String get todayMealDeleteCancel => 'Vazgeç';

  @override
  String get todayMealDeleted => 'Öğün silindi.';

  @override
  String get todayMealDeleteFailed => 'Silinemedi.';

  @override
  String get mealTypeBreakfastShort => 'Kahvaltı';

  @override
  String get mealTypeLunchShort => 'Öğle';

  @override
  String get mealTypeDinnerShort => 'Akşam';

  @override
  String get mealTypeSnackShort => 'Atıştırma';

  @override
  String streakLongestNeverActive(int longest) {
    return 'En uzun serin: $longest gün';
  }

  @override
  String streakTodayDoneSubtitle(int longest) {
    return 'Bugün de hallettin · En uzun: $longest gün';
  }

  @override
  String streakTodayMissedSubtitle(int longest) {
    return 'Bugünü de eklemeyi unutma · En uzun: $longest';
  }

  @override
  String get waterAllDaysList => 'Tüm Günler';

  @override
  String get waterTodayBadge => 'BUGÜN';

  @override
  String get waterNoEntry => 'Kayıt yok';

  @override
  String get weightRecordsList => 'Kayıtlar';

  @override
  String weightEntriesCount(int n) {
    return '$n giriş';
  }

  @override
  String historyDaysSuffix(int n) {
    return '$n gün';
  }

  @override
  String get moodGreat => 'Harika';

  @override
  String get moodGood => 'İyi';

  @override
  String get moodNeutral => 'Normal';

  @override
  String get moodBad => 'Zor';

  @override
  String get moodRough => 'Çok Zor';

  @override
  String get verifyEmailTitle => 'E-postanı Doğrula';

  @override
  String verifyEmailSubtitle(String email) {
    return '$email adresine bir doğrulama linki gönderdik. Linke tıkladığında otomatik olarak devam edeceksin.';
  }

  @override
  String get verifyEmailWaitingTitle => 'Email bekleniyor...';

  @override
  String get verifyEmailWaitingBody =>
      'E-postandaki linke tıklamadan ilerleyemezsin. Spam klasörünü de kontrol et.';

  @override
  String get verifyEmailResend => 'Tekrar gönder';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Tekrar gönder (${seconds}sn)';
  }

  @override
  String get verifyEmailResent => 'Yeni doğrulama emaili gönderildi.';

  @override
  String get verifyEmailSignOut => 'Farklı email kullan / Çıkış';

  @override
  String get coachBubbleGentleMealUnder =>
      'Özenle kaydedildi. Bugün hâlâ alanın var, acelesi yok.';

  @override
  String get coachBubbleGentleMealOver =>
      'Kaydedildi. Tek bir öğün gününü tanımlamaz. Kendine nazik ol.';

  @override
  String get coachBubbleGentleMealOnTrack =>
      'Bugün güzel bir denge. Bedenini dinliyorsun.';

  @override
  String get coachBubbleGentleWaterLow =>
      'Şimdi biraz su iyi gelirdi, hazır olduğunda.';

  @override
  String get coachBubbleGentleStreakMilestone =>
      'Her gün usulca buradasın. İşte bu gerçek.';

  @override
  String get coachBubbleGentleFirstMeal =>
      'İlk öğün girildi. Güne yumuşak, sakin bir başlangıç.';

  @override
  String get coachBubbleFunnyMealUnder =>
      'Kaydedildi! Daha çok yerin var — çatal kalkışa hazır.';

  @override
  String get coachBubbleFunnyMealOver =>
      'Bol öğün, bol keyif. Yarın yine lezzetli bir sayfa.';

  @override
  String get coachBubbleFunnyMealOnTrack =>
      'Şefin öpücüğü. Dengeyle artık can ciğersiniz.';

  @override
  String get coachBubbleFunnyWaterLow =>
      'Su şişen biraz küsmüş gibi. Söylemeden geçmeyeyim.';

  @override
  String get coachBubbleFunnyStreakMilestone =>
      'Seri sağlam gidiyor — birileri formda!';

  @override
  String get coachBubbleFunnyFirstMeal =>
      'Kahvaltı kulübü bildiriyor. Güne lezzetli bir başlangıç.';

  @override
  String get coachBubbleDirectMealUnder =>
      'Kaydedildi. Günün kalanına yer var — iyi planla.';

  @override
  String get coachBubbleDirectMealOver =>
      'Kaydedildi, biraz fazla. Dert değil — sonraki öğünleri ayarla.';

  @override
  String get coachBubbleDirectMealOnTrack =>
      'Kaydedildi. Tam yolunda. Böyle devam.';

  @override
  String get coachBubbleDirectWaterLow => 'Su bugün geride. Bir bardak al.';

  @override
  String get coachBubbleDirectStreakMilestone =>
      'Seri tutuyor. İşi yapan istikrar.';

  @override
  String get coachBubbleDirectFirstMeal =>
      'İlk öğün girildi. Güzel — günün tonunu belirle.';

  @override
  String get coachBubbleCalmMealUnder =>
      'Not edildi. İlerisi açık. Kendi temponla ilerle.';

  @override
  String get coachBubbleCalmMealOver =>
      'Not edildi. Önemli olan farkındalık. Sonraki öğün senin.';

  @override
  String get coachBubbleCalmMealOnTrack =>
      'Not edildi. Dengeli ve sakin — huzurlu bir ilerleme.';

  @override
  String get coachBubbleCalmWaterLow =>
      'Su biraz az. Baskı yok — uygun olduğunda yudumla.';

  @override
  String get coachBubbleCalmStreakMilestone =>
      'Her gün sessiz bir istikrar. Bu sayılır.';

  @override
  String get coachBubbleCalmFirstMeal =>
      'İlk öğün not edildi. Güne sakin bir başlangıç.';

  @override
  String get mealHistoryTitle => 'Öğün Geçmişi';

  @override
  String get historyYesterday => 'Dün';

  @override
  String get mealHistoryEmptyTitle => 'Henüz öğün eklenmedi';

  @override
  String get mealHistoryEmptyBody =>
      'Eklediğin öğünler burada güne göre gruplanır.';

  @override
  String get settingsCoachSection => 'Koç';

  @override
  String get settingsYourData => 'Verilerin';

  @override
  String get settingsExportData => 'Verilerimi Dışa Aktar';

  @override
  String get settingsExportDataDesc =>
      'Tüm öğün, su, kilo, alışkanlık ve içgörü kayıtlarını JSON olarak indir. Veri taşınabilirliği hakkı (KVKK / GDPR Mad. 20).';

  @override
  String get settingsExportFailed => 'Verilerin dışa aktarılamadı.';

  @override
  String get settingsDeleteDesc =>
      'Profilini, öğünlerini ve tüm verilerini kalıcı olarak siler.';

  @override
  String get settingsDeleteTitle => 'Hesap silinsin mi?';

  @override
  String get settingsDeleteConfirmBody =>
      'Bu işlem profilini, tüm öğün, su, kilo geçmişini, alışkanlıkları ve abonelikleri kalıcı olarak siler. Geri alınamaz.';

  @override
  String get settingsDeleteType => 'Onaylamak için DELETE yaz:';

  @override
  String get settingsDeleteFailed => 'Hesap silinemedi.';

  @override
  String get settingsLanguageItalian => 'İtalyanca';

  @override
  String get settingsLanguageRussian => 'Rusça';

  @override
  String get coachTodaysTips => 'Bugünün ipuçları';

  @override
  String get coachNutritionScore => 'Beslenme puanı';

  @override
  String get coachScoreHigh => 'Sağlam bir gün — böyle devam.';

  @override
  String get coachScoreMid =>
      'Çoğunlukla yolunda. Küçük bir ayar çok şey değiştirir.';

  @override
  String get coachScoreMixed =>
      'Karışık sinyaller — bugün tek bir şeye odaklanalım.';

  @override
  String get coachScoreReset =>
      'Nazik bir sıfırlama iyi gelir. Aşağıdan bir ipucu seç.';

  @override
  String get coachOfflineTitle => 'Koç çevrimdışı';

  @override
  String get coachRegenerate => 'Yenile';

  @override
  String get coachRegenerateUpgrade => 'Yenilemek için yükselt';

  @override
  String get coachRegenerateFree => 'Yenile (günde 1 ücretsiz)';

  @override
  String get coachEmptyTitle => 'Koçun hazırlanıyor';

  @override
  String get coachEmptyBody =>
      'Bugün ilk öğününü ekle — koçun sana özel günlük insight ve ipuçları hazırlasın.';

  @override
  String get paywallNoPackages =>
      'Şu anda abonelik paketi yok. Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachScoreExcellent => 'Mükemmel';

  @override
  String get coachScoreOnTrack => 'Yolunda';

  @override
  String get coachScoreImprove => 'Gelişebilir';

  @override
  String get coachScoreNeedsCare => 'Özen gerek';

  @override
  String get coachRecommendedStep => 'Önerilen sonraki adım';

  @override
  String get coachActionHabitAdded => 'Alışkanlık eklendi';

  @override
  String get coachActionWaterLogged => 'Su eklendi';

  @override
  String get coachActionReminderSet => 'Hatırlatıcı ayarlandı';

  @override
  String get coachActionTargetUpdated => 'Hedef güncellendi';

  @override
  String get coachActionDone => 'Tamam';

  @override
  String get homeOpenSettings => 'Ayarları aç';

  @override
  String get homeAddFood => 'Yemek Ekle';

  @override
  String get homeSeeAll => 'Tümünü gör';

  @override
  String get homeMealNameQuestion => 'Ne yedin?';

  @override
  String get homeMealNameHint => 'ör. meyveli yoğurt';

  @override
  String get homeCaloriesHint => 'ör. 180';

  @override
  String get homeCaloriesKcal => 'Kalori (kcal)';

  @override
  String get macroProteinG => 'Protein (g)';

  @override
  String get macroCarbsG => 'Karbonhidrat (g)';

  @override
  String get macroFatG => 'Yağ (g)';

  @override
  String get homeSaveMeal => 'Öğünü kaydet';

  @override
  String get homeFoodNameRequired => 'Yemek adı gerekli';

  @override
  String get homeCaloriesRequired => 'Bir kalori değeri gir (> 0)';

  @override
  String get homeSaveFailed => 'Öğün kaydedilemedi.';

  @override
  String get homeWaterLogFailed => 'Su eklenemedi. Tekrar denemek için dokun.';

  @override
  String get homePlannerCtaTitle => 'Haftanı planla';

  @override
  String get homePlannerCtaSubtitle =>
      'Planlı öğünleri + alışveriş listesini gör';

  @override
  String get homeNoMealsScanHint =>
      'İlk öğününü eklemek için aşağıdaki \"Yemek Ekle\"ye dokun';

  @override
  String get mealScanScreenTitle => 'Yapay Zeka Yemek Taraması';

  @override
  String get mealScanIdleTitle => 'Yemeğini fotoğrafla';

  @override
  String get mealScanIdleSubtitle =>
      'Kameranı tabağına doğrult. Nuveli\'nin yapay zekası birkaç saniyede kalori ve makroları tahmin edecek.';

  @override
  String get mealScanTakePhoto => 'Fotoğraf çek';

  @override
  String get mealScanChooseGallery => 'Galeriden seç';

  @override
  String mealScanScansLeft(int remaining, int total) {
    return '$remaining/$total tarama kaldı';
  }

  @override
  String get mealScanUnlimited => 'Sınırsız';

  @override
  String get mealScanNameLabel => 'Öğün adı';

  @override
  String get mealScanAnalyzingStep1 => 'Yemeğin analiz ediliyor...';

  @override
  String get mealScanAnalyzingStep2 => 'Yiyecekler tanımlanıyor...';

  @override
  String get mealScanAnalyzingStep3 => 'Porsiyonlar tahmin ediliyor...';

  @override
  String get mealScanAnalyzingStep4 => 'Makrolar hesaplanıyor...';

  @override
  String get mealScanAnalyzingStep5 => 'Neredeyse bitti...';

  @override
  String get mealScanSaving => 'Öğün kaydediliyor...';

  @override
  String get mealScanRateLimitTitle => 'Çok fazla tarama, çok hızlı';

  @override
  String get mealScanErrorTitle => 'Tarama başarısız';

  @override
  String get mealScanAddManuallyInstead => 'Manuel olarak ekle';

  @override
  String get mealScanNotFoodTitle => 'Hmm, yiyecek göremedim';

  @override
  String get mealScanNotFoodHint =>
      'Tabağın daha net bir fotoğrafını çekmeyi dene ya da bu öğünü manuel olarak kaydet.';

  @override
  String get mealScanTryAnotherPhoto => 'Başka bir fotoğraf dene';

  @override
  String get mealScanAddManually => 'Manuel ekle';

  @override
  String get mealScanRetake => 'Yeniden çek';

  @override
  String mealScanConfidentScore(int score) {
    return '%$score güven';
  }

  @override
  String get mealScanDetectedFoods => 'Tespit edilen yiyecekler';

  @override
  String get mealScanPortionSize => 'Porsiyon boyutu';

  @override
  String get mealScanDiscard => 'Sil';

  @override
  String get mealScanAiTip => 'YZ ipucu';

  @override
  String get mealScanRemoveTooltip => 'Kaldır';

  @override
  String get mealScanImageLoadError => 'Görsel yüklenemedi';

  @override
  String get mealScanEditFood => 'Yiyeceği düzenle';

  @override
  String get mealScanSaveChanges => 'Değişiklikleri kaydet';

  @override
  String get mealScanFieldName => 'Ad';

  @override
  String get plannerScreenTitle => 'Yemek Planı';

  @override
  String get plannerGroceryListTooltip => 'Alışveriş listesi';

  @override
  String get plannerThisWeek => 'Bu hafta';

  @override
  String get plannerNextWeek => 'Gelecek hafta';

  @override
  String get plannerLastWeek => 'Geçen hafta';

  @override
  String plannerInWeeks(int n) {
    return '$n hafta içinde';
  }

  @override
  String plannerWeeksAgo(int n) {
    return '$n hafta önce';
  }

  @override
  String get plannerPrevWeekTooltip => 'Önceki hafta';

  @override
  String get plannerNextWeekTooltip => 'Sonraki hafta';

  @override
  String plannerTotalsBanner(int kcal, int days) {
    return '$days gün için $kcal kcal planlandı';
  }

  @override
  String get plannerEmptyTitle => 'Bu hafta için henüz plan yok';

  @override
  String get plannerEmptyAiHint =>
      'YZ koçun saniyeler içinde tam bir hafta taslağı hazırlasın.';

  @override
  String get plannerEmptyPremiumHint =>
      'YZ haftalık planlar Premium özelliğidir. Kilitliği açmak için yükselt.';

  @override
  String get plannerAddMealManually => 'Öğünü manuel ekle';

  @override
  String get plannerGenerateAiPlan => 'YZ planı oluştur';

  @override
  String get plannerUnlockAiPlan => 'YZ plan oluşturmanın kilidini aç';

  @override
  String get plannerPremiumFeature => 'Premium özellik';

  @override
  String get plannerPaywallTitle => 'Bu haftanın ötesini gör ve planla';

  @override
  String get plannerPaywallBody =>
      'Ücretsiz planlar yalnızca mevcut haftayı kapsar. Gelecek haftalara bakabilmek, tekrarlayan planlar oluşturabilmek ve YZ ile tam hafta planı oluşturabilmek için yükselt.';

  @override
  String get plannerSeePremium => 'Premium\'u Gör';

  @override
  String get plannerBackToThisWeek => 'Bu haftaya dön';

  @override
  String get plannerLoadError => 'Planın yüklenemedi';

  @override
  String get plannerEditNameNote => 'Ad / notu düzenle';

  @override
  String get plannerRemoveFromPlan => 'Plandan kaldır';

  @override
  String get plannerRemoveEntryTitle => 'Giriş kaldırılsın mı?';

  @override
  String plannerRemoveEntryBody(String name) {
    return '\"$name\" bu plandan kaldırılsın mı?';
  }

  @override
  String get plannerRemove => 'Kaldır';

  @override
  String get plannerToday => 'Bugün';

  @override
  String plannerDayStats(int meals, int kcal) {
    return '$meals planlandı · $kcal kcal';
  }

  @override
  String get plannerAddMealTooltip => 'Öğün ekle';

  @override
  String plannerServingsCount(String n) {
    return '$n porsiyon';
  }

  @override
  String get plannerAddToPlan => 'Plana ekle';

  @override
  String get plannerMealName => 'Öğün adı';

  @override
  String get plannerServings => 'Porsiyon';

  @override
  String get plannerNoteOptional => 'Not (isteğe bağlı)';

  @override
  String get plannerMealNameRequired => 'Öğün adı gereklidir';

  @override
  String get plannerServingsError => 'Porsiyon 0\'dan büyük olmalıdır';

  @override
  String get plannerEditEntry => 'Girişi düzenle';

  @override
  String get plannerEditCaloriesHint =>
      'Kalori veya porsiyon değiştirmek için bu girişi sil ve yeniden ekle.';

  @override
  String get plannerGenerateSubtitle =>
      'Koçun tam bir haftayı taslak olarak hazırlar. Aşağıdaki ayrıntıları düzenle — tümü isteğe bağlı.';

  @override
  String get plannerDietaryPref => 'Diyet tercihi (isteğe bağlı)';

  @override
  String get plannerAvoidIngredients =>
      'Kaçınılacak malzemeler (virgülle ayrılmış)';

  @override
  String get plannerDailyCalorieTarget => 'Günlük kalori hedefi (isteğe bağlı)';

  @override
  String get plannerMealsPerDay => 'Günlük öğün sayısı';

  @override
  String get plannerAnythingElse => 'Başka bir şey? (isteğe bağlı)';

  @override
  String get plannerCalorieTargetError =>
      'Kalori hedefi 800–6000 arasında olmalıdır';

  @override
  String get plannerGenerating => 'Oluşturuluyor…';

  @override
  String get plannerGeneratePlan => 'Plan oluştur';

  @override
  String plannerMealsCreated(int n) {
    return 'Haftanız için $n öğün planlandı.';
  }

  @override
  String get plannerGroceryList => 'Alışveriş listesi';

  @override
  String get plannerGroceryLoadError => 'Alışveriş listesi yüklenemedi';

  @override
  String get plannerGroceryEmpty =>
      'Henüz alışveriş listesi yok — plana bir tarif ekle.';

  @override
  String plannerGroceryUsedIn(int n) {
    return '$n tarifte kullanıldı';
  }

  @override
  String get analyticsTitle => 'Analizler';

  @override
  String get analyticsSubtitle => 'Haftana bir bakış';

  @override
  String get analyticsErrorWeeklyBars => 'Haftalık çubuklar yüklenemedi';

  @override
  String get analyticsErrorMacroBreakdown => 'Makro dağılımı yüklenemedi';

  @override
  String get analyticsErrorWeightTrend => 'Kilo trendi yüklenemedi';

  @override
  String get analyticsLast7Days => 'Son 7 gün';

  @override
  String analyticsDaysOnTarget(int n) {
    return '$n/7 gün hedefe ulaşıldı';
  }

  @override
  String analyticsKcalAvg(String avg) {
    return '$avg kcal ort.';
  }

  @override
  String analyticsTarget(int target) {
    return '· hedef $target';
  }

  @override
  String get analyticsWeeklyEmpty =>
      'Haftalık trendini görmek için birkaç öğün gir';

  @override
  String get analyticsMacroBreakdown => 'Makro dağılımı';

  @override
  String get analytics7DayAverage => '7 günlük ortalama';

  @override
  String get analyticsMacroEmpty =>
      'Bir öğün girdiğinde makro dağılımı burada görünür';

  @override
  String get analyticsMacroProtein => 'Protein';

  @override
  String get analyticsMacroCarbs => 'Karbonhidrat';

  @override
  String get analyticsMacroFat => 'Yağ';

  @override
  String get analyticsWeightTrend => 'Kilo trendi';

  @override
  String analyticsWeightTrendDays(int n) {
    return '$n gün';
  }

  @override
  String get analyticsWeightTrendEmpty => 'Trendi görmek için kilonu gir';

  @override
  String profileGreeting(String name) {
    return 'Merhaba, $name';
  }

  @override
  String get profileYourGoals => 'Hedefleriniz';

  @override
  String get profileCouldNotLoad => 'Yüklenemedi';

  @override
  String get profileCouldNotLoadSection => 'Bu bölüm yüklenemedi';

  @override
  String get profileLogWeight => 'Kilo gir';

  @override
  String get profileDailyTarget => 'Günlük Hedef';

  @override
  String profileKcalLeftToday(String n) {
    return 'Bugün $n kcal kaldı';
  }

  @override
  String get profileDailyTargetReached => 'Günlük hedefe ulaşıldı';

  @override
  String get profileStreak => 'Seri';

  @override
  String get profileStreakDays => ' gün';

  @override
  String get profileStreakKeepGoing => 'Devam et!';

  @override
  String get profileStreakStartToday => 'Başlamak için bugün bir öğün gir';

  @override
  String get profileCaloriesVsTarget => 'Kalori - Hedef Karşılaştırması';

  @override
  String get profileProgressLast7Days => 'Son 7 gün';

  @override
  String get profileAvg => 'Ort.';

  @override
  String get profileWithinTarget => 'Hedef dahilinde';

  @override
  String get profileOffTarget => 'Hedef dışında';

  @override
  String profileDaysHit(int n) {
    return '$n/7 gün hedefe ulaşıldı';
  }

  @override
  String get profileProgressNoData => 'Henüz veri yok';

  @override
  String get profileProgressNoDataHint =>
      'Birkaç gün yemek logladığında trend buraya gelir.';

  @override
  String get profileRecommendedTitle => 'Sana Özel Öneriler';

  @override
  String get profileRecommendedSubtitle =>
      'Hedeflerine ulaşmanı sağlayacak kişiselleştirilmiş ipuçları';

  @override
  String get profileRec1Title => 'Yemeklerden önce su iç';

  @override
  String get profileRec1Desc =>
      'Porsiyon kontrolü ve hidrasyona yardımcı olur.';

  @override
  String get profileRec2Title => '30 dakikalık yürüyüş ekle';

  @override
  String get profileRec2Desc => 'Günlük TDEE\'ne ulaşmanın kolay yolu.';

  @override
  String get profileRec3Title => '7–8 saat uy';

  @override
  String get profileRec3Desc => 'Daha iyi toparlanma, daha iyi açlık kontrolü.';

  @override
  String get profileWeightGoal => 'Kilo Hedefi';

  @override
  String get profileLogWeightToSeeTrend => 'Trendi görmek için kilo gir';

  @override
  String profileProgressPercent(String n) {
    return '%$n tamamlandı';
  }

  @override
  String get profileSetWeightGoal => 'Kilo\nhedefini belirle';

  @override
  String get profileTapToStartTracking => 'Takibe başlamak için dokun';

  @override
  String get profileSetWeightGoalTitle => 'Kilo hedefini belirle';

  @override
  String get profileSetWeightGoalSubtitle =>
      'İlerlemenizi takip edip önerileri düzenleyeceğiz.';

  @override
  String get profileGoalType => 'HEDEF TÜRÜ';

  @override
  String get profileGoalLose => 'Kaybet';

  @override
  String get profileGoalMaintain => 'Koru';

  @override
  String get profileGoalGain => 'Kazan';

  @override
  String get profileStartingWeight => 'Başlangıç kilosu';

  @override
  String get profileTargetWeight => 'Hedef kilo';

  @override
  String get profileMaintainWeightAt => 'Kiloyu koru';

  @override
  String get profileTargetDate => 'Hedef tarihi';

  @override
  String get profileChooseDate => 'Tarih seç';

  @override
  String get profileSaveGoal => 'Hedefi kaydet';

  @override
  String get profileGoalErrorTarget =>
      '20 ile 400 kg arasında bir hedef kilo girin';

  @override
  String get profileGoalErrorStart =>
      '20 ile 400 kg arasında bir başlangıç kilosu girin';

  @override
  String get profileGoalErrorLoseLower =>
      'Hedef, başlangıç kilosundan düşük olmalı';

  @override
  String get profileGoalErrorGainHigher =>
      'Hedef, başlangıç kilosundan yüksek olmalı';

  @override
  String get profileGoalSaveError =>
      'Kaydedilemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get profileLogWeightTitle => 'Kilonu gir';

  @override
  String get profileLogWeightSubtitle =>
      'Hedefinize doğru ilerlemenizi takip edin';

  @override
  String get profileWeightLabel => 'Kilo';

  @override
  String get profileWeightNoteOptional => 'Not (isteğe bağlı)';

  @override
  String get profileWeightNoteHint => 'Egzersiz sonrası, sabah, vb.';

  @override
  String get profileWeightError => '20 ile 400 kg arasında bir kilo girin';

  @override
  String get profileSaveWeight => 'Kiloyu kaydet';

  @override
  String profileWeightSaving(String kg) {
    return '$kg kg kaydediliyor...';
  }

  @override
  String profileWeightSaved(String kg) {
    return 'Kilo kaydedildi ($kg kg)';
  }

  @override
  String profileWeightSaveFailed(String kg) {
    return '$kg kg kaydedilemedi';
  }

  @override
  String get profileWeightSavedShort => 'Kilo kaydedildi';

  @override
  String get profileWeightStillFailed => 'Hâlâ kaydedilemedi';

  @override
  String get profileEditTitle => 'Profili düzenle';

  @override
  String get profileEditName => 'Ad';

  @override
  String get profileEditNameHint => 'Adınız';

  @override
  String get profileEditSex => 'Cinsiyet';

  @override
  String get profileEditDob => 'Doğum tarihi';

  @override
  String get profileEditSelectDate => 'Tarih seçin';

  @override
  String get profileEditHeightCm => 'Boy (cm)';

  @override
  String get profileEditWeightKg => 'Kilo (kg)';

  @override
  String get profileEditActivityLevel => 'Aktivite seviyesi';

  @override
  String get profileEditDietaryPref => 'Beslenme tercihi';

  @override
  String get profileEditUpdated => 'Profil güncellendi';

  @override
  String get welcomeGetStarted => 'Başlayalım';

  @override
  String get loginWelcomeBack => 'Tekrar hoş geldin';

  @override
  String get loginSubtitle => 'Yolculuğuna devam etmek için giriş yap';

  @override
  String get loginForgotPasswordFull => 'Şifreni mi unuttun?';

  @override
  String get loginSignIn => 'Giriş yap';

  @override
  String get loginDontHaveAccount => 'Hesabın yok mu?';

  @override
  String get loginSignUp => 'Kayıt ol';

  @override
  String get signupCreateAccount => 'Hesap oluştur';

  @override
  String get signupNutritionJourney => 'Beslenme yolculuğuna başlayalım';

  @override
  String get signupConfirmPassword => 'Şifreyi onayla';

  @override
  String get signupTermsAgree => 'Kabul ediyorum: ';

  @override
  String get signupTermsOfService => 'Kullanım Koşulları';

  @override
  String get signupTermsAnd => ' ve ';

  @override
  String get signupPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get signupAcceptTermsError => 'Devam etmek için Koşulları kabul edin.';

  @override
  String get signupAlreadyHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get signupSignIn => 'Giriş yap';

  @override
  String get forgotPasswordTitle => 'Şifreyi sıfırla';

  @override
  String get forgotPasswordSubtitle =>
      'E-postanı gir, şifre sıfırlama bağlantısı gönderelim.';

  @override
  String get forgotPasswordSendLink => 'Sıfırlama bağlantısı gönder';

  @override
  String get forgotPasswordRemember => 'Şifreni hatırladın mı?';

  @override
  String get forgotPasswordCheckEmail => 'E-postanı kontrol et';

  @override
  String forgotPasswordSentLink(String email) {
    return '$email adresine şifre sıfırlama bağlantısı gönderdik.';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Girişe geri dön';

  @override
  String get verifyEmailSentLinkTo =>
      'Doğrulama bağlantısı şu adrese gönderildi:';

  @override
  String get verifyEmailOpenOnDevice => 'Devam etmek için bu cihazda aç.';

  @override
  String get verifyEmailResendEmail => 'E-postayı yeniden gönder';

  @override
  String verifyEmailResendInSeconds(int seconds) {
    return '$seconds sn sonra tekrar gönder';
  }

  @override
  String get verifyEmailWrongEmail => 'Yanlış e-posta mı?';

  @override
  String get verifyEmailGoBack => 'Geri dön';

  @override
  String get resetPasswordTitle => 'Yeni şifre belirle';

  @override
  String get resetPasswordSubtitle => 'Hesabın için güçlü bir şifre seç.';

  @override
  String get resetPasswordNewPassword => 'Yeni şifre';

  @override
  String get resetPasswordConfirmPassword => 'Şifreyi onayla';

  @override
  String get resetPasswordUpdate => 'Şifreyi güncelle';

  @override
  String get resetPasswordUpdated => 'Şifre güncellendi';

  @override
  String get resetPasswordCanNowSignIn =>
      'Artık yeni şifrenle giriş yapabilirsin.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String get onboardingSignOutTooltip => 'Çıkış yap';

  @override
  String get onboardingSignOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get onboardingSignOutBody =>
      'İlerlemeniz kaydedildi. Kuruluma daha sonra devam edebilirsiniz.';

  @override
  String get onboardingCompleteStepsError =>
      'Devam etmeden önce tüm adımları tamamlayın.';

  @override
  String get onboardingSaveError =>
      'Profilin kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get onboardingStep1Title => 'Merhaba! Seni tanıyalım';

  @override
  String get onboardingStep1Body =>
      'Vücuduna, yaşam tarzına ve hedeflerine göre beslenme koçluğunu kişiselleştireceğiz. Sadece bir dakika sürer.';

  @override
  String get onboardingStep2Title => 'Bize kendinizden bahsedin';

  @override
  String get onboardingStep2Subtitle =>
      'Bu, günlük ihtiyaçlarını hesaplamamıza yardımcı olur.';

  @override
  String get onboardingYourName => 'Adın';

  @override
  String get onboardingNameHint => 'Seni nasıl çağıralım?';

  @override
  String get onboardingNameRequired => 'İsim zorunludur';

  @override
  String get onboardingDateOfBirth => 'Doğum tarihi';

  @override
  String get onboardingSelectDate => 'Tarih seç';

  @override
  String get onboardingSelectDob => 'Lütfen doğum tarihinizi seçin';

  @override
  String get onboardingSelectGender => 'Lütfen cinsiyetinizi seçin';

  @override
  String get onboardingStep3Title => 'Vücut ölçülerin';

  @override
  String get onboardingStep3Subtitle =>
      'Endişelenme, bunları istediğin zaman güncelleyebilirsin.';

  @override
  String get onboardingHeight => 'Boy';

  @override
  String get onboardingCurrentWeight => 'Mevcut ağırlık';

  @override
  String get onboardingStep4Title => 'Hedeflerin';

  @override
  String get onboardingStep4Subtitle =>
      'Günlük hedeflerini buna göre belirleyeceğiz.';

  @override
  String get onboardingActivityLevelLabel => 'Aktivite düzeyi';

  @override
  String get onboardingYourGoalLabel => 'Hedefin';

  @override
  String get onboardingTargetWeight => 'Hedef ağırlık';

  @override
  String get onboardingToLose => 'vermek';

  @override
  String get onboardingToGain => 'almak';

  @override
  String get onboardingSelectActivityError =>
      'Lütfen aktivite düzeyinizi seçin';

  @override
  String get onboardingSelectGoalError => 'Lütfen bir hedef seçin';

  @override
  String get onboardingStep5Title => 'Günlük hedeflerin';

  @override
  String get onboardingStep5Subtitle =>
      'Vücuduna, yaşam tarzına ve hedefine göre kişiselleştirildi.';

  @override
  String get onboardingDailyCalories => 'GÜNLÜK KALORİ';

  @override
  String get onboardingMacros => 'Makrolar';

  @override
  String get onboardingProtein => 'Protein';

  @override
  String get onboardingCarbs => 'Karbonhidrat';

  @override
  String get onboardingFat => 'Yağ';

  @override
  String get onboardingDailyWater => 'Günlük su';

  @override
  String get onboardingCompleteSetup => 'Kurulumu Tamamla';

  @override
  String get onboardingAdjustAnytime =>
      'Bunları istediğin zaman Ayarlar\'da düzenleyebilirsin.';

  @override
  String get authContinueWithApple => 'Apple ile devam et';

  @override
  String get authContinueWithGoogle => 'Google ile devam et';

  @override
  String get authValidatorEmailRequired => 'E-posta zorunludur';

  @override
  String get authValidatorEmailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get authValidatorPasswordRequired => 'Şifre zorunludur';

  @override
  String get authValidatorPasswordLength => 'En az 8 karakter';

  @override
  String get authValidatorPasswordNumber => 'En az bir rakam ekleyin';

  @override
  String get authValidatorPasswordSimpleLength => 'En az 6 karakter';

  @override
  String get authValidatorConfirmRequired => 'Lütfen şifreyi onaylayın';

  @override
  String get authValidatorPasswordsNoMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordStrengthWeak => 'Zayıf';

  @override
  String get passwordStrengthFair => 'Orta';

  @override
  String get passwordStrengthStrong => 'Güçlü';

  @override
  String get passwordStrengthVeryStrong => 'Çok güçlü';

  @override
  String get passwordStrengthSuggestLength => 'En az 8 karakter kullanın';

  @override
  String get passwordStrengthSuggestNumber => 'Bir rakam ekleyin';

  @override
  String get passwordStrengthSuggestCase => 'Büyük ve küçük harf karıştırın';

  @override
  String get passwordStrengthSuggestSymbol => 'Sembol ekleyin (!@#\\\$%)';

  @override
  String get authOrDivider => 'veya';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navScan => 'Tara';

  @override
  String get navAnalytics => 'Analiz';

  @override
  String get homeTodaySummary => 'Bugünün Özeti';

  @override
  String homeKcalRemaining(String count) {
    return '$count kcal kaldı';
  }

  @override
  String homeKcalOver(String count) {
    return '$count kcal fazla';
  }

  @override
  String homeOfKcalTarget(String count) {
    return '/ $count kcal';
  }

  @override
  String homeOfGlasses(String count) {
    return '/ $count bardak';
  }

  @override
  String get recipeBrowserTitle => 'Tarif Ara';

  @override
  String get recipeBrowserSearchHint => 'Tariflerde ara…';

  @override
  String get recipeBrowserEmpty => 'Tarif bulunamadı';

  @override
  String get recipeBrowserEmptyHint =>
      'Tarif kütüphanesi yakında büyüyecek. Öğünleri manuel ekleyebilirsiniz.';

  @override
  String get recipeBrowserLoadError => 'Tarifler yüklenemedi';

  @override
  String recipeBrowserCaloriesPerServing(int n) {
    return 'Porsiyon başına $n kcal';
  }

  @override
  String get recipeBrowserProtein => 'Protein';

  @override
  String get recipeBrowserCarbs => 'Karbonhidrat';

  @override
  String get recipeBrowserFat => 'Yağ';

  @override
  String get recipeBrowserAddToPlan => 'Plana ekle';

  @override
  String get recipeBrowserServingsLabel => 'Porsiyon';

  @override
  String get recipeBrowserMealType => 'Öğün türü';

  @override
  String get recipeBrowserDay => 'Gün';

  @override
  String get recipeBrowserAdded => 'Plana eklendi';

  @override
  String get recipeBrowserAddFailed => 'Plana eklenemedi';

  @override
  String get habitUpdateFailed => 'Alışkanlık güncellenemedi';

  @override
  String get notifScreenTitle => 'Bildirimler';

  @override
  String get notifOpenSystemSettingsTitle => 'Sistem ayarları açılsın mı?';

  @override
  String get notifOpenSystemSettingsBody =>
      'Bildirimleri reddettiniz. Yeniden açmak için Ayarlar\'a gidin.';

  @override
  String get notifOpenSettings => 'Ayarları Aç';

  @override
  String get notifAllNotifications => 'Tüm bildirimler';

  @override
  String get notifMasterSwitch => 'Nuveli bildirimlerini etkinleştir';

  @override
  String get notifMasterSwitchDesc => 'Aşağıdaki her şey için ana anahtar.';

  @override
  String get notifWaterSection => 'Su';

  @override
  String get notifWaterMorning => 'Sabah · 09:00';

  @override
  String get notifWaterMorningDesc => 'Hidrasyon rutinini başlat.';

  @override
  String get notifWaterAfternoon => 'Öğleden sonra · 13:00';

  @override
  String get notifWaterAfternoonDesc => 'Öğle arası hatırlatıcı.';

  @override
  String get notifWaterEvening => 'Akşam · 18:30';

  @override
  String get notifWaterEveningDesc => 'Günü kapatırken içmeyi unutma.';

  @override
  String get notifMealsSection => 'Öğünler';

  @override
  String get notifMealsTitle => 'Öğle ve akşam yemeği hatırlatıcıları';

  @override
  String get notifMealsDesc => '12:30 ve 19:00\'da kayıt için uyarı.';

  @override
  String get notifHabitsSection => 'Alışkanlıklar';

  @override
  String get notifHabitsTitle => 'Alışkanlık hatırlatıcıları';

  @override
  String get notifHabitsDesc =>
      'Belirlediğin saatlerde her alışkanlık için uyarı. Alışkanlıklar ekranından yönetebilirsin.';

  @override
  String get notifSleepSection => 'Uyku';

  @override
  String get notifSleepTitle => 'Rüzgar azaltma hatırlatıcısı';

  @override
  String get notifSleepDesc => 'Yatma saatinden 30 dakika önce.';

  @override
  String get notifBedtime => 'Yatma saati';

  @override
  String get notifCoachingSection => 'Koçluk';

  @override
  String get notifStreakTitle => 'Seri uyarısı';

  @override
  String get notifStreakDesc => 'Bugün kayıt yapmadıysan 21:00\'de uyarı.';

  @override
  String get notifAiInsightTitle => 'Yapay zeka içgörüsü hazır';

  @override
  String get notifAiInsightDesc => 'Koçluk tazelendiğinde sabah bildirimi.';

  @override
  String get notifWeeklyRecapTitle => 'Haftalık özet';

  @override
  String get notifWeeklyRecapDesc => 'Pazar 20:00 özeti.';

  @override
  String get notifPermissionOff => 'Bildirimler kapalı';

  @override
  String get notifPermissionDenied =>
      'Hatırlatıcılar için Ayarlar\'dan bildirimleri aç.';

  @override
  String get notifPermissionNotAsked =>
      'Yalnızca seçtiğin bildirimleri göndereceğiz.';

  @override
  String get notifPermissionAllow => 'İzin Ver';

  @override
  String get notifPermissionSettings => 'Ayarlar';

  @override
  String get notifTestButton => 'Test bildirimi gönder (10s)';

  @override
  String get notifTestScheduled => 'Test bildirimi 10 saniyede zamanlandı.';

  @override
  String get coachActionAddMeal => 'Öğün ekle';

  @override
  String get coachActionSetReminder => 'Hatırlatıcı kur';

  @override
  String get coachActionAddHabit => 'Alışkanlık ekle';

  @override
  String get coachActionLogWater => 'Su kaydet';

  @override
  String get coachActionUpdateTarget => 'Hedefi güncelle';

  @override
  String get coachActionApply => 'Uygula';
}
