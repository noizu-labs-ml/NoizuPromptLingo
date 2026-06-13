# NEXT-STEPS — Modal GenAI Gateway integration handoff

**Audience:** the engineer taking this from "scaffolded + locally verified" to
"deployed on Modal and integrated into product."
**Status date:** 2026-06-08
**Location:** `Space/Infra/Noizu/services/modal`

This document is intentionally verbose. Read the **"What is and isn't verified"**
section first — it is the difference between "looks done" and "is done."

---

## 1. TL;DR for the impatient

1. The gateway (OpenAI-compatible router) and all 10 Modal app definitions are
   written, compile, build a valid Modal object graph (modal 1.4.3), and the
   gateway serves every route end-to-end **in stub mode**. 13/13 unit tests pass.
2. **No model has actually run on a GPU yet.** Every media model's inference body
   and every vLLM launch was written against the libraries' documented APIs but
   has **not** been executed on hardware. Treat each as "needs a first-run
   shakedown," not "working."
3. The single biggest blocker: **the pinned vLLM version (`0.8.5`) predates
   Qwen3.6 / Gemma-4 / GLM-4.6V and will not recognize their architectures.**
   Bump it before deploying `llm.py`. See §4.1.
4. Deploy path is `make deploy-ci` (env-token auth + secrets + all apps), then
   paste the printed vLLM URLs into `config/models.yaml`, then redeploy the
   gateway. See §5.

---

## 2. What this is

A Modal/NVIDIA counterpart to the Apple-Silicon `Services/GenAI` gateway. One
OpenAI-compatible HTTPS endpoint that fans out, by `model` id, to:

- **vLLM apps** (`modal_apps/llm.py`) — Qwen3.6, Gemma-4, GLM-4.6V, an embedding
  model. vLLM exposes a native `/v1/...` surface; the gateway proxies to it.
- **Media classes** (`modal_apps/{image,tts,stt,music,sfx,video,threed}.py`) —
  each a Modal `@app.cls` with a single `infer(kind, payload)` method. The
  gateway dispatches via `modal.Cls.from_name(app, cls).infer.remote.aio(...)`
  and reshapes the result into the matching OpenAI response.

The gateway itself is `modal_apps/gateway.py` (a Modal `asgi_app`) for a single
public URL, or `make serve` to run it locally against the deployed apps.

Read `README.md` for the user-facing overview and `docs/modal-platform-notes.md`
for how Modal works. Model selection rationale + licenses live in `models.md`.

---

## 3. What is and isn't verified

### Verified locally (in this sandbox, no GPU)

- `src/modal_genai/*` and `modal_apps/*` all `py_compile` clean.
- All 10 `modal_apps` modules **import and build the real Modal object graph**
  under modal 1.4.3 (this caught and fixed a real bug: web-server functions must
  be module-global, not closures — see git history of `llm.py`).
- The gateway boots under real `uvicorn` and correctly serves `/health`,
  `/v1/models`, `/v1/chat/completions`, `/v1/images/generations`,
  `/v1/audio/speech`, `/v1/3d/generations` **in stub mode**.
- `tests/test_gateway.py` — 13 tests, all passing (`make test`).
- `deploy-ci.sh` dry-run (stubbed `modal` binary): auth-gating, secret creation,
  app ordering, and the `ONLY` / `SKIP_SECRETS` / `SKIP_GATEWAY` knobs all behave.

### NOT verified — needs a real deploy + GPU (this is the actual work)

| Area | Risk | Where |
|---|---|---|
| vLLM model-arch support | **High** — pinned vLLM is too old for the 2026 models | `modal_apps/common.py` `vllm_image()` |
| Media inference bodies | **High** — diffusers/kokoro/faster-whisper/acestep/stable-audio/wan/trellis calls never executed | each `modal_apps/*.py` |
| PyPI package names/versions | **Medium** — some installs (`acestep`, `trellis`, model repo extras) may need GitHub installs or different names | `*_image` builders |
| HF repo IDs + access | **Medium** — repo existence confirmed via Hub search; exact files/revisions and gated-access acceptance not confirmed | `config/models.yaml`, app `MODEL`/`REPO` constants |
| GPU availability/fit | **Medium** — VRAM math from `models.md`; not benchmarked | `gpu=` per app |
| Cold-start vs `startup_timeout` | **Medium** — first run pulls tens of GB; may exceed timeouts | per app |
| `modal.Cls.from_name` dispatch | **Medium** — gateway→class call path not run live | `providers.py` `ModalClsProvider` |
| Secrets/Volumes at runtime | **Low/Medium** — wiring is standard but untested | `common.py` |

---

## 4. Per-modality notes, risks, and required actions

### 4.1 LLMs — `modal_apps/llm.py` (REQUIRED ACTION before deploy)

- **Bump vLLM.** `common.py:vllm_image()` pins `vllm==0.8.5`. That release
  predates Qwen3.6 (`qwen3_5`/`qwen3_6` model types), Gemma-4 (`gemma4`), and
  GLM-4.6V (`glm4v`). It **will fail** to load these with "unknown architecture."
  Pin to a vLLM release that lists support for all three (check the vLLM
  changelog / `vllm/model_executor/models`), or build from a recent commit. This
  is the #1 thing to fix.
- **Multimodal serving.** Qwen3.6, Gemma-4, and GLM-4.6V are image-text-to-text.
  Confirm the chosen vLLM version serves their vision path and that you pass any
  required flags (e.g. `--limit-mm-per-prompt`, `--max-model-len` sufficient for
  image tokens). The gateway forwards arbitrary OpenAI fields, so vision content
  blocks pass through unmodified.
- **FP8 + H100.** `Qwen/Qwen3.6-27B-FP8` assumes Hopper FP8. If H100 capacity is
  tight, switch to the non-FP8 `Qwen/Qwen3.6-27B` on A100-80GB, or the MoE
  `Qwen/Qwen3.6-35B-A3B`. Update both `llm.py` (`gpu=`, repo) and the
  `config/models.yaml` metadata.
- **Embeddings.** `embed` uses `--task embed`. Confirm the flag name for your
  vLLM version (older builds used `--task embedding`).
- **`--api-key`.** Each server is launched with the shared `MODAL_GENAI_VLLM_KEY`
  from the `modal-genai-vllm` secret; the gateway sends it as the bearer token
  (config `providers.vllm-*.api_key: ${MODAL_GENAI_VLLM_KEY}`, expanded from env).
- **Startup timeout.** `startup_timeout=720s`. First boot also downloads weights
  to the HF-cache Volume; 27B FP8 is ~30GB. If the first cold start times out,
  raise it or pre-warm the Volume with a one-off `modal run` download.

### 4.2 Image — `modal_apps/image.py`

- Three classes: `ZImage` (Z-Image-Turbo, L40S, 8-step — the default fast pick),
  `QwenImage` (A100-80GB), `SDXL` (L40S).
- **Pipeline classes are assumptions.** `ZImage`/`QwenImage` use
  `DiffusionPipeline.from_pretrained(..., trust_remote_code=True)`. Confirm the
  actual diffusers pipeline class and call signature for each repo (Z-Image uses
  a custom S3-DiT; it may ship its own pipeline or require a specific diffusers
  version / custom code). SDXL uses `StableDiffusionXLPipeline` with
  `variant="fp16"` — confirm the fp16 variant exists for the pinned repo.
- Verify `num_inference_steps`, `guidance`/`true_cfg`, and width/height handling
  per model. Z-Image-Turbo is distilled; do **not** crank steps.
- Image-edit (`image` field) is accepted by the schema but the bodies currently
  do text-to-image only. Wire edit pipelines if you need Qwen-Image-Edit.

### 4.3 TTS — `modal_apps/tts.py` (Kokoro)

- `kokoro` PyPI package + `KPipeline(lang_code="a")`. Confirm package version and
  that voices (`af_heart` default) download at runtime. `misaki[en]` provides the
  English G2P. Output is 24kHz WAV.
- For non-English, `lang_code` must change per request — currently fixed to `a`
  (American English). Extend `infer` to map a `language` field if needed.

### 4.4 STT — `modal_apps/stt.py` (Whisper large-v3-turbo)

- Uses `faster-whisper` (CTranslate2) with `deepdml/faster-whisper-large-v3-turbo-ct2`.
  Confirm that repo id and `compute_type="float16"` on L4. `task` is
  transcribe/translate. Returns text + segments.
- Alternative: `models.md` notes vLLM can serve Whisper natively
  (`--task transcription`) for a literal `/v1/audio/transcriptions`. If you'd
  rather keep ASR on vLLM, move it into `llm.py` and switch the provider kind to
  `vllm` in config. The current design keeps it as a media class for uniformity.

### 4.5 Music — `modal_apps/music.py` (ACE-Step)

- **Package name risk.** `pip_install("acestep")` — verify the real distribution.
  ACE-Step is commonly installed from its GitHub repo
  (`git+https://github.com/ace-step/ACE-Step.git`) rather than a PyPI wheel.
  Adjust `IMAGE` accordingly.
- `ACEStepPipeline(checkpoint_dir=...)` and the `__call__` signature
  (`prompt`, `lyrics`, `audio_duration`, `infer_step`, `guidance_scale`) are
  assumptions — confirm against the installed version. The OpenAI single `prompt`
  is mapped to the style/tags field with empty lyrics; expose a `lyrics` field if
  you want lyric-driven songs.

### 4.6 SFX — `modal_apps/sfx.py` (Stable Audio Open 1.0)

- **License: Stability AI Community License — free only under $1M annual revenue.**
  This is the one non-permissive backend. Before this ships to a revenue-bearing
  product, confirm you're under the cap or buy the Stability Enterprise license,
  or drop this model and repurpose ACE-Step for SFX. Tracked in `models.md` §7.
- Uses `stable-audio-tools` `get_pretrained_model` + `generate_diffusion_cond`.
  Confirm `sample_size`/`sample_rate` from the model config and the output tensor
  layout (code assumes `(batch, channels, samples)` → transpose to
  `(samples, channels)`).

### 4.7 Video — `modal_apps/video.py` (Wan 2.2)

- `Wan-AI/Wan2.2-T2V-A14B-Diffusers` via diffusers `WanPipeline` + `AutoencoderKLWan`.
  Confirm these classes exist in your diffusers version (Wan support is recent)
  and the `num_frames`/`fps`/guidance params. 14B on H100; if cost/availability
  is a problem, switch to the 1.3B variant on L40S.
- Returns a `task` object with the mp4 inlined as base64 **and** written to the
  `modal-genai-outputs` Volume. For large/long clips, base64 in JSON is heavy —
  consider returning only the Volume path + a short-lived download endpoint.
- Image-to-video (`image` field) is accepted but not wired; add the I2V pipeline
  if needed.

### 4.8 3D — `modal_apps/threed.py` (TRELLIS.2)

- **Heaviest build.** Uses a CUDA `devel` base and builds custom ops
  (`xformers`, sparse/voxel kernels, `spconv`, `flash-attn` via `ATTN_BACKEND`).
  Expect a slow first image build and possible compilation pitfalls (CUDA/torch
  ABI). Budget time here.
- `trellis` package name + `TrellisImageTo3DPipeline.from_pretrained(MODEL)` and
  `postprocessing_utils.to_glb(...)` are assumptions — TRELLIS is often installed
  from its GitHub repo with extra setup. Verify against the official install.
- Image-to-3D only (by design). Pair with `z-image` for text-to-3D: generate an
  image, pass its data URL / path as `image`. (`_materialize_image` handles data
  URLs, http(s) URLs, and local paths.)

### 4.9 OCR / vision

- `/v1/ocr` currently resolves to the stub. If you need OCR, either point a
  `local-ocr` model at GLM-4.6V/Qwen3-VL via the chat path, or add a `modal_cls`
  OCR backend. Vision Q&A already works through the multimodal chat models.

---

## 5. Deploy runbook

### 5.0 Prerequisites

- A Modal account + workspace; API token from <https://modal.com/settings/tokens>.
- A Hugging Face token (`HF_TOKEN`) with access accepted for any gated repos.
  **Check each model's HF page for a license/access gate** (Gemma historically
  required acceptance; Wan/TRELLIS/Qwen-Image may too). Accept before first pull.
- `uv` installed. `uv sync --extra modal` to get the gateway deps + modal client.

### 5.1 One-time secrets (or let `deploy-ci.sh` do it)

```bash
modal secret create huggingface HF_TOKEN=hf_xxx
modal secret create modal-genai-vllm  MODAL_GENAI_VLLM_KEY=$(openssl rand -hex 24)
modal secret create modal-genai-gateway \
    MODAL_GENAI_API_KEY=$(openssl rand -hex 24) \
    MODAL_GENAI_VLLM_KEY=<same vllm key>
```

### 5.2 Interactive deploy

```bash
modal setup                 # browser auth
make deploy-llm             # fix vLLM version FIRST (see §4.1)
make deploy-image           # ... and so on; shake each one out individually
make deploy-gateway         # last
```

Deploy and validate **one app at a time** the first time, not `make deploy` all
at once — you want to see each model's first-run logs in isolation.

### 5.3 Non-interactive / CI deploy

Put `MODAL_TOKEN_ID`, `MODAL_TOKEN_SECRET`, `HF_TOKEN` (and ideally stable
`MODAL_GENAI_VLLM_KEY` / `MODAL_GENAI_API_KEY`) in `.env`, then:

```bash
make deploy-ci                      # auth + secrets + all apps + gateway
SKIP_SECRETS=1 ./deploy-ci.sh       # secrets already exist
ONLY="llm image" ./deploy-ci.sh     # subset
MODAL_ENVIRONMENT=prod ./deploy-ci.sh
```

Note: `deploy-ci.sh` calls the `modal` binary on `PATH`. In a uv-managed venv,
either activate it or set `MODAL_BIN="uv run modal"`.

### 5.4 The two-pass URL step (important)

vLLM URLs aren't known until `llm.py` deploys once. After the first deploy:

1. Note the four printed URLs:
   `https://<workspace>--modal-genai-llm-{qwen,gemma,glm,embed}.modal.run`.
2. Paste each into `config/models.yaml` → `providers.vllm-*.base_url` (append
   `/v1`).
3. Redeploy the gateway so the baked config picks them up:
   `SKIP_SECRETS=1 SKIP_GATEWAY=0 ONLY= ./deploy-ci.sh` or `make deploy-gateway`.

The gateway image bakes `config/models.yaml` (`add_local_dir` in
`modal_apps/gateway.py`), so config changes require a gateway redeploy.

---

## 6. Validation checklist (do this after deploy)

```bash
BASE=https://<workspace>--modal-genai-gateway-fastapi.modal.run
KEY=<MODAL_GENAI_API_KEY>
```

- [ ] `curl $BASE/health` → `{"status":"ok","stub_mode":false,...}`
      (**stub_mode must be false** in the deployed gateway).
- [ ] `curl -H "Authorization: Bearer $KEY" $BASE/v1/models` lists all 13.
- [ ] Chat: each of `qwen3.6`, `gemma-4`, `glm-4.6v` returns a real completion
      (not the stub string "Stub chat provider...").
- [ ] Vision: send an image content block to `glm-4.6v` / `qwen3.6`.
- [ ] Embeddings: `embed` returns vectors of the expected dimension.
- [ ] Image: `z-image` returns a decodable PNG > 1KB (stub is 70 bytes).
- [ ] TTS: `kokoro` returns playable WAV.
- [ ] STT: round-trip the TTS WAV through `whisper`.
- [ ] Music/SFX: `ace-step` / `stable-audio` return audio.
- [ ] Video/3D: `wan` / `trellis` return a `completed` task with a real artifact.
- [ ] `BASE_URL=$BASE API_KEY=$KEY ./smoke-test.sh` passes end-to-end.

A response that still contains a `Stub ...` string means that provider fell back
to stub — check `stub_mode` and that the provider kind/`base_url` are correct.

---

## 7. Product integration

- **Auth:** clients send `Authorization: Bearer <MODAL_GENAI_API_KEY>`. Rotate by
  updating the `modal-genai-gateway` secret + redeploying the gateway.
- **OpenAI SDK / LiteLLM:** point `base_url` at `"$BASE/v1"`. For LiteLLM, register
  each `model` id as a custom OpenAI provider against the same base; media routes
  (`/v1/images`, `/v1/audio`, `/v1/3d`, `/v1/video`) are standard-ish OpenAI
  shapes (video/3d return a `task` object, not OpenAI-native — handle accordingly).
- **Adding a model:** add an entry to `config/models.yaml` (a `model` + a
  `provider`). For a new media backend, add a class with `infer(kind, payload)`
  to the relevant `modal_apps/*.py` and point the provider's `app_name`/`cls_name`
  at it. For a new LLM, add a `@modal.web_server` function in `llm.py` and a
  `vllm` provider with its URL. Redeploy the app + the gateway.
- **The `infer` contract** (what a media class must return):
  - speech / audio: `{"audio_base64": str, "media_type": "audio/wav"}`
  - image: `{"images": [{"b64_json": str}], "revised_prompt": str}`
  - transcribe/translate: `{"text": str, "segments": [...]}`
  - video/3d: `{"status": "completed", "output": {...}}`
  See `providers.py:ModalClsProvider` for the exact mapping.

---

## 8. Operations & cost

- **Scale-to-zero** is the default; idle apps cost nothing. Cold starts pull
  weights from the HF-cache Volume (fast after the first pull). Tune
  `scaledown_window` (per app) to trade idle cost for latency, and set
  `min_containers>0` only where you need always-warm latency (you pay for the
  reserved GPU).
- **Per-second GPU rates** (≈, see `docs/modal-platform-notes.md`): L4 $0.80/hr,
  L40S $1.95, A100-80GB $2.50, H100 $3.95. The H100 models (Qwen3.6 FP8, Wan) are
  the cost drivers — consider smaller/quantized variants if usage is bursty.
- **Concurrency:** vLLM functions use `@modal.concurrent(max_inputs=...)` so one
  GPU serves many requests via continuous batching; tune per model. Media classes
  default to one request at a time per container; raise `max_containers` to fan
  out, or add `@modal.concurrent` if the backend is thread/async-safe.
- **Observability:** `modal app logs <app-name>` per app; the gateway exposes
  `/v1/providers/status` and `/v1/models/{id}/status`. Wire these into health
  checks. There is currently no metrics export — add one if you need SLOs.
- **First-pull pre-warming:** to avoid first-request timeouts, pre-download
  weights into the Volume with a throwaway `modal run` that just instantiates the
  class / runs `vllm serve --download-dir` once.

---

## 9. Known gaps / backlog

- [ ] **Bump vLLM** to a version supporting Qwen3.6 / Gemma-4 / GLM-4.6V (§4.1).
- [ ] Validate every media `infer` body on its target GPU (§3, §4).
- [ ] Confirm PyPI vs GitHub installs for `acestep`, `trellis`,
      `stable-audio-tools`, Z-Image custom code.
- [ ] Confirm/accept HF gated access for all repos before first pull.
- [ ] Streaming: `/v1/chat/completions` `stream:true` is forwarded but the proxy
      currently awaits full JSON — add true SSE pass-through for token streaming.
- [ ] Video/3D artifact delivery: replace inline base64 with Volume + signed
      download URLs for large outputs.
- [ ] OCR backend (currently stub) — wire to a VLM if required.
- [ ] Image-edit and image-to-video paths (schemas accept inputs; bodies are
      text-only today).
- [ ] No rate limiting / quota in the gateway beyond the bearer key — add if
      exposed beyond internal use.
- [ ] `requires-python>=3.11`; CI/build hosts need a 3.11+ interpreter (the
      sandbox this was built in only had 3.10, which runs the gateway fine but
      `uv sync` wants 3.11+).
- [ ] Add an integration test that runs against a real deployed gateway (the
      current suite is offline/stub only).

---

## 10. File map

```
services/modal/
  README.md                 user-facing overview + quick start
  NEXT-STEPS.md             this file
  models.md                 model selection + license analysis (source of truth for picks)
  docs/
    modal-platform-notes.md how Modal works (pricing, primitives, cold starts)
    modal-examples.md        pointers to modal-labs/modal-examples
  pyproject.toml            gateway package + [modal] extra
  Makefile                  sync / deploy* / serve / start|stop|status / test / smoke
  deploy-ci.sh              non-interactive deploy (env tokens + secrets + apps)
  smoke-test.sh             exercise every modality against a running gateway
  .env.example              all env vars (gateway, vLLM key, Modal tokens, HF)
  config/models.yaml        model -> provider routing (EDIT vLLM base_urls post-deploy)
  src/modal_genai/          the gateway (FastAPI, OpenAI-compatible)
    openai_schemas.py       request/response models
    config.py               YAML loader (+${ENV} expansion), provider/model schema
    settings.py             env-driven settings (host/port/api_key/stub_mode)
    providers.py            Stub / vLLM-proxy / OpenAI-proxy / ModalCls dispatch + registry
    server.py               /v1/* routes
    main.py                 local uvicorn entrypoint
  modal_apps/               Modal deployments (one per modality + gateway)
    common.py               shared image builders, Volumes, Secrets  <-- vLLM PIN HERE
    llm.py                  vLLM: qwen / gemma / glm / embed          <-- FIX VERSION
    image.py                ZImage / QwenImage / SDXL
    tts.py                  Kokoro
    stt.py                  Whisper
    music.py                AceStep
    sfx.py                  StableAudio (revenue-capped license)
    video.py               Wan
    threed.py              Trellis (heavy CUDA build)
    gateway.py             OpenAI-compatible router as a Modal asgi_app
  tests/test_gateway.py     13 offline stub-mode tests
```

---

## 11. Contacts / provenance

- Built to mirror `Space/Services/GenAI` (Apple-Silicon gateway) — same `/v1/*`
  surface and provider-registry shape, so client code is portable between them.
- Model picks and license caveats: see `models.md` (commercial-license aware).
- Modal mechanics and pricing: see `docs/modal-platform-notes.md`.
- If a model id or repo needs changing, it's a one-line edit in
  `config/models.yaml` plus the matching `MODEL`/`REPO` constant in the app file;
  redeploy the app and the gateway.
