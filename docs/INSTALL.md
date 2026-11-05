# TEa.G3-studio installation

## Requirements
- Flutter stable SDK
- Android Studio and Android SDK for Android builds
- macOS with Xcode for iPadOS builds
- Python 3 (used by the platform configuration script)

## Generate and configure Android/iOS projects

From the repository root:

```bash
bash tool/configure_platforms.sh
flutter analyze
flutter run
```

The script runs Flutter's official project generator for Android and iOS, then applies:
- App display name: `TEa.G3-studio`
- Android application ID: `com.teag3.studio`
- iOS bundle identifier: `com.teag3.studio`

The generated native folders are local build inputs and are not committed to this branch.

## Build Android

```bash
flutter build apk --release
```

## Build iPadOS

On macOS:

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode, select the Runner target, configure your Apple Developer Team and signing settings, and build for the intended device.

## Install agent skills

```bash
bash install.sh
```

See [AI_SKILLS.md](AI_SKILLS.md) for Claude Code and Codex skill paths.
