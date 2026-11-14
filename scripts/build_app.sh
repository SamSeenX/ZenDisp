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

echo "==> Applying ad-hoc codesign with stable identifier..."
codesign --force --deep --sign - --identifier "com.samseen.ZenDisp" "$APP_DIR"

echo "==> ZenDisp.app build complete at $APP_DIR"
