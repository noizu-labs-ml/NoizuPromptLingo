# Project Architecture Summary

run-claude provides directory-aware model routing for Claude Code and OpenCode via a self-healing local LLM gateway. Entering a directory with a declared profile registers models with the proxy and sets environment variables routing Claude Code or OpenCode through it. Runtime traffic flows through a two-proxy chain — front proxy (:4443) → LiteLLM proxy (:4444) — kept alive by a self-healing watchdog daemon.

## Components

- **CLI** (`cli.py`): Subcommands — enter, leave, janitor, set-folder, status, env, proxy, db, profiles, models, with, install, secrets.
- **OpenCode CLI** (`opencode_cli.py`): `run-open-code` entry point sharing the same command handlers.
- **Agent runner** (`agent_runner.py`): Shared Claude/OpenCode launch logic; sets ANTHROPIC_BASE_URL to the front proxy and per-tier model vars.
- **Profiles** (`profiles.py`): Multi-file YAML loading with fallthrough (user override > user > built-in). Maps opus/sonnet/haiku tiers to model definitions.
- **State** (`state.py`): JSON persistence for tokens, refcounts, model leases, PIDs, stop marker.
- **Proxy lifecycle** (`proxy.py`): LiteLLM start/stop, health checks, model registration via HTTP API.
- **Front proxy** (`front_proxy.py`): Always-on reverse proxy :4443 → :4444; in passthrough mode (claude-plan profile) Anthropic models forward to api.anthropic.com with original OAuth auth.
- **Watchdog** (`watchdog.py`): Detached daemon restarting either proxy when down; a stop.marker sentinel distinguishes intentional stops from crashes.
- **LiteLLM launcher** (`litellm_proxy.py`): `run-litellm-proxy` entry; prisma schema patching then exec litellm.
- **Config** (`config.py`): Secrets (YAML, mode 0600), .env generation, env var hydration.
- **Hooks** (`hooks/`): Lifecycle hook chain (PRE_REQUEST, POST_RESPONSE, PRE/POST_TOOL_CALL) with error isolation.
- **Provider Compat** (`callbacks/provider_compat.py`): Strips unsupported fields and thinking blocks for strict providers (Groq, Cerebras, Together, Anyscale); runs in the LiteLLM proxy process.

## Key Patterns

- Stable tokens via SHA256 hash of directory path
- Refcount with 15-min lease prevents model thrashing
- `os.environ/VAR` syntax hydrated at runtime
- Multi-file config fallback with `model: null` disable
- Stop-marker sentinel: watchdog honors intentional stops, auto-restarts crashes
- Hook chain with error isolation
- Strict provider detection handles both litellm and model group names

## Infrastructure

- Front proxy: `127.0.0.1:4443` (agent-facing endpoint)
- LiteLLM proxy: `127.0.0.1:4444`
- TimescaleDB: Docker container, port `5433` (extensions: vector, pg_trgm)
- Config: `~/.config/run-claude/` (XDG); State: `~/.local/state/run-claude/` (XDG)

## Ecosystem Fit

Lives at `utilities/agent/run-claude` in the Noizu Infra monorepo but is not part of the shell-utility toolchain: no k8-lib, not installed by `make install-utilities`, no `.infra-config.yaml` target. Self-contained Python package (hatchling + uv) installed via `make install` (`uv tool install .`); console scripts: run-claude, run-open-code, run-litellm-proxy. Provides per-directory provider routing (Groq, Cerebras, Ollama, mixed) for agent sessions working on the monorepo. LiteLLM upstream pinned as submodule at `repos/litellm`.

## Detailed Docs

- [arch/data-flows.md](arch/data-flows.md) — Mermaid flow diagrams for enter/leave/janitor/resolution
- [arch/design-patterns.md](arch/design-patterns.md) — Pattern details with code examples
- [arch/infrastructure.md](arch/infrastructure.md) — Network, env vars, process lifecycle, security
