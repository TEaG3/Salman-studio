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

# Android is the first supported native target. iOS scaffolding is intentionally deferred.
flutter create --platforms=android --org com.teag3 --project-name tea_g3_studio .

python3 - <<'PY'
from pathlib import Path
import re

root = Path.cwd()
display_name = "TEa.G3-studio"
application_id = "com.teag3.studio"

manifest = root / "android/app/src/main/AndroidManifest.xml"
if not manifest.exists():
    raise SystemExit("Flutter did not generate android/app/src/main/AndroidManifest.xml")
text = manifest.read_text()
text = re.sub(r'android:label="[^"]+"', f'android:label="{display_name}"', text, count=1)
manifest.write_text(text)

gradle_files = (root / "android/app/build.gradle", root / "android/app/build.gradle.kts")
gradle = next((path for path in gradle_files if path.exists()), None)
if gradle is None:
    raise SystemExit("Flutter did not generate the Android app Gradle file")
text = gradle.read_text()
if gradle.name.endswith(".kts"):
    text, count = re.subn(r'applicationId\s*=\s*"[^"]+"', f'applicationId = "{application_id}"', text, count=1)
else:
    text, count = re.subn(r'applicationId\s+"[^"]+"', f'applicationId "{application_id}"', text, count=1)
if count != 1:
    raise SystemExit("Could not safely set the Android applicationId")
gradle.write_text(text)

print(f"Configured Android app: {display_name} ({application_id})")
PY

flutter pub get
echo "Android project scaffolding is ready."
