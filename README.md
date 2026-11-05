# TEa.G3-studio

A local-first Flutter video-editing app. Android is the first native target; iOS is deferred.

The Android editor supports local video import, source preview, a clip list, saved in/out points, local JSON project persistence, a validated sequential edit-decision-list (EDL), and single-clip MP4 trimming through Jetpack Media3 Transformer.

## Prepare Android

Install the Flutter stable SDK, Android Studio, and the Android SDK. From the repository root run:

```bash
bash tool/configure_platforms.sh
flutter analyze --fatal-infos
flutter test
flutter run
```

The script generates the official Android Flutter scaffolding, sets the display name to **TEa.G3-studio**, sets the Android application ID to `com.teag3.studio`, adds the Media3 Transformer dependency, and runs `flutter pub get`.

## Build Android

```bash
flutter build apk --release
```

GitHub Actions runs analysis, tests, and an Android release build for pull requests and publishes the APK as a workflow artifact.

## Current limitations

- MP4 export currently trims one selected source clip. Concatenating multiple clips, multi-track editing, transitions, overlays, audio mixing, and frame-accurate timeline preview are not implemented yet.
- Export files are stored in the app's private documents directory; a user-facing gallery/share destination is a follow-up task.
- The AI assistant is a placeholder. No media or prompts are sent to a cloud provider.
- The web editor, backend API, MCP server, ChatGPT app integration, and Claude MCP integration are not deployed yet.
- Android release signing for a store release still needs a private signing key and protected CI secrets. Never commit signing keys or API secrets.

## AI editing skills

This repository includes the `video-edit` skill for Claude Code and Codex-compatible agents. Skills provide instructions; they do not themselves connect to ChatGPT or Claude services or execute editing operations.

See [docs/ROADMAP.md](docs/ROADMAP.md), [docs/PLATFORM-ARCHITECTURE.md](docs/PLATFORM-ARCHITECTURE.md), and [docs/AI-AND-MODEL-ROADMAP.md](docs/AI-AND-MODEL-ROADMAP.md).
