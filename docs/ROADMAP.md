# Frame Studio roadmap

## MVP foundation
- [x] Flutter cross-platform app structure
- [x] Import local video and copy it into app storage
- [x] Preview source video
- [x] Clip list and edit-point metadata
- [x] Save project data locally as JSON
- [x] AI service boundary (placeholder only)

## Next milestones
- [ ] Actual trimming and MP4 export
- [ ] Concatenate multiple clips
- [ ] Multi-track video, audio, and text timeline
- [ ] Arabic RTL captions and subtitle timing
- [ ] Crop, aspect ratio, transforms, color controls
- [ ] Undo/redo and autosave
- [ ] Optional AI provider integration with explicit consent
- [ ] Backup and restore projects

## Scope notes
The current in/out controls store edit metadata; they do not render a trimmed video.
The AI assistant is a placeholder and does not contact any cloud service.
Core import, preview, and project persistence are designed to work offline.
