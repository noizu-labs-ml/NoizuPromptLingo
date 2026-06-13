from __future__ import annotations

import base64
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from modal_genai.server import create_app
from modal_genai.settings import Settings

CONFIG = Path(__file__).resolve().parent.parent / "config" / "models.yaml"


@pytest.fixture()
def client() -> TestClient:
    # stub_mode keeps media providers offline; no Modal token/GPU required.
    settings = Settings(model_config_path=CONFIG, api_key=None, stub_mode=True)
    return TestClient(create_app(settings))


def test_health(client):
    body = client.get("/health").json()
    assert body["status"] == "ok"
    assert body["stub_mode"] is True
    assert body["models"] >= 10


def test_models_lists_named_backends(client):
    ids = {m["id"] for m in client.get("/v1/models").json()["data"]}
    # the three named LLMs plus representative media backends
    assert {"qwen3.6", "gemma-4", "glm-4.6v"} <= ids
    assert {"z-image", "kokoro", "whisper", "ace-step", "wan", "trellis"} <= ids


def test_chat_completion_stub(client):
    r = client.post("/v1/chat/completions", json={"model": "qwen3.6", "messages": [{"role": "user", "content": "hi"}]})
    assert r.status_code == 200
    assert r.json()["choices"][0]["message"]["role"] == "assistant"


def test_embeddings_stub(client):
    r = client.post("/v1/embeddings", json={"model": "embed", "input": ["a", "b"]})
    assert r.status_code == 200
    assert len(r.json()["data"]) == 2


def test_image_generation_stub_returns_png(client):
    r = client.post("/v1/images/generations", json={"model": "z-image", "prompt": "a cube"})
    assert r.status_code == 200
    b64 = r.json()["data"][0]["b64_json"]
    assert base64.b64decode(b64)[:8] == b"\x89PNG\r\n\x1a\n"


def test_tts_stub_returns_audio(client):
    r = client.post("/v1/audio/speech", json={"model": "kokoro", "input": "hello", "response_format": "wav"})
    assert r.status_code == 200
    assert r.headers["content-type"] == "audio/wav"


def test_audio_generation_stub(client):
    r = client.post("/v1/audio/generations", json={"model": "ace-step", "prompt": "lofi", "duration_seconds": 5})
    assert r.status_code == 200


def test_transcription_stub(client):
    files = {"file": ("clip.wav", b"RIFFfake", "audio/wav")}
    r = client.post("/v1/audio/transcriptions", data={"model": "whisper"}, files=files)
    assert r.status_code == 200
    assert "text" in r.json()


def test_video_task_stub(client):
    r = client.post("/v1/video/generations", json={"model": "wan", "prompt": "a plane"})
    assert r.status_code == 200
    task = r.json()
    assert task["object"] == "task"
    # task is retrievable
    assert client.get(f"/v1/tasks/{task['id']}").status_code == 200


def test_3d_task_stub(client):
    r = client.post("/v1/3d/generations", json={"model": "trellis", "image": "x.png", "response_format": "glb"})
    assert r.status_code == 200
    assert r.json()["kind"] == "3d.generation"


def test_provider_status(client):
    status = client.get("/v1/providers/status").json()
    assert "vllm-qwen" in status
    assert status["image-zimage"]["kind"] == "modal_cls"


def test_unknown_model_404(client):
    r = client.post("/v1/chat/completions", json={"model": "nope", "messages": [{"role": "user", "content": "hi"}]})
    assert r.status_code == 404


def test_auth_enforced_when_key_set():
    settings = Settings(model_config_path=CONFIG, api_key="secret", stub_mode=True)
    c = TestClient(create_app(settings))
    assert c.get("/v1/models").status_code == 401
    assert c.get("/v1/models", headers={"Authorization": "Bearer secret"}).status_code == 200
