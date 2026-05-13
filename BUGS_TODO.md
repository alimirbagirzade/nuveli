# Nuveli — Yapılacaklar

**Son güncelleme:** 13 Mayıs 2026, öğleden sonra
**Durum:** İki gün boyunca devasa ilerleme. Backend stabil, AI çalışıyor, account akışı temiz. Geriye App Store hazırlığı kaldı.

---

## 🔴 P0 — Launch blockers (App Store için zorunlu)

### 1. Apple Sign In
**Neden:** App Store kuralı — email/password authentication varsa Apple Sign In **zorunlu**.
Olmadan TestFlight'a çıkılabilir ama App Review reddeder.

**Plan:**
- `sign_in_with_apple` package ekle (pubspec.yaml)
- iOS: Apple Developer'da "Sign in with Apple" capability aç
- Supabase Auth → Providers → Apple Provider'ı yapılandır
- Login/signup ekranlarına "Apple ile devam et" butonu ekle
- Backend'de Apple JWT verify (Supabase otomatik halleder)

**Tahmini süre:** 2-3 saat

### 2. Google Sign In
**Neden:** Apple kadar zorunlu değil ama Apple Sign In eklendiyse genelde birlikte gelir, kullanıcılar bekler.

**Plan:**
- `google_sign_in` package
- Firebase ve/veya Supabase'de Google OAuth client ID
- iOS: GoogleService-Info.plist (zaten varsa kontrol)
- Android: SHA-1 fingerprint Firebase'e

**Tahmini süre:** 1-2 saat

---

## 🟠 P1 — Production readiness

### 3. TestFlight'a yükle
- Apple Developer Program enrollment ($99/yıl, 24-48 saat onay)
- Bundle ID: `com.nuveli.app` — App Store Connect'te app oluştur
- Xcode'da Archive → Distribute → App Store Connect
- TestFlight Internal Testing grubu oluştur
- Gerçek cihazda end-to-end test

**Tahmini süre:** Yarım gün (enrollment hariç)

### 4. App Store listing
- 7 dilde açıklamalar (tr, en, de, es, fr, it, ru)
- Screenshot'lar (6.7" iPhone — 1290x2796) — en az 3, ideal 6
- Promosyon görseli
- Privacy policy URL (nuveli.com.tr'de hazır mı?)
- Support URL

**Tahmini süre:** 4-6 saat (içerik + tasarım)

### 5. Manuel meal kalori auto-fill (P1 feature)
Kullanıcı "pilav" yazınca otomatik kalori dolması.

**Seçenekler:**
- Backend `/meal/lookup-text` endpoint (GPT-4 ile text→nutrition) — en hızlı, mevcut altyapı
- Open Food Facts API — bedava ama Türk yemekleri zayıf
- USDA food database — sadece İngilizce/ABD ürünleri

**Tahmini süre:** 1-2 saat

---

## 🟡 P2 — Polish / nice-to-have

- **Bootstrap re-routing test:** Onboarding bitmiş user app restart'ta acceptance'a düşmemeli. Son testlerde reproduce edilmedi, sürekli izle.
- **Real cold start test:** cron-job.org keepalive'ı 20dk pause et, app aç → ColdStartView göründüğünü doğrula.
- **Android deep link real device:** Emulator yok, gerçek cihazda nuveli:// linkini test et.
- **REVENUECAT_WEBHOOK_SECRET:** Premium aktif olunca Render env'e eklenecek.
- **Premium personas:** Atlet, Anne, Bilge — şu an sadece "Mentor" var.
- **Supabase service_role + JWT rotation:** Düşük öncelik, sızdırılmadı.
- **Custom domain:** api.nuveli.com.tr → CNAME nuveli-api.onrender.com (kozmetik).
- **MealAnalysisResultScreen test:** Codec fix sonrası eski test silindi, yeniden yaz (provider mock'lu).

---

## ✅ Tamamlandı

### 13 Mayıs 2026
- ✅ Codec warning fix — MealAnalysisResult Riverpod state'e taşındı (9d0a54d)
- ✅ Back button GoError fix — `_safeBack` helper + canPop check (ec1bc1c)
- ✅ Backend debug kodu temizlendi — `meal_service.py` production-clean (fa35439)
- ✅ Render konsolide — ikinci `nuveli-test` Docker servisi silindi
- ✅ Account switch testi — ambz↔alimir geçişi sorunsuz

### 12 Mayıs 2026
- ✅ OpenAI key rotation + Render env güncellendi
- ✅ AI analiz çalışıyor (text + image, confidence: high)
- ✅ Account state leak fix — `_clearAllUserStateProvider`, 12 provider invalidate (71a9553)
- ✅ Email verification (PKCE → implicit + verify_email_screen)
- ✅ Deep link (iOS + Android, nuveli://)
- ✅ cron-job.org keepalive (her 5dk /health ping)
- ✅ Cold start UX (ColdStartError, ColdStartView, retry logic) (74411b5)
- ✅ Onboarding repository AppError sarması (4 metod)
- ✅ Splash logo tam ekran (scaleAspectFill + siyah arka plan)
- ✅ Meal capture crash fix (failed durumda /meal/result atla) (eb2c8f6)
- ✅ `reset-nuveli` developer alias

---

## 📂 Kritik path'ler

- Repo: `~/development/nuveli/`
- Backend URL: `https://nuveli-api.onrender.com`
- Service ID: `srv-d7jtrr1kh4rs739ocoa0` (Python 3, Free tier, Oregon)
- Supabase project: `asicgcnpahdnitzalcva`
- Bundle ID: `com.nuveli.app`
- Domain: `nuveli.com.tr` (Namecheap)
