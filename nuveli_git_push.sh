#!/bin/bash
set -e

cd "$HOME/development/nuveli" || { echo "❌ Repo bulunamadı"; exit 1; }

echo "═══ 1. Dizin & branch kontrolü ═══"
pwd
git branch --show-current

echo ""
echo "═══ 2. .gitignore'a 3 satır ekleniyor ═══"
{
  echo ""
  echo "# Konsolidasyon backup ve script - 15 May 2026"
  echo "_backup_consolidate_*.tar.gz"
  echo "_archive/"
  echo "nuveli_consolidate.sh"
} >> .gitignore

tail -6 .gitignore

echo ""
echo "═══ 3. Tüm değişiklikleri stage ediyoruz ═══"
git add -A

echo ""
echo "Stage edilen dosya sayısı: $(git diff --cached --name-only | wc -l | tr -d ' ')"
echo ""
echo "İlk 15 dosya:"
git diff --cached --name-only | head -15
echo "..."

echo ""
echo "═══ 4. Commit ═══"
git commit -m "release v1.0: website rebuild + app production-ready

Website:
- Anasayfa: Ocean Palette + Plus Jakarta + Inter, 11-section landing
- 5 sayfa footer fix: Hesap Sil linki, Google Play uyumlu
- Mimari konsolide: legal + landing -> website/public_html
- htaccess: dil rewrite, Options -Indexes, TR redirect
- 28/28 URL erişilebilir

App:
- AndroidManifest: kamera, foto, push, internet izinleri
- Version 0.20.5+43 -> 1.0.0+1
- 7 dilde l10n update

Repo:
- _archive/legacy: eski legal, landing arsivlendi
- docs/sprints: SPRINT MD dosyalari tasindi"

echo ""
echo "═══ 5. Yeni commit özeti ═══"
git log -1 --stat | head -10

echo ""
echo "═══ 6. GitHub'a push ═══"
git push origin main

echo ""
echo "═══ 7. Final durum ═══"
git status

echo ""
echo "✅ Tamamlandı! GitHub'a baktığında en son commit'i göreceksin."
