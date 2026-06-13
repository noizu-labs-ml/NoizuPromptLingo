# Project Architecture Summary

run-claude is an agent shim controller providing directory-aware model routing via a LiteLLM proxy. When entering a directory with a declared profile, models are registered with the proxy and environment variables route Claude Code through it.

## Components

- **CLI** (`cli.py`): Entry point with subcommands — enter, leave, janitor, set-folder, status, env, proxy, db, profiles, models, with, install, secrets.
- **Profiles** (`profiles.py`): Multi-file YAML profile loading with fallthrough (user override > user > built-in). Profiles map opus/sonnet/haiku tiers to model definitions.
- **State** (`state.py`): JSON persistence for tokens, refcounts, model leases, and proxy PID.
- **Proxy** (`proxy.py`): LiteLLM proxy lifecycle — start/stop, health checks, model registration via HTTP API.
- **Config** (`config.py`): Secrets management (YAML, mode 0600), .env generation for Docker, env var hydration.
- **Hooks** (`hooks/`): Extensible lifecycle hook system with sequential execution and error isolation. Events: PRE_REQUEST, POST_RESPONSE, PRE_TOOL_CALL, POST_TOOL_CALL. YAML-configurable with dynamic module loading.
- **Provider Compat** (`callbacks/provider_compat.py`): Strips unsupported fields and thinking blocks for strict providers (Groq, Cerebras, Together, Anyscale). Uses `_is_strict_provider()` for model string detection. Runs in LiteLLM proxy process.

## Key Patterns

- Stable tokens via SHA256 hash of directory path
- Refcount with 15-min lease prevents model thrashing
- `os.environ/VAR` syntax hydrated at runtime
- Multi-file config fallback with `model: null` disable
- Hook chain with error isolation (one failure doesn't break others)
- Strict provider detection handles both litellm and model group names

## Infrastructure

- LiteLLM proxy: `127.0.0.1:4444`
- TimescaleDB: Docker container, port `5433`
- Config: `~/.config/run-claude/` (XDG)
- State: `~/.local/state/run-claude/` (XDG)

## Detailed Docs

- [arch/data-flows.md](arch/data-flows.md) — Mermaid flow diagrams for enter/leave/janitor/resolution
- [arch/design-patterns.md](arch/design-patterns.md) — Pattern details with code examples
- [arch/infrastructure.md](arch/infrastructure.md) — Network, env vars, process lifecycle, security
