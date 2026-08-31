# Changelog — utilities/agent/run-claude

## [Unreleased]
- Runtime provider-key swap on go-litellm: named key registry (`zai` ← `ZAI_SUB_KEY`, `tyna` ← `ZAI_SUB_KEY_TYNA`) plus `GET/POST /keys`, `POST /keys/switch`. `run-claude keys switch zai tyna` rebinds the `zai/*` family to the Tyna subscription without changing model ids; `keys add` / `keys list` / chat `/key` included. Bindings persist across proxy restarts.
- Profiles that omit `fable_model` export `ANTHROPIC_DEFAULT_FABLE_MODEL` as the opus model so Claude Code's fable alias still resolves.
- Alibaba Token Plan (`QWEN_SUB_KEY`, Anthropic-compat `https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic`): `alibaba` profile tiers fable=`kimi-k3`, opus=`qwen3.8-max`, sonnet=`glm-5.2`, haiku=`qwen3.6-flash`. Chat catalog covers Qwen 3.8/3.7/3.6, DeepSeek V4 Pro/Flash, Kimi K3/K2.7/2.6/2.5, GLM-5.2/5.1/5, MiniMax-M2.5 (skips image/video/audio and Anthropic-incompatible `deepseek-v3.2`). Same set on kitchen-sink / claude-plan / all-sub / claude-enhanced. Optional `fable_model` exports as `ANTHROPIC_DEFAULT_FABLE_MODEL` (falls back to opus).
- Wafer Serverless (`WAFER_AI_API_KEY`, `https://pass.wafer.ai`): live catalog as `WAFER_GLM52`, `WAFER_KIMI_K3`, `WAFER_KIMI_K26`, `WAFER_QWEN35_397B`, `WAFER_DS_V4_FLASH_FAST` plus `[1m]` aliases. `wafer` profile defaults: `wafer/opus[1m]` (Kimi-K3), `wafer/sonnet[1m]` (GLM-5.2), `wafer/haiku` (DeepSeek-V4-Flash-0731-Fast); same set registered on kitchen-sink / claude-plan / all-sub / claude-enhanced.
- Second Z.AI subscription (`ZAI_SUB_KEY_TYNA`): catalog copies `zai-tyna/{opus,sonnet,haiku}` plus `[1m]` variants, registered alongside the `zai/*` set on `zai-pro`, `kitchen-sink`, `claude-plan`, `all-sub`, and `claude-enhanced`.
- Default unified gateway is `go-litellm` (no env var). The launcher resolves the binary from package `bin/`, `~/.local/bin`, PATH, or a source build; `make install` builds it first. Override with `FRONT_PROXY_COMMAND=ex-litellm` or `python` for the legacy two-process path. `run-claude proxy status` names the live implementation (`LiteLLM (real)`, `GoLiteLLM Proxy`, `ElixirLiteLLM Proxy`) and shows Configured when it differs from the running process.
- Groq: strip `pattern` / `patternProperties` from Claude Code tool JSON Schema. Groq's 2020-12 compiler 400s on values such as `^[A-Za-z0-9_=-]{1,4096}$` (`tools[n].function.parameters`).
- groq-pro: GPT-OSS reasoning was swallowed as an empty Claude Code turn. The gateway now hides Groq `reasoning` (`include_reasoning: false`), maps remaining reasoning to Anthropic `thinking` blocks, streams `tool_use`, fails closed on unknown aliases, and surfaces upstream 4xx instead of a fake empty 200 SSE. Claude Code `[1m]` suffixes fall back to the base groq alias. Retired Groq IDs (Llama 3/4, Kimi K2, Qwen3-32b) dropped from the groq-pro picker; Compound / Qwen3.6 / MiniMax M2.7 remain.
- Restructured `docs/` for the per-level NPL arch/layout doc convention: rewrote `PROJ-ARCH.md`/`PROJ-LAYOUT.md` and their summaries, refreshed `docs/layout/run-claude-package.md` (ff72b3565bf, 2026-07-16)
- Added `docs/PROJ-HOWTO.md` + summary + `docs/howto/` extractions: task-oriented guides for install/setup, provider switching, secrets, watchdog lifecycle, model/profile customization, and stuck-state troubleshooting (2026-07-17)
- Added `docs/PROJ-FAQ.md` + summary: motivation/fit/comparison/capability/caveat/trust Q&A cross-linked to PROJ-HOWTO and PROJ-ARCH (2026-07-17)

## [m4-proxy-logging-and-model-refresh] — 2026-07-09 — tag: `utilities-agent-run-claude/m4-proxy-logging-and-model-refresh`
Milestone summary: hardened proxy logging so it never breaks CLI commands and never leaks credentials, and refreshed the default Claude model lineup.

### Added
- Sensitive-key redaction for proxy logs: `SENSITIVE_LOG_KEYS` matching plus URL-credential scrubbing, covered by `tests/test_proxy_logging.py`
- Optional httpx/httpcore debug logging via `RUN_CLAUDE_HTTPX_LOG_FILE` with safe fallback candidates

### Changed
- Proxy log destination now prefers the XDG state dir (`proxy.log`), falling back to `/var/log` only when writable; logging failures can no longer prevent `run-claude proxy status` from importing
- Default Anthropic profiles bumped: `claude-opus-4-6` → `claude-opus-4-8`, `claude-sonnet-4-6` → `claude-sonnet-5` (incl. `[1m]` variants); matching `models.yaml` entries added
- Pinned nodejs `24.18.0` in `.tool-versions`

## [m3-front-proxy-hardening] — 2026-06-27 — tag: `utilities-agent-run-claude/m3-front-proxy-hardening`
Milestone summary: turned the front proxy (:4443) into a first-class auth/bootstrap layer and broadened multi-provider profile coverage.

### Added
- Front-proxy auth handling: `FILL_ME_IN` placeholder substitution, persisted auth state (`front-proxy-auth-state.json`), and JSONL request logging (`tests/test_front_proxy.py`)
- `/bootstrap` endpoint for the Claude CLI: serves available models from LiteLLM `model/info` as `additional_model_options`, merged with local model definitions
- New provider profiles: OpenAI GPT-5.5/5.4, ZAI GLM-5.x, Cerebras GLM, Groq (compound, qwen3-32b, gpt-oss-120b), Grok 4.3, DeepSeek v4 — with ~230 new `models.yaml` entries

### Changed
- Shell hooks (`bash_hook.sh`, `zsh_hook.zsh`) and CLI wiring updated for the new front-proxy flow

## [m2-watchdog-and-model-catalog] — 2026-06-20 — tag: `utilities-agent-run-claude/m2-watchdog-and-model-catalog`
Milestone summary: made the proxy pair self-healing and overhauled the model catalog.

### Added
- Self-healing watchdog daemon (`watchdog.py`, ~300 lines + tests): detached setsid process keeping both the front proxy (:4443) and LiteLLM proxy (:4444) alive; intentional stops recorded via a `stop.marker` sentinel so deliberate `proxy stop` is never undone; re-spawned idempotently by `proxy start` and the shell-hook `enter`
- `run-claude proxy` CLI subcommands and state-dir helpers supporting the watchdog lifecycle

### Changed
- Major `models.yaml` refresh (~250 changed lines) plus updated packaged defaults

## [m1-initial-landing] — 2026-06-14 — tag: `utilities-agent-run-claude/m1-initial-landing`
Milestone summary: the run-claude package lands whole (~16.8k lines) — a multi-provider agent-runner toolkit that fronts Claude Code (and OpenCode) with a local proxy stack.

### Added
- `run_claude` Python package: CLI (`cli.py`), front proxy (`front_proxy.py`, :4443), LiteLLM proxy manager (`proxy.py`/`litellm_proxy.py`, :4444), profile system (`profiles.py`, `profiles.yaml`, packaged defaults), model catalogs (`models.yaml`, ~1300-line default), provider-compat callbacks, hook chain loader/builtins, state management, `agent_runner.py`, `opencode_cli.py`
- Shell integration: `hooks/bash_hook.sh`, `hooks/zsh_hook.zsh`, `hooks/install.sh`; `with-agent-shim` launcher; `scripts/run-litellm-*`
- `dep/` docker-compose stack (LiteLLM + TimescaleDB) and envrc templates
- Docs suite (`docs/PROJ-ARCH*`, `PROJ-LAYOUT*`, arch/ and layout/ subdocs, `PRD-AUTO-INFRA.md`), README, SECRETS guides (quickstart/advanced), CLAUDE.md, Makefile
- Playground projects per provider (cerebras, groq, local, multi) and test suites (`test_cli`, `test_hooks`, `test_callbacks`)
