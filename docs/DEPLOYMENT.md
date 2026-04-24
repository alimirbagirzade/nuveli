# Production Deployment Guide

Nuveli'yi App Store ve Play Store'a çıkarma rehberi.

## Production Hazırlığı Checklist

### Backend
- [ ] Supabase production projesi oluşturuldu
- [ ] `backend/.env` production değerleriyle dolu
- [ ] Migrations çalıştırıldı (001-005 + yenileri)
- [ ] OpenAI API key production'a set
- [ ] RevenueCat webhook secret eklendi
- [ ] Backend deploy edildi (Render.com / Fly.io / AWS)
- [ ] HTTPS aktif, custom domain bağlı
- [ ] Backend URL mobile app'e set edildi

### Frontend
- [ ] `.env.production` hazır (dart-define-from-file)
- [ ] Firebase projesi kurulu ([FIREBASE_SETUP.md](./FIREBASE_SETUP.md))
- [ ] `google-services.json` ve `GoogleService-Info.plist` yerinde
- [ ] App icon'ları hazır (1024x1024 iOS, 512x512 Android)
- [ ] Splash screen hazır
- [ ] App Store screenshots (5-10 adet her dil için)
- [ ] Play Store screenshots (2-8 adet her dil için)
- [ ] Privacy policy live: https://nuveli.com.tr/gizlilik.html
- [ ] Terms live: https://nuveli.com.tr/sartlar.html

### RevenueCat
- [ ] Products tanımlandı (weekly/monthly/yearly)
- [ ] App Store Connect bağlantısı
- [ ] Play Console bağlantısı
- [ ] Entitlements set (`premium`)
- [ ] Offerings set (`default`)
- [ ] Test purchases çalışıyor

## iOS Build

### İlk kez kurulum

```bash
cd ~/development/nuveli/app
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### Development build (simulator)
```bash
flutter run --dart-define-from-file=.env.development
```

### TestFlight için archive
```bash
flutter build ipa --dart-define-from-file=.env.production
```

Çıktı: `build/ios/ipa/nuveli.ipa`

### App Store Connect'e yükle
1. Xcode → Window → Organizer
2. Archives sekmesi → son build'i seç
3. "Distribute App" → "App Store Connect"
4. "Upload"

### TestFlight'ta test
1. https://appstoreconnect.apple.com
2. My Apps → Nuveli → TestFlight
3. Internal testing grubu oluştur
4. Test kullanıcıları ekle
5. Build'i test için gönder

## Android Build

### Development build
```bash
flutter run --dart-define-from-file=.env.development
```

### Release AAB (Play Store)
```bash
flutter build appbundle --dart-define-from-file=.env.production
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

### Signing key oluştur (ilk kez)

```bash
keytool -genkey -v -keystore ~/nuveli-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias nuveli
```

`app/android/key.properties` oluştur:
```properties
storePassword=xxxxxx
keyPassword=xxxxxx
keyAlias=nuveli
storeFile=/Users/yourname/nuveli-key.jks
```

⚠️ **ASLA `key.properties` veya `.jks` dosyasını commit etme!**

### Play Console'a yükle
1. https://play.google.com/console
2. Nuveli app → Production
3. "Create new release"
4. AAB'yi sürükle bırak
5. Release notes yaz
6. "Save" → "Review release" → "Start rollout"

## Environment Files

### `.env.development` (commit edilebilir)
```
APP_ENV=development
API_BASE_URL=http://localhost:8000
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=eyJ-dev-key
RC_APPLE_KEY=
RC_GOOGLE_KEY=
```

### `.env.production` (ASLA COMMIT ETME)
```
APP_ENV=production
API_BASE_URL=https://api.nuveli.com
SUPABASE_URL=https://nuveli-prod.supabase.co
SUPABASE_ANON_KEY=eyJ-real-prod-key
RC_APPLE_KEY=appl_realkey_here
RC_GOOGLE_KEY=goog_realkey_here
```

## Release Cadence

Önerilen sürüm döngüsü:

- **Alpha** (internal): Her hafta, TestFlight internal + Play Internal testing
- **Beta** (closed): 2 haftada bir, 100-500 kişilik closed test
- **Production**: 4-6 haftada bir major, hotfix'ler gerektiğinde

## Version Bumping

`pubspec.yaml`:
```yaml
version: 1.0.0+1  # semver+build
```

- `1.0.0` → user-facing version
- `+1` → build number (iOS ve Android için her build'de artır)

Her release öncesi:
```bash
# pubspec.yaml'da version'ı güncelle, sonra:
git tag v1.0.1
git push --tags
```

## Rollback Stratejisi

### iOS
- App Store Connect'te "Reject" eski submission (24 saat içinde)
- Sonra yeni build upload et
- Phased release kullan (%1 → %10 → %50 → %100)

### Android
- Play Console'da "Halt rollout"
- Yeni version code ile yeni AAB yükle
- Staged rollout kullan

### Backend
- Render/Fly rollback komutu: `fly releases rollback`
- Supabase migrations: rollback migration yaz, uygula
- ZeroDowntime için blue-green deploy

## Monitoring

Production canlıya çıktıktan sonra:

| Metrik | Kaynak | Hedef |
|--------|--------|-------|
| Crash rate | Firebase Crashlytics | <%1 |
| API response time | Backend logs | <500ms p95 |
| DAU / MAU | Firebase Analytics | artış |
| Retention D1/D7 | Analytics | >%40 / >%20 |
| Trial conversion | RevenueCat | >%10 |
| Backend errors | Sentry/logs | <0.1% |

## İlk Hafta Sonrası

- [ ] Crashlytics dashboard'u kontrol et
- [ ] User feedback oku (App Store reviews)
- [ ] Slow endpoint'leri optimize et
- [ ] Conversion funnel analiz et
- [ ] Hotfix gerekli mi karar ver

## Sık Karşılaşılan Sorunlar

### iOS: "ITMS-90078: Missing Push Notification Entitlement"
Firebase Messaging ekliyse Apple Developer'da push capability aktif et.

### Android: "Upload failed - Version code already exists"
`pubspec.yaml`'da `version` bölümünde `+1` → `+2` olarak artır.

### "Invalid API Base URL"
`.env.production`'da `API_BASE_URL` `http://` ile başlıyor olabilir. Production'da `https://` olmalı.

### "RevenueCat products not loading"
- App Store Connect / Play Console'da ürünler "Ready for sale" mi?
- Bundle ID / Package name eşleşiyor mu?
- TestFlight'ta "Sandbox" test user ile test

---

**Detaylar için:**
- [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
- [app-store-submission.md](./app-store-submission.md)
- [play-store-submission.md](./play-store-submission.md)
