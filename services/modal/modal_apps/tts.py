"""Kokoro-82M text-to-speech on Modal (Apache-2.0, L4).

The smallest commercial-safe default TTS. 54 voices, English + several langs.

Contract: infer("speech", payload) -> {"audio_base64": ..., "media_type": "audio/wav"}
payload: {input, voice="af_heart", response_format="wav", speed?}

Deploy: modal deploy modal_apps/tts.py
"""

from __future__ import annotations

import io

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, SCALEDOWN_WINDOW, b64_bytes, torch_image

app = modal.App("modal-genai-tts")

IMAGE = torch_image("kokoro>=0.9.4", "soundfile>=0.12.1", "misaki[en]>=0.9.4")

DEFAULT_VOICE = "af_heart"
SAMPLE_RATE = 24000


@app.cls(
    image=IMAGE,
    gpu="L4",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 10,
)
class Kokoro:
    @modal.enter()
    def load(self):
        from kokoro import KPipeline

        # 'a' = American English; the pipeline lazily fetches voices as needed.
        self.pipeline = KPipeline(lang_code="a")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind != "speech":
            raise ValueError(f"Kokoro only handles speech, got {kind!r}")
        import numpy as np
        import soundfile as sf

        text = payload["input"]
        voice = payload.get("voice") or DEFAULT_VOICE
        if voice == "default":
            voice = DEFAULT_VOICE
        speed = float(payload.get("speed") or 1.0)

        chunks = []
        for _, _, audio in self.pipeline(text, voice=voice, speed=speed):
            chunks.append(audio)
        if not chunks:
            raise RuntimeError("Kokoro produced no audio")
        audio = np.concatenate(chunks)

        buf = io.BytesIO()
        sf.write(buf, audio, SAMPLE_RATE, format="WAV")
        return {"audio_base64": b64_bytes(buf.getvalue()), "media_type": "audio/wav"}
