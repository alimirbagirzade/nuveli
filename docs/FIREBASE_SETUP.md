# Firebase Kurulum Rehberi

Uygulama Firebase olmadan da çalışır (development). Ancak Crashlytics ve Analytics için Firebase gerekli. Bu rehber sıfırdan kurulum için.

## Ne Zaman Gerekli?

| Özellik | Firebase gerekli mi? |
|---------|---------------------|
| Auth (Supabase) | ❌ Hayır |
| Meal tracking | ❌ Hayır |
| AI Coach | ❌ Hayır |
| Premium / RevenueCat | ❌ Hayır |
| Crashlytics (hata raporlama) | ✅ Evet |
| Analytics (kullanım istatistikleri) | ✅ Evet |
| Push notifications | ✅ Evet |

**Özet:** Core uygulama Firebase olmadan çalışır. Production'a çıkmadan önce Crashlytics kurmak ÖNEMLİ — yoksa hataları göremezsin.

## Firebase Console Kurulumu (15 dakika)

### 1. Proje oluştur

1. https://console.firebase.google.com adresine git
2. "Add project" tıkla
3. Proje adı: `Nuveli`
4. Google Analytics'i aktif et (opsiyonel ama önerilir)

### 2. iOS App ekle

1. Firebase projesinde iOS ikonu tıkla
2. Bundle ID gir: `com.nuveli.app`
3. App nickname: `Nuveli iOS`
4. `GoogleService-Info.plist` indir
5. Dosyayı `app/ios/Runner/` klasörüne koy
6. Xcode ile Runner projesini aç → Runner target'a dosyayı sürükle bırak
7. "Copy items if needed" ✅ işaretle

### 3. Android App ekle

1. Firebase projesinde Android ikonu tıkla
2. Package name: `com.nuveli.app`
3. App nickname: `Nuveli Android`
4. SHA-1 (opsiyonel, Google Sign-In için gerekli)
5. `google-services.json` indir
6. Dosyayı `app/android/app/` klasörüne koy

### 4. Crashlytics Aktifle

Firebase Console'da:
1. Build → Crashlytics
2. "Get started" tıkla
3. SDK kurulum otomatik (Flutter zaten bağlı)

### 5. Test et

```bash
cd ~/development/nuveli/app
flutter clean
flutter pub get
flutter run
```

Uygulama açıldığında Firebase Console → Crashlytics → Dashboard'da "User opened app" event'i görmelisin.

## Crashlytics Test Hatası

Production'a çıkmadan Crashlytics'in çalıştığını test et:

1. Uygulamaya debug butonu ekle (temporary):
```dart
ElevatedButton(
  onPressed: () => FirebaseCrashlytics.instance.crash(),
  child: Text('Test Crash'),
)
```

2. Butona bas → uygulama çöker
3. Tekrar aç → crash raporu Firebase'e gönderilir
4. ~5 dakika içinde Dashboard'da görünür
5. Test tamamsa butonu kaldır

## Güvenlik Kuralları

### ASLA commit etme
- `google-services.json`
- `GoogleService-Info.plist`
- Firebase API key'leri

Bu dosyalar `.gitignore`'da:
```
app/android/app/google-services.json
app/ios/Runner/GoogleService-Info.plist
```

### Doğrulama

```bash
# Git'te izleniyor mu kontrol et (false dönmeli)
git check-ignore app/android/app/google-services.json

# Eğer git'e girmişse ve hata alırsan:
git rm --cached app/android/app/google-services.json
git rm --cached app/ios/Runner/GoogleService-Info.plist
```

## Yaygın Hatalar

### "No Firebase App" hatası

```dart
// main.dart içinde initialization unutulmuş
await Firebase.initializeApp();
```

### Android: "google-services.json not found"

Dosya yanlış yerde. Doğru yol:
```
app/android/app/google-services.json  ✓
app/android/google-services.json  ✗
```

### iOS: "Module FirebaseCore not found"

Pod install gerekli:
```bash
cd app/ios
pod install
cd ..
```

## Development Modu

`app_config.dart` içinde:
```dart
static bool get isFirebaseEnabled => isProduction || isStaging;
```

Development'ta Firebase kapalı — yanlış event'ler production dashboard'a düşmesin.

## Alternatif: Firebase Olmadan Çalıştır

Acil durumda Firebase'i tamamen devre dışı bırak:

`main.dart`:
```dart
// Firebase initialization'ı koşula bağla
if (AppConfig.isFirebaseEnabled) {
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
```

Bu yaklaşım development'ta zaten aktif. Production'da da Firebase kurmadan deploy edebilirsin (crash raporu yok ama uygulama çalışır).

## Production Öncesi Checklist

- [ ] Firebase projesi oluşturuldu
- [ ] iOS app eklendi + plist kopyalandı
- [ ] Android app eklendi + json kopyalandı
- [ ] Crashlytics "Get started" tıklandı
- [ ] Test crash yapıldı, dashboard'da görüldü
- [ ] `.gitignore` Firebase dosyalarını engelliyor
- [ ] `git status` → `google-services.json` veya `GoogleService-Info.plist` listede değil

---

**Sonraki adım:** [Deployment Guide](./DEPLOYMENT.md) (iOS + Android build)
