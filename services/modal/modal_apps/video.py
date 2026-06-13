"""Wan 2.2 text/image-to-video on Modal (Apache-2.0, H100).

The clear commercial-safe video pick: scales from 1.3B (L40S) to 14B (H100),
unrestricted, outputs fully yours.

Contract: infer("video", payload) -> {"status": "completed", "output": {...}}
payload: {prompt, image?, size="WxH", duration_seconds?, fps?}
output: {url, path, video_base64, fps, frames}

Deploy: modal deploy modal_apps/video.py
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
    torch_image,
)

app = modal.App("modal-genai-video")

IMAGE = torch_image("diffusers>=0.32.0", "imageio>=2.36.0", "imageio-ffmpeg>=0.5.1", "ftfy>=6.3.0")

MODEL = "Wan-AI/Wan2.2-T2V-A14B-Diffusers"


@app.cls(
    image=IMAGE,
    gpu="H100",
    volumes={HF_CACHE_DIR: HF_CACHE, OUTPUTS_DIR: OUTPUTS},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 30,
)
class Wan:
    @modal.enter()
    def load(self):
        import torch
        from diffusers import AutoencoderKLWan, WanPipeline

        vae = AutoencoderKLWan.from_pretrained(MODEL, subfolder="vae", torch_dtype=torch.float32)
        self.pipe = WanPipeline.from_pretrained(MODEL, vae=vae, torch_dtype=torch.bfloat16).to("cuda")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind != "video":
            raise ValueError(f"Wan handles video, got {kind!r}")
        from diffusers.utils import export_to_video

        prompt = payload["prompt"]
        fps = int(payload.get("fps") or 16)
        duration = float(payload.get("duration_seconds") or 5.0)
        num_frames = max(16, int(fps * duration) // 4 * 4 + 1)

        try:
            w, h = (payload.get("size") or "832x480").lower().split("x", 1)
            width, height = int(w), int(h)
        except Exception:
            width, height = 832, 480

        result = self.pipe(
            prompt=prompt,
            height=height,
            width=width,
            num_frames=num_frames,
            guidance_scale=5.0,
        )
        frames = result.frames[0]

        out_dir = Path(OUTPUTS_DIR) / "video"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"wan-{int(time.time())}.mp4"
        export_to_video(frames, str(out_path), fps=fps)
        OUTPUTS.commit()

        data = out_path.read_bytes()
        return {
            "status": "completed",
            "output": {
                "path": str(out_path),
                "video_base64": b64_bytes(data),
                "media_type": "video/mp4",
                "fps": fps,
                "frames": num_frames,
                "size": f"{width}x{height}",
            },
        }
