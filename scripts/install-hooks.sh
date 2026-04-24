#!/bin/bash
# Git hook'larını yerel repo'ya kur.
# Tek seferlik çalıştır, sonra otomatik her commit'te trigger olur.
#
# Kullanım: ./scripts/install-hooks.sh

set -e

HOOK_DIR=".git/hooks"

if [ ! -d ".git" ]; then
  echo "❌ Bu komut repo root'unda çalıştırılmalı (.git klasörü bulunamadı)."
  exit 1
fi

# pre-commit'i kopyala ve executable yap
cp scripts/pre-commit "$HOOK_DIR/pre-commit"
chmod +x "$HOOK_DIR/pre-commit"

echo "✅ Pre-commit hook kuruldu: $HOOK_DIR/pre-commit"
echo ""
echo "Test etmek için: boş bir dosya değişikliği yap ve 'git commit' et."
echo "Hook'u bypass etmek için: git commit --no-verify"
