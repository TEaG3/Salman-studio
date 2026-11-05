# TEa.G3-studio roadmap

## Android foundation
- [x] Flutter Android app structure
- [x] Import local video and copy it into app storage
- [x] Preview source video
- [x] Clip list and editable in/out points
- [x] Save project data locally as JSON, with legacy filename migration
- [x] Validated sequential edit-decision-list (EDL) model
- [x] Native single-clip MP4 trim export through AndroidX Media3 Transformer
- [x] Export progress events from the native Android layer
- [x] GitHub Actions analysis, unit-test, and Android release-build workflow

## Next milestones
- [ ] Verify generated Android project and release build on GitHub Actions
- [ ] Save exported files to Android MediaStore and add share flow
- [ ] Concatenate multiple clips and render a complete timeline
- [ ] Multi-track video, audio, and text timeline
- [ ] Frame-accurate preview and playback range controls
- [ ] Arabic RTL captions and subtitle timing
- [ ] Crop, aspect ratio, transforms, color controls
- [ ] Undo/redo and autosave
- [ ] Backend API and provider-neutral AI gateway with explicit consent
- [ ] Web editor using the shared project/EDL contract
- [ ] Authenticated MCP tools and verified ChatGPT/Claude integrations
- [ ] Custom model evaluation and possible fine-tuning on licensed, consented data

## Scope notes
The current Android export trims one selected source clip. It does not yet concatenate multiple clips or render a complete multi-track timeline.
The AI assistant remains a local placeholder and does not contact any cloud service.
Source import, preview, project persistence, and EDL creation are designed to work offline.
