from __future__ import annotations

import os
from pathlib import Path
from typing import Any, Literal

import yaml
from pydantic import BaseModel, ConfigDict, Field


class ProviderConfig(BaseModel):
    """Configuration for one routing backend.

    Provider kinds for the Modal/NVIDIA construct:

    - ``stub``               deterministic in-process responses (no Modal).
    - ``vllm``               proxy OpenAI traffic to a deployed vLLM web app
                             (native ``/v1/chat/completions`` etc.). Set
                             ``base_url`` to the ``*.modal.run`` URL, or
                             ``app_name`` + ``endpoint`` to resolve it.
    - ``openai_compatible``  proxy to any OpenAI-compatible ``base_url``.
    - ``modal_cls``          dispatch to a deployed Modal class method via
                             ``modal.Cls.from_name(app_name, cls_name)``. Used
                             for media models that have no OpenAI standard
                             (image / tts / stt / music / video / 3d / sfx).
    """

    model_config = ConfigDict(extra="allow")

    kind: Literal["stub", "vllm", "openai_compatible", "modal_cls"] = "stub"
    lifecycle: Literal["scale_to_zero", "persistent", "external", "stub"] = "scale_to_zero"
    idle_timeout_seconds: float = 300.0
    max_concurrency: int = 8
    timeout_seconds: float = 600.0

    # Proxy backends (vllm / openai_compatible)
    base_url: str | None = None
    api_key: str | None = None

    # Modal resolution (vllm via app lookup, and modal_cls dispatch)
    app_name: str | None = None
    cls_name: str | None = None
    endpoint: str | None = None  # web endpoint label for vllm app URL lookup
    method: str | None = None  # method name on the Modal class to call

    # Free-form backend hints (gpu tier, repo id, default voice, etc.). These
    # are passed through to the Modal class at call time and surfaced in status.
    gpu: str | None = None
    repo: str | None = None
    default_voice: str | None = None
    options: dict[str, Any] = Field(default_factory=dict)


class ModelConfig(BaseModel):
    id: str
    type: Literal[
        "chat",
        "completion",
        "tts",
        "stt",
        "audio",
        "image",
        "video",
        "3d",
        "ocr",
        "embedding",
        "vision",
        "other",
    ]
    provider: str
    capabilities: list[str] = Field(default_factory=list)
    metadata: dict[str, Any] = Field(default_factory=dict)


class GatewayConfig(BaseModel):
    models: list[ModelConfig] = Field(default_factory=list)
    providers: dict[str, ProviderConfig] = Field(default_factory=dict)


def load_config(path: Path) -> GatewayConfig:
    if not Path(path).exists():
        return GatewayConfig(
            models=[
                ModelConfig(id="qwen3.6", type="chat", provider="stub", capabilities=["chat", "text"]),
                ModelConfig(id="local-image", type="image", provider="stub", capabilities=["images.generate"]),
            ],
            providers={"stub": ProviderConfig(kind="stub")},
        )

    # Expand ${ENV_VAR} references (e.g. api keys, deployed URLs) from the
    # environment before parsing. Unset vars are left as-is.
    text = os.path.expandvars(Path(path).read_text())
    raw = yaml.safe_load(text) or {}
    return GatewayConfig.model_validate(raw)
