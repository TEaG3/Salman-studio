# TEa.G3 backend foundation

This is a local-development API, not a hosted production service.

## Run locally

Use Python 3.11 or newer:

```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload
```

Open `http://127.0.0.1:8000/docs` for the API. SQLite is created at `backend/data/teag3.db`; set `TEAG3_DATABASE_PATH` to change it.

## Current endpoints

- `GET /health`
- `GET /v1/capabilities`
- `POST /v1/projects`
- `GET /v1/projects`
- `GET /v1/projects/{projectId}`
- `POST /v1/projects/{projectId}/edit-plans`

The planner creates a deterministic Arabic/English draft with an output profile. It does not generate images or videos and does not render files. The API explicitly reports those capabilities as unavailable.

## Security

This starter has no authentication or multi-user authorization. Bind it to localhost only. Do not expose it publicly or store provider secrets in this repository. Add authentication, authorization, rate limiting, CORS restrictions, secure file storage, retention controls, and production database backups before deployment.
