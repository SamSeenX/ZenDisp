#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "==> Ensuring latest release build exists..."
./scripts/build_app.sh

DMG_STAGING="$PROJECT_DIR/build/dmg_staging"
DMG_OUTPUT="$PROJECT_DIR/build/ZenDisp.dmg"

echo "==> Preparing DMG staging environment..."
rm -rf "$DMG_STAGING" "$DMG_OUTPUT"
mkdir -p "$DMG_STAGING"

cp -R "/Applications/ZenDisp.app" "$DMG_STAGING/ZenDisp.app"
ln -s /Applications "$DMG_STAGING/Applications"

echo "==> Creating compressed ZenDisp.dmg..."
hdiutil create -volname "ZenDisp" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_OUTPUT"

SIGN_IDENTITY="-"
if security find-identity -p codesigning -v | grep -q "ZenDisp Local"; then
    SIGN_IDENTITY="ZenDisp Local"
fi

echo "==> Signing DMG..."
codesign --force -s "$SIGN_IDENTITY" "$DMG_OUTPUT" 2>/dev/null || true

rm -rf "$DMG_STAGING"
echo "==> ZenDisp.dmg created successfully at: $DMG_OUTPUT ($(du -h "$DMG_OUTPUT" | cut -f1))"
