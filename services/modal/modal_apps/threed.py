"""TRELLIS.2 image-to-3D on Modal (MIT, A100-80GB).

Best commercial-safe high-fidelity image-to-3D. Needs >=24GB VRAM, CUDA 12.x.
Pair with an image backend for text-to-3D: generate a source image (z-image),
then pass it here.

Contract: infer("3d", payload) -> {"status": "completed", "output": {...}}
payload: {image (data-url or http url or path), response_format="glb"}
output: {path, model_base64, format}

Deploy: modal deploy modal_apps/threed.py
"""

from __future__ import annotations

import time
from pathlib import Path

import modal

from .common import (
    HF_CACHE,
    HF_CACHE_DIR,
    HF_SECRET,
    OUTPUTS,
    OUTPUTS_DIR,
    SCALEDOWN_WINDOW,
    b64_bytes,
    decode_b64,
    torch_image,
)

app = modal.App("modal-genai-3d")

# TRELLIS needs a CUDA devel base to build its sparse/voxel CUDA ops.
IMAGE = (
    torch_image(cuda_devel=True)
    .apt_install("libgl1", "libglib2.0-0")
    .pip_install(
        "trellis>=0.1.0",
        "trimesh>=4.5.0",
        "rembg>=2.0.59",
        "onnxruntime>=1.20.0",
        "xformers>=0.0.28",
    )
    .env({"ATTN_BACKEND": "flash-attn", "SPCONV_ALGO": "native"})
)

MODEL = "microsoft/TRELLIS.2-4B"


def _materialize_image(image: str) -> str:
    """Return a local path for a data URL, http URL, or existing path."""
    import tempfile

    import httpx

    if image.startswith("data:image/"):
        _, payload = image.split(",", 1)
        path = tempfile.mktemp(suffix=".png")
        Path(path).write_bytes(decode_b64(payload))
        return path
    if image.startswith("http://") or image.startswith("https://"):
        path = tempfile.mktemp(suffix=".png")
        Path(path).write_bytes(httpx.get(image, timeout=60).content)
        return path
    return image


@app.cls(
    image=IMAGE,
    gpu="A100-80GB",
    volumes={HF_CACHE_DIR: HF_CACHE, OUTPUTS_DIR: OUTPUTS},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 30,
)
class Trellis:
    @modal.enter()
    def load(self):
        from trellis.pipelines import TrellisImageTo3DPipeline

        self.pipe = TrellisImageTo3DPipeline.from_pretrained(MODEL)
        self.pipe.cuda()

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind != "3d":
            raise ValueError(f"Trellis handles 3d, got {kind!r}")
        if not payload.get("image"):
            raise ValueError("TRELLIS is image-to-3D: provide `image` (data URL, http URL, or path).")
        from PIL import Image
        from trellis.utils import postprocessing_utils

        fmt = payload.get("response_format", "glb")
        image_path = _materialize_image(payload["image"])
        image = Image.open(image_path).convert("RGB")

        outputs = self.pipe.run(image, seed=int(payload.get("seed", 1)))
        glb = postprocessing_utils.to_glb(
            outputs["gaussian"][0],
            outputs["mesh"][0],
            simplify=0.95,
            texture_size=1024,
        )

        out_dir = Path(OUTPUTS_DIR) / "3d"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"trellis-{int(time.time())}.{fmt}"
        glb.export(str(out_path))
        OUTPUTS.commit()

        data = out_path.read_bytes()
        return {
            "status": "completed",
            "output": {
                "path": str(out_path),
                "model_base64": b64_bytes(data),
                "format": fmt,
                "media_type": "model/gltf-binary",
            },
        }
