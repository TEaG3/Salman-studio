# Salman-studio

## TEa.G3-studio

A local-first Flutter video-editing starter targeting iPadOS and Android.

The app source is in the repository root. It currently provides local video import, source preview, a clip list, saved in/out edit-point metadata, and local JSON project persistence.

### Build
```bash
flutter create . --platforms=android,ios
flutter pub get
flutter analyze
flutter run
```

Android:
```bash
flutter build apk --release
```

iPadOS requires macOS and Xcode:
```bash
flutter build ios --release
```

### Current limitations
- Edit points are metadata only; actual trimming and MP4 export are not implemented yet.
- The AI assistant is a placeholder. No media or prompts are sent to a cloud provider.
- iOS signing and device testing must be completed in Xcode on macOS.

See [docs/ROADMAP.md](docs/ROADMAP.md) for planned milestones.


## AI editing skills

This repository includes the `video-edit` skill for:
- Claude Code: `.claude/skills/video-edit/SKILL.md`
- OpenAI Codex-compatible agents: `.agents/skills/video-edit/SKILL.md`
- Shared source: `skills/video-edit/SKILL.md`

Install both user-level copies:
```bash
bash install.sh
```

Install only Claude Code:
```bash
bash install.sh --claude
```

Install only Codex-compatible agents:
```bash
bash install.sh --codex
```

Install into this repository checkout:
```bash
bash install.sh --project
```

See [docs/AI_SKILLS.md](docs/AI_SKILLS.md) and [docs/INSTALL.md](docs/INSTALL.md).
