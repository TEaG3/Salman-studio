# TEa.G3-studio installation

## Requirements
- Flutter stable SDK
- Android Studio and Android SDK for Android builds
- macOS with Xcode for iPadOS builds

## Prepare the project

```bash
flutter create . --platforms=android,ios
flutter pub get
flutter analyze
flutter run
```

## Build Android

```bash
flutter build apk --release
```

## Build iPadOS

On macOS:

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and configure signing.

## Install agent skills

```bash
bash install.sh
```

See [AI_SKILLS.md](AI_SKILLS.md) for Claude Code and Codex skill paths.
