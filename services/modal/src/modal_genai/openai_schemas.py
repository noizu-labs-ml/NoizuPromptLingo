from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field


class ModelObject(BaseModel):
    id: str
    object: Literal["model"] = "model"
    created: int = 0
    owned_by: str = "modal-genai"


class ModelList(BaseModel):
    object: Literal["list"] = "list"
    data: list[ModelObject]


class ChatMessage(BaseModel):
    role: Literal["system", "user", "assistant", "tool"]
    content: str | list[dict[str, Any]] | None = None
    name: str | None = None
    tool_call_id: str | None = None


class ChatCompletionRequest(BaseModel):
    model: str
    messages: list[ChatMessage]
    temperature: float | None = None
    max_tokens: int | None = None
    stream: bool = False
    tools: list[dict[str, Any]] | None = None
    tool_choice: str | dict[str, Any] | None = None

    model_config = {"extra": "allow"}


class CompletionRequest(BaseModel):
    model: str
    prompt: str | list[str]
    temperature: float | None = None
    max_tokens: int | None = None
    stream: bool = False

    model_config = {"extra": "allow"}


class SpeechRequest(BaseModel):
    model: str
    input: str
    voice: str = "default"
    response_format: str = "mp3"
    speed: float | None = None

    model_config = {"extra": "allow"}


class AudioGenerationRequest(BaseModel):
    model: str
    prompt: str
    response_format: str = "wav"
    duration_seconds: float | None = None

    model_config = {"extra": "allow"}


class ImageGenerationRequest(BaseModel):
    model: str
    prompt: str
    n: int = 1
    size: str = "1024x1024"
    response_format: Literal["url", "b64_json"] = "b64_json"
    seed: int | None = None
    quality: str | None = None
    style: str | None = None
    image: str | None = None  # optional source image for edit pipelines

    model_config = {"extra": "allow"}


class VideoGenerationRequest(BaseModel):
    model: str
    prompt: str
    image: str | None = None
    duration_seconds: float | None = None
    size: str = "832x480"
    fps: int | None = None

    model_config = {"extra": "allow"}


class Model3DGenerationRequest(BaseModel):
    model: str
    prompt: str | None = None
    image: str | None = None
    response_format: Literal["glb", "obj", "ply"] = "glb"

    model_config = {"extra": "allow"}


class TaskObject(BaseModel):
    id: str
    object: Literal["task"] = "task"
    status: Literal["queued", "running", "completed", "failed"]
    model: str
    kind: str
    created: int
    output: dict[str, Any] | None = None
    error: str | None = None


class OcrRequest(BaseModel):
    model: str
    image: str | None = None
    prompt: str | None = None

    model_config = {"extra": "allow"}


class EmbeddingRequest(BaseModel):
    model: str
    input: str | list[str]
    encoding_format: Literal["float", "base64"] = "float"
    dimensions: int | None = None

    model_config = {"extra": "allow"}
