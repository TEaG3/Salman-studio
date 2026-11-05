# TEa.G3 project database model

The first database uses SQLite for local development. PostgreSQL can be adopted for hosted multi-user operation while retaining the same entity model.

## Entities

- `projects`: project identity, description, language and timestamps.
- `assets`: imported video, image, audio, fonts and technical metadata.
- `tracks`: independent video, audio, text, graphics and effects layers.
- `clips`: source asset, source in/out points, timeline position, speed, volume and transform settings.
- `captions`: Unicode text, language, RTL/LTR direction, timing and style.
- `effects`: effect type and parameter JSON, optionally scoped to a clip.
- `transitions`: ordered clip pair, transition type, duration and parameters.
- `edit_plans`: original natural-language brief and structured plan.
- `render_jobs`: job status, progress, export profile, output reference and errors.
- `ai_sessions`: provider/model provenance.
- `provider_usage`: task-level usage and estimated cost for transparent quotas.

## Integrity and privacy

- Child records are tied to a project with foreign keys and cascade deletion.
- Clip source-out must be later than source-in; caption end must be later than caption start.
- A render job is complete only after a renderer verifies the output file.
- Timestamps use UTC ISO-8601; text is UTF-8 with explicit language and direction.
- Media stays local by default. Provider credentials never belong in project records or mobile code.

The executable schema is `backend/schema.sql`.
