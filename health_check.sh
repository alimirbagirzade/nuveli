#!/bin/bash
# Nuveli Project Health Check
# Bu script tüm bağımlılıkları ve temel çalışma durumunu kontrol eder

set -e  # Hata olursa dur

echo "========================================="
echo "NUVELI PROJECT HEALTH CHECK"
echo "========================================="
echo ""

# Renk kodları
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Başarı/başarısızlık sayaçları
SUCCESS=0
FAIL=0

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 yüklü"
        ((SUCCESS++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 bulunamadı - kurulması gerekiyor"
        ((FAIL++))
        return 1
    fi
}

section() {
    echo ""
    echo -e "${YELLOW}━━━ $1 ━━━${NC}"
}

# ============================================
# 1. SISTEM GEREKSİNİMLERİ
# ============================================
section "Sistem Gereksinimleri"

check_command "python3"
check_command "flutter"
check_command "git"

# Python versiyonu
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo "  Python sürümü: $PYTHON_VERSION"
fi

# Flutter versiyonu
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1 | cut -d' ' -f2)
    echo "  Flutter sürümü: $FLUTTER_VERSION"
fi

# ============================================
# 2. BACKEND KONTROLÜ
# ============================================
section "Backend Kontrolü"

cd backend 2>/dev/null || { echo -e "${RED}✗${NC} backend/ klasörü bulunamadı"; exit 1; }

# Virtual environment var mı?
if [ -d "venv" ]; then
    echo -e "${GREEN}✓${NC} venv/ klasörü mevcut"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} venv/ yok - oluşturuluyor..."
    python3 -m venv venv
fi

# Activate ve dependencies install
source venv/bin/activate

echo "Backend dependencies kontrol ediliyor..."
pip install -q -r requirements.txt

# Backend dosyalarının syntax kontrolü
echo "Backend syntax kontrolü..."
BACKEND_FILES=(
    "app/main.py"
    "app/core/config.py"
    "app/services/profile_service.py"
    "app/api/routes/profile.py"
)

for file in "${BACKEND_FILES[@]}"; do
    if python3 -m py_compile "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $file"
        ((SUCCESS++))
    else
        echo -e "${RED}✗${NC} $file syntax hatası"
        ((FAIL++))
    fi
done

# .env dosyası var mı?
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env dosyası mevcut"
    ((SUCCESS++))
else
    echo -e "${RED}✗${NC} .env dosyası eksik"
    echo "  → backend/.env.example dosyasını .env olarak kopyala"
    ((FAIL++))
fi

cd ..

# ============================================
# 3. FRONTEND KONTROLÜ
# ============================================
section "Frontend Kontrolü"

cd app 2>/dev/null || { echo -e "${RED}✗${NC} app/ klasörü bulunamadı"; exit 1; }

# pubspec.yaml var mı?
if [ -f "pubspec.yaml" ]; then
    echo -e "${GREEN}✓${NC} pubspec.yaml mevcut"
    ((SUCCESS++))
else
    echo -e "${RED}✗${NC} pubspec.yaml bulunamadı"
    ((FAIL++))
    exit 1
fi

# Dependencies install
echo "Flutter dependencies yükleniyor..."
flutter pub get > /dev/null 2>&1

# Kritik dosyaların varlığını kontrol et
echo "Kritik dosyalar kontrol ediliyor..."
CRITICAL_FILES=(
    "lib/main.dart"
    "lib/app.dart"
    "lib/core/routing/app_router.dart"
    "lib/features/auth/data/auth_repository.dart"
    "lib/features/onboarding/providers/onboarding_controller.dart"
    "lib/features/meal/providers/meal_providers.dart"
    "lib/features/coach/data/coach_repository.dart"
    "lib/features/settings/providers/settings_providers.dart"
    "lib/features/premium/utils/trial_gift_trigger.dart"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
        ((SUCCESS++))
    else
        echo -e "${RED}✗${NC} $file eksik"
        ((FAIL++))
    fi
done

# Flutter analyze (syntax + lint)
echo "Flutter analyze çalıştırılıyor..."
if flutter analyze --no-pub > /tmp/flutter_analyze.log 2>&1; then
    echo -e "${GREEN}✓${NC} Flutter analyze başarılı (hata yok)"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} Flutter analyze uyarıları var:"
    grep "error •" /tmp/flutter_analyze.log | head -5
    # Uyarılar fail sayılmaz ama gösterilir
fi

# Test dosyaları var mı?
echo "Test suite kontrol ediliyor..."
TEST_FILES=(
    "test/_helpers/test_helpers.dart"
    "test/core/app_error_test.dart"
    "test/features/onboarding/onboarding_controller_test.dart"
    "test/features/meal/meal_repository_test.dart"
)

TEST_EXISTS=0
for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        ((TEST_EXISTS++))
    fi
done

if [ $TEST_EXISTS -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Test dosyaları mevcut ($TEST_EXISTS/4)"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} Test dosyaları eksik"
fi

cd ..

# ============================================
# 4. FIREBASE CONFIG KONTROLÜ
# ============================================
section "Firebase Konfigürasyonu"

if [ -f "app/android/app/google-services.json" ]; then
    echo -e "${GREEN}✓${NC} google-services.json mevcut"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} app/android/app/google-services.json eksik"
    echo "  → Firebase Console'dan indir"
fi

if [ -f "app/ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✓${NC} GoogleService-Info.plist mevcut"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} app/ios/Runner/GoogleService-Info.plist eksik"
    echo "  → Firebase Console'dan indir"
fi

# ============================================
# 5. ENVIRONMENT TEMPLATE KONTROLÜ
# ============================================
section "Environment Dosyaları"

if [ -f "backend/.env.example" ]; then
    echo -e "${GREEN}✓${NC} backend/.env.example mevcut"
    ((SUCCESS++))
else
    echo -e "${YELLOW}!${NC} .env.example eksik - oluşturuluyor..."
    cat > backend/.env.example << 'EOF'
APP_ENV=development
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
OPENAI_API_KEY=sk-...
REVENUECAT_WEBHOOK_SECRET=your-revenuecat-secret
EOF
    echo "  → backend/.env.example oluşturuldu"
fi

# ============================================
# ÖZET
# ============================================
section "Kontrol Özeti"

TOTAL=$((SUCCESS + FAIL))
echo ""
echo "Toplam kontrol: $TOTAL"
echo -e "${GREEN}Başarılı: $SUCCESS${NC}"
echo -e "${RED}Başarısız: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Proje tamamen hazır!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Şimdi yapabileceklerin:"
    echo "  1. Backend'i başlat:"
    echo "     cd backend && source venv/bin/activate && python run.py"
    echo ""
    echo "  2. Frontend'i çalıştır:"
    echo "     cd app && flutter run"
    echo ""
    echo "  3. Test suite'i çalıştır:"
    echo "     cd app && flutter test"
else
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}! Bazı sorunlar var - yukarıya bak${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
fi
