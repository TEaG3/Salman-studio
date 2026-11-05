#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter, then rerun this script." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required to apply the native display-name settings." >&2
  exit 1
fi

# Generate the official Flutter Android and iOS project scaffolding.
flutter create --platforms=android,ios --org com.teag3 --project-name tea_g3_studio .

# Apply the public app name and stable store identifiers to generated native files.
python3 - <<'PY'
from pathlib import Path
import re

root = Path.cwd()
display_name = "TEa.G3-studio"
bundle_id = "com.teag3.studio"

manifest = root / "android/app/src/main/AndroidManifest.xml"
if manifest.exists():
    text = manifest.read_text()
    text = re.sub(r'android:label="[^"]+"', f'android:label="{display_name}"', text, count=1)
    manifest.write_text(text)

# Flutter templates may use Groovy or Kotlin Gradle files.
for gradle in (root / "android/app/build.gradle", root / "android/app/build.gradle.kts"):
    if gradle.exists():
        text = gradle.read_text()
        text = re.sub(r'applicationId\s*[= ]\s*"[^"]+"', f'applicationId = "{bundle_id}"', text)
        gradle.write_text(text)

info = root / "ios/Runner/Info.plist"
if info.exists():
    text = info.read_text()
    text = re.sub(
        r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)',
        rf'\g<1>{display_name}\g<2>',
        text,
        count=1,
    )
    info.write_text(text)

project = root / "ios/Runner.xcodeproj/project.pbxproj"
if project.exists():
    text = project.read_text()
    text = re.sub(
        r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;',
        f'PRODUCT_BUNDLE_IDENTIFIER = {bundle_id};',
        text,
    )
    project.write_text(text)

print(f"Configured app display name: {display_name}")
print(f"Configured iOS bundle identifier and Android applicationId: {bundle_id}")
PY

flutter pub get
echo "Platform scaffolding and TEa.G3-studio identifiers are ready."
echo "For iPadOS release builds, open ios/Runner.xcworkspace in Xcode and configure signing."
