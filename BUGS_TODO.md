# Nuveli — Yapılacaklar

**Son güncelleme:** 14 Mayıs 2026
**Durum:** App tamamen çalışır halde. Backend stabil, AI çalışıyor, 7 dilde legal sayfalar yayında. Geriye Apple Developer + iOS native hazırlıkları kaldı.

---

## 🔴 P0 — Launch blockers (App Store için zorunlu)

### 1. Apple Developer Program enrollment
**Neden:** App Store'a yüklemenin tek yolu.

**Plan:**
- https://developer.apple.com/programs/enroll/
- Individual üyelik: $99/yıl
- Apple ID ile giriş
- Kimlik doğrulama (T.C. kimlik fotoğrafı)
- Onay süresi: 24-48 saat
- Onay sonrası: App Store Connect ve Certificates, Identifiers & Profiles erişimi açılır

**Tahmini süre:** 15 dk doldurma + 1-2 gün bekleme

### 2. Apple Sign In
**Neden:** App Store kuralı — email/password authentication varsa Apple Sign In **zorunlu**.

**Plan:**
- pubspec.yaml'a `sign_in_with_apple` package ekle
- iOS: Xcode'da "Sign in with Apple" capability aktif et
- Supabase Auth → Providers → Apple Provider yapılandır
- Login/signup ekranlarına "Apple ile devam et" butonu
- Test: iCloud hesabıyla giriş yap

**Tahmini süre:** 2-3 saat

### 3. Google Sign In
**Neden:** Apple ile birlikte beklenir, kullanıcı kolaylığı.

**Plan:**
- `google_sign_in` package
- Firebase ve/veya Supabase Google OAuth client ID
- Android: SHA-1 fingerprint Firebase'e

**Tahmini süre:** 1-2 saat

---

## 🟠 P1 — Production hazırlıkları

### 4. iOS teknik hazırlıklar
- **Info.plist izin açıklamaları** (NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSUserNotificationUsageDescription)
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) — iOS 17+ zorunlu
- **App icons** — 1024x1024 master + tüm boyutlar (Xcode otomatik üretir)
- **Version + Build numbers** — `pubspec.yaml`'da `version: 1.0.0+1` formatı
- **Bundle ID:** `com.nuveli.app` (zaten ayarlı)

**Tahmini süre:** 2-3 saat

### 5. App Store Connect listing
- App oluştur (Bundle ID seç)
- 7 dilde **açıklamalar** (kısa + uzun)
- 7 dilde **anahtar kelimeler** (keywords)
- **Screenshot'lar** — 6.7" iPhone (1290x2796) — en az 3, ideal 6
- **Promosyon görseli** (opsiyonel)
- Privacy Policy URL: `https://nuveli.com.tr/privacy/[dil]` ✅ HAZIR
- Terms URL: `https://nuveli.com.tr/terms/[dil]` ✅ HAZIR
- Support URL: `https://nuveli.com.tr/iletisim.html` ✅ HAZIR
- Support email: `support@nuveli.com.tr` ✅ HAZIR

**Tahmini süre:** Yarım gün (içerik + screenshot tasarımı)

### 6. TestFlight'a ilk yükleme
- Xcode'da Archive → Distribute → App Store Connect
- TestFlight Internal Testing grubu oluştur
- Kendini test kullanıcısı ekle
- Cihazda kur, end-to-end test

**Tahmini süre:** 1-2 saat (ilk seferde sertifika/profile sorunları olabilir)

---

## 🟡 P2 — Polish / nice-to-have

- **Manuel meal AI auto-fill** (P1'den ertelendi) — `/meal/manual` ekranında "AI ile doldur" butonu. Tasarım kararı verildi: ana akış `/meal/capture` zaten text-only AI yapıyor.
- **Real cold start test** — cron-job.org keepalive'ı 20dk pause et, app aç → `ColdStartView` göründüğünü doğrula
- **Android deep link real device test** — Şu an sadece iOS test edildi (emulator yok)
- **REVENUECAT_WEBHOOK_SECRET** — Premium aktif olunca Render env'e eklenecek
- **Premium personas** — Atlet, Anne, Bilge (şu an sadece "Mentor")
- **Bootstrap re-routing test** — onboarding bitmiş user app restart'ta acceptance'a düşmemeli (son testlerde reproduce edilmedi)
- **Custom domain api.nuveli.com.tr** — Render free tier custom domain desteklemiyor, paid plan ($7/ay) gerekli. Kozmetik.
- **MealAnalysisResultScreen test** — Codec fix sonrası eski test silindi, yeniden yaz (provider mock'lu)
- **Supabase service_role + JWT rotation** — Düşük öncelik, sızdırılmadı

---

## ✅ Tamamlandı

### 14 Mayıs 2026
- ✅ Codec warning fix — MealAnalysisResult Riverpod state'e taşındı (9d0a54d)
- ✅ Back button GoError fix — `_safeBack` helper + canPop check (ec1bc1c)
- ✅ Backend debug kodu temizlendi (fa35439)
- ✅ Render konsolide — ikinci Docker servisi silindi
- ✅ `/meals/lookup-text` endpoint deneme + revert (manuel ekrana gerek olmadığı anlaşıldı, temiz state)
- ✅ Privacy + Terms TR güncellendi (18+, KVKK Madde 9/11/12, Istanbul mahkemeleri)
- ✅ Privacy + Terms 6 dilde güncellendi: EN, DE, FR, ES, IT, RU
- ✅ App Store başvurusu için **legal hazır** (7 dilde, KVKK + GDPR uyumlu)

### 13 Mayıs 2026
- ✅ OpenAI key rotation + Render env güncellendi
- ✅ AI analiz çalışıyor (text + image, confidence: high)
- ✅ Account state leak fix — `_clearAllUserStateProvider`, 12 provider invalidate (71a9553)

### 12 Mayıs 2026
- ✅ Email verification (PKCE → implicit + verify_email_screen)
- ✅ Deep link (iOS + Android, nuveli://)
- ✅ cron-job.org keepalive (her 5dk /health ping)
- ✅ Cold start UX (ColdStartError, ColdStartView, retry logic) (74411b5)
- ✅ Onboarding repository AppError sarması
- ✅ Splash logo tam ekran (scaleAspectFill + siyah arka plan)
- ✅ Meal capture crash fix (failed durumda /meal/result atla) (eb2c8f6)
- ✅ `reset-nuveli` developer alias

---

## 📂 Kritik path'ler

- **Repo:** `~/development/nuveli/`
- **Backend URL:** `https://nuveli-api.onrender.com`
- **Render Service ID:** `srv-d7jtrr1kh4rs739ocoa0` (Python 3, Free tier, Oregon)
- **Supabase project:** `asicgcnpahdnitzalcva`
- **Bundle ID:** `com.nuveli.app`
- **Domain:** `nuveli.com.tr` (Natro hosting)
- **Support email:** `support@nuveli.com.tr`
- **Legal URLs (App Store için):**
  - https://nuveli.com.tr/gizlilik.html
  - https://nuveli.com.tr/sartlar.html
  - https://nuveli.com.tr/privacy/{en,de,fr,es,it,ru}
  - https://nuveli.com.tr/terms/{en,de,fr,es,it,ru}
