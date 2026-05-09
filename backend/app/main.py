import os
from contextlib import asynccontextmanager
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

_backend_env = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(_backend_env)

from app.config import get_gemini_config_debug

from app.routers import vision as vision_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: e.g. init DB clients
    yield
    # Shutdown


app = FastAPI(
    title="project_ai API",
    description="Gemini + image pipeline for the Flutter app",
    version="0.1.0",
    lifespan=lifespan,
)

_origins = os.getenv("CORS_ORIGINS", "").strip()
if _origins:
    _allow_origins = [o.strip() for o in _origins.split(",") if o.strip()]
else:
    # Default permissive for local Flutter / emulators (browser CORS only).
    _allow_origins = ["*"]

_use_wildcard = len(_allow_origins) == 1 and _allow_origins[0] == "*"

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allow_origins,
    allow_credentials=not _use_wildcard,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/api/v1/vision/debug-config", tags=["vision"])
def vision_debug_config():
    """Which .env path and GEMINI_MODEL the server uses (no secret values). Registered on app so Swagger always lists it."""
    return get_gemini_config_debug()


app.include_router(vision_router.router)
