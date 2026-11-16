#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "==> Building ZenDisp in release mode..."
swift build -c release

APP_DIR="$PROJECT_DIR/build/ZenDisp.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Packaging ZenDisp.app..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$PROJECT_DIR/.build/release/ZenDisp" "$MACOS_DIR/ZenDisp"
chmod +x "$MACOS_DIR/ZenDisp"
cp "$PROJECT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
mkdir -p "$RESOURCES_DIR"
cp -R "$PROJECT_DIR/Resources/"* "$RESOURCES_DIR/" 2>/dev/null || true

SIGN_IDENTITY="-"
if security find-identity -p codesigning -v | grep -q "ZenDisp Local"; then
    SIGN_IDENTITY="ZenDisp Local"
    echo "==> Using trusted certificate: ZenDisp Local"
else
    echo "==> Using ad-hoc signature"
fi

echo "==> Clearing extended attributes and signing..."
xattr -cr "$APP_DIR"
codesign --force --deep -s "$SIGN_IDENTITY" -r='designated => identifier "com.samseen.ZenDisp"' "$APP_DIR"

INSTALL_DIR="/Applications/ZenDisp.app"
echo "==> Installing to $INSTALL_DIR..."
pkill -f "ZenDisp" 2>/dev/null || true
sleep 0.5
rm -rf "$INSTALL_DIR"
cp -R "$APP_DIR" "$INSTALL_DIR"
xattr -cr "$INSTALL_DIR"
codesign --force --deep -s "$SIGN_IDENTITY" -r='designated => identifier "com.samseen.ZenDisp"' "$INSTALL_DIR"

echo "==> ZenDisp.app installed successfully at $INSTALL_DIR"
