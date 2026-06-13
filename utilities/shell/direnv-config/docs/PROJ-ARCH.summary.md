# Project Architecture — Summary

**direnv-config** is a YAML-backed configuration layer for direnv consisting of a Rust CLI (`dc`), shell integration hooks, and four read-only SDK clients.

## Components

- **Rust CLI (`dc`)** — Manages YAML config stores: write configs, read values, resolve layers, export as env vars
- **direnv stdlib (`lib/direnv-stdlib.sh`)** — Shell functions (`dc_yaml`, `dc_export`, `dc_get`, `dc_set`) used in `.envrc` files
- **Shell hook (`bin/dc-init`)** — `precmd` hook that watches `.version` for IPC-driven env var reload
- **SDKs (`sdk/`)** — TypeScript, Python, Elixir, PHP read-only clients with native + CLI backends

## Key Architectural Patterns

- **Layer resolution**: `base.yaml` -> `{DC_ENV}.yaml` -> `local.yaml` -> `secrets.yaml`, deep-merged into `.active`
- **Parent chain inheritance**: Stores form an implicit hierarchy by filesystem path; configs deep-merge ancestor-first
- **Tombstone pruning**: `_dc_pruned: true` discards inherited config at any level
- **Flatten rules**: `_dc` config maps YAML paths to env var names (explicit + wildcard)
- **File-based IPC**: Monotonic `.version` counter enables cross-process state sharing via `precmd` polling

## Technology

Rust (clap, serde_yaml, anyhow), POSIX shell, YAML configs stored at `~/.local/state/direnv-config/`.
