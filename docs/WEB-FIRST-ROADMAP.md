# TEa.G3 web-first rollout

## Decision
Deliver the responsive web workspace first for iPad 10 and desktop browsers. Keep the existing Flutter project intact; resume Android packaging after the web experience and API contracts stabilize.

## Current web foundation
- Static, RTL-first Arabic interface in `web/`.
- Responsive navigation for tablet and phone widths.
- Project creation saved in the current browser's localStorage.
- Local image/video/audio import and temporary browser preview using object URLs.
- A deterministic draft production checklist; it is not an LLM response.
- PWA manifest and service worker for an installable/offline app shell.
- GitHub Pages workflow validates the static app and deploys the `web/` directory.

## Deployment setup
1. In GitHub repository Settings → Pages, set Build and deployment source to **GitHub Actions**.
2. Push to `teag3-web-first-ipad` or run the workflow manually.
3. Open the Pages URL shown in the successful workflow deployment.

The workflow needs Pages deployment permissions. If repository Pages is disabled or policy blocks deployment, enable Pages with GitHub Actions in repository settings before rerunning.

## Important current limits
- Browser project records are local to that browser/device; there is no cross-device sync yet.
- Imported media is held as temporary browser object URLs. It is not uploaded or persistently stored.
- The existing FastAPI service is local-development-only: SQLite, no authentication, no PostgreSQL ownership model, no secure object storage. Do not expose it publicly.
- The web shell does not claim to generate images/video/audio. Generation, rendering, cloud sync, accounts and secure media storage remain unimplemented.
- The API URL setting is a placeholder for a later authenticated integration; no secrets belong in the browser.
- A PWA app-shell cache does not make project media or database data available offline.

## Next implementation gates
1. Validate the interface on iPad Safari and common desktop browsers.
2. Add durable local project/media persistence and export/import of project files.
3. Migrate backend persistence to PostgreSQL and implement authentication/authorization.
4. Add signed object-storage uploads and quotas.
5. Integrate actual image/video/audio engines only after confirming free compute and model licenses.
6. Reconnect the stable project schema to Flutter and produce the Android app.
