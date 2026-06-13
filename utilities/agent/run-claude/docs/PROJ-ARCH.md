# Project Architecture

run-claude is an agent shim controller providing directory-aware model routing via a LiteLLM proxy. When you `cd` into a directory declaring a profile, the required models are registered with a running LiteLLM proxy and environment variables are set so Claude Code (or other tools) route through it. The system uses a two-layer configuration: **model definitions** (standalone LiteLLM configs in `defaults/models.yaml`) and **profiles** (lightweight references mapping opus/sonnet/haiku tiers to model definitions in `defaults/profiles.yaml`).

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLI Layer (cli.py)                          │
│   Main entry point with command dispatch for enter/leave/proxy      │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐       ┌───────────────┐
│   Profiles    │      │     State     │       │     Proxy     │
│  Management   │      │  Management   │       │  Management   │
│ (profiles.py) │      │  (state.py)   │       │  (proxy.py)   │
└───────┬───────┘      └───────┬───────┘       └───────┬───────┘
        │                      │                       │
        ▼                      ▼                       ▼
┌───────────────┐      ┌───────────────┐       ┌───────────────┐
│  YAML Files   │      │  state.json   │       │ LiteLLM Proxy │
│profiles.yaml  │      │               │       │   (port 4444) │
│ models.yaml   │      │               │       │               │
└───────────────┘      └───────────────┘       └───────┬───────┘
                                                       │
                                               ┌───────▼───────┐
                                               │  TimescaleDB  │
                                               │  (port 5433)  │
                                               └───────────────┘
```

## Core Components

### 1. CLI Layer (`cli.py`)

Entry point handling all user commands.

| Command | Handler | Purpose |
|---------|---------|---------|
| `enter` | `cmd_enter()` | Register directory + profile + token |
| `leave` | `cmd_leave()` | Unregister directory token |
| `janitor` | `cmd_janitor()` | Clean up expired model leases |
| `set-folder` | `cmd_set_folder()` | Configure directory with .envrc |
| `status` | `cmd_status()` | Show proxy & state status |
| `env` | `cmd_env()` | Print environment for profile |
| `proxy` | `cmd_proxy()` | Proxy control (start/stop/status) |
| `db` | `cmd_db()` | Database management (start/stop/migrate) |
| `profiles` | `cmd_profiles()` | Profile management |
| `models` | `cmd_models()` | Model definition management |
| `with` | `cmd_run()` | Run command with profile |
| `install` | `cmd_install()` | Install built-in assets |
| `secrets` | `cmd_secrets()` | Secrets management |

### 2. Profile System (`profiles.py`)

Multi-file configuration with fallthrough loading. Profiles map opus/sonnet/haiku tiers to model definitions. File search order: user override → user → package user → package built-in (first match wins, `model: null` disables and falls through).

Key data structures: `ModelDef` (litellm params), `ProfileMeta` (tier-to-model mapping), `Profile` (meta + resolved model list).

### 3. State Management (`state.py`)

Persistent JSON state tracking tokens (directory-to-profile mapping), model refcounts, and leases. Stored at `~/.local/state/run-claude/state.json`. The refcount-with-lease pattern prevents model thrashing — models at refcount 0 get a 15-minute grace period before the janitor removes them.

### 4. Proxy Management (`proxy.py`)

LiteLLM proxy lifecycle: start/stop subprocess, health checks (30 retries × 10s), and model registration/deletion via HTTP API. Runs on `127.0.0.1:4444` with generated config at `~/.local/state/run-claude/litellm_config.yaml`.

### 5. Secrets Management (`config.py`)

Secure credential storage in `~/.config/run-claude/.secrets` (YAML, mode 0600). Exports to `.env` for Docker Compose. Hydrates `os.environ/VAR` references in model definitions at runtime.

### 6. Hooks System (`hooks/`)

Extensible lifecycle hook system with sequential execution and error isolation. Events: `PRE_REQUEST`, `POST_RESPONSE`, `PRE_TOOL_CALL`, `POST_TOOL_CALL`. YAML-configurable with dynamic module loading. Built-in hooks: `log_request`, `log_response`, `strip_provider_fields`.

### 7. Provider Compat Callback (`callbacks/provider_compat.py`)

LiteLLM custom callback that strips unsupported fields for strict providers (Groq, Cerebras, Together, Anyscale). Uses `_is_strict_provider()` to detect provider from model strings (handles both litellm format like `cerebras/zai-glm-4.7` and model group names like `cerebras-pro/opus`). Strips thinking blocks entirely and cleans tool_use fields. Runs inside the LiteLLM proxy process (separate venv), not the main run-claude process.

## Data Flows

The primary flows are **directory enter** (direnv triggers → load profile → start proxy → register models → set env vars), **directory leave** (decrement refcounts → set leases for cleanup), **janitor cleanup** (expire leases → delete unused models), and **profile resolution** (multi-file fallthrough with env hydration).

→ *See [arch/data-flows.md](arch/data-flows.md) for mermaid flow diagrams*

## Design Patterns

Key patterns: stable token generation (SHA256 hash of directory path), refcount with 15-min lease, `os.environ/VAR` hydration, multi-file config fallback with `model: null` disable, first-run initialization, health check with recovery, and hook chain with error isolation.

→ *See [arch/design-patterns.md](arch/design-patterns.md) for details and code examples*

## Infrastructure

LiteLLM proxy on `127.0.0.1:4444` backed by TimescaleDB (Docker, port `5433`). XDG-compliant paths: config at `~/.config/run-claude/`, state at `~/.local/state/run-claude/`. Proxy uses Prisma ORM for model registry and request logging. Database extensions: `vector` (embeddings), `pg_trgm` (trigram search).

→ *See [arch/infrastructure.md](arch/infrastructure.md) for network diagram, env vars, process lifecycle, and security details*

## External Dependencies

| Package | Purpose |
|---------|---------|
| `pyyaml` | YAML parsing for profiles, models, secrets |
| `httpx` | HTTP client for proxy API calls |
| `psycopg2-binary` | PostgreSQL driver for database testing |
| `prisma` | ORM for LiteLLM proxy (referenced in env) |
