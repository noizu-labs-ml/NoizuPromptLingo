"""Whisper large-v3-turbo speech-to-text on Modal (MIT, L4).

Best speed/quality/compat ASR pick. Multilingual transcription + translation.

Contract:
  infer("transcribe", payload) -> {"text": ..., "segments": [...]}
  infer("translate",  payload) -> {"text": ...}
payload: {audio_base64, filename, task}

Deploy: modal deploy modal_apps/stt.py
"""

from __future__ import annotations

import tempfile

import modal

from .common import HF_CACHE, HF_CACHE_DIR, HF_SECRET, SCALEDOWN_WINDOW, decode_b64, torch_image

app = modal.App("modal-genai-stt")

# faster-whisper (CTranslate2) is the throughput-friendly runtime for v3-turbo.
IMAGE = torch_image("faster-whisper>=1.1.0")

MODEL = "deepdml/faster-whisper-large-v3-turbo-ct2"


@app.cls(
    image=IMAGE,
    gpu="L4",
    volumes={HF_CACHE_DIR: HF_CACHE},
    secrets=[HF_SECRET],
    scaledown_window=SCALEDOWN_WINDOW,
    timeout=60 * 15,
)
class Whisper:
    @modal.enter()
    def load(self):
        from faster_whisper import WhisperModel

        self.model = WhisperModel(MODEL, device="cuda", compute_type="float16")

    @modal.method()
    def infer(self, kind: str, payload: dict) -> dict:
        if kind not in {"transcribe", "translate"}:
            raise ValueError(f"Whisper handles transcribe/translate, got {kind!r}")
        audio = decode_b64(payload["audio_base64"])
        suffix = "-" + (payload.get("filename") or "audio.wav")
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=True) as tmp:
            tmp.write(audio)
            tmp.flush()
            segments, _info = self.model.transcribe(tmp.name, task=kind)
            seg_list = [
                {"id": i, "start": s.start, "end": s.end, "text": s.text}
                for i, s in enumerate(segments)
            ]
        text = "".join(s["text"] for s in seg_list).strip()
        if kind == "translate":
            return {"text": text}
        return {"text": text, "segments": seg_list}
