# Quality-Based Provider Selection & Eval-Gated Generation (schema v0.4)

Status: approved design — implementation in progress (2026-06-13)

## Motivation

Prompt authors should declare *intent* (asset type, quality tier, duration) and
*acceptance criteria* (eval block), not provider plumbing. The tool owns provider
choice, tries candidates in preference order, grades each output against the
prompt's `eval` section using a hosted Qwen 3.6 model (LM Studio, OpenAI-compatible),
and falls back to the next provider until the output passes or candidates are
exhausted (best-scoring output is then kept, with a warning).

## Schema v0.4 changes (`.media.prompt`)

```yaml
schema: "0.4"
id: hero-001
type: image            # image | music | voice | audio | video | component | react-page |
                       # html | style-guide | diagram | document
                       # NEW: music, voice (replace ambiguous audio+service combos;
                       # bare "audio" with no service is treated as voice)
quality: medium        # NEW: low | medium | high (default: medium)
# service: gemini      # NOW OPTIONAL — explicit service pins provider (skips auto-selection)
# model: imagen-4.0-generate-001   # still optional, only meaningful with service

prompt:
  text: "..."

output:
  duration: 8          # NEW: seconds, for video/music/voice (alias: length)
  formats: [{format: png}]
  dimensions: {aspect_ratio: "16:9"}

eval:                  # drives grading + provider fallback
  pass_threshold: 0.75       # weighted normalized score in [0,1]; default 0.7
  max_attempts: 3            # max provider candidates to try; default: all available
  required_pass: [readability]   # these criteria must individually reach pass_threshold
  criteria:
    composition: {weight: 2, description: "Subject centered, rule of thirds"}
    readability: {weight: 3, description: "Title text crisp and legible",
                  fail_signals: ["garbled text", "missing title"]}
  reject_if:
    - "watermark or signature visible"
    - "extra limbs or malformed anatomy"
```

Back-compat: v0.3 files keep working — `service` present means pinned provider,
absent means auto-select (v0.3's implicit gemini default is dropped; type drives
selection). `quality` absent → `medium`.

## Provider candidate tables

One function owns the mapping (`providers::candidates_for(kind, quality) -> Vec<Candidate{service, model}>`),
ordered best-first, filtered at runtime by API-key availability (`api_key_env` set).
If empty after filtering → hard error listing the missing env vars.

| Kind | low | medium | high |
|---|---|---|---|
| image | gemini/imagen-4.0-fast-generate-001 | gemini/imagen-4.0-generate-001 | gemini/imagen-4.0-ultra-generate-001 → gemini/imagen-4.0-generate-001 |
| video | grok-video/grok-imagine-video → veo/veo-3.0-fast-generate-001 | veo/veo-3.0-fast-generate-001 → grok-video | veo/veo-3.0-generate-001 → grok-video |
| music | suno/V4 | suno/V4_5ALL | suno/V4_5ALL |
| voice | qwen-tts/qwen3-tts-flash → openai-tts/gpt-4o-mini-tts | openai-tts/gpt-4o-mini-tts → elevenlabs/eleven_multilingual_v2 | elevenlabs/eleven_multilingual_v2 → openai-tts/gpt-4o-mini-tts |
| chat (component/react-page/html/style-guide/diagram/document/svg) | gemini-chat/gemini-2.5-flash → openai-chat/gpt-4.1 | anthropic/claude-sonnet-4-6 → openai-chat/gpt-4.1 → gemini-chat/gemini-2.5-flash | anthropic/claude-opus-4-6 → anthropic/claude-sonnet-4-6 → gemini-chat/gemini-2.5-pro |

CLI `--service`/`--model` override everything; YAML `service:` pins; otherwise table order.

## Generation loop (pipeline)

For each output path:

1. Resolve candidate list (pinned service → single entry; else table, capped by `eval.max_attempts`).
2. For each candidate provider: generate `variant_count` variants (existing logic).
3. If an `eval` block exists and the evaluator endpoint is reachable:
   score every variant; best variant passes (weighted score ≥ pass_threshold,
   all `required_pass` criteria individually ≥ threshold, no `reject_if` hit) → accept, stop.
   Otherwise remember global best (score, path) and continue to next provider.
4. No eval block / evaluator unreachable: legacy behavior (multi-variant → pick best
   via evaluator if reachable, else Groq fallback if GROQ_API_KEY set, else first;
   accept immediately, no provider fallback).
5. Candidates exhausted without a pass: keep global best, emit warning with scores.

## Evaluator (eval.rs)

OpenAI-compatible chat completions client.

Endpoint resolution (first reachable wins; probe = GET `{base}/models`, 2s timeout):
1. `MEDIA_EVAL_BASE_URL` env / `--eval-url`
2. `http://192.168.68.59:3713/v1` — LAN inference server hosting Qwen 3.6 (also
   forwards to noizu.server, which the cluster's socat bridge targets)
3. `http://noizu.server:3713/v1` — noizu.server forward of the LAN inference server
4. `http://lmstudio-proxy:3713/v1` — in-cluster service (platform-ai ns; socat bridge)
5. `http://127.0.0.1:3713/v1` — `kubectl port-forward` of the in-cluster bridge

Model: `MEDIA_EVAL_MODEL` / `--eval-model`, else auto-discover from `/models`:
prefer id containing `qwen3.6` or `qwen-3.6`, else any `qwen`, else first
non-embedding model. API key: `MEDIA_EVAL_API_KEY`, default `lm-studio`.
Request timeout: `MEDIA_EVAL_TIMEOUT` seconds, default 300 — the hosted model is a
reasoning model (slow first token); responses may carry a `<think>…</think>` block
which is stripped before JSON parsing.

Scoring request: system prompt instructs the model to grade the artifact against the
criteria and reply ONLY with JSON:
`{"scores": {"<criterion>": 0-10, ...}, "reject_hits": ["<matched reject_if>"], "notes": "..."}`.
Weighted score = Σ(w·s/10)/Σw. Parse defensively (strip fences); on parse failure
retry once, then treat as un-scorable.

Artifact handling by output extension:
- images (png/jpg/jpeg/webp): base64 `image_url` part
- text-like (svg/mmd/puml/dot/html/tsx/ts/js/md/json/txt/css): inline text content (truncate ~32KB)
- video (mp4/webm/mov): if `ffmpeg` on PATH, extract ≤4 evenly-spaced frames to temp PNGs and send as images; else un-scorable
- audio (mp3/wav/ogg/flac): un-scorable (warn, accept) — until an audio-capable eval model is wired

Un-scorable artifacts never block: warn + accept first successful generation.

## Duration

`output.duration` (seconds, serde alias `length`) flows into `GenerationOptions.duration_seconds`
and is wired per provider where the API supports it (veo `durationSeconds`,
grok-video duration param, suno track-length hint); ignored elsewhere with a verbose note.

## CLI additions

`--quality <low|medium|high>` (override), `--service <svc>` (pin), `--no-eval`
(skip grading/fallback), `--eval-url <url>`, `--eval-model <id>`.

## Local access to the cluster evaluator

Helper: `bin/media-eval-port-forward` — loops
`kubectl --context noizu -n platform-ai port-forward svc/lmstudio-proxy 3713:3713`.
Needed when the LAN server (192.168.68.59:3713) isn't directly reachable from this
machine. Note: the in-cluster bridge targets the host-side tunnel on node
k8s-mvm-2 (127.0.0.1:3713), fed by the LAN server's forward to noizu.server — that
leg must be up for in-cluster (and port-forwarded) eval to work.
