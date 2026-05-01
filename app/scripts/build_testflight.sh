#!/bin/bash
# =============================================================
# Nuveli — TestFlight Build Script
# Kullanım: cd app && ./scripts/build_testflight.sh
# =============================================================
set -e

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$APP_DIR/.env.production"

echo "🚀 Nuveli TestFlight Build başlıyor..."

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ HATA: .env.production bulunamadı!"
  echo "   cp .env.production.example .env.production  ile oluştur ve doldur."
  exit 1
fi

cd "$APP_DIR"
echo "📦 flutter clean + pub get..."
flutter clean && flutter pub get

echo "🍎 pod install..."
cd ios && pod install --repo-update && cd ..

echo "🔨 IPA build ediliyor (5-10 dk)..."
flutter build ipa \
  --dart-define-from-file=".env.production" \
  --export-options-plist=ios/ExportOptions.plist \
  --release

echo ""
echo "✅ TAMAMLANDI! → build/ios/ipa/nuveli.ipa"
echo "Sonraki adım: Xcode → Window → Organizer → Archives → Distribute"
