#!/bin/bash
# Build LidAwake.app (universal: Apple Silicon + Intel) into ~/Applications.
# Needs only the Xcode Command Line Tools: xcode-select --install
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP="${LIDAWAKE_DEST:-${HOME}/Applications}/LidAwake.app"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>            <string>LidAwake</string>
	<key>CFBundleDisplayName</key>     <string>LidAwake</string>
	<key>CFBundleIdentifier</key>      <string>local.lidawake</string>
	<key>CFBundleExecutable</key>      <string>LidAwake</string>
	<key>CFBundlePackageType</key>     <string>APPL</string>
	<key>CFBundleShortVersionString</key> <string>1.0.0</string>
	<key>CFBundleVersion</key>         <string>1</string>
	<key>LSMinimumSystemVersion</key>  <string>14.0</string>
	<!-- Menu bar only: no Dock icon, no app switcher entry. -->
	<key>LSUIElement</key>             <true/>
</dict>
</plist>
PLIST

for arch in arm64 x86_64; do
	swiftc -O -parse-as-library \
		-target "$arch-apple-macos14.0" \
		-o "$TMP/LidAwake-$arch" \
		"$SRC_DIR/LidAwake.swift"
done
lipo -create -output "$APP/Contents/MacOS/LidAwake" "$TMP"/LidAwake-*

# Ad-hoc sign so Launch at Login (SMAppService) accepts a stable identity.
codesign --force --sign - --identifier local.lidawake "$APP"

echo "built: $APP"
