from __future__ import annotations

from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="MODAL_GENAI_", env_file=".env", extra="ignore")

    host: str = "127.0.0.1"
    port: int = 8080
    reload: bool = False
    api_key: str | None = None
    model_config_path: Path = Field(default=Path("config/models.yaml"), alias="MODAL_GENAI_MODEL_CONFIG")

    # When true, providers that would otherwise dispatch to Modal return
    # deterministic stub responses instead. Lets the gateway and its test
    # suite run with no Modal client, token, or GPU available.
    stub_mode: bool = False

    # Modal workspace + environment used to resolve deployed apps when the
    # gateway dispatches via `modal.Cls.from_name` / proxies to vLLM URLs.
    modal_environment: str | None = None
