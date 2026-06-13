"""Shared Modal infrastructure for the GenAI backends.

Volumes, secrets, base images, and small helpers reused by every modality app.
All weights live on a shared HF cache Volume (write-once / read-many) rather than
being baked into images, so cold starts only pay for the bytes actually read.
"""

from __future__ import annotations

import modal

# ---------------------------------------------------------------------------
# Shared persistent storage + credentials
# ---------------------------------------------------------------------------

# Hugging Face cache, shared across all apps. Mounted at HF_HOME.
HF_CACHE = modal.Volume.from_name("modal-genai-hf-cache", create_if_missing=True)
HF_CACHE_DIR = "/cache/huggingface"

# Output scratch for large artifacts (video/3d) when we don't want to inline
# multi-MB base64 in the JSON response.
OUTPUTS = modal.Volume.from_name("modal-genai-outputs", create_if_missing=True)
OUTPUTS_DIR = "/outputs"

# Secret holding HF_TOKEN (create with: modal secret create huggingface HF_TOKEN=...)
HF_SECRET = modal.Secret.from_name("huggingface", required_keys=["HF_TOKEN"])

# Optional shared bearer token enforced by the vLLM apps.
VLLM_AUTH_SECRET = modal.Secret.from_name("modal-genai-vllm", required_keys=["MODAL_GENAI_VLLM_KEY"])

CACHE_ENV = {
    "HF_HOME": HF_CACHE_DIR,
    "HF_HUB_ENABLE_HF_TRANSFER": "1",
    "HF_HUB_CACHE": f"{HF_CACHE_DIR}/hub",
}

# Idle window before a backend container scales to zero (seconds).
SCALEDOWN_WINDOW = 300

# ---------------------------------------------------------------------------
# Base images
# ---------------------------------------------------------------------------

def torch_image(*extra_pip: str, cuda_devel: bool = False) -> modal.Image:
    """A CUDA-ready torch image with hf_transfer for fast weight pulls."""
    if cuda_devel:
        base = modal.Image.from_registry(
            "nvidia/cuda:12.4.1-devel-ubuntu22.04", add_python="3.11"
        )
    else:
        base = modal.Image.debian_slim(python_version="3.11")
    image = (
        base.apt_install("git", "ffmpeg", "libsndfile1")
        .pip_install(
            "torch==2.5.1",
            "transformers>=4.49.0",
            "accelerate>=1.2.0",
            "huggingface_hub[hf_transfer]>=0.27.0",
            "safetensors>=0.4.5",
            "pillow>=10.4.0",
            "numpy<2.2",
        )
        .env(CACHE_ENV)
    )
    if extra_pip:
        image = image.pip_install(*extra_pip)
    return image


def vllm_image(vllm_version: str = "0.8.5") -> modal.Image:
    """Image for vLLM OpenAI-compatible serving."""
    return (
        modal.Image.debian_slim(python_version="3.11")
        .pip_install(
            f"vllm=={vllm_version}",
            "huggingface_hub[hf_transfer]>=0.27.0",
            "flashinfer-python",
        )
        .env(CACHE_ENV)
    )


def b64_bytes(data: bytes) -> str:
    import base64

    return base64.b64encode(data).decode()


def decode_b64(data: str) -> bytes:
    import base64

    return base64.b64decode(data)
