"""TEa.G3 local backend foundation. Not a hosted production service."""
from __future__ import annotations
import json
import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
try:
    from .ai_director import DirectorChatInput, DirectorUnavailable, chat as director_chat, model_status
except ImportError:  # supports `uvicorn app:app` from the backend directory
    from ai_director import DirectorChatInput, DirectorUnavailable, chat as director_chat, model_status

ROOT = Path(__file__).resolve().parent
DB_PATH = Path(os.getenv("TEAG3_DATABASE_PATH", str(ROOT / "data" / "teag3.db")))
SCHEMA_PATH = ROOT / "schema.sql"
app = FastAPI(title="TEa.G3-studio API", version="0.2.0")

class ProjectInput(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    description: str = Field(default="", max_length=2000)
    language: str = Field(default="ar", pattern="^(ar|en|auto)$")

class PlanInput(BaseModel):
    brief: str = Field(min_length=1, max_length=10000)

@contextmanager
def db():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys=ON")
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

def initialize():
    with db() as conn:
        conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))

def build_plan(project_id: str, brief: str):
    text = brief.lower()
    if any(word in text for word in ("9:16", "ريلز", "reels", "تيك توك", "tiktok", "عمودي")):
        aspect, width, height = "vertical", 1080, 1920
    elif any(word in text for word in ("1:1", "مربع", "square")):
        aspect, width, height = "square", 1080, 1080
    elif "4:5" in text:
        aspect, width, height = "portrait", 1080, 1350
    elif "4k" in text:
        aspect, width, height = "4k", 3840, 2160
    else:
        aspect, width, height = "landscape", 1920, 1080
    arabic = any("\u0600" <= char <= "\u06ff" for char in brief)
    steps = (["تحليل الملفات المضافة", "بناء تسلسل المشاهد والمسارات", "إعداد النصوص العربية والإنجليزية والانتقالات", "فحص توافق التصدير قبل التنفيذ"] if arabic else ["Inspect imported assets", "Build scene order and timeline tracks", "Prepare bilingual captions and transitions", "Validate export support before execution"])
    warning = "خطة أولية فقط؛ لم يتم إنشاء أو تصدير أي صورة أو فيديو." if arabic else "Draft plan only; no image or video has been generated or exported."
    return {
        "schemaVersion": "1.0", "projectId": project_id, "status": "draft",
        "profile": {"aspect": aspect, "width": width, "height": height, "frameRate": 30, "container": "mp4"},
        "timeline": [], "notes": [brief, *steps, warning]
    }

@app.on_event("startup")
def on_startup():
    initialize()

@app.get("/health")
def health():
    return {"status": "ok", "database": "sqlite", "mode": "local-development"}

@app.get("/v1/capabilities")
def capabilities():
    return {"operations": ["project.create", "project.list", "project.read", "plan.create", "ai.status", "ai.chat"], "database": "sqlite", "imageGeneration": False, "videoGeneration": False, "rendering": False, "note": "Generation and rendering are not yet connected."}

@app.post("/v1/projects", status_code=201)
def create_project(payload: ProjectInput):
    project_id = str(uuid4())
    now = datetime.now(timezone.utc).isoformat()
    with db() as conn:
        conn.execute("INSERT INTO projects(id,name,description,language,created_at,updated_at) VALUES(?,?,?,?,?,?)", (project_id, payload.name, payload.description, payload.language, now, now))
    return {"id": project_id, "name": payload.name, "description": payload.description, "language": payload.language, "createdAt": now, "updatedAt": now}

@app.get("/v1/projects")
def list_projects():
    with db() as conn:
        rows = conn.execute("SELECT id,name,description,language,created_at,updated_at FROM projects ORDER BY updated_at DESC").fetchall()
    return {"items": [dict(row) for row in rows]}

@app.get("/v1/projects/{project_id}")
def get_project(project_id: str):
    with db() as conn:
        row = conn.execute("SELECT * FROM projects WHERE id=?", (project_id,)).fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Project not found")
        plans = conn.execute("SELECT id,status,brief,plan_json,created_at FROM edit_plans WHERE project_id=? ORDER BY created_at DESC", (project_id,)).fetchall()
    result = dict(row)
    result["plans"] = [{"id": p["id"], "status": p["status"], "brief": p["brief"], "plan": json.loads(p["plan_json"]), "createdAt": p["created_at"]} for p in plans]
    return result

@app.post("/v1/projects/{project_id}/edit-plans", status_code=201)
def create_plan(project_id: str, payload: PlanInput):
    with db() as conn:
        exists = conn.execute("SELECT 1 FROM projects WHERE id=?", (project_id,)).fetchone()
        if exists is None:
            raise HTTPException(status_code=404, detail="Project not found")
    plan = build_plan(project_id, payload.brief)
    plan_id = str(uuid4())
    now = datetime.now(timezone.utc).isoformat()
    with db() as conn:
        conn.execute("INSERT INTO edit_plans(id,project_id,status,brief,plan_json,created_at) VALUES(?,?,?,?,?,?)", (plan_id, project_id, "draft", payload.brief, json.dumps(plan, ensure_ascii=False), now))
        conn.execute("UPDATE projects SET updated_at=? WHERE id=?", (now, project_id))
    return {"id": plan_id, "status": "draft", "plan": plan, "createdAt": now}


@app.get("/v1/ai/status")
async def ai_status():
    """Report whether the optional local GPT-OSS runtime is enabled and reachable."""
    return await model_status()


@app.post("/v1/ai/chat")
async def ai_chat(payload: DirectorChatInput):
    """Send a text brief to the explicitly enabled local GPT-OSS model."""
    try:
        return await director_chat(payload.message, payload.language)
    except DirectorUnavailable as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
