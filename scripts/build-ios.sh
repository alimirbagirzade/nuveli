#!/bin/bash
# Nuveli iOS Production Build
#
# Kullanım:
#   ./scripts/build-ios.sh
#
# Gereksinimler:
#   - Xcode + iOS development certificate
#   - app/.env.production dosyası dolu
#   - Apple Developer hesabı + app ID kayıtlı

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

if [ ! -f "$APP_DIR/ios/Runner/GoogleService-Info.plist" ]; then
  echo -e "${RED}❌ Firebase iOS config eksik: GoogleService-Info.plist${NC}"
  echo "Çözüm: Firebase Console → iOS app → Download config file"
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

echo -e "${YELLOW}📱 iOS Release build oluşturuluyor...${NC}"
flutter build ios \
  --release \
  --dart-define-from-file="$ENV_FILE"

echo ""
echo -e "${GREEN}✅ Build tamamlandı!${NC}"
echo ""
echo "Sonraki adımlar:"
echo "  1. Xcode'da aç: open ios/Runner.xcworkspace"
echo "  2. Product → Archive"
echo "  3. Distribute App → App Store Connect → Upload"
echo "  4. App Store Connect'te TestFlight altında görünecek"
