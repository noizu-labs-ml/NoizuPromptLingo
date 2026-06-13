"""ACE-Step text-to-music on Modal (Apache-2.0, L40S).

Best commercial-safe music model: ~3.5B diffusion, full song in <20s on A100.

Contract: infer("audio", payload) -> {"audio_base64": ..., "media_type": "audio/wav"}
payload: {prompt, duration_seconds?}

Deploy: modal deploy modal_apps/music.py
"""

from __future__ import annotations

import io

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, SCALEDOWN_WINDOW, b64_bytes, torch_image

app = modal.App("modal-genai-music")

IMAGE = torch_image(
    "acestep>=0.1.0",
    "soundfile>=0.12.1",
    "librosa>=0.10.2",
    cuda_devel=False,
)

CHECKPOINT_DIR = f"{HF_CACHE_DIR}/acestep"


@app.cls(
    image=IMAGE,
    gpu="L40S",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 20,
)
class AceStep:
    @modal.enter()
    def load(self):
        from acestep.pipeline_ace_step import ACEStepPipeline

        self.pipe = ACEStepPipeline(
            checkpoint_dir=CHECKPOINT_DIR,
            dtype="bfloat16",
            torch_compile=False,
        )

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind != "audio":
            raise ValueError(f"AceStep handles audio generation, got {kind!r}")
        import soundfile as sf

        prompt = payload["prompt"]
        duration = float(payload.get("duration_seconds") or 30.0)

        # ACE-Step takes a tag/style prompt plus optional lyrics. We map the
        # OpenAI-style single prompt onto the style field with empty lyrics.
        audio, sample_rate = self.pipe(
            prompt=prompt,
            lyrics=payload.get("lyrics", ""),
            audio_duration=duration,
            infer_step=60,
            guidance_scale=15.0,
            return_audio=True,
        )
        buf = io.BytesIO()
        sf.write(buf, audio, sample_rate, format="WAV")
        return {"audio_base64": b64_bytes(buf.getvalue()), "media_type": "audio/wav"}
