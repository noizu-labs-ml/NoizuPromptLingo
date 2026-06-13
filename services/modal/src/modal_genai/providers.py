from __future__ import annotations

import asyncio
import base64
import time
from contextlib import asynccontextmanager
from typing import Any
from uuid import uuid4

import httpx
from fastapi import HTTPException, Response

from modal_genai.config import GatewayConfig, ModelConfig, ProviderConfig
from modal_genai.openai_schemas import (
    AudioGenerationRequest,
    ChatCompletionRequest,
    CompletionRequest,
    EmbeddingRequest,
    ImageGenerationRequest,
    Model3DGenerationRequest,
    OcrRequest,
    SpeechRequest,
    VideoGenerationRequest,
)
from modal_genai.settings import Settings

_MEDIA_TYPES = {
    "mp3": "audio/mpeg",
    "wav": "audio/wav",
    "opus": "audio/opus",
    "flac": "audio/flac",
}


def _media_type(format_name: str) -> str:
    return _MEDIA_TYPES.get(format_name, "application/octet-stream")


def _not_supported(provider_kind: str, capability: str) -> HTTPException:
    return HTTPException(
        status_code=501,
        detail=f"Provider kind '{provider_kind}' does not support {capability}",
    )


class Provider:
    """Base provider. Every capability defaults to HTTP 501 so a backend only
    needs to override what it actually serves."""

    def __init__(self, config: ProviderConfig, settings: Settings):
        self.config = config
        self.settings = settings
        self.active_requests = 0
        self.last_used_at: float | None = None
        self.last_error: str | None = None
        self._semaphore = asyncio.Semaphore(max(1, config.max_concurrency))

    @asynccontextmanager
    async def use(self):
        async with self._semaphore:
            self.active_requests += 1
            self.last_used_at = time.time()
            try:
                yield self
                self.last_error = None
            except Exception as exc:  # noqa: BLE001 - surface to caller, record for status
                self.last_error = str(exc)
                raise
            finally:
                self.active_requests -= 1
                self.last_used_at = time.time()

    def lifecycle_state(self) -> str:
        if self.active_requests:
            return "running"
        return {
            "persistent": "idle",
            "external": "external",
            "stub": "stub",
        }.get(self.config.lifecycle, "cold")

    def status(self) -> dict[str, Any]:
        return {
            "kind": self.config.kind,
            "lifecycle": self.config.lifecycle,
            "state": self.lifecycle_state(),
            "active_requests": self.active_requests,
            "last_used_at": int(self.last_used_at) if self.last_used_at else None,
            "max_concurrency": self.config.max_concurrency,
            "gpu": self.config.gpu,
            "app_name": self.config.app_name,
            "last_error": self.last_error,
        }

    async def unload(self) -> dict[str, Any]:
        # Modal apps scale to zero on their own idle window; there is nothing to
        # actively kill from the gateway. Report the intent for symmetry with
        # the Apple Silicon construct.
        if self.active_requests:
            raise HTTPException(status_code=409, detail="Provider is currently handling a request")
        return {
            "state": self.lifecycle_state(),
            "note": "Modal backends scale to zero automatically after their idle window.",
        }

    # --- capabilities (override what you serve) ---------------------------
    async def chat_completions(self, request: ChatCompletionRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "chat completions")

    async def completions(self, request: CompletionRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "completions")

    async def audio_speech(self, request: SpeechRequest) -> Response:
        raise _not_supported(self.config.kind, "audio speech")

    async def audio_transcriptions(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "audio transcriptions")

    async def audio_translations(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "audio translations")

    async def audio_generations(self, request: AudioGenerationRequest) -> Response:
        raise _not_supported(self.config.kind, "audio generations")

    async def image_generations(self, request: ImageGenerationRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "image generations")

    async def video_generations(self, request: VideoGenerationRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "video generations")

    async def model3d_generations(self, request: Model3DGenerationRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "3d generations")

    async def ocr(self, request: OcrRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "ocr")

    async def embeddings(self, request: EmbeddingRequest) -> dict[str, Any]:
        raise _not_supported(self.config.kind, "embeddings")


class StubProvider(Provider):
    """Deterministic responses so clients can integrate before backends deploy."""

    def lifecycle_state(self) -> str:
        return "stub"

    async def chat_completions(self, request: ChatCompletionRequest) -> dict[str, Any]:
        content = "Stub chat provider. Deploy the Modal vLLM backend for real inference."
        return {
            "id": f"chatcmpl-{uuid4().hex}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": request.model,
            "choices": [{"index": 0, "message": {"role": "assistant", "content": content}, "finish_reason": "stop"}],
            "usage": {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0},
        }

    async def completions(self, request: CompletionRequest) -> dict[str, Any]:
        return {
            "id": f"cmpl-{uuid4().hex}",
            "object": "text_completion",
            "created": int(time.time()),
            "model": request.model,
            "choices": [{"index": 0, "text": "Stub completion provider.", "finish_reason": "stop"}],
            "usage": {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0},
        }

    async def audio_speech(self, request: SpeechRequest) -> Response:
        payload = f"stub speech model={request.model} voice={request.voice}\n".encode()
        return Response(content=payload, media_type=_media_type(request.response_format))

    async def audio_transcriptions(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        return {"text": f"Stub transcription for {filename} using {model} ({len(content)} bytes)."}

    async def audio_translations(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        return {"text": f"Stub translation for {filename} using {model} ({len(content)} bytes)."}

    async def audio_generations(self, request: AudioGenerationRequest) -> Response:
        payload = f"stub generated audio model={request.model} prompt={request.prompt}\n".encode()
        return Response(content=payload, media_type=_media_type(request.response_format))

    async def image_generations(self, request: ImageGenerationRequest) -> dict[str, Any]:
        png_1x1 = (
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        )
        return {
            "created": int(time.time()),
            "data": [{"b64_json": png_1x1, "revised_prompt": f"Stub image for: {request.prompt}"} for _ in range(request.n)],
        }

    async def video_generations(self, request: VideoGenerationRequest) -> dict[str, Any]:
        return {
            "id": f"task-{uuid4().hex}",
            "object": "task",
            "status": "completed",
            "model": request.model,
            "kind": "video.generation",
            "created": int(time.time()),
            "output": {"message": "Stub video provider.", "prompt": request.prompt, "size": request.size},
        }

    async def model3d_generations(self, request: Model3DGenerationRequest) -> dict[str, Any]:
        return {
            "id": f"task-{uuid4().hex}",
            "object": "task",
            "status": "completed",
            "model": request.model,
            "kind": "3d.generation",
            "created": int(time.time()),
            "output": {
                "message": "Stub 3D provider.",
                "prompt": request.prompt,
                "image": request.image,
                "response_format": request.response_format,
            },
        }

    async def ocr(self, request: OcrRequest) -> dict[str, Any]:
        return {"text": "Stub OCR provider.", "model": request.model}

    async def embeddings(self, request: EmbeddingRequest) -> dict[str, Any]:
        inputs = request.input if isinstance(request.input, list) else [request.input]
        dims = request.dimensions or 8
        return {
            "object": "list",
            "model": request.model,
            "data": [{"object": "embedding", "index": i, "embedding": [0.0] * dims} for i, _ in enumerate(inputs)],
            "usage": {"prompt_tokens": 0, "total_tokens": 0},
        }


class OpenAICompatibleProvider(Provider):
    """Proxy LLM/text/embedding traffic to any OpenAI-compatible ``base_url``.

    This is the provider used for the Modal vLLM backends, whose ``vllm serve``
    process already exposes a literal ``/v1/...`` surface."""

    def lifecycle_state(self) -> str:
        return "running" if self.active_requests else "external"

    def _headers(self) -> dict[str, str]:
        headers = {}
        if self.config.api_key:
            headers["Authorization"] = f"Bearer {self.config.api_key}"
        return headers

    def _url(self, path: str) -> str:
        if not self.config.base_url:
            raise HTTPException(status_code=500, detail="Provider base_url is required for proxy dispatch")
        return f"{self.config.base_url.rstrip('/')}/{path.lstrip('/')}"

    async def _post_json(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        async with httpx.AsyncClient(timeout=self.config.timeout_seconds) as client:
            response = await client.post(self._url(path), json=payload, headers=self._headers())
        if response.status_code >= 400:
            raise HTTPException(status_code=response.status_code, detail=response.text)
        return response.json()

    async def chat_completions(self, request: ChatCompletionRequest) -> dict[str, Any]:
        return await self._post_json("/chat/completions", request.model_dump(exclude_none=True))

    async def completions(self, request: CompletionRequest) -> dict[str, Any]:
        return await self._post_json("/completions", request.model_dump(exclude_none=True))

    async def embeddings(self, request: EmbeddingRequest) -> dict[str, Any]:
        return await self._post_json("/embeddings", request.model_dump(exclude_none=True))

    async def audio_speech(self, request: SpeechRequest) -> Response:
        async with httpx.AsyncClient(timeout=self.config.timeout_seconds) as client:
            response = await client.post(self._url("/audio/speech"), json=request.model_dump(exclude_none=True), headers=self._headers())
        if response.status_code >= 400:
            raise HTTPException(status_code=response.status_code, detail=response.text)
        return Response(content=response.content, media_type=response.headers.get("content-type"))

    async def _post_audio_file(self, path: str, model: str, filename: str, content: bytes) -> dict[str, Any]:
        files = {"file": (filename, content)}
        data = {"model": model}
        async with httpx.AsyncClient(timeout=self.config.timeout_seconds) as client:
            response = await client.post(self._url(path), data=data, files=files, headers=self._headers())
        if response.status_code >= 400:
            raise HTTPException(status_code=response.status_code, detail=response.text)
        return response.json()

    async def audio_transcriptions(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        return await self._post_audio_file("/audio/transcriptions", model, filename, content)

    async def audio_translations(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        return await self._post_audio_file("/audio/translations", model, filename, content)


class VllmProvider(OpenAICompatibleProvider):
    """vLLM on Modal. Identical proxy behaviour to OpenAICompatibleProvider but a
    distinct kind so status/telemetry can distinguish vLLM GPU backends."""


class ModalClsProvider(Provider):
    """Dispatch to a deployed Modal class' ``infer`` method.

    The Modal class contract is a single coroutine-friendly method::

        infer(kind: str, payload: dict) -> dict

    returning a normalized dict that this provider converts into the matching
    OpenAI response object. Used for media modalities with no OpenAI standard:
    image, tts, stt, music, video, 3d, sfx, ocr.

    When ``settings.stub_mode`` is set, or the ``modal`` client is unavailable,
    dispatch falls back to :class:`StubProvider` so the gateway and tests run
    with no Modal token or GPU.
    """

    def __init__(self, config: ProviderConfig, settings: Settings):
        super().__init__(config, settings)
        self._stub = StubProvider(config, settings)
        self._cls_handle = None

    def _resolve_cls(self):
        if self._cls_handle is not None:
            return self._cls_handle
        if not self.config.app_name or not self.config.cls_name:
            raise HTTPException(status_code=500, detail="modal_cls provider requires app_name and cls_name")
        try:
            import modal  # imported lazily; only needed for live dispatch
        except ImportError as exc:  # pragma: no cover - exercised only without modal
            raise HTTPException(
                status_code=503,
                detail="Modal client not installed. `uv sync --extra modal` or set MODAL_GENAI_STUB_MODE=1.",
            ) from exc
        cls = modal.Cls.from_name(self.config.app_name, self.config.cls_name)
        self._cls_handle = cls
        return cls

    async def _infer(self, kind: str, payload: dict[str, Any]) -> dict[str, Any]:
        cls = self._resolve_cls()
        instance = cls()
        method = self.config.method or "infer"
        fn = getattr(instance, method)
        merged = {**self.config.options, **payload}
        try:
            return await fn.remote.aio(kind, merged)
        except HTTPException:
            raise
        except Exception as exc:  # noqa: BLE001 - turn backend errors into 502s
            raise HTTPException(status_code=502, detail=f"Modal dispatch failed: {exc}") from exc

    def _use_stub(self) -> bool:
        if self.settings.stub_mode:
            return True
        try:
            import modal  # noqa: F401
        except ImportError:
            return True
        return False

    async def image_generations(self, request: ImageGenerationRequest) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.image_generations(request)
        result = await self._infer("image", request.model_dump(exclude_none=True))
        images = result.get("images") or result.get("data") or []
        created = int(time.time())
        data = []
        for item in images:
            if "b64_json" in item:
                data.append({"b64_json": item["b64_json"], "revised_prompt": item.get("revised_prompt", request.prompt)})
            elif "url" in item:
                data.append({"url": item["url"], "revised_prompt": item.get("revised_prompt", request.prompt)})
        return {"created": created, "data": data}

    async def audio_speech(self, request: SpeechRequest) -> Response:
        if self._use_stub():
            return await self._stub.audio_speech(request)
        result = await self._infer("speech", request.model_dump(exclude_none=True))
        audio = base64.b64decode(result["audio_base64"])
        return Response(content=audio, media_type=result.get("media_type", _media_type(request.response_format)))

    async def audio_generations(self, request: AudioGenerationRequest) -> Response:
        if self._use_stub():
            return await self._stub.audio_generations(request)
        result = await self._infer("audio", request.model_dump(exclude_none=True))
        audio = base64.b64decode(result["audio_base64"])
        return Response(content=audio, media_type=result.get("media_type", _media_type(request.response_format)))

    async def audio_transcriptions(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.audio_transcriptions(model, filename, content)
        payload = {"model": model, "filename": filename, "audio_base64": base64.b64encode(content).decode(), "task": "transcribe"}
        result = await self._infer("transcribe", payload)
        return {"text": result.get("text", ""), "segments": result.get("segments", [])}

    async def audio_translations(self, model: str, filename: str, content: bytes) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.audio_translations(model, filename, content)
        payload = {"model": model, "filename": filename, "audio_base64": base64.b64encode(content).decode(), "task": "translate"}
        result = await self._infer("translate", payload)
        return {"text": result.get("text", "")}

    async def video_generations(self, request: VideoGenerationRequest) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.video_generations(request)
        result = await self._infer("video", request.model_dump(exclude_none=True))
        return self._as_task(request.model, "video.generation", result)

    async def model3d_generations(self, request: Model3DGenerationRequest) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.model3d_generations(request)
        result = await self._infer("3d", request.model_dump(exclude_none=True))
        return self._as_task(request.model, "3d.generation", result)

    async def ocr(self, request: OcrRequest) -> dict[str, Any]:
        if self._use_stub():
            return await self._stub.ocr(request)
        return await self._infer("ocr", request.model_dump(exclude_none=True))

    def _as_task(self, model: str, kind: str, result: dict[str, Any]) -> dict[str, Any]:
        return {
            "id": result.get("id", f"task-{uuid4().hex}"),
            "object": "task",
            "status": result.get("status", "completed"),
            "model": model,
            "kind": kind,
            "created": int(time.time()),
            "output": result.get("output", result),
            "error": result.get("error"),
        }


class ProviderRegistry:
    def __init__(self, config: GatewayConfig, settings: Settings):
        self.config = config
        self.settings = settings
        self.providers = {name: self._build(provider) for name, provider in config.providers.items()}

    def _build(self, config: ProviderConfig) -> Provider:
        if self.settings.stub_mode:
            # Fully offline: every backend returns deterministic stubs, with no
            # Modal token, vLLM URL, or GPU required. Used by the test suite.
            return StubProvider(config, self.settings)
        return {
            "stub": StubProvider,
            "vllm": VllmProvider,
            "openai_compatible": OpenAICompatibleProvider,
            "modal_cls": ModalClsProvider,
        }.get(config.kind, StubProvider)(config, self.settings)

    def model(self, model_id: str) -> ModelConfig:
        for model in self.config.models:
            if model.id == model_id:
                return model
        raise HTTPException(status_code=404, detail=f"Unknown model: {model_id}")

    def provider_for_model(self, model_id: str) -> Provider:
        model = self.model(model_id)
        provider = self.providers.get(model.provider)
        if provider is None:
            raise HTTPException(status_code=500, detail=f"Provider is not configured: {model.provider}")
        return provider

    def provider_name_for_model(self, model_id: str) -> str:
        return self.model(model_id).provider

    def model_status(self, model_id: str) -> dict[str, Any]:
        model = self.model(model_id)
        provider = self.provider_for_model(model_id)
        return {"model": model.id, "type": model.type, "provider": model.provider, **provider.status()}

    def provider_statuses(self) -> dict[str, Any]:
        return {name: provider.status() for name, provider in self.providers.items()}

    async def unload_model(self, model_id: str) -> dict[str, Any]:
        provider = self.provider_for_model(model_id)
        return {"model": model_id, "provider": self.provider_name_for_model(model_id), **await provider.unload()}

    async def unload_provider(self, provider_name: str) -> dict[str, Any]:
        provider = self.providers.get(provider_name)
        if provider is None:
            raise HTTPException(status_code=404, detail=f"Unknown provider: {provider_name}")
        return {"provider": provider_name, **await provider.unload()}
