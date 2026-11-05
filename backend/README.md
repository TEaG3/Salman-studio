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


## Optional local GPT-OSS 20B AI Director

The API includes an optional Ollama adapter for GPT-OSS 20B. It is disabled by default and accepts localhost Ollama endpoints only.

1. Install Ollama on the computer that will run the model, using the official instructions: https://ollama.com/download
2. Download the model in a terminal:

```bash
ollama pull gpt-oss:20b
```

3. Start Ollama (the desktop app normally runs the local service), then configure the backend environment before starting FastAPI.

macOS/Linux:
```bash
export TEAG3_AI_PROVIDER=gpt_oss_local
export TEAG3_OLLAMA_URL=http://127.0.0.1:11434
export TEAG3_OLLAMA_MODEL=gpt-oss:20b
uvicorn app:app --reload
```

Windows PowerShell:
```powershell
$env:TEAG3_AI_PROVIDER="gpt_oss_local"
$env:TEAG3_OLLAMA_URL="http://127.0.0.1:11434"
$env:TEAG3_OLLAMA_MODEL="gpt-oss:20b"
uvicorn app:app --reload
```

Check runtime status:
```bash
curl http://127.0.0.1:8000/v1/ai/status
```

Send a text-only test:
```bash
curl -X POST http://127.0.0.1:8000/v1/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"اكتب فكرة إعلان قصيرة بالعربية لمنتج عناية، مع تقسيمها إلى مشاهد.","language":"ar"}'
```

The chat endpoint returns text only. It does not generate image/video/audio files and does not call external media tools yet. When the provider is disabled or Ollama/model is unavailable, the endpoint returns HTTP 503 with an explicit reason. The rule-based planner remains available.

For tests, from this directory run `python -m pytest -q`. Tests mock Ollama responses; they verify adapter logic but do not replace a real inference test on the target computer. Do not expose this unauthenticated backend publicly.
