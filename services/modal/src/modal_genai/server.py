from __future__ import annotations

from fastapi import Depends, FastAPI, File, Form, Header, HTTPException, UploadFile

from modal_genai.config import load_config
from modal_genai.openai_schemas import (
    AudioGenerationRequest,
    ChatCompletionRequest,
    CompletionRequest,
    EmbeddingRequest,
    ImageGenerationRequest,
    Model3DGenerationRequest,
    ModelList,
    ModelObject,
    OcrRequest,
    SpeechRequest,
    TaskObject,
    VideoGenerationRequest,
)
from modal_genai.providers import ProviderRegistry
from modal_genai.settings import Settings


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or Settings()
    config = load_config(settings.model_config_path)
    registry = ProviderRegistry(config, settings)

    app = FastAPI(title="Modal GenAI Gateway", version="0.1.0")
    app.state.settings = settings
    app.state.config = config
    app.state.registry = registry
    app.state.tasks = {}

    async def require_auth(authorization: str | None = Header(default=None)) -> None:
        if not settings.api_key:
            return
        if authorization != f"Bearer {settings.api_key}":
            raise HTTPException(status_code=401, detail="Invalid or missing API key")

    @app.get("/health")
    async def health() -> dict[str, object]:
        return {"status": "ok", "models": len(config.models), "stub_mode": settings.stub_mode}

    @app.get("/v1/models", dependencies=[Depends(require_auth)])
    async def models() -> ModelList:
        return ModelList(data=[ModelObject(id=model.id) for model in config.models])

    @app.get("/v1/models/{model_id}/status", dependencies=[Depends(require_auth)])
    async def model_status(model_id: str):
        return registry.model_status(model_id)

    @app.post("/v1/models/{model_id}/unload", dependencies=[Depends(require_auth)])
    async def unload_model(model_id: str):
        return await registry.unload_model(model_id)

    @app.get("/v1/providers/status", dependencies=[Depends(require_auth)])
    async def provider_status():
        return registry.provider_statuses()

    @app.post("/v1/providers/{provider_name}/unload", dependencies=[Depends(require_auth)])
    async def unload_provider(provider_name: str):
        return await registry.unload_provider(provider_name)

    @app.post("/v1/chat/completions", dependencies=[Depends(require_auth)])
    async def chat_completions(request: ChatCompletionRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.chat_completions(request)

    @app.post("/v1/completions", dependencies=[Depends(require_auth)])
    async def completions(request: CompletionRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.completions(request)

    @app.post("/v1/audio/speech", dependencies=[Depends(require_auth)])
    async def audio_speech(request: SpeechRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.audio_speech(request)

    @app.post("/v1/audio/transcriptions", dependencies=[Depends(require_auth)])
    async def audio_transcriptions(model: str = Form(...), file: UploadFile = File(...)):
        provider = registry.provider_for_model(model)
        content = await file.read()
        async with provider.use():
            return await provider.audio_transcriptions(model, file.filename or "audio", content)

    @app.post("/v1/audio/translations", dependencies=[Depends(require_auth)])
    async def audio_translations(model: str = Form(...), file: UploadFile = File(...)):
        provider = registry.provider_for_model(model)
        content = await file.read()
        async with provider.use():
            return await provider.audio_translations(model, file.filename or "audio", content)

    @app.post("/v1/audio/generations", dependencies=[Depends(require_auth)])
    async def audio_generations(request: AudioGenerationRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.audio_generations(request)

    @app.post("/v1/images/generations", dependencies=[Depends(require_auth)])
    async def image_generations(request: ImageGenerationRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.image_generations(request)

    @app.post("/v1/video/generations", dependencies=[Depends(require_auth)])
    async def video_generations(request: VideoGenerationRequest) -> TaskObject:
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            task = TaskObject.model_validate(await provider.video_generations(request))
        app.state.tasks[task.id] = task
        return task

    @app.post("/v1/3d/generations", dependencies=[Depends(require_auth)])
    async def model3d_generations(request: Model3DGenerationRequest) -> TaskObject:
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            task = TaskObject.model_validate(await provider.model3d_generations(request))
        app.state.tasks[task.id] = task
        return task

    @app.get("/v1/tasks/{task_id}", dependencies=[Depends(require_auth)])
    async def tasks(task_id: str) -> TaskObject:
        task = app.state.tasks.get(task_id)
        if task is None:
            raise HTTPException(status_code=404, detail=f"Unknown task: {task_id}")
        return task

    @app.post("/v1/ocr", dependencies=[Depends(require_auth)])
    async def ocr(request: OcrRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.ocr(request)

    @app.post("/v1/embeddings", dependencies=[Depends(require_auth)])
    async def embeddings(request: EmbeddingRequest):
        provider = registry.provider_for_model(request.model)
        async with provider.use():
            return await provider.embeddings(request)

    return app
