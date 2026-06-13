"""Stable Audio Open 1.0 text-to-sound-effect on Modal (Stability Community
License, L4).

Best dedicated SFX option. NOTE: free only under $1M annual revenue — track the
threshold and buy a Stability Enterprise license (or migrate to ACE-Step samples)
before crossing it. See models.md section 7.

Contract: infer("audio", payload) -> {"audio_base64": ..., "media_type": "audio/wav"}
payload: {prompt, duration_seconds?}

Deploy: modal deploy modal_apps/sfx.py
"""

from __future__ import annotations

import io

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, SCALEDOWN_WINDOW, b64_bytes, torch_image

app = modal.App("modal-genai-sfx")

IMAGE = torch_image("stable-audio-tools>=0.0.16", "soundfile>=0.12.1", "einops>=0.8.0")

MODEL = "stabilityai/stable-audio-open-1.0"


@app.cls(
    image=IMAGE,
    gpu="L4",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 15,
)
class StableAudio:
    @modal.enter()
    def load(self):
        import torch
        from stable_audio_tools import get_pretrained_model

        self.model, self.config = get_pretrained_model(MODEL)
        self.sample_rate = self.config["sample_rate"]
        self.sample_size = self.config["sample_size"]
        self.device = "cuda"
        self.model = self.model.to(self.device)

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind != "audio":
            raise ValueError(f"StableAudio handles audio generation, got {kind!r}")
        import soundfile as sf
        import torch
        from stable_audio_tools.inference.generation import generate_diffusion_cond

        prompt = payload["prompt"]
        seconds = float(payload.get("duration_seconds") or 11.0)

        conditioning = [{"prompt": prompt, "seconds_start": 0, "seconds_total": seconds}]
        output = generate_diffusion_cond(
            self.model,
            steps=100,
            cfg_scale=7,
            conditioning=conditioning,
            sample_size=self.sample_size,
            sigma_min=0.3,
            sigma_max=500,
            device=self.device,
        )
        output = output.to(torch.float32).div(output.abs().max()).clamp(-1, 1)
        audio = output.cpu().numpy()[0].T  # (samples, channels)

        buf = io.BytesIO()
        sf.write(buf, audio, self.sample_rate, format="WAV")
        return {"audio_base64": b64_bytes(buf.getvalue()), "media_type": "audio/wav"}
