#!/bin/bash
# Nuveli Android Production Build
#
# Kullanım:
#   ./scripts/build-android.sh
#
# Gereksinimler:
#   - Android Studio + Android SDK
#   - app/.env.production dosyası dolu
#   - android/key.properties + android/app/nuveli-release.jks dosyaları var
#   - Google Play Console'da app kayıtlı

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../app"
ENV_FILE="$APP_DIR/.env.production"

# ----------------------------------------------------------------------------
# Pre-flight checks
# ----------------------------------------------------------------------------

if [ ! -f "$ENV_FILE" ]; then
  echo -e "${RED}❌ .env.production eksik: $ENV_FILE${NC}"
  echo "Çözüm: cp app/.env.production.example app/.env.production && doldur"
  exit 1
fi

if [ ! -f "$APP_DIR/android/app/google-services.json" ]; then
  echo -e "${RED}❌ Firebase Android config eksik: google-services.json${NC}"
  echo "Çözüm: Firebase Console → Android app → Download config file"
  exit 1
fi

if [ ! -f "$APP_DIR/android/key.properties" ]; then
  echo -e "${RED}❌ Android signing config eksik: android/key.properties${NC}"
  echo ""
  echo "Çözüm: android/key.properties dosyası oluştur:"
  echo "  storePassword=<your-password>"
  echo "  keyPassword=<your-password>"
  echo "  keyAlias=<your-alias>"
  echo "  storeFile=<path-to-keystore.jks>"
  exit 1
fi

# ----------------------------------------------------------------------------
# Build
# ----------------------------------------------------------------------------

cd "$APP_DIR"

echo -e "${YELLOW}🧹 Temiz build için cache temizleniyor...${NC}"
flutter clean
flutter pub get

echo -e "${YELLOW}⚙️  Kod generate...${NC}"
dart run build_runner build --delete-conflicting-outputs

echo -e "${YELLOW}🧪 Testleri çalıştır...${NC}"
flutter test

echo -e "${YELLOW}🤖 Android App Bundle oluşturuluyor...${NC}"
flutter build appbundle \
  --release \
  --dart-define-from-file="$ENV_FILE"

BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"

echo ""
echo -e "${GREEN}✅ Build tamamlandı!${NC}"
echo -e "${GREEN}📦 Bundle: $APP_DIR/$BUNDLE_PATH${NC}"
echo ""
echo "Sonraki adımlar:"
echo "  1. Google Play Console → App release → Internal testing / Production"
echo "  2. .aab dosyasını upload et"
echo "  3. Release notes + screenshot'ları doldur"
echo "  4. Review for release"
