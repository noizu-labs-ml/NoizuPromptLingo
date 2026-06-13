"""Text-to-image backends on Modal.

All three are commercial-safe per models.md:
  ZImage     -> Tongyi-MAI/Z-Image-Turbo  (Apache-2.0, L40S, 8-step turbo)  default fast pick
  QwenImage  -> Qwen/Qwen-Image           (Apache-2.0, A100-80GB)           best text/quality
  SDXL       -> stabilityai/sdxl-base-1.0 (OpenRAIL++, L40S)                deep LoRA ecosystem

Contract: infer("image", payload) -> {"images": [{"b64_json": ...}], "revised_prompt": ...}
payload: {prompt, size="WxH", n=1, seed?, image?}

Deploy: modal deploy modal_apps/image.py
"""

from __future__ import annotations

import io

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, SCALEDOWN_WINDOW, b64_bytes, torch_image

app = modal.App("modal-genai-image")

IMAGE = torch_image("diffusers>=0.32.0", "sentencepiece>=0.2.0", "protobuf>=4.25.0")


def _parse_size(size: str, default=(1024, 1024)) -> tuple[int, int]:
    try:
        w, h = size.lower().split("x", 1)
        return int(w), int(h)
    except Exception:
        return default


def _encode(image) -> str:
    buf = io.BytesIO()
    image.save(buf, format="PNG")
    return b64_bytes(buf.getvalue())


class _BaseImage:
    """Shared infer loop. Subclasses set REPO and implement `_pipe()`."""

    REPO: str = ""

    def _load(self):  # overridden in @modal.enter
        raise NotImplementedError

    def _generate(self, prompt: str, width: int, height: int, seed, steps: int):
        import torch

        generator = None
        if seed is not None:
            generator = torch.Generator(device="cuda").manual_seed(int(seed))
        result = self.pipe(
            prompt=prompt,
            width=width,
            height=height,
            num_inference_steps=steps,
            generator=generator,
        )
        return result.images[0]

    def _infer(self, kind: str, payload: dict, default_steps: int) -> dict:
        if kind != "image":
            raise ValueError(f"{type(self).__name__} only handles image generation, got {kind!r}")
        prompt = payload["prompt"]
        width, height = _parse_size(payload.get("size", "1024x1024"))
        n = int(payload.get("n", 1))
        seed = payload.get("seed")
        steps = int(payload.get("steps", default_steps))
        images = []
        for i in range(n):
            s = None if seed is None else int(seed) + i
            img = self._generate(prompt, width, height, s, steps)
            images.append({"b64_json": _encode(img)})
        return {"images": images, "revised_prompt": prompt}


@app.cls(
    image=IMAGE,
    gpu="L40S",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 20,
)
class ZImage(_BaseImage):
    REPO = "Tongyi-MAI/Z-Image-Turbo"

    @modal.enter()
    def load(self):
        import torch
        from diffusers import DiffusionPipeline

        self.pipe = DiffusionPipeline.from_pretrained(
            self.REPO, torch_dtype=torch.bfloat16, trust_remote_code=True
        ).to("cuda")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        # Turbo model: distilled to ~8 steps.
        return self._infer(kind, payload, default_steps=8)


@app.cls(
    image=IMAGE,
    gpu="A100-80GB",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 30,
)
class QwenImage(_BaseImage):
    REPO = "Qwen/Qwen-Image"

    @modal.enter()
    def load(self):
        import torch
        from diffusers import DiffusionPipeline

        self.pipe = DiffusionPipeline.from_pretrained(
            self.REPO, torch_dtype=torch.bfloat16, trust_remote_code=True
        ).to("cuda")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        return self._infer(kind, payload, default_steps=30)


@app.cls(
    image=IMAGE,
    gpu="L40S",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 20,
)
class SDXL(_BaseImage):
    REPO = "stabilityai/stable-diffusion-xl-base-1.0"

    @modal.enter()
    def load(self):
        import torch
        from diffusers import StableDiffusionXLPipeline

        self.pipe = StableDiffusionXLPipeline.from_pretrained(
            self.REPO, torch_dtype=torch.float16, variant="fp16", use_safetensors=True
        ).to("cuda")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        return self._infer(kind, payload, default_steps=30)
