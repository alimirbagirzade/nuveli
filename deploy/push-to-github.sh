#!/bin/bash
# ============================================================
# Nuveli — GitHub Push Script
# Bu script'i ZIP'i açtığın klasörde çalıştır.
# Gereksinim: git yüklü + GitHub hesabına SSH veya token erişimi
# ============================================================

set -e

REPO_URL="https://github.com/alimirbagirzade/Nuveli.git"
BRANCH="main"

echo "▸ Nuveli repo push başlıyor..."
echo ""

# Bu klasör bir git repo değilse başlat
if [ ! -d ".git" ]; then
    echo "▸ Git repo başlatılıyor..."
    git init
    git branch -M main
fi

# Remote tanımla veya güncelle
if git remote get-url origin > /dev/null 2>&1; then
    echo "▸ Remote 'origin' zaten tanımlı, güncelleniyor..."
    git remote set-url origin "$REPO_URL"
else
    echo "▸ Remote 'origin' ekleniyor: $REPO_URL"
    git remote add origin "$REPO_URL"
fi

# Config (lokal değilse varsayılan olarak ekle)
git config user.email 2>/dev/null || git config user.email "dev@nuveli.com.tr"
git config user.name 2>/dev/null || git config user.name "Nuveli Dev"

# Tüm dosyaları stage et
echo "▸ Dosyalar ekleniyor..."
git add .

# Commit
if git diff --cached --quiet; then
    echo "▸ Commit edilecek değişiklik yok."
else
    echo "▸ Commit oluşturuluyor..."
    git commit -m "initial: Nuveli MVP — Flutter + FastAPI + landing page"
fi

# Push
echo "▸ GitHub'a push ediliyor..."
echo "  Not: Authentication gerekirse GitHub token veya SSH kullan."
git push -u origin "$BRANCH" || git push -u origin "$BRANCH" --force-with-lease

echo ""
echo "✓ Push tamamlandı!"
echo "  Repo: https://github.com/alimirbagirzade/Nuveli"
echo ""
echo "Sonraki adımlar:"
echo "  1. Render.com'a bağla (deploy/README.md → adım 3)"
echo "  2. Supabase kurulumu yap (deploy/README.md → adım 2)"
echo "  3. Landing dosyalarını cPanel'e yükle (deploy/README.md → adım 1)"
