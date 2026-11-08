# TEa.G3-studio

TEa.G3-studio is being developed as a hybrid AI creative-production platform for personal video editing, portraits and image work, motion graphics, animation, bilingual typography, audio, and advertising. Android is the first native target; iOS is deferred.

## Current web editor

The static web editor runs in a modern browser on Windows, macOS, Linux, iPad and Android. It supports local media import, browser-local media/project storage, a multi-clip video/audio timeline, source in/out trimming, sequence preview, and WebM export. Web export now mixes audio clips into the video output when the browser supports Web Audio and MediaRecorder. Audio clips are currently sequenced from the beginning of the video; independent clip placement, overlapping tracks, fades, effects and transitions are not available yet. Browser/device compatibility must be checked, especially on iPad Safari.

## Platform support status

- **Web:** available as a browser-based editor; works on Windows through Edge/Chrome/Firefox and on supported mobile browsers. It does not require a Windows installer.
- **Android:** native Flutter app foundation; local import/preview/project saving and single-clip MP4 trim export. Native multi-track audio/video export is not implemented yet.
- **Windows desktop:** native Flutter target is generated and built by Windows CI. The first test release is a portable ZIP containing the app executable and runtime files; native video export still needs Windows-specific implementation and testing. Until a release artifact is published, use the web editor in a Windows browser.
- **iOS/iPadOS native app:** deferred; the web editor can be used in Safari, subject to browser limitations.

## Current Android app

The Flutter Android editor supports local video import, source preview, a clip list, saved in/out points, local JSON project persistence, and single-clip MP4 trimming through Jetpack Media3 Transformer. It is not yet a full multi-track editor.

## Backend foundation (new)

A local Python/FastAPI starter is available in `backend/`. It includes a SQLite database schema for projects, assets, tracks, clips, captions, effects, transitions, edit plans, render jobs, AI sessions, and provider usage. It provides project create/list/read endpoints and a deterministic Arabic/English creative-brief planner.

Run it locally:

```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload
```

Open `http://127.0.0.1:8000/docs`. The backend is for local development only; it has no authentication and must not be exposed to the public internet.

## Free hosting direction

The target is a $0/month baseline without paid AI-agent subscriptions or required paid model APIs. The proposed hosting split is a static web frontend, a small FastAPI API, managed PostgreSQL, and object storage. Heavy AI generation is optional and remains unavailable unless genuinely free GPU compute is confirmed.

See [Free-hosting architecture](docs/FREE-HOSTING-ARCHITECTURE.md) for provider choices, free-tier limitations, security requirements, and the staged migration plan. This is a target architecture, not a claim that cloud deployment is complete.

## Prepare Android

Install Flutter stable, Android Studio, and the Android SDK. From the repository root:

```bash
bash tool/configure_platforms.sh
flutter analyze --fatal-infos
flutter test
flutter run
```

The script generates Android scaffolding, sets the display name to **TEa.G3-studio**, sets application ID `com.teag3.studio`, adds Media3 Transformer, and runs `flutter pub get`.

## Build Android

```bash
flutter build apk --release
```

GitHub Actions is configured to run Flutter analysis, tests, and a release APK build for pull requests.

## Current limitations

- The Android export currently trims one selected source clip. Multi-clip composition, multi-track editing, transitions, overlays, audio mixing, and frame-accurate timeline preview are not implemented.
- The Python planner currently creates draft plans only; it does not generate images/videos or render media.
- No ComfyUI, Diffusers, open video model, hosted generation API, or FFmpeg multi-track renderer has been connected yet.
- The backend has no authentication, multi-user authorization, upload service, or production deployment. Keep it local.
- ChatGPT/Claude/Gemini/Kimi/DeepSeek tool integrations are not published or end-to-end tested.
- No custom TEa.G3 foundation model has been trained.
- Store signing requires a private key and protected secrets. Never commit signing keys or provider API keys.

## Architecture and development notes

- [Platform architecture](docs/PLATFORM-ARCHITECTURE.md)
- [Free-hosting architecture](docs/FREE-HOSTING-ARCHITECTURE.md)
- [AI and model roadmap](docs/AI-AND-MODEL-ROADMAP.md)
- [GPT-OSS 20B AI Director integration](docs/GPT-OSS-20B-INTEGRATION.md)
- [DeepSeek and Kimi open-weight model integration](docs/OPEN-WEIGHT-MODELS-DEEPSEEK-KIMI.md)
- [Open model and media-engine strategy](docs/OPEN-SOURCE-MODEL-STACK.md)
- [Database model](docs/DATA-MODEL.md)
- [Production algorithm](docs/PRODUCTION-ALGORITHM.md)
- [Backend setup](backend/README.md)

Media files should remain local by default. Any cloud upload or paid provider use must be opt-in and clearly disclosed. Keep credentials in a secure server-side secret store, never in Flutter or Git.
