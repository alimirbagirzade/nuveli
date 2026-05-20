# Nuveli — Tüm Key'ler ve Nasıl Alınır

**Son Güncelleme:** 1 Mayıs 2026  
**Proje:** Nuveli AI Calorie Coach  
**Repo:** github.com/alimirbagirzade/nuveli_test

---

## 📋 İçindekiler

1. [Supabase](#1-supabase)
2. [OpenAI](#2-openai)
3. [Render.com](#3-rendercom)
4. [Apple Developer](#4-apple-developer)
5. [RevenueCat](#5-revenuecat)
6. [Firebase (Opsiyonel)](#6-firebase-opsiyonel)
7. [Güvenli Saklama](#7-güvenli-saklama)

---

## 1. Supabase

### Nerede: https://supabase.com/dashboard

**Proje Bilgileri:**
- **Proje Adı:** nuveli-dev
- **Organizasyon:** alimirbagirzade
- **Region:** Frankfurt (eu-central-1)
- **Plan:** Free

### Gerekli Key'ler (3 adet):

#### 1.1 SUPABASE_URL
- **Nerede:** Dashboard → Project Settings → API
- **Örnek:** `https://asicgcnpahdnitzalcva.supabase.co`
- **Kullanım:** Frontend + Backend
- **Public mı?** ✅ Evet (public URL, güvenli)

**Nasıl Bulunur:**
```
1. https://supabase.com/dashboard → nuveli-dev projesini seç
2. Sol menü → Settings (⚙️) → API
3. "Project URL" kopyala
```

#### 1.2 SUPABASE_ANON_KEY
- **Nerede:** Dashboard → Project Settings → API → Project API keys → `anon` `public`
- **Örnek:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJz...` (JWT token)
- **Kullanım:** Flutter app (frontend)
- **Public mı?** ✅ Evet (Row Level Security ile korunuyor)

**Nasıl Bulunur:**
```
1. Supabase Dashboard → Settings → API
2. "Project API keys" bölümünde "anon public" başlıklı key
3. Yanındaki 👁️ ikonuna tıkla → göster → kopyala
```

#### 1.3 SUPABASE_SERVICE_ROLE_KEY
- **Nerede:** Dashboard → Project Settings → API → Project API keys → `service_role` `secret`
- **Örnek:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJz...` (JWT token)
- **Kullanım:** Backend (FastAPI)
- **Public mı?** ❌ **HAYIR! GİZLİ TUTULMALI**

**Nasıl Bulunur:**
```
1. Supabase Dashboard → Settings → API
2. "Project API keys" bölümünde "service_role secret" başlıklı key
3. Yanındaki 👁️ ikonuna tıkla → göster → kopyala
```

⚠️ **ÇOK ÖNEMLİ:** Service role key **tüm RLS kurallarını bypass eder**. ASLA frontend'de kullanma, ASLA git'e commit etme.

#### 1.4 SUPABASE_JWT_SECRET
- **Nerede:** Dashboard → Project Settings → API → JWT Settings → `JWT Secret`
- **Örnek:** `792108ee-5129-4431-88a9-c4f5e80d0ed1` (UUID formatı)
- **Kullanım:** Backend (token doğrulama)
- **Public mı?** ❌ **HAYIR! GİZLİ TUTULMALI**

**Nasıl Bulunur:**
```
1. Supabase Dashboard → Settings → API
2. "JWT Settings" bölümü → "JWT Secret" satırı
3. Yanındaki 👁️ ikonuna tıkla → göster → kopyala
```

---

## 2. OpenAI

### Nerede: https://platform.openai.com/api-keys

**Kullanım:** AI Coach (GPT-4o + Vision)

### Gerekli Key (1 adet):

#### 2.1 OPENAI_API_KEY
- **Nerede:** OpenAI Platform → API Keys → Create new secret key
- **Örnek:** `sk-proj-XaNCMYlzWqWhiQH38TPMjlcZ3L3mPH7...` (uzun token)
- **Kullanım:** Backend (meal analysis + coach chat)
- **Public mı?** ❌ **HAYIR! GİZLİ TUTULMALI**

**Nasıl Oluşturulur:**
```
1. https://platform.openai.com/api-keys → Sign in
2. "+ Create new secret key" butonu
3. Name: "Nuveli Backend Production"
4. Permissions: "All" (ya da sadece "Model capabilities")
5. Create → KEY'İ KOPYALA (bir daha gösterilmez!)
```

**Önemli Ayarlar:**
```
1. https://platform.openai.com/settings/organization/limits
2. "Monthly budget" → $5 limit koy (free tier koruması)
3. "Usage notifications" → email adresini ekle
```

**Maliyet İzleme:**
- https://platform.openai.com/usage
- Aylık $5 limiti aşınca otomatik durur

---

## 3. Render.com

### Nerede: https://dashboard.render.com

**Kullanım:** Backend hosting (FastAPI + uvicorn)

### Gerekli Key (1 adet):

#### 3.1 RENDER_API_KEY
- **Nerede:** Dashboard → Account Settings → API Keys → Create API Key
- **Örnek:** `rnd_LBbvjP8zosPVPGismbg2iM2Qwiap`
- **Kullanım:** Deployment otomasyonu (opsiyonel, manuel deploy için gerekmez)
- **Public mı?** ❌ **HAYIR! GİZLİ TUTULMALI**

**Nasıl Oluşturulur:**
```
1. https://dashboard.render.com/u/settings/api-keys
2. "Create API Key" butonu
3. Name: "Nuveli Deploy"
4. Create → kopyala
```

**Render Servis Bilgileri:**
- **Servis Adı:** Nuveli-api
- **URL:** https://nuveli-api.onrender.com
- **Plan:** Free (750 saat/ay)
- **Region:** Oregon (US-West)

**Environment Variables (Render Dashboard'da manuel set edilen):**
Render Dashboard → Nuveli-api servisi → Environment → Add Environment Variable

Eklenecek değişkenler:
```
APP_ENV = production
SUPABASE_URL = (Supabase'den al)
SUPABASE_SERVICE_ROLE_KEY = (Supabase'den al)
SUPABASE_JWT_SECRET = (Supabase'den al)
OPENAI_API_KEY = (OpenAI'den al)
REVENUECAT_WEBHOOK_SECRET = (RevenueCat'ten al)
```

---

## 4. Apple Developer

### Nerede: https://developer.apple.com

**Kullanım:** App Store + TestFlight

### Gerekli Bilgiler:

#### 4.1 Apple Developer Program Üyelik
- **Ücret:** $99/yıl
- **Kayıt:** https://developer.apple.com/programs/enroll/
- **Onay süresi:** 24-48 saat

**Üyelik Tipleri:**
- ✅ **Individual:** Kişisel geliştirici ($99/yıl)
- ❌ **Organization:** Şirket adına ($99/yıl, D-U-N-S numarası gerekli)
- ❌ **Enterprise:** Kurum içi dağıtım ($299/yıl)

#### 4.2 App ID (Bundle Identifier)
- **Nerede:** developer.apple.com → Certificates, Identifiers & Profiles → Identifiers
- **Mevcut Bundle ID:** `com.nuveli.app`
- **Nasıl Oluşturulur:**
```
1. developer.apple.com → Account → Certificates, Identifiers & Profiles
2. Identifiers → + butonu → App IDs → App
3. Description: Nuveli
4. Bundle ID: Explicit → com.nuveli.app
5. Capabilities: Push Notifications işaretle
6. Continue → Register
```

#### 4.3 App Store Connect
- **Nerede:** https://appstoreconnect.apple.com
- **App Oluşturma:**
```
1. appstoreconnect.apple.com → My Apps → + butonu → New App
2. Platform: iOS
3. Name: Nuveli
4. Primary Language: Turkish
5. Bundle ID: com.nuveli.app (dropdown'dan seç)
6. SKU: nuveli-ios-001 (benzersiz ID)
7. User Access: Full Access
```

#### 4.4 Provisioning Profile
Xcode otomatik oluşturur ("Automatically manage signing" seçiliyse).

**Manuel oluşturma (gerekirse):**
```
1. developer.apple.com → Certificates, Identifiers & Profiles → Profiles
2. + butonu → App Store → Continue
3. App ID: com.nuveli.app
4. Certificate: Seç (yoksa önce certificate oluştur)
5. Profile Name: Nuveli App Store
6. Generate → Download
```

---

## 5. RevenueCat

### Nerede: https://app.revenuecat.com

**Kullanım:** In-app satın alma yönetimi (freemium → premium)

### Gerekli Key'ler (2 adet):

#### 5.1 RC_APPLE_KEY (iOS)
- **Nerede:** RevenueCat Dashboard → Project → Apps → iOS app → API Keys
- **Örnek:** `appl_xxxxxxxxxxxxxxxxxxxxxxxxx`
- **Kullanım:** Flutter app (iOS)
- **Public mı?** ✅ Evet (frontend-safe)

**Nasıl Alınır:**
```
1. https://app.revenuecat.com → Sign in (GitHub ile giriş yapılabilir)
2. Yeni proje oluştur: "Nuveli"
3. Apps → Add App → iOS
4. App Name: Nuveli iOS
5. Bundle ID: com.nuveli.app
6. App Store Connect API Key ekle (App Store Connect → Users & Access)
7. API Keys sekmesi → "Apple App-Specific Shared Secret" kopyala
```

#### 5.2 RC_GOOGLE_KEY (Android)
- **Nerede:** RevenueCat Dashboard → Project → Apps → Android app → API Keys
- **Örnek:** `goog_xxxxxxxxxxxxxxxxxxxxxxxxx`
- **Kullanım:** Flutter app (Android)
- **Public mı?** ✅ Evet (frontend-safe)

**Nasıl Alınır:**
```
1. RevenueCat Dashboard → Apps → Add App → Android
2. App Name: Nuveli Android
3. Package Name: com.nuveli.app (build.gradle'dan al)
4. Google Play Console Service Credentials ekle
5. API Keys sekmesi → kopyala
```

#### 5.3 REVENUECAT_WEBHOOK_SECRET
- **Nerede:** RevenueCat Dashboard → Project Settings → Integrations → Webhooks
- **Örnek:** `Bearer sk_webhook_xxxxxxxxxxxxxxxxxxxxx`
- **Kullanım:** Backend (webhook doğrulama)
- **Public mı?** ❌ **HAYIR! GİZLİ TUTULMALI**

**Nasıl Oluşturulur:**
```
1. RevenueCat Dashboard → Project Settings
2. Integrations → Webhooks → Add Webhook
3. URL: https://nuveli-api.onrender.com/premium/webhook
4. Authorization Header: kopyala (Bearer token)
5. Events: Select All → Save
```

---

## 6. Firebase (Opsiyonel)

### Nerede: https://console.firebase.google.com

**Kullanım:** Analytics + Crashlytics + Push Notifications

### Gerekli Dosyalar (2 adet):

#### 6.1 google-services.json (Android)
- **Nerede:** Firebase Console → Project Settings → General → Your apps → Android app
- **Kullanım:** `app/android/app/google-services.json`

**Nasıl İndirilir:**
```
1. https://console.firebase.google.com → Nuveli projesi
2. Project Settings (⚙️)
3. Your apps → Android icon → Add app
4. Android package name: com.nuveli.app
5. Download google-services.json
6. Dosyayı app/android/app/ klasörüne koy
```

#### 6.2 GoogleService-Info.plist (iOS)
- **Nerede:** Firebase Console → Project Settings → General → Your apps → iOS app
- **Kullanım:** `app/ios/Runner/GoogleService-Info.plist`

**Nasıl İndirilir:**
```
1. Firebase Console → Your apps → iOS icon → Add app
2. iOS bundle ID: com.nuveli.app
3. Download GoogleService-Info.plist
4. Xcode'da Runner klasörüne sürükle-bırak
```

#### 6.3 Firebase Cloud Messaging Server Key (Push için)
- **Nerede:** Firebase Console → Project Settings → Cloud Messaging → Server key
- **Kullanım:** Backend (push notification gönderme)

---

## 7. Güvenli Saklama

### ❌ ASLA YAPMA:
- Git'e commit etme (`.gitignore` kontrol et)
- Slack/WhatsApp'ta paylaşma
- Screenshot alıp public yerlere atma
- Sertifikalı olmayan sitelere girme

### ✅ YAPILMASI GEREKENLER:

#### 7.1 1Password / Bitwarden (Öneri)
```
Folder: Nuveli Production
├── Supabase Credentials
│   ├── URL: https://asicgcnpahdnitzalcva.supabase.co
│   ├── Anon Key: eyJhbGci...
│   ├── Service Role Key: eyJhbGci...
│   └── JWT Secret: 792108ee-...
├── OpenAI
│   └── API Key: sk-proj-...
├── Render
│   └── API Key: rnd_LBbv...
├── Apple Developer
│   ├── Account: alimirbagirzade@gmail.com
│   └── Team ID: (App Store Connect'ten al)
└── RevenueCat
    ├── Apple Key: appl_xxx
    ├── Google Key: goog_xxx
    └── Webhook Secret: Bearer sk_webhook_...
```

#### 7.2 .env Dosyaları (Lokal Development)
```bash
# Backend
backend/.env          → .gitignore'da (ASLA commit etme)

# Frontend
app/.env.development  → .gitignore'da
app/.env.production   → .gitignore'da
```

#### 7.3 Render Dashboard (Production)
Environment variables Render dashboard'da manuel girilir. API key ile de set edilebilir ama dashboard daha güvenli.

---

## 8. Hızlı Referans Tablosu

| Key | Nerede Bulunur | Public? | Kullanım |
|-----|----------------|---------|----------|
| `SUPABASE_URL` | Supabase Dashboard → API | ✅ | Frontend + Backend |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → API | ✅ | Frontend |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Dashboard → API | ❌ | Backend ONLY |
| `SUPABASE_JWT_SECRET` | Supabase Dashboard → API | ❌ | Backend ONLY |
| `OPENAI_API_KEY` | OpenAI Platform → API Keys | ❌ | Backend ONLY |
| `RENDER_API_KEY` | Render Dashboard → Settings | ❌ | Deploy automation |
| `RC_APPLE_KEY` | RevenueCat → Apps → iOS | ✅ | iOS app |
| `RC_GOOGLE_KEY` | RevenueCat → Apps → Android | ✅ | Android app |
| `REVENUECAT_WEBHOOK_SECRET` | RevenueCat → Webhooks | ❌ | Backend ONLY |

---

## 9. Mevcut Değerler (Production)

**Not:** Güvenlik için sadece ilk birkaç karakter gösterilmiş. Tam değerleri 1Password/Bitwarden'da sakla.

```
SUPABASE_URL=https://asicgcnpahdnitzalcva.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzaWNnY25wYWhkbml0emFsY3ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NTU1NzIsImV4cCI6MjA5MjMzMTU3Mn0.0UX_wdWYSRCG-xULsrKzNwgjIhXJh7pfUygQqjgz-_k
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJI... (tam key → 1Password)
SUPABASE_JWT_SECRET=792108ee-5129-4431-88a9-c4f5e80d0ed1
OPENAI_API_KEY=sk-proj-XaNCM... (tam key → 1Password)
RENDER_API_KEY=rnd_LBbvjP8zosPVPGismbg2iM2Qwiap
```

**RevenueCat key'leri henüz yok** — hesap oluşturulup app eklenince buraya eklenecek.

---

## 10. Key Rotation (Yenileme) — Ne Zaman Gerekli?

### 🚨 Acil Yenileme Gerekli:
- Key public bir yere sızdıysa (git commit, screenshot, Slack)
- Güvenlik ihlali şüphesi
- Eski çalışan/ortaktan ayrıldı

### 🔄 Rutin Yenileme (Öneri):
- **OpenAI:** 6 ayda bir
- **Supabase Service Role:** 6 ayda bir
- **Render API Key:** 1 yılda bir
- **JWT Secret:** Asla (değişirse tüm kullanıcılar logout olur)

### Nasıl Yenilenir:
```
1. Yeni key oluştur (eski key henüz geçerli)
2. Render + .env dosyalarını güncelle
3. Deploy + test
4. Eski key'i 24 saat sonra sil (rollback için buffer)
```

---

## 11. Sorun Giderme

### "Kaydetme başarısız" hatası:
→ Backend env var'larını kontrol et (SUPABASE_JWT_SECRET doğru mu?)

### "API rate limit exceeded":
→ OpenAI Dashboard → Usage → limit kontrolü

### "Authentication failed":
→ SUPABASE_ANON_KEY doğru mu? Expired olmamış mı?

### "Render service suspended":
→ Free tier 750 saat/ay limiti aşıldı → Paid plan gerekli

---

## 12. Checklist — Production'a Çıkmadan Önce

- [ ] Tüm key'ler 1Password/Bitwarden'da kayıtlı
- [ ] `.env` dosyaları `.gitignore`'da
- [ ] OpenAI monthly budget $5 limit set
- [ ] Supabase RLS rules aktif
- [ ] Render env vars production değerleriyle dolu
- [ ] RevenueCat webhook endpoint test edildi
- [ ] Apple Developer üyelik aktif ($99 ödendi)
- [ ] Firebase project oluşturuldu (analytics için)
- [ ] Backend `/health` endpoint 200 döndürüyor
- [ ] TestFlight internal test başarılı

---

**Son güncelleme:** 1 Mayıs 2026  
**Hazırlayan:** Claude (Anthropic)  
**Proje:** Nuveli AI Calorie Coach
