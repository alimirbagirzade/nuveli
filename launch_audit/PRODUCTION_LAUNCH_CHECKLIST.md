# 🚀 Production Launch Checklist

**Sahada bitirilecekler için tek-kaynak rehber.** Audit fazları (Phase 1-8) ve `LAUNCH_DECISION.md` zaten kod tarafının yeşil olduğunu gösteriyor — bu dokümanda **Ali'nin cihazda + dashboard'da + storeda** yapacağı her şey adım adım var.

**Tahmini toplam süre:** 6-8 saat (test) + Apple review bekleme (1-3 gün) + Play review (3-7 gün).

---

## Önce-Sahadayken Test (Cihazda)

### 1. Smoke test (~30 dk)
```bash
cd /Users/mirbagirzade/Development/nuveli/app
flutter run -d <ios-device-id>      # flutter devices ile id'leri gör
# veya
flutter run -d <android-device-id>
```

**iOS'ta:**
- [ ] Cold start < 3 sn
- [ ] Welcome → "Continue with Apple" → Apple ID picker → onboarding → dashboard
- [ ] Welcome → "Continue with Google" → Google account picker → onboarding → dashboard
- [ ] Dashboard avatar (sağ üstte) tap → Settings ekranı açılır
- [ ] Settings → "Export My Data" → backend 200 → share sheet açılır → Files'a kaydet → JSON dosyasını aç, doğru şekil
- [ ] Settings → "Delete My Account" → "DELETE" yaz → Confirm → backend 200 → welcome'a düş
- [ ] Silinen hesabın email'iyle tekrar signup → temiz başlangıç (eski meals/water yok)

**Android'de:**
- [ ] Aynı flow — "Continue with Google" + "Export" + "Delete"
- [ ] iOS-only "Continue with Apple" butonunun GÖZÜKMEDİĞİNI doğrula

### 2. Phase 3 RLS + DB consistency probes (~20 dk)
Supabase Dashboard → SQL Editor:
- [ ] `launch_audit/FAZ_3_DATA_INTEGRITY/rls_policy_test.md` içindeki 14 sorguyu çalıştır
   - Her cross-user count = 0 olmalı
   - Cross-user INSERT denemesi RLS violation vermeli
- [ ] `launch_audit/FAZ_3_DATA_INTEGRITY/database_consistency.md` 10 sorguyu çalıştır
   - Orphan record sayıları = 0
   - Sanity bounds = 0 ihlal
   - Streak/premium state tutarlı

Sonuçları `LAUNCH_DECISION.md`'in Phase 3 satırına yapıştır (86 → final skor).

### 3. Phase 4 user-journey (~3-4 saat)
`launch_audit/FAZ_4_USER_JOURNEY/test_checklist.md` — 65 senaryo.
- [ ] Happy path 20/20 (hedef: ≥19)
- [ ] Sad path: ≥25/30 (hedef: ≥25)
- [ ] Unhappy user: ≥12/15

Critical fail varsa (auth bozuk, premium broken vb.) → fix → retest.

### 4. Phase 5 device matrix (~3-4 saat)
`launch_audit/FAZ_5_DEVICE_MATRIX/test_matrix.md` — 8 cihaz × 5 senaryo.
- [ ] iPhone SE / iPhone 14 Pro Max / iPad Pro tepe-noktaları
- [ ] iOS 17 + Android API 33 minimum
- [ ] 7 dilde permission popup'ları + dashboard greeting

### 5. Phase 6 load + stress (~2 saat)
```bash
export TEST_TOKEN="<paste real JWT>"
k6 run --vus 50 --duration 5m launch_audit/FAZ_6_LOAD_STRESS/load_test.js
```
- [ ] p95 < 2000ms
- [ ] error rate < 1%
- [ ] 100 concurrent user sustain

Render free tier 100 user dayanmıyorsa → paid plan'a geç submission öncesi.

---

## Production Firebase / Google Cloud

### 6. Play App Signing SHA → Firebase
1. Play Console → bu uygulamayı seç
2. **Setup → App integrity → App signing**
3. **App signing key certificate** bölümünde:
   - **SHA-1 certificate fingerprint** → kopyala
   - **SHA-256 certificate fingerprint** → kopyala
4. Firebase Console → **Project settings → General → Your apps → Android app**
5. **+ Add fingerprint** → SHA-1 yapıştır → Save
6. Tekrar **+ Add fingerprint** → SHA-256 yapıştır → Save
7. **Download google-services.json** → `app/android/app/google-services.json` üzerine yaz (eskisini overwrite)

⚠️ **Bu yapılmazsa Play Store'daki kullanıcılar Google Sign-In'ı kullanamaz.** Debug SHA dev için yeterli, prod'da release-signed APK farklı imza taşır.

### 7. Production .env (Render)
Render dashboard → Nuveli backend service → Environment:
- [ ] `SUPABASE_URL` = production
- [ ] `SUPABASE_SERVICE_ROLE_KEY` = production service role
- [ ] `SUPABASE_JWT_SECRET` = production JWT secret
- [ ] `OPENAI_API_KEY` = production tier key
- [ ] `REVENUECAT_WEBHOOK_SECRET` = RC webhook secret
- [ ] `CORS_ORIGINS` = `https://nuveli.com.tr,https://nuveli.app` (Ali doğruladı)
- [ ] `SENTRY_DSN` = production Sentry project

### 8. Backend health check
- [ ] `curl https://nuveli-api.onrender.com/health` → 200 OK
- [ ] `pip install -r requirements.txt` deploy log'unda jose 3.5.0 + slowapi 0.1.9 görünüyor

### 9. App Store reviewer account seed
```bash
cd /Users/mirbagirzade/Development/nuveli/backend
source venv/bin/activate
python scripts/seed_reviewer_account.py --allow-production
```
Çıktıdaki credentials'ı (email + password + user_id) **App Store Connect → App Review Information → Sign-In Required → Username/Password** alanlarına yapıştır.

---

## App Store Connect (Apple)

### 10. App Privacy form
Apple Privacy Nutrition Label — `launch_audit/FAZ_7_COMPLIANCE/SUMMARY.md` "Apple Privacy Nutrition Label" bölümündeki tablo:
- [ ] 11 data type doğru işaretlendi
- [ ] **"Used to Track You" hepsi NO**
- [ ] Privacy Policy URL: `https://nuveli.com.tr/gizlilik.html` (veya İngilizce: `/privacy/en`)

### 11. Subscription disclosure
Paywall'ın aşağıdakileri açıkça gösterdiğini doğrula:
- [ ] Free trial süresi (7 gün)
- [ ] Auto-renew price (aylık $9.99, yıllık $XX.XX)
- [ ] "Cancel anytime in App Store settings"
- [ ] "Restore Purchases" butonu var

### 12. Reviewer notes
App Review Information → Notes:
```
1. Use the test account provided (reviewer@nuveli.app / ReviewPass2026!) — already has Premium and 7 days of demo data.
2. Account deletion: Avatar (top-right of dashboard) → Settings → Delete My Account → type "DELETE" → confirm.
3. Data export: Settings → Export My Data → opens system share sheet with JSON.
4. Apple Sign-In is available on Welcome / Login / Signup screens.
5. The app is a wellness coach — no medical advice, no clinical diet plans. See Terms at https://nuveli.com.tr/sartlar.html.

If you need anything else: support@nuveli.com.tr
```

### 13. Description language polish
- [ ] "medical" / "treat" / "cure" / "diagnose" kelimeleri YOK (Apple 1.4 reject sebebi)
- [ ] "Personalized wellness tracking" / "AI calorie coach" gibi wellness odaklı dil ✅

### 14. Build + submit
```bash
cd /Users/mirbagirzade/Development/nuveli/app
flutter build ipa --release
```
- [ ] Build başarılı, `.ipa` < 200MB
- [ ] Xcode → Window → Organizer → Archives → Distribute App → App Store Connect → Upload
- [ ] TestFlight'ta görünür mü kontrol
- [ ] App Store Connect → Submit for Review → manual release

---

## Google Play Console

### 15. Data Safety form
- [ ] Tüm data types declare edildi
- [ ] **Encryption in transit: Yes**
- [ ] **Data deletion mechanism: Yes** → `https://nuveli.com.tr/delete-account` (veya in-app yönlendirme)

### 16. Permission justifications
Play Console → App content → Sensitive permissions:
- [ ] `SCHEDULE_EXACT_ALARM` — açıklama: "Used for reliable meal + water reminder notifications at user-chosen times"
- [ ] `RECEIVE_BOOT_COMPLETED` — açıklama: "Re-schedules pending notifications after device reboot"
- [ ] `CAMERA` — açıklama: "User takes meal photos for AI calorie analysis"

### 17. Health features declaration
- [ ] "Health and fitness features" declared
- [ ] **NOT a medical app** — explicitly checked
- [ ] Not for diagnosis/treatment

### 18. Build + upload
```bash
cd /Users/mirbagirzade/Development/nuveli/app
flutter build appbundle --release
```
- [ ] `.aab` build başarılı, < 200MB
- [ ] Play Console → Production → Create release → upload `.aab`
- [ ] Staged rollout %20 (gözlem için)

---

## Submission Day Order

Apple çoğunlukla Google'dan hızlı review'a girer. Önerilen:

```
SABAH (09:00)
  1. Backend deploy verify (Render canlı + health 200)
  2. Reviewer seed çalıştır → credentials elde
  3. Production SHA-1/256 Firebase'e ekle, google-services.json refresh
  4. Local build:
       flutter clean
       flutter build ipa --release
       flutter build appbundle --release

ÖĞLE (12:00)
  5. App Store Connect — Submit for Review (manual release)
  6. Play Console — Production release upload + start rollout

ÖĞLEDEN SONRA (15:00)
  7. Sentry dashboard izle (crash rate < 0.5%)
  8. Render server load izle
  9. OpenAI usage paneline bak (cost spike var mı)

AKŞAM
  10. Submission confirmation email geldi mi
  11. Yarına hazır: hotfix branch ile bekle
```

---

## Post-Launch İlk 72 Saat

`launch_audit/FAZ_8_GO_NOGO/LAUNCH_DECISION.md` "Post-Launch İlk 72 Saat Plan" bölümüne bak. Özet:
- 0-24 saat: crash rate + support email monitoring
- 24-48 saat: conversion funnel analiz
- 48-72 saat: hotfix gerekirse v1.0.1 hazırla

---

## STOP — Bu Olursa Submit DURDUR

`LAUNCH_DECISION.md` "STOP CRITERIA" bölümü. Özet:
1. Phase 4'te ≥2 Critical fail
2. iPhone SE veya iPhone 14 Pro'da crash
3. Phase 6 p95 > 5000ms
4. RLS cross-user data leak (1 satır bile)
5. Production backend down
6. CI red (artık olmamalı ama olursa)

---

## Referanslar

- Audit master: `launch_audit/00_audit_overview.md`
- Decision: `launch_audit/FAZ_8_GO_NOGO/LAUNCH_DECISION.md`
- Known issues v1.0.1: `launch_audit/FAZ_8_GO_NOGO/known_issues_v1.md`
- Google Sign-In setup: `docs/auth/google-signin-setup.md`
- Firebase setup: `docs/FIREBASE_SETUP.md`
- Submission detail: `launch_assets/submission/submit_checklist.md`
- Release QA: `docs/qa/release-checklist.md`

**Bu doc launch günü tek-kaynak. Diğer doc'lar daha derin ama bu sıralamayı takip et.**
