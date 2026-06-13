# Modal GenAI Gateway (NVIDIA)

An OpenAI-compatible GenAI stack that runs on **Modal** NVIDIA GPUs — the
counterpart to the Apple Silicon `Services/GenAI` gateway. Same `/v1/*` surface,
same client code; the backends are Modal apps instead of local MLX/MFLUX/NeMo
subprocesses.

One endpoint gets you text + vision inference, embeddings, image generation,
text-to-speech, transcription, music, sound effects, video, and 3D — each on a
right-sized GPU that scales to zero when idle.

Model picks follow [`models.md`](models.md) (commercial-license-aware), and the
Modal mechanics are summarized in [`docs/modal-platform-notes.md`](docs/modal-platform-notes.md).

## Architecture

```
            OpenAI client (curl / SDK / LiteLLM)
                          │  /v1/chat, /v1/images, /v1/audio, /v1/3d ...
                          ▼
        ┌─────────────────────────────────────────┐
        │  Gateway (FastAPI, modal_genai)          │  one URL, CPU, scale-to-zero
        │  routes by `model` → provider            │  modal_apps/gateway.py (asgi)
        └───────────────┬───────────────┬──────────┘
         vllm proxy     │               │  modal.Cls.from_name(...).infer
                        ▼               ▼
        ┌───────────────────────┐   ┌───────────────────────────────────┐
        │ vLLM apps (OpenAI)    │   │ Media classes (per modality)      │
        │ Qwen3.6 / Gemma-4 /   │   │ image / tts / stt / music / sfx / │
        │ GLM-4.6V / embeddings │   │ video / 3d                        │
        └───────────────────────┘   └───────────────────────────────────┘
```

Two backend kinds, mirroring the Mac gateway's provider split:

- **`vllm`** — LLMs run `vllm serve`, which already exposes a literal
  `/v1/chat/completions` etc. The gateway just proxies to the deployed
  `*.modal.run` URL.
- **`modal_cls`** — media models have no OpenAI standard, so each is a Modal
  class with one `infer(kind, payload)` method; the gateway dispatches via
  `modal.Cls.from_name(app, cls)` and converts the result to the OpenAI shape.

The gateway can run **on Modal** (`modal_apps/gateway.py` → one public URL) or
**locally** (`make serve`, dispatching to the deployed apps). With
`MODAL_GENAI_STUB_MODE=1` the whole gateway runs fully offline with deterministic
stubs — no token, no GPU — which is what the test suite uses.

## Models

| Endpoint id | Modality | Repo | License | Default GPU |
|---|---|---|---|---|
| `qwen3.6` | chat + vision | `Qwen/Qwen3.6-27B-FP8` | Apache-2.0 | H100 |
| `gemma-4` | chat + vision | `google/gemma-4-12B-it` | Apache-2.0 | L40S |
| `glm-4.6v` | vision chat | `zai-org/GLM-4.6V-Flash` | MIT | L40S |
| `embed` | embeddings | `Qwen/Qwen3-Embedding-0.6B` | Apache-2.0 | L4 |
| `z-image` | text→image (fast) | `Tongyi-MAI/Z-Image-Turbo` | Apache-2.0 | L40S |
| `qwen-image` | text→image (quality) | `Qwen/Qwen-Image` | Apache-2.0 | A100-80GB |
| `sdxl` | text→image | `stabilityai/stable-diffusion-xl-base-1.0` | OpenRAIL++ | L40S |
| `kokoro` | text→speech | `hexgrad/Kokoro-82M` | Apache-2.0 | L4 |
| `whisper` | speech→text | `openai/whisper-large-v3-turbo` | MIT | L4 |
| `ace-step` | text→music | `ACE-Step/ACE-Step-v1-3.5B` | Apache-2.0 | L40S |
| `stable-audio` | text→SFX | `stabilityai/stable-audio-open-1.0` | Stability Community¹ | L4 |
| `wan` | text/image→video | `Wan-AI/Wan2.2-T2V-A14B` | Apache-2.0 | H100 |
| `trellis` | image→3D | `microsoft/TRELLIS.2-4B` | MIT | A100-80GB |

¹ Stable Audio Open is free **only under $1M annual revenue**. Track the
threshold and buy a Stability Enterprise license (or fall back to ACE-Step
samples) before crossing it. Everything else is uncapped Apache-2.0 / MIT.
Swap any repo or GPU in [`config/models.yaml`](config/models.yaml).

## Quick start

```bash
uv sync                       # gateway deps
uv sync --extra modal         # + the modal client for deploying/dispatching
modal setup                   # one-time Modal auth
```

Create the secrets the apps expect (`make secrets` prints these):

```bash
modal secret create huggingface HF_TOKEN=hf_xxx
modal secret create modal-genai-vllm  MODAL_GENAI_VLLM_KEY=$(openssl rand -hex 24)
modal secret create modal-genai-gateway \
    MODAL_GENAI_API_KEY=$(openssl rand -hex 24) \
    MODAL_GENAI_VLLM_KEY=<same vllm key as above>
```

Deploy the backends, then the gateway:

```bash
make deploy            # all model apps + gateway
# or one at a time:
make deploy-llm        # Qwen3.6 / Gemma-4 / GLM-4.6V / embeddings (vLLM)
make deploy-image      # Z-Image / Qwen-Image / SDXL
make deploy-tts        # Kokoro
# ... stt music sfx video threed
make deploy-gateway    # the single OpenAI URL (deploy LAST)
```

`modal deploy modal_apps/llm.py` prints the per-model URLs. Paste the four vLLM
URLs into `config/models.yaml` (`providers.vllm-*.base_url`), then re-run
`make deploy-gateway` so the gateway image picks them up.

### Non-interactive / CI deploy

No browser step. Put Modal API tokens (from https://modal.com/settings/tokens)
and `HF_TOKEN` in `.env`, then:

```bash
make deploy-ci        # auth via env tokens -> (re)create secrets -> deploy all apps + gateway
```

`deploy-ci.sh` reads `MODAL_TOKEN_ID` / `MODAL_TOKEN_SECRET` directly (Modal
honors these env vars, so no `modal setup`), creates the three secrets with
`--force`, and deploys in dependency order. Auto-generates `MODAL_GENAI_VLLM_KEY`
/ `MODAL_GENAI_API_KEY` if unset and prints them (set them in `.env` to keep them
stable across re-deploys). Knobs:

```bash
SKIP_SECRETS=1 ./deploy-ci.sh        # secrets already exist
SKIP_GATEWAY=1 ./deploy-ci.sh        # model apps only
ONLY="llm image" ./deploy-ci.sh      # deploy a subset (+gateway unless skipped)
MODAL_ENVIRONMENT=prod ./deploy-ci.sh  # target a specific Modal environment
```

Two-pass flow (URLs aren't known until the LLM app deploys once): run
`make deploy-ci` → paste the printed vLLM URLs into `config/models.yaml` → re-run
`SKIP_SECRETS=1 ./deploy-ci.sh` to redeploy the gateway with them baked in.

## Use it

The deployed gateway gives you `https://<workspace>--modal-genai-gateway-fastapi.modal.run`.
Point any OpenAI client at it:

```bash
BASE=https://<workspace>--modal-genai-gateway-fastapi.modal.run
KEY=<MODAL_GENAI_API_KEY>

# chat (multimodal Qwen 3.6)
curl $BASE/v1/chat/completions -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3.6","messages":[{"role":"user","content":"Hello"}]}'

# image
curl $BASE/v1/images/generations -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' \
  -d '{"model":"z-image","prompt":"a matte black espresso machine","size":"1024x1024"}'

# speech
curl $BASE/v1/audio/speech -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' \
  -d '{"model":"kokoro","input":"Hello from Modal","voice":"af_heart","response_format":"wav"}' \
  -o speech.wav
```

Python (OpenAI SDK):

```python
from openai import OpenAI
client = OpenAI(base_url=f"{BASE}/v1", api_key=KEY)
client.chat.completions.create(model="qwen3.6", messages=[{"role": "user", "content": "hi"}])
```

## Endpoints

`GET /health` · `GET /v1/models` · `GET /v1/models/{id}/status` ·
`GET /v1/providers/status` · `POST /v1/chat/completions` · `POST /v1/completions` ·
`POST /v1/embeddings` · `POST /v1/audio/speech` · `POST /v1/audio/transcriptions` ·
`POST /v1/audio/translations` · `POST /v1/audio/generations` ·
`POST /v1/images/generations` · `POST /v1/video/generations` ·
`POST /v1/3d/generations` · `GET /v1/tasks/{id}` · `POST /v1/ocr`

Video and 3D return a `task` object (with the artifact base64-encoded plus a path
on the outputs Volume); everything else returns the standard OpenAI body.

## Running the gateway locally

```bash
make serve            # uvicorn on :8080, dispatches to deployed Modal apps
make start / status / stop / logs
make smoke            # exercises every modality against the running gateway
```

## Develop / test

```bash
make test             # offline stub mode, no Modal/GPU needed (13 tests)
```

The gateway package is `src/modal_genai/` (schemas, config, providers, server);
the Modal deployments are `modal_apps/` (one file per modality + `gateway.py`).
Add a model by adding an entry to `config/models.yaml` and, for a new media
backend, a class with an `infer(kind, payload)` method in the matching app.

## Cost notes

Per-second pricing, scale-to-zero (see `docs/modal-platform-notes.md`): L40S
≈$1.95/hr, A100-80GB ≈$2.50/hr, H100 ≈$3.95/hr, L4 ≈$0.80/hr. Idle apps cost
nothing. The big spenders are the H100 models (Qwen3.6-27B-FP8, Wan video) — keep
`min_containers=0` (default) unless you need warm latency, and consider quantized
/ smaller variants (`gemma-4-E4B-it`, `Wan2.2` 1.3B, `qwen-image` GGUF) to drop to
L40S/L4. Adjust `scaledown_window` per app to trade idle cost for cold starts.
