# Nuveli Deployment Rehberi

Bu rehber projenin hangi bileşeninin nereye deploy edileceğini ve sırasıyla ne yapılacağını anlatır.

---

## Mimari Özeti

```
┌──────────────────────┐     ┌──────────────────────┐
│ nuveli.com.tr        │     │ App Store / Play Store│
│ (Shared hosting)     │     │ (Flutter app)         │
│ Landing + Privacy    │     │                       │
└──────────────────────┘     └────────────┬──────────┘
                                           │
                             ┌─────────────▼──────────┐
                             │ api.nuveli.com.tr      │
                             │ (Render / Railway)     │
                             │ FastAPI backend        │
                             └─────────────┬──────────┘
                                           │
                             ┌─────────────▼──────────┐
                             │ Supabase Cloud         │
                             │ Auth + DB + Storage    │
                             └────────────────────────┘
```

---

## 1) Landing Page — `nuveli.com.tr` (Shared Hosting)

**Dosyalar:** `landing/` klasöründe (`index.html`, `gizlilik.html`, `sartlar.html`, `favicon.svg`, `robots.txt`, `sitemap.xml`)

**Adımlar:**
1. cPanel → **File Manager** → `public_html/`
2. Klasörün içini **boşalt** (varsayılan index.html gibi)
3. Yerel bilgisayarda `landing/` içindeki **tüm dosyaları** seç → ZIP yap
4. cPanel'e ZIP'i yükle → **Extract** → ZIP'i sil
5. Tarayıcıda `https://nuveli.com.tr` → çalışıyor olmalı

**SSL (HTTPS):** cPanel → **SSL/TLS Status** → Let's Encrypt otomatik etkinleştir.

---

## 2) Supabase Kurulumu

1. https://supabase.com → yeni proje oluştur
2. Region: **Europe (Frankfurt)** (Türkiye'ye yakın, düşük gecikme)
3. Project URL ve anon key'i not al → Flutter'da kullanılacak
4. Service role key'i not al → Backend'de kullanılacak (ASLA frontend'e koyma!)
5. **SQL Editor** → sırayla çalıştır:
   - `backend/migrations/001_initial_user_tables.sql`
   - `backend/migrations/002_meal_and_summary_tables.sql`
   - `backend/migrations/003_coach_tables.sql`
6. **Authentication** → Email ayarlarını yap → Apple/Google OAuth etkinleştir (opsiyonel)

---

## 3) Backend Deploy — Render.com (ÜCRETSİZ)

**Neden shared hosting değil?** FastAPI Python runtime gerektirir; shared hosting genellikle PHP'dir.

**Render.com adımları:**

1. https://render.com → GitHub ile bağlan
2. **New → Web Service** → `alimirbagirzade/Nuveli` reposunu seç
3. Ayarlar:
   - **Name:** `nuveli-app`
   - **Root Directory:** `backend`
   - **Runtime:** Python 3
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Plan:** Free (yeterli)
4. **Environment Variables** ekle:
   ```
   APP_ENV=production
   APP_VERSION=1.0.0
   LOG_LEVEL=INFO
   SUPABASE_URL=<senin supabase URL>
   SUPABASE_SERVICE_ROLE_KEY=<senin service role key>
   SUPABASE_JWT_SECRET=<senin JWT secret>
   OPENAI_API_KEY=<senin OpenAI key>
   ```
5. **Create Web Service**
6. 5 dakika sonra canlı: `https://nuveli-app.onrender.com`

**Custom domain (`api.nuveli.com.tr`):**
1. Render dashboard → Settings → Custom Domain
2. `api.nuveli.com.tr` ekle
3. cPanel DNS → CNAME record: `api` → `nuveli-app.onrender.com`

### Alternatif: Railway
- https://railway.app → aynı süreç
- $5/ay'dan ücretsiz kredi var

### Alternatif: Fly.io
- https://fly.io → CLI gerektirir
- 3 VM ücretsiz

---

## 4) RevenueCat Kurulumu

1. https://app.revenuecat.com → hesap aç
2. **New Project → "Nuveli"**
3. **Apps:** iOS ve Android app'leri ekle (App Store Connect ve Play Console bundle ID'lerini gir)
4. **Products:** App Store Connect ve Play Console'da aboneliği tanımla → RevenueCat'e ekle
5. **Offerings → "default"** oluştur → monthly ve annual product'ları ekle
6. **API Keys:** Apple ve Google public key'leri not al → Flutter'a koy (`--dart-define=RC_APPLE_KEY=...`)

---

## 5) Firebase Kurulumu

1. https://console.firebase.google.com → yeni proje "Nuveli"
2. iOS ve Android app'leri ekle
3. `GoogleService-Info.plist` → `app/ios/Runner/` içine
4. `google-services.json` → `app/android/app/` içine
5. Analytics + Crashlytics + Cloud Messaging etkinleştir
6. FCM Server Key'i not al → backend'de kullanılacak

---

## 6) Flutter App Build

### Android
```bash
cd app
flutter pub get
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=API_BASE_URL=https://api.nuveli.com.tr \
  --dart-define=RC_GOOGLE_KEY=xxx
```
Çıktı: `build/app/outputs/bundle/release/app-release.aab` → Play Console'a yükle

### iOS
```bash
cd app
flutter pub get
flutter build ipa --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=API_BASE_URL=https://api.nuveli.com.tr \
  --dart-define=RC_APPLE_KEY=xxx
```
Xcode'da aç → App Store Connect'e Archive & Upload

---

## 7) Kontrol Listesi

- [ ] Landing page `nuveli.com.tr`'de canlı + SSL aktif
- [ ] Supabase projesi oluşturuldu, 3 migration çalıştırıldı
- [ ] Backend Render'da canlı, `/health` yanıt veriyor
- [ ] `api.nuveli.com.tr` DNS bağlandı
- [ ] RevenueCat projesi kuruldu, product'lar tanımlı
- [ ] Firebase proje + GoogleService dosyaları eklendi
- [ ] Flutter `flutter run` ile local'de test edildi
- [ ] App Store Connect + Play Console hesapları açıldı
- [ ] İlk build yüklendi (TestFlight / internal testing)

---

## Not: Shared Hosting ve FastAPI

cPanel shared hosting'inde FastAPI çalıştırmak **teorik olarak** mümkün (Passenger ile) ama:
- Performans kötü olur
- Process management sorunlu
- WebSocket desteklenmez (gelecekte koç için gerekebilir)
- Supabase ile arada iyi tanışmaz

Bu yüzden **Render (ücretsiz)** öneriyoruz. Ayda ~750 saat ücretsiz kredi yeterli.
