# .gitignore Eklemeleri

**Hedef:** Production secret'larının git'e commit edilmesini önlemek.

⚠️ **Bir secret bir kez commit edilirse → git history'de KALICI** (force push ile silmek bile zor).

---

## 📄 Tam .gitignore (Production-Ready)

Bu içeriği `~/Development/nuveli/.gitignore` dosyasına yapıştır (veya mevcut .gitignore'a append et).

```gitignore
# ═══════════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════
.env
.env.local
.env.development
.env.staging
.env.production
.env.*.local
**/.env*

# Backend
backend/.env

# Flutter
app/.env*
app/lib/config/secrets.dart

# ═══════════════════════════════════════════════════════════════
# ANDROID — KEYSTORES & SIGNING
# ═══════════════════════════════════════════════════════════════
android/keystore.properties
android/app/*.jks
android/app/*.keystore
**/*.jks
**/*.keystore
**/*.p8
**/*.p12
**/*.pem
key.properties

# ═══════════════════════════════════════════════════════════════
# IOS — PROVISIONING & CERTIFICATES
# ═══════════════════════════════════════════════════════════════
ios/*.mobileprovision
ios/*.p12
ios/*.cer
ios/exportOptions.plist
ios/Runner.xcworkspace/xcuserdata/
ios/Pods/

# Firebase iOS (içerikte API key var, public ama commit etmek riskli)
# Eğer commit ediyorsan yorum yapma; etmiyorsan satırı aç:
# ios/Runner/GoogleService-Info.plist

# ═══════════════════════════════════════════════════════════════
# FIREBASE
# ═══════════════════════════════════════════════════════════════

# Service account JSON — ASLA commit etme
**/firebase-service-account.json
**/*-firebase-adminsdk-*.json
serviceAccountKey.json

# Google services JSON (Android) — opsiyonel
# Eğer team içinde paylaşmak istersen commit et (API key public)
# Strict policy varsa:
# android/app/google-services.json

# ═══════════════════════════════════════════════════════════════
# FLUTTER (default + custom)
# ═══════════════════════════════════════════════════════════════
**/.dart_tool/
**/.packages
**/.pub-cache/
**/.pub/
**/build/
**/.flutter-plugins
**/.flutter-plugins-dependencies
**/.metadata
**/pubspec.lock.bak

# Generated files (Riverpod, Hive)
**/*.g.dart
**/*.freezed.dart
**/*.gr.dart
# ⚠️ NOT: build_runner output'larını commit etmek isteyebilirsin
# Eğer CI/CD'de build_runner çalışmıyorsa commit et:
# !lib/**/*.g.dart

# Coverage
coverage/
*.lcov

# ═══════════════════════════════════════════════════════════════
# IOS BUILD ARTIFACTS
# ═══════════════════════════════════════════════════════════════
ios/.symlinks/
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Flutter/ephemeral/
ios/Flutter/app.flx
ios/Flutter/app.zip
ios/Flutter/flutter_assets/
ios/Flutter/flutter_export_environment.sh
ios/ServiceDefinitions.json

# ═══════════════════════════════════════════════════════════════
# ANDROID BUILD ARTIFACTS
# ═══════════════════════════════════════════════════════════════
android/.gradle/
android/captures/
android/gradlew
android/gradlew.bat
android/gradle/wrapper/gradle-wrapper.jar
android/local.properties
android/**/GeneratedPluginRegistrant.java

# ═══════════════════════════════════════════════════════════════
# IDE
# ═══════════════════════════════════════════════════════════════
.idea/
.vscode/
*.iml
*.iws
*.ipr
*.swp
*.swo
.idea_modules/

# VSCode (bazı dosyaları commit etmek isteyebilirsin)
# Önerilen:
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# ═══════════════════════════════════════════════════════════════
# OS
# ═══════════════════════════════════════════════════════════════
.DS_Store
.AppleDouble
.LSOverride
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
Thumbs.db
ehthumbs.db
Desktop.ini

# ═══════════════════════════════════════════════════════════════
# LOGS & TEMP
# ═══════════════════════════════════════════════════════════════
*.log
*.tmp
*.temp
logs/
tmp/

# ═══════════════════════════════════════════════════════════════
# BACKEND (Python FastAPI)
# ═══════════════════════════════════════════════════════════════
backend/__pycache__/
backend/**/__pycache__/
backend/*.pyc
backend/.pytest_cache/
backend/.coverage
backend/htmlcov/
backend/venv/
backend/.venv/
backend/env/
backend/dist/
backend/*.egg-info/

# Backend secrets
backend/credentials/
backend/secrets/

# ═══════════════════════════════════════════════════════════════
# SUPABASE
# ═══════════════════════════════════════════════════════════════
supabase/.temp/
supabase/.branches/

# ═══════════════════════════════════════════════════════════════
# LAUNCH ASSETS (paylaşılır ama bazıları büyük)
# ═══════════════════════════════════════════════════════════════

# Final üretilmiş icon'lar paylaşılabilir
# launch_assets/icons/*.png → commit ET (designer çıktısı)

# Screenshot kaynak dosyaları (Figma export) commit ET
# launch_assets/screenshots/**/*.png → commit ET

# Promo video kaynak büyük dosyalar — LFS kullan veya .gitignore
launch_assets/promo_video/*.mov
launch_assets/promo_video/*.mp4
launch_assets/promo_video/*.aep  # After Effects project
launch_assets/promo_video/*.psd  # Photoshop project
launch_assets/promo_video/raw/

# Figma kaynak dosyaları (binary, büyük)
*.fig
*.sketch
*.xd

# ═══════════════════════════════════════════════════════════════
# BACKUP & ARCHIVE
# ═══════════════════════════════════════════════════════════════
*.bak
*.backup
*.old
*.orig
*~

# ═══════════════════════════════════════════════════════════════
# CERTIFICATES & KEYS (genel)
# ═══════════════════════════════════════════════════════════════
*.key
*.crt
*.cer
*.csr
private_key*
*.pfx
```

---

## 🧪 Test: .gitignore Çalışıyor mu?

`.gitignore` ekledikten sonra kontrol:

```bash
cd ~/Development/nuveli

# Şu anki tracked dosyaları gör
git ls-files | head -20

# Yeni .gitignore'un etkili olduğunu test et
echo "test" > .env.production
git status
# Expected: ".env.production" GÖRÜNMEMELI (ignored)

# Eğer önceden tracked'sa zorla unstage
git rm --cached .env.production
git rm --cached android/keystore.properties
git rm --cached android/app/google-services.json  # Eğer commit etmek istemiyorsan

# Şimdi commit et
git add .gitignore
git commit -m "Update .gitignore for production secrets"
```

---

## 🚨 Eğer Secret Zaten Commit Edildiyse

```bash
# 1. Secret'ı geri al (current state)
git rm --cached .env.production
git commit -m "Remove .env.production from tracking"

# 2. Tüm git history'den sil (BFG Repo-Cleaner veya filter-branch)
# Önerilen tool: BFG (https://rtyley.github.io/bfg-repo-cleaner/)

brew install bfg
bfg --delete-files .env.production

# Veya tüm history'de bir string'i değiştir
bfg --replace-text passwords.txt

# 3. Cleanup
cd .git
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# 4. Force push (TEHLİKELİ — sadece kendi solo repoda)
git push origin --force --all

# 5. Secret'ı ROTATE et (varsayım: artık kompromize)
# - Supabase service role key → yenile
# - OpenAI API key → revoke, yeni oluştur
# - Tüm production env vars → güncelle
```

⚠️ **Force push, takım çalışıyorsa büyük sorun yaratır.** Bu adımı önce Slack/Discord'da duyur.

---

## 📋 Pre-Commit Hook (İleri Düzey, Opsiyonel)

Secret'ların kazara commit edilmesini önlemek için:

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Block .env files
if git diff --cached --name-only | grep -E "\.env"; then
  echo "❌ ERROR: .env file detected in commit. Add to .gitignore."
  exit 1
fi

# Block keystore files
if git diff --cached --name-only | grep -E "\.(jks|keystore|p8|p12)$"; then
  echo "❌ ERROR: Keystore/certificate file detected."
  exit 1
fi

# Block files with common secret patterns
if git diff --cached | grep -E "(api_key|password|secret_key|private_key)" | grep -E "=\s*['\"][a-zA-Z0-9]{20,}"; then
  echo "⚠️  WARNING: Possible secret detected in code."
  echo "If this is intentional, run: git commit --no-verify"
  exit 1
fi

exit 0
```

```bash
chmod +x .git/hooks/pre-commit
```

---

## ✅ Checklist

- [ ] `.gitignore` güncellendi
- [ ] `.env.production` ignored
- [ ] `keystore.properties` ignored
- [ ] `*.jks` ignored
- [ ] Firebase service account JSON ignored
- [ ] `git status` ekledikten sonra hiçbir secret görünmüyor
- [ ] Eğer önceden commit edilmiş secret varsa → BFG ile temizlendi + key'ler rotate edildi
- [ ] Pre-commit hook kuruldu (opsiyonel)

---

**Önemli:** `.gitignore` kuralları **commit edildikten sonraki dosyalar için** çalışır. Daha önce tracked'sa `git rm --cached` ile çıkarmak gerekir.
