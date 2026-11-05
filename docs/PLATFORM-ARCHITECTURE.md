# TEa.G3-studio platform architecture

## Product direction

TEa.G3-studio is a local-first video editor with a shared AI-assisted workflow across Android, web, ChatGPT, and Claude. Android is the first native target. iOS is intentionally deferred.

## System layout

- **Android app (Flutter):** local media import, project management, preview, editing controls, and offline-capable editing.
- **Web app:** browser-based project workspace and editor. It must call the same documented backend contracts as Android; it must not reimplement editing rules independently.
- **Media engine:** deterministic editing/rendering service. AI proposes structured edit operations; the media engine validates and executes them.
- **TEa.G3 AI gateway:** provider-neutral API for model calls, prompt policy, tool routing, usage limits, and consent enforcement.
- **ChatGPT integration:** a documented tool interface (MCP or supported ChatGPT app/action surface) exposing safe project and editing operations.
- **Claude integration:** MCP server/tool interface plus the existing Claude Code video-edit skill.
- **Model R&D:** evaluate existing models first; later fine-tune an open model on licensed, reviewed, task-specific data if evaluation demonstrates a real benefit.

## Critical separation

The language model is not the video editor. It returns a validated edit decision list (EDL) or invokes typed tools. The media engine is the only component allowed to claim that a render/export completed, and it must verify the output file.

## Initial service boundaries

1. Identity and project API
2. Media asset metadata API (media bytes stay on device by default)
3. Editing project and EDL API
4. Render job API
5. AI orchestration and provider adapter API
6. Tool/MCP adapter for ChatGPT and Claude

## Privacy and offline behavior

- Import, preview, project editing, and local persistence should work without an account or network.
- No video, audio, transcript, thumbnail, or project content is uploaded to an AI provider without an explicit, informed user action.
- Prefer sending a text-only edit brief or low-detail metadata when sufficient.
- API keys and provider credentials belong on the server, never in the Android app or browser bundle.
- Offer a clear local-only mode and explain which features require connectivity.
- Provide deletion and retention controls for any server-side project data.

## AI command contract

The AI layer should produce a typed command proposal, not arbitrary shell commands or arbitrary file paths. Initial operation families:

- inspect_project
- list_assets
- create_edit_plan
- set_clip_range
- reorder_clips
- add_caption
- set_audio_gain
- request_render

Every operation must be checked against the project schema, supported engine capabilities, and user authorization. Destructive operations require confirmation.

## Phased delivery

### Phase 1 — foundations
- Document shared project and EDL contracts.
- Add a provider-neutral AI gateway boundary.
- Keep the current Flutter app operational and offline.
- Establish a web workspace shell and integration specifications.

### Phase 2 — real editing
- Select and validate a maintained Android-compatible media engine.
- Implement trim, concatenation, audio, text overlays, and MP4 export.
- Add render progress, cancellation, and output verification.
- Add equivalent web capabilities where browser support permits.

### Phase 3 — integrations
- Publish typed MCP tools for project inspection and editing.
- Connect ChatGPT and Claude through their supported integration surfaces.
- Keep skills as instructions, while tools perform actual actions.

### Phase 4 — custom model
- Build a licensed dataset of editing requests, structured EDLs, and reviewed outcomes.
- Create evaluation tests for instruction following, EDL validity, Arabic/English handling, and tool safety.
- Compare prompting, retrieval, and fine-tuning before choosing a model.
- Fine-tune only when measurable evaluation gains justify the cost.
- Deploy behind the same AI gateway so Android, web, ChatGPT, and Claude do not depend on one model vendor.

## Non-goals for the first milestone

- Training a foundation model from scratch.
- Uploading user videos by default.
- Claiming real-time cloud rendering before infrastructure exists.
- Claiming a ChatGPT or Claude integration is published before its app/tool registration and end-to-end test are complete.
