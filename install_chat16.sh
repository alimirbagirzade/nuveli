#!/bin/bash
# Nuveli — Chat 16 dosya yerleştirme & pub get scripti
#
# Bu script ~/Development/nuveli/ kökünde çalıştırılmalı.
# ZIP yanlışlıkla nuveli/lib/ altına açıldığı için dosyaları
# app/lib/ altına taşıyıp pubspec.yaml'a dio paketini ekler.

set -e  # Hata olunca dur

echo "🌊 Nuveli — Chat 16 kurulum scripti"
echo ""

# ---------------------------------------------------------
# 1. Repo kök kontrolü
# ---------------------------------------------------------
if [ ! -d ".git" ]; then
    echo "❌ Bu script'i nuveli repo kökünde çalıştır:"
    echo "   cd ~/Development/nuveli && bash install_chat16.sh"
    exit 1
fi

# ---------------------------------------------------------
# 2. Flutter projesinin yerini bul
# ---------------------------------------------------------
if [ -f "app/pubspec.yaml" ]; then
    FLUTTER_DIR="app"
    echo "✅ Flutter projesi bulundu: ./app/"
elif [ -f "pubspec.yaml" ]; then
    FLUTTER_DIR="."
    echo "✅ Flutter projesi repo kökünde."
else
    echo "❌ pubspec.yaml bulunamadı. pubspec.yaml dosyan nerede?"
    echo ""
    echo "Aramak için:"
    echo "   find ~/Development/nuveli -name pubspec.yaml 2>/dev/null"
    exit 1
fi

# ---------------------------------------------------------
# 3. Yanlış yerdeki dosyaları taşı
# ---------------------------------------------------------
if [ -d "lib" ] && [ "$FLUTTER_DIR" != "." ]; then
    echo ""
    echo "📦 Dosyalar lib/ → $FLUTTER_DIR/lib/ altına taşınıyor..."

    # Hedef klasörleri oluştur
    mkdir -p "$FLUTTER_DIR/lib/core/network"
    mkdir -p "$FLUTTER_DIR/lib/core/data/repositories"
    for feature in dashboard profile analytics water_tracker meal_planner habits ai_coach meal_scan; do
      mkdir -p "$FLUTTER_DIR/lib/features/$feature/providers"
    done

    # Network dosyaları
    if [ -d "lib/core/network" ]; then
        for f in lib/core/network/*.dart; do
            [ -f "$f" ] && mv "$f" "$FLUTTER_DIR/lib/core/network/"
        done
    fi

    # Repository dosyaları
    if [ -d "lib/core/data/repositories" ]; then
        for f in lib/core/data/repositories/*.dart; do
            [ -f "$f" ] && mv "$f" "$FLUTTER_DIR/lib/core/data/repositories/"
        done
    fi

    # Provider dosyaları
    for feature in dashboard profile analytics water_tracker meal_planner habits ai_coach meal_scan; do
        if [ -d "lib/features/$feature/providers" ]; then
            for f in lib/features/$feature/providers/*.dart; do
                [ -f "$f" ] && mv "$f" "$FLUTTER_DIR/lib/features/$feature/providers/"
            done
        fi
    done

    # Boş yanlış lib/ klasörünü temizle
    rm -rf lib/
    echo "✅ Taşıma bitti, boş lib/ klasörü silindi."
else
    echo "ℹ️  lib/ altında taşınacak dosya yok."
fi

# ---------------------------------------------------------
# 4. pubspec.yaml'a dio ekle
# ---------------------------------------------------------
echo ""
echo "📝 pubspec.yaml kontrol ediliyor..."

PUBSPEC="$FLUTTER_DIR/pubspec.yaml"
if grep -q "^  dio:" "$PUBSPEC"; then
    echo "✅ dio paketi zaten ekli."
else
    python3 <<PYEOF
import re, sys

path = "$PUBSPEC"
with open(path, 'r') as f:
    content = f.read()

# Önce: '  flutter:\n    sdk: flutter\n' patternından sonra ekle
new_content, n = re.subn(
    r'(  flutter:\n    sdk: flutter\n)',
    r'\1  dio: ^5.4.0\n',
    content,
    count=1
)

if n == 0:
    # Bulunamadı → dependencies: satırının hemen altına ekle
    new_content, n = re.subn(
        r'^(dependencies:\s*\n)',
        r'\1  dio: ^5.4.0\n',
        content,
        count=1,
        flags=re.MULTILINE
    )

if n == 0:
    print("⚠️  pubspec.yaml'a dio eklenemedi (pattern bulunamadı).")
    print("   Manuel ekle: dependencies: bloğunun altına 'dio: ^5.4.0'")
    sys.exit(1)

with open(path, 'w') as f:
    f.write(new_content)
print("✅ dio: ^5.4.0 eklendi.")
PYEOF
fi

# ---------------------------------------------------------
# 5. flutter pub get
# ---------------------------------------------------------
echo ""
echo "📦 flutter pub get..."
cd "$FLUTTER_DIR"
flutter pub get

# ---------------------------------------------------------
# 6. flutter analyze (özet)
# ---------------------------------------------------------
echo ""
echo "🔍 flutter analyze (kısa rapor)..."
echo "─────────────────────────────────────────────────"

# Tam çıktıyı bir dosyaya kaydet, özetini ekrana ver
flutter analyze lib/core/ lib/features/ 2>&1 | tee /tmp/nuveli_chat16_analyze.log | tail -20 || true

echo "─────────────────────────────────────────────────"
TOTAL_ISSUES=$(grep -c "error •\|warning •" /tmp/nuveli_chat16_analyze.log 2>/dev/null || echo "0")
echo ""
echo "📊 Toplam issue: $TOTAL_ISSUES"
echo "📄 Tam log: /tmp/nuveli_chat16_analyze.log"

cd ..

# ---------------------------------------------------------
# 7. Sonraki adımlar
# ---------------------------------------------------------
echo ""
echo "✨ Script bitti!"
echo ""
echo "Sıradaki adımlar:"
echo "  1. Yukarıdaki analyze özetini ve issue sayısını Claude'a yapıştır"
echo "  2. Eğer 0 hata varsa: doğrudan commit & push (script aşağıdaki komutu önerir)"
echo "  3. Hata varsa: muhtemelen model class uyumsuzluğu, beraber çözeriz"
echo ""
echo "Git commit komutu (analyze yeşilse):"
echo "  cd ~/Development/nuveli"
echo "  git add $FLUTTER_DIR/lib/ $FLUTTER_DIR/pubspec.yaml $FLUTTER_DIR/pubspec.lock docs/chat16/"
echo "  git status"
echo "  git commit -m 'feat: Chat 16 - Repository integration'"
echo "  git push"
