#!/bin/bash
set -e
cd "$(dirname "$0")"
CURRENT=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION=$(echo $CURRENT | cut -d'+' -f1)
BUILD=$(echo $CURRENT | cut -d'+' -f2)
MAJOR=$(echo $VERSION | cut -d'.' -f1)
MINOR=$(echo $VERSION | cut -d'.' -f2)
PATCH=$(echo $VERSION | cut -d'.' -f3)
case "$1" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0; BUILD=$((BUILD+1));;
  minor) MINOR=$((MINOR+1)); PATCH=0; BUILD=$((BUILD+1));;
  patch) PATCH=$((PATCH+1)); BUILD=$((BUILD+1));;
  build) BUILD=$((BUILD+1));;
  *) echo "Kullanim: ./bump-version.sh [major|minor|patch|build]"; echo "Mevcut: $CURRENT"; exit 1;;
esac
NEW="$MAJOR.$MINOR.$PATCH+$BUILD"
sed -i.bak "s/^version: .*/version: $NEW/" pubspec.yaml && rm pubspec.yaml.bak
echo "✅ $CURRENT -> $NEW"
