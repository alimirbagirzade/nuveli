# Chat 15 — Authentication Flow ✅

Bu paket Nuveli'nin tüm authentication + onboarding akışını içeriyor.

## 📦 İçerik (30 dosya)

```
nuveli-chat15/
├── pubspec_patch.yaml          ← Yeni dependency'ler (pubspec.yaml'a merge et)
├── .env.example                ← .env şablonu (kopyala → .env, key'leri doldur)
├── docs/setup_notes.md         ← Supabase Apple Provider + iOS/Android config
└── lib/
    ├── main_template.dart      ← main.dart için referans (manuel merge)
    ├── core/utils/
    │   └── calorie_calculator.dart    (BMR/TDEE/makro hesaplama)
    └── features/auth/
        ├── models/             (auth_errors, auth_user, onboarding_data)
        ├── services/           (auth_service, apple_signin_service, profile_service)
        ├── providers/          (auth, current_user, onboarding)
        ├── widgets/            (text_field, button, social_button, link, strength)
        └── screens/
            ├── welcome_screen.dart
            ├── login_screen.dart
            ├── signup_screen.dart
            ├── forgot_password_screen.dart
            ├── reset_password_screen.dart
            ├── email_verification_screen.dart
            ├── auth_gate.dart          ← App root router
            └── onboarding/
                ├── onboarding_screen.dart    (5-step PageView wrapper)
                ├── widgets/onboarding_progress_bar.dart
                └── steps/
                    ├── step_1_welcome.dart
                    ├── step_2_personal_info.dart
                    ├── step_3_body_metrics.dart
                    ├── step_4_goals.dart
                    └── step_5_targets.dart
```

## 🚀 Local kuruluma 5 adım

### 1. Dosyaları kopyala
```bash
cd ~/Development/nuveli

# lib/ klasörünü olduğu gibi merge et (overwrite OK — yeni dosyalar)
cp -r /path/to/nuveli-chat15/lib/* lib/

# Docs
cp -r /path/to/nuveli-chat15/docs/* docs/  # docs/ yoksa mkdir docs

# .env şablonunu kullan
cp /path/to/nuveli-chat15/.env.example .env
# → .env'i aç, gerçek key'leri doldur (credentials guide'dan)
```

### 2. main.dart'ı güncelle
`lib/main_template.dart` referansını incele, mevcut `lib/main.dart`'a şu kısımları ekle:
- `await dotenv.load()` ve `await Supabase.initialize(...)` (runApp öncesi)
- `ProviderScope` wrapper
- `home: const AuthGate()`

### 3. pubspec.yaml'a dependency'leri ekle
`pubspec_patch.yaml`'daki block'ları `dependencies:` altına ekle, sonra:
```bash
flutter pub get
```

Ayrıca `assets:` bölümüne `.env`'i eklediğinden emin ol:
```yaml
flutter:
  assets:
    - .env
```

### 4. Supabase + iOS native config
`docs/setup_notes.md`'yi takip et:
- Supabase dashboard'da Apple provider'ı aç (Client ID, Team ID, Key ID, P8 key)
- iOS: `Runner/Info.plist`'e URL scheme ekle (`com.nuveli.app`)
- iOS: Xcode'da "Sign in with Apple" capability ekle
- Android: `AndroidManifest.xml`'e intent-filter ekle

### 5. Test
```bash
flutter run
# → Welcome screen açılmalı
# → Sign up → email confirmation → onboarding → dashboard placeholder
```

## 🔧 GitHub'a push

```bash
cd ~/Development/nuveli
git checkout -b feature/chat-15-auth
git add lib/ docs/ pubspec.yaml .env.example
git status   # .env LİSTEDE OLMAMALI! .gitignore'da olduğundan emin ol
git commit -m "feat: Chat 15 - Authentication flow with 5-step onboarding"
git push -u origin feature/chat-15-auth
```

## ⚠️ Bilinmesi gerekenler

| Konu | Durum |
|---|---|
| **DashboardScreen** | `auth_gate.dart` içinde `_DashboardPlaceholder` olarak duruyor. Chat 4 (Dashboard) tamamlandığında gerçek widget ile değiştir. TODO marker var. |
| **Theme dependency** | Tüm UI Chat 1'deki `AppColors`, `AppTypography`, `NuveliBackground`'a referans veriyor. Bu dosyalar mevcut değilse compile hatası alırsın. |
| **Backend** | `profile_service.dart` `API_BASE_URL`'i `.env`'den okuyor. Chat 14 backend deploy edilmediyse onboarding "Could not reach server" hatası verir — `auth_gate.dart` bu durumda onboarding ekranına devam ettirir. |
| **Apple Sign-In** | Yalnızca iOS/macOS'ta gösterilir. Android'de buton görünmez. |
| **Email confirmation** | Supabase project'te açıksa, signup sonrası `EmailVerificationScreen` gösterilir. Kapalıysa otomatik login + onboarding'e geçer. |
| **Deep link routing** | Reset password ve email confirmation linkleri için `com.nuveli.app://reset-password` ve `com.nuveli.app://email-confirmed` schemes kullanılıyor. Native config'i `setup_notes.md`'de. Chat 17'de go_router ile entegre edilecek. |
| **Onboarding persist** | Kullanıcı onboarding'i yarıda bırakırsa, SharedPreferences'a kaydedilen draft'tan devam edebilir (key: `nuveli_onboarding_draft_v1`). |

## 🧪 Test akışı

1. **Welcome** → Get Started → **Signup** (email + güçlü password + confirm + Terms ✓)
2. **EmailVerification** ekranı → Gmail'i aç, link'e tıkla → app'e dön
3. **AuthGate** → profil yok → **Onboarding** Step 1 (Welcome)
4. Step 2: name + birthday + gender
5. Step 3: height (170cm) + weight (70kg) slider
6. Step 4: activity = Moderate + goal = Maintain
7. Step 5: hesaplanan kalori/makro/su gözükmeli → **Complete Setup**
8. → **DashboardPlaceholder** ekranı (sign out butonu ile)

## 📚 Sonraki Chat

**Chat 16: HomeScreen + Bottom Nav** veya **Chat 4: Dashboard** ile devam edilebilir. Master plan'a göre Chat 4 daha kritik (gerçek dashboard).
