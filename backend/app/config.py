import os
from pathlib import Path

from dotenv import dotenv_values, load_dotenv

_BACKEND_ROOT = Path(__file__).resolve().parent.parent
_ENV_PATH = _BACKEND_ROOT / ".env"

load_dotenv(_ENV_PATH)


def _from_backend_env(name: str) -> str | None:
    if not _ENV_PATH.is_file():
        return None
    raw = dotenv_values(_ENV_PATH).get(name)
    if raw is None:
        return None
    s = str(raw).strip().strip("\ufeff").strip('"').strip("'")
    return s or None


def _sanitize_model_id(name: str) -> str:
    n = (name or "").strip().strip("\ufeff").strip('"').strip("'")
    if n.startswith("models/"):
        n = n.split("/", 1)[-1]
    return n


def get_gemini_api_key() -> str:
    # 不使用 lru_cache：.env 更新後不需重開程序即可讀到新金鑰（仍建議重啟 uvicorn）
    v = _from_backend_env("GEMINI_API_KEY")
    if v:
        return v
    return os.getenv("GEMINI_API_KEY", "").strip()


def get_gemini_model() -> str:
    """Resolve model id. backend/.env wins over OS env.

    Many free-tier keys show limit:0 for ``gemini-2.0-flash``; we remap that to ``gemini-2.5-flash``
    unless ``GEMINI_ALLOW_2_0_FLASH=1`` is set (OS or backend/.env).
    """
    v = _from_backend_env("GEMINI_MODEL")
    if not v:
        v = os.getenv("GEMINI_MODEL", "").strip()
    if not v:
        v = "gemini-2.5-flash"
    v = _sanitize_model_id(v)
    allow_20 = (
        (_from_backend_env("GEMINI_ALLOW_2_0_FLASH") or "").lower() in ("1", "true", "yes")
        or (os.getenv("GEMINI_ALLOW_2_0_FLASH") or "").strip().lower() in ("1", "true", "yes")
    )
    if v == "gemini-2.0-flash" and not allow_20:
        return "gemini-2.5-flash"
    return v


def get_gemini_config_debug() -> dict:
    """Safe fields for troubleshooting (no secrets)."""
    raw_file = None
    if _ENV_PATH.is_file():
        raw_file = dotenv_values(_ENV_PATH).get("GEMINI_MODEL")
    return {
        "cwd": os.getcwd(),
        "backend_env_path": str(_ENV_PATH.resolve()),
        "env_file_exists": _ENV_PATH.is_file(),
        "gemini_model_raw_in_file": raw_file,
        "gemini_model_os": os.getenv("GEMINI_MODEL"),
        "gemini_model_resolved": get_gemini_model(),
        "allow_2_0_flash_flag": (_from_backend_env("GEMINI_ALLOW_2_0_FLASH") or os.getenv("GEMINI_ALLOW_2_0_FLASH") or ""),
        "api_key_from_file": bool(_from_backend_env("GEMINI_API_KEY")),
        "api_key_from_os": bool(os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")),
        "resolved_api_key_length": len(get_gemini_api_key()),
        "note": (
            "If gemini_model_resolved is 2.5.x but Google errors still mention gemini-2.0-flash, "
            "that text is often the free-tier quota bucket name, not the request line. "
            "Then you need a new API key/project, wait for reset, or enable billing."
        ),
    }
