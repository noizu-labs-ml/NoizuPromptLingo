# Project Architecture

## Overview

`direnv-config` replaces sprawling `export VAR=value` `.envrc` files with structured, versioned, mergeable YAML configs. A Rust CLI (`dc`) manages config stores on disk; a direnv stdlib extension (`dc_yaml`, `dc_export`) bridges the YAML store into shell environment variables. A `precmd` shell hook watches for version changes, enabling child-process IPC — any process can mutate the YAML store and the parent shell picks up changes on the next prompt.

Four read-only SDK clients (TypeScript, Python, Elixir, PHP) provide application-level access to resolved configs without shelling out.

## System Diagram

```mermaid
graph TB
    subgraph Shell["Shell Environment"]
        envrc[".envrc<br/>dc_yaml + dc_export"]
        precmd["precmd hook<br/>(dc-init)"]
        env["Exported ENV vars"]
    end

    subgraph CLI["dc CLI (Rust)"]
        yaml_cmd["dc yaml"]
        get_cmd["dc get"]
        set_cmd["dc set"]
        env_cmd["dc env"]
    end

    subgraph Store["YAML Store (~/.local/state/direnv-config/)"]
        layers["Layer Files<br/>base → env → local → secrets"]
        active[".active<br/>(resolved snapshot)"]
        version[".version<br/>(monotonic counter)"]
        dc_cfg["_dc/base.yaml<br/>(flatten rules)"]
    end

    subgraph SDKs["SDK Clients (read-only)"]
        ts["TypeScript"]
        py["Python"]
        ex["Elixir"]
        php["PHP"]
    end

    envrc -->|writes| yaml_cmd
    yaml_cmd -->|merge + resolve| layers
    layers -->|deep merge| active
    yaml_cmd -->|bumps| version
    envrc -->|reads| env_cmd
    env_cmd -->|flatten rules| dc_cfg
    env_cmd -->|reads| active
    env_cmd -->|emits exports| env
    precmd -->|watches| version
    precmd -->|re-evals| env_cmd
    set_cmd -->|writes local.yaml| layers
    get_cmd -->|reads| active
    ts & py & ex & php -->|reads| active
```

## Core Components

| Component | Purpose |
|-----------|---------|
| `src/cmd/` | CLI subcommands (yaml, get, set, env, init, list, bump, prune, purge, secrets, status, unset) |
| `src/store/` | Store discovery, layout, version tracking, layer resolution, parent-chain merging |
| `src/yaml/` | Deep merge engine, path expression evaluator, flatten-to-env-var system |
| `lib/direnv-stdlib.sh` | direnv extension functions (`dc_yaml`, `dc_export`, `dc_get`, `dc_set`) |
| `bin/dc-init` | Shell hook generator — registers `precmd` for version-based IPC |
| `sdk/` | Read-only clients in 4 languages with native and CLI backends |

## Layer Resolution

Configs within a single store resolve by deep-merging YAML layers in fixed order: `base.yaml` -> `{DC_ENV}.yaml` -> `local.yaml` -> `secrets.yaml`. The merged result is written to `.active`.

-> *See [arch/layer-resolution.md](arch/layer-resolution.md) for details*

## Parent Chain Inheritance

Stores form an implicit hierarchy based on filesystem path. A store for `/Users/keith/Github/k8/projects` inherits from `/Users/keith/Github/k8` if that store exists. Resolution walks the ancestor chain and deep-merges `.active` files from oldest to newest. A `_dc_pruned: true` tombstone at any level discards all prior layers.

-> *See [arch/parent-chain.md](arch/parent-chain.md) for details*

## Flatten Rules

The `_dc` named config contains flatten rules that map config paths to environment variable names. Explicit rules map `config.key.path` to `ENV_VAR`. Wildcard rules (`tab.*: TAB_*`) iterate all keys at a level. The `dc env` command evaluates all rules and emits `export` statements with proper shell escaping.

-> *See [arch/flatten-rules.md](arch/flatten-rules.md) for details*

## IPC Model

Child processes cannot modify a parent's environment directly. `dc` works around this by writing to the shared YAML store and bumping `.version`. The `precmd` hook (installed by `dc-init`) compares the version counter on each prompt and re-evaluates `dc env` when it changes. This enables cross-process communication — a deploy script can `dc set tab status "deploying"` and the parent shell's tab title updates on the next prompt.

## Secret Management

Secrets are first-class and distinct from settings (see the README's
"Secret Management" section for usage).

- **Marking**: a YAML scalar is a secret when its trimmed body begins with `🔒`;
  an optional `❗` run encodes a sensitivity tier (0–3). `⛔` is the sentinel for
  shadowed ("locked-down") secrets.
- **Encryption at rest**: XChaCha20-Poly1305 AEAD (RustCrypto `chacha20poly1305`)
  with a symmetric key in `~/.config/direnv-config/settings.yaml`. Each secret is
  serialized as a **flat self-describing scalar** `dcenc:v1:t<tier>:<base64url(nonce‖ct‖tag)>`.
  The flat-scalar shape is load-bearing: `merge`/`path`/`flatten` and **every SDK**
  treat it as an opaque string and pass it through without the key. A contract-test
  fixture (`sdk/contract-tests`, `secret-store`) enforces this passthrough.
- **Routing**: `dc yaml` splits a heredoc — plain keys to the requested layer,
  `🔒` keys encrypted into `secrets.yaml` regardless of `--layer`. Already-encrypted
  bodies are stored verbatim (no double-encryption).
- **Redaction by default / audited reveal**: `dc get` never decrypts unless asked
  (`--reveal`/`--clippy`); `⛔` requires the stricter `--reveal-restricted`. Every
  reveal appends a JSONL record to the audit log (`audit.rs`).
- **Shadow store**: `dc config secure` relocates a secret to
  `<project>/.secrets/restricted.config.yaml` and leaves a `⛔` sentinel resolved
  via `shadow.rs`.
- **Source editing**: `dc config` edits the literal `.envrc*` heredocs via a
  line-oriented locator (`envrc/locator.rs`) that preserves comments/formatting.
- **Remote sync**: native Infisical (reqwest blocking + rustls) and Kubernetes
  (`kubectl`) clients power `dc compare`/`dc push`/`dc infisical`; comparison uses
  SHA-256 digests so no plaintext or length leaks.

## Technology Stack

| Layer | Technology |
|-------|-----------|
| CLI | Rust (clap, serde_yaml, anyhow, chrono, sha2) |
| Crypto | XChaCha20-Poly1305 (chacha20poly1305), base64 |
| Remote sync | reqwest (blocking, rustls) for Infisical; `kubectl` for Kubernetes |
| Shell integration | POSIX sh / zsh / bash |
| Config format | YAML (serde_yaml) |
| State location | `~/.local/state/direnv-config/` (XDG_STATE_HOME) |
| Settings/key | `~/.config/direnv-config/settings.yaml` |
| Store addressing | Path-to-name: strip leading `/`, replace `/` with `-`, SHA-256 truncation at 200 chars |
| SDKs | TypeScript, Python, Elixir, PHP — native (file read) + CLI backends |

## Key Decisions

- **File-based IPC over sockets**: Simpler, survives process restarts, works across unrelated processes
- **Monotonic version counter**: Cheap change detection without filesystem watchers
- **Deep merge with tombstones**: `_dc_pruned: true` allows child stores to explicitly delete inherited config without removing the parent
- **Flatten rules in `_dc` config**: Decouples YAML structure from env var naming — the mapping is itself configuration
- **SDK dual backends**: Native backend reads YAML directly (no `dc` binary needed); CLI backend shells out for compatibility
