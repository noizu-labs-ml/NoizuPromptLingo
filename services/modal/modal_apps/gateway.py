"""Single OpenAI-compatible endpoint, hosted on Modal.

Wraps the `modal_genai` FastAPI gateway as a Modal ASGI app so the whole stack
has one public HTTPS URL:

    https://<workspace>--modal-genai-gateway-fastapi.modal.run/v1/...

It runs on CPU (cheap, scale-to-zero) and dispatches:
  - chat/completions/embeddings  -> proxied to the deployed vLLM app URLs
  - media (image/tts/stt/...)     -> modal.Cls.from_name(...).infer.remote()

Deploy LAST, after the model apps exist (or it will stub media until they do):
    modal deploy modal_apps/gateway.py

Config + source are baked into the image. Point the vLLM base_urls in
config/models.yaml at the deployed URLs before deploying (or set them via the
MODAL_GENAI_VLLM_* env on the gateway secret).
"""

from __future__ import annotations

from pathlib import Path

import modal

LOCAL_ROOT = Path(__file__).parent.parent

image = (
    modal.Image.debian_slim(python_version="3.11")
    .pip_install(
        "fastapi>=0.115.0",
        "httpx>=0.27.0",
        "pydantic-settings>=2.6.0",
        "python-multipart>=0.0.12",
        "pyyaml>=6.0.2",
        "uvicorn[standard]>=0.30.0",
    )
    .env({"MODAL_GENAI_MODEL_CONFIG": "/root/config/models.yaml"})
    .add_local_dir(LOCAL_ROOT / "config", remote_path="/root/config")
    .add_local_python_source("modal_genai")
)

app = modal.App("modal-genai-gateway")

# Gateway needs: an API key to protect itself, and the vLLM shared key to reach
# the LLM apps. Both live in one secret.
GATEWAY_SECRET = modal.Secret.from_name(
    "modal-genai-gateway", required_keys=["MODAL_GENAI_API_KEY", "MODAL_GENAI_VLLM_KEY"]
)


@app.function(
    image=image,
    secrets=[GATEWAY_SECRET],
    scaledown_window=300,
    timeout=60 * 15,
    min_containers=0,
)
@modal.concurrent(max_inputs=50)
@modal.asgi_app()
def fastapi():
    from modal_genai.server import create_app
    from modal_genai.settings import Settings

    # stub_mode stays False: media dispatch via modal.Cls.from_name works because
    # we're running inside Modal with a client available.
    settings = Settings(stub_mode=False)
    return create_app(settings)
