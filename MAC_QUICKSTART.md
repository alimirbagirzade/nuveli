# Nuveli - Mac'te İlk Kurulum

Bu kılavuz projeyi Mac'te ilk kez çalıştırmak için gereken adımları gösterir.

## 📋 Ön Gereksinimler

Aşağıdaki yazılımların yüklü olduğundan emin ol:

```bash
# Python 3.9+ kontrol
python3 --version

# Flutter 3.x+ kontrol
flutter --version

# Git kontrol
git --version
```

Eğer eksik varsa:
- **Python**: `brew install python@3.11`
- **Flutter**: https://docs.flutter.dev/get-started/install/macos
- **Git**: `brew install git`

## 🚀 Hızlı Başlangıç (5 dakika)

### 1. Health Check Çalıştır

```bash
cd ~/development/nuveli
./health_check.sh
```

Bu script:
- ✅ Tüm bağımlılıkları kontrol eder
- ✅ Backend + frontend syntax'ı doğrular
- ✅ Eksik dosyaları bildirir
- ✅ Nelerin çalışır durumda olduğunu gösterir

### 2. Backend Kurulumu

```bash
cd backend

# Virtual environment oluştur (bir kez)
python3 -m venv venv

# Aktif et
source venv/bin/activate

# Dependencies yükle
pip install -r requirements.txt

# Environment dosyası oluştur
cp .env.example .env
# .env dosyasını aç ve Supabase/OpenAI key'lerini doldur

# Backend'i başlat
python app/main.py
```

Backend `http://localhost:8000` üzerinde çalışacak.
Tarayıcıda aç: http://localhost:8000/docs (Swagger API dokümantasyonu)

### 3. Frontend Kurulumu

```bash
cd app

# Dependencies yükle
flutter pub get

# Code generation (Riverpod + Freezed)
dart run build_runner build --delete-conflicting-outputs

# Emulator başlat (iOS)
open -a Simulator

# Veya Android emulator
flutter emulators --launch <emulator_name>

# App'i çalıştır
flutter run
```

## 🧪 Testleri Çalıştır

```bash
cd app
flutter test
```

Şu an 4 test dosyası var:
- `app_error_test.dart` - Error mapping
- `onboarding_controller_test.dart` - Onboarding flow
- `meal_repository_test.dart` - Meal CRUD
- `settings_repository_test.dart` - Settings

## 🔧 Sorun Giderme

### "Command not found: flutter"

```bash
# Flutter path'e ekle (bir kez)
export PATH="$PATH:`pwd`/flutter/bin"

# Veya kalıcı olarak (~/.zshrc veya ~/.bash_profile)
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### "ModuleNotFoundError" (Backend)

```bash
# venv aktif mi kontrol et
which python
# /path/to/nuveli/backend/venv/bin/python görmeli

# Aktif değilse:
source venv/bin/activate
```

### "No file or directory: google-services.json"

Firebase config dosyaları eksik (opsiyonel - uygulama yine de çalışır):

1. Firebase Console'a git: https://console.firebase.google.com
2. Projeyi seç
3. Android app → google-services.json indir → `app/android/app/` içine koy
4. iOS app → GoogleService-Info.plist indir → `app/ios/Runner/` içine koy

### Backend "/health" hatası

.env dosyası doğru doldurulmamış olabilir:
```bash
cd backend
cat .env  # Kontrol et

# Supabase değerleri gerçek mi?
# SUPABASE_URL https:// ile başlamalı
# API key'ler "your-" ile başlamamalı
```

## 📱 Emulator İpuçları

### iOS Simulator başlatma
```bash
open -a Simulator

# Belirli cihaz
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
```

### Android Emulator başlatma
```bash
flutter emulators
flutter emulators --launch Pixel_7_API_34
```

## 🎯 Sonraki Adımlar

Backend + frontend çalışıyorsa:

1. **Signup flow test et**: Email + password ile kayıt ol
2. **Acceptance + onboarding**: 11 ekranı geç
3. **Home ekranına ulaş**: Trial gift modal çıkmalı
4. **Meal capture**: Fotoğraf çek veya text gir
5. **Coach chat**: Mesaj gönder
6. **Settings**: Logout/delete account test et

## 📚 Daha Fazla Bilgi

- Detaylı kurulum: `/docs/SETUP.md`
- Backend API: http://localhost:8000/docs
- Flutter hot reload: `r` tuşu (değişiklikler anında uygulanır)
- Backend restart: `Ctrl+C` sonra tekrar `python app/main.py`

## 🆘 Yardım

Sorun devam ediyorsa:
1. `health_check.sh` çıktısını kaydet
2. Terminal hatalarını kopyala
3. Benimle paylaş
