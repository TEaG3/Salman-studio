# TEa.G3-studio

TEa.G3-studio is being developed as a hybrid AI creative-production platform for personal video editing, portraits and image work, motion graphics, animation, bilingual typography, audio, and advertising. Android is the first native target; iOS is deferred.

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
- [Open model and media-engine strategy](docs/OPEN-SOURCE-MODEL-STACK.md)
- [Database model](docs/DATA-MODEL.md)
- [Production algorithm](docs/PRODUCTION-ALGORITHM.md)
- [Backend setup](backend/README.md)

Media files should remain local by default. Any cloud upload or paid provider use must be opt-in and clearly disclosed. Keep credentials in a secure server-side secret store, never in Flutter or Git.
