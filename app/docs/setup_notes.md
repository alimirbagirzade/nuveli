# Chat 15 — Platform Setup Notları

Bu dosya, Chat 15 dosyaları **çalışsın** diye yapılması gereken
platform/Supabase ayarlarını listeler. Kod yetmiyor — bu adımlar olmadan
Apple Sign-In ve deep link çalışmaz.

---

## 1. Supabase Dashboard — Auth Ayarları

### 1.1 Email/Password Auth
1. https://supabase.com/dashboard → nuveli-dev → **Authentication** → **Providers**
2. **Email** → açık olduğundan emin ol
3. **Confirm email** → açık (production'da güvenli)

### 1.2 Apple Sign-In Provider
1. **Authentication → Providers → Apple** → enable
2. Aşağıdaki bilgileri Apple Developer'dan al:
   - **Services ID:** `com.nuveli.app.signin` (veya benzeri, App ID değil)
   - **Team ID:** Apple Developer hesabından
   - **Key ID:** Apple Developer → Keys → "Sign in with Apple" key
   - **Private Key:** `.p8` dosyasının içeriği (yeni satırlarıyla birlikte)
3. **Save**

### 1.3 Redirect URL (Password Reset için)
1. **Authentication → URL Configuration**
2. **Redirect URLs** kısmına ekle:
   ```
   com.nuveli.app://reset-password
   com.nuveli.app://email-confirmed
   ```
3. **Site URL:** `com.nuveli.app://` (development için yeterli)

### 1.4 Email Templates (Opsiyonel ama önerilen)
1. **Authentication → Email Templates**
2. **Confirm signup** ve **Reset password** template'lerinde redirect URL'in
   yukarıdaki custom scheme'le eşleştiğinden emin ol.

---

## 2. iOS — Xcode Ayarları

### 2.1 Bundle ID
- Xcode → Runner target → Signing & Capabilities
- **Bundle Identifier:** `com.nuveli.app` (master plan'la aynı)

### 2.2 Sign in with Apple Capability
1. Signing & Capabilities → **+ Capability** → **Sign in with Apple**
2. Listede görünmeli (yoksa Apple Developer hesabında App ID'de bu capability
   açık mı kontrol — credentials_guide.md → 4.2)

### 2.3 Info.plist — Custom URL Scheme (Deep Link)
`ios/Runner/Info.plist` dosyasına ekle (mevcut `<dict>` içine):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.nuveli.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.nuveli.app</string>
        </array>
    </dict>
</array>
```

### 2.4 Minimum iOS Version
`ios/Podfile` → en üstte:
```ruby
platform :ios, '13.0'   # sign_in_with_apple iOS 13+ gerektirir
```

---

## 3. Android — Manifest Ayarları

### 3.1 Package Name
`android/app/build.gradle`:
```gradle
applicationId "com.nuveli.app"
minSdkVersion 23   // supabase_flutter için
```

### 3.2 AndroidManifest.xml — Deep Link Intent Filter
`android/app/src/main/AndroidManifest.xml` → `<activity android:name=".MainActivity"...>` içine ekle:

```xml
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.nuveli.app" />
</intent-filter>
```

> **Not:** Android'de Apple Sign-In yoktur. Google Sign-In Chat 16'da
> eklenebilir (şu an scope dışı).

---

## 4. .env Dosyası Oluştur

Repo root'unda:

```bash
cp .env.example .env
```

`.env` içine production değerlerini doldur (credentials_guide.md → section 9).

`.gitignore`'a ekle (yoksa):
```
.env
.env.development
.env.production
```

`pubspec.yaml`'da assets bölümüne ekle:
```yaml
flutter:
  assets:
    - .env
```

---

## 5. Doğrulama Checklist

Chat 15 koduna geçmeden önce aşağıdakileri tamamla:

- [ ] Supabase Dashboard → Email provider aktif
- [ ] Supabase Dashboard → Apple provider doldurulmuş ve aktif
- [ ] Supabase Dashboard → Redirect URLs eklendi
- [ ] iOS → Sign in with Apple capability aktif
- [ ] iOS → Info.plist URL scheme eklendi
- [ ] Android → AndroidManifest intent-filter eklendi
- [ ] `.env` dosyası oluşturuldu ve dolduruldu
- [ ] `pubspec.yaml` patch uygulandı, `flutter pub get` çalıştırıldı
- [ ] Backend (`https://nuveli-api.onrender.com/me/onboarding`) ayakta (Chat 14 ✅)

---

## 6. Olası Hatalar & Çözümleri

| Hata | Neden | Çözüm |
|---|---|---|
| `Apple Sign-In not available` | iOS Capability eksik | Xcode → Capabilities ekle |
| `redirect URI not allowed` | Supabase URL Configuration | `com.nuveli.app://...` ekle |
| `Email link doesn't open app` | Custom scheme manifest'te yok | AndroidManifest intent-filter ekle |
| `FileNotFoundError: .env` | Assets'e eklenmemiş | `pubspec.yaml` flutter.assets'e ekle |
| `Invalid login credentials` | Email confirm açık ama mail doğrulanmamış | İlk önce e-postayı onayla |
| Auth state hiç değişmiyor | `Supabase.initialize` çağrılmamış | `main.dart`'taki güncelleme uygulanmış mı? |
