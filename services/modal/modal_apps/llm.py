"""vLLM OpenAI-compatible LLM serving on Modal (NVIDIA GPUs).

Each model is its own web endpoint under one app, so each gets an independent
autoscaling pool and GPU while sharing the HF cache Volume. vLLM's own server
provides a literal ``/v1/chat/completions`` (+ ``/v1/completions``,
``/v1/embeddings``) surface, so the gateway just proxies to these URLs.

Deploy:    modal deploy modal_apps/llm.py
URLs:      https://<workspace>--modal-genai-llm-<name>.modal.run/v1

Named models (all Apache-2.0 / MIT, verified on the Hub):
  qwen  -> Qwen/Qwen3.6-27B-FP8        (H100)   multimodal
  gemma -> google/gemma-4-12B-it       (L40S)   multimodal
  glm   -> zai-org/GLM-4.6V-Flash      (L40S)   vision
  embed -> Qwen/Qwen3-Embedding-0.6B   (L4)     embeddings

NOTE: Modal requires web-server functions at module global scope, so each model
is its own decorated function (no closures / factories).
"""

from __future__ import annotations

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, VLLM_AUTH_SECRET, vllm_image

app = modal.App("modal-genai-llm")

IMAGE = vllm_image()
VLLM_PORT = 8000
LLM_SCALEDOWN = 60 * 10  # keep a GPU warm for 10 min of idle interactive use
STARTUP_TIMEOUT = 60 * 12

_COMMON_KW = dict(
    image=IMAGE,
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET, VLLM_AUTH_SECRET],
    scaledown_window=LLM_SCALEDOWN,
    timeout=60 * 60,
)


def _run_vllm(model_repo: str, served_name: str, extra_args: list[str]) -> None:
    """Launch `vllm serve` listening on VLLM_PORT. Called from a web_server fn."""
    import os
    import subprocess

    cmd = [
        "vllm",
        "serve",
        model_repo,
        "--served-model-name",
        served_name,
        "--host",
        "0.0.0.0",
        "--port",
        str(VLLM_PORT),
        "--api-key",
        os.environ["MODAL_GENAI_VLLM_KEY"],
        "--trust-remote-code",
        *extra_args,
    ]
    subprocess.Popen(cmd)


# ---- Qwen 3.6 (27B FP8) — multimodal flagship, H100 -----------------------
@app.function(gpu="H100", max_containers=2, **_COMMON_KW)
@modal.concurrent(max_inputs=32)
@modal.web_server(port=VLLM_PORT, startup_timeout=STARTUP_TIMEOUT)
def qwen():
    _run_vllm(
        "Qwen/Qwen3.6-27B-FP8",
        "qwen3.6",
        ["--max-model-len", "32768", "--gpu-memory-utilization", "0.92"],
    )


# ---- Gemma 4 (12B-it) — multimodal, L40S ----------------------------------
@app.function(gpu="L40S", max_containers=2, **_COMMON_KW)
@modal.concurrent(max_inputs=32)
@modal.web_server(port=VLLM_PORT, startup_timeout=STARTUP_TIMEOUT)
def gemma():
    _run_vllm(
        "google/gemma-4-12B-it",
        "gemma-4",
        ["--max-model-len", "16384", "--gpu-memory-utilization", "0.90"],
    )


# ---- GLM 4.6V Flash — vision LLM (MIT), L40S ------------------------------
@app.function(gpu="L40S", max_containers=2, **_COMMON_KW)
@modal.concurrent(max_inputs=32)
@modal.web_server(port=VLLM_PORT, startup_timeout=STARTUP_TIMEOUT)
def glm():
    _run_vllm(
        "zai-org/GLM-4.6V-Flash",
        "glm-4.6v",
        ["--max-model-len", "16384", "--gpu-memory-utilization", "0.90"],
    )


# ---- Qwen3 embeddings — cheap L4 ------------------------------------------
@app.function(gpu="L4", max_containers=2, **_COMMON_KW)
@modal.concurrent(max_inputs=64)
@modal.web_server(port=VLLM_PORT, startup_timeout=STARTUP_TIMEOUT)
def embed():
    _run_vllm("Qwen/Qwen3-Embedding-0.6B", "embed", ["--task", "embed"])
