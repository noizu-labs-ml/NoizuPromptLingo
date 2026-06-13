"""Modal deployment apps for the GenAI gateway backends.

One app per modality, each deployable with `modal deploy modal_apps/<file>.py`:

    llm.py     vLLM OpenAI-compatible serving (Qwen3.6, Gemma-4, GLM-4.6V, embed)
    image.py   Z-Image-Turbo / Qwen-Image / SDXL
    tts.py     Kokoro-82M
    stt.py     Whisper large-v3-turbo
    music.py   ACE-Step
    sfx.py     Stable Audio Open
    video.py   Wan 2.2
    threed.py  TRELLIS.2
    gateway.py OpenAI-compatible router (asgi) fronting all of the above
"""
