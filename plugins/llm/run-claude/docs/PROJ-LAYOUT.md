# Project Layout

This document describes the folder structure and file organization of the run-claude project.

## Root Level

```
run-claude/
├── .claude/                 # Claude Code config → [layout/claude-config.md](layout/claude-config.md)
├── dep/                     # Docker infrastructure (TimescaleDB, LiteLLM)
│   ├── docker-compose.yaml  #   TimescaleDB service definition
│   ├── docker-compose.override.yaml  # Dev overrides (port 5433)
│   ├── litellm.Dockerfile   #   Custom LiteLLM proxy image
│   └── config/timescaledb/  #   DB init scripts
├── docs/                    # Documentation → [layout/docs.md](layout/docs.md)
├── hooks/                   # Shell integration (bash/zsh hooks, installer)
│   ├── bash_hook.sh         #   Bash PROMPT_COMMAND hook
│   ├── zsh_hook.zsh         #   Zsh precmd hook
│   └── install.sh           #   Hook installation script
├── playground/              # Test directories for profile switching
│   ├── cerebras-project/    #   Cerebras profile test
│   ├── groq-project/        #   Groq profile test
│   ├── local-project/       #   Local (Ollama) profile test
│   └── multi-project/       #   Multi-provider test
├── repos/                   # Third-party source (git submodules)
│   └── litellm/             #   LiteLLM upstream (pinned)
├── run_claude/              # Main Python package → [layout/run-claude-package.md](layout/run-claude-package.md)
│   ├── callbacks/           #   Provider compatibility layer (runs in proxy venv)
│   ├── defaults/            #   Built-in configs (models, profiles, hooks)
│   ├── hooks/               #   Lifecycle hook system
│   ├── cli.py               #   CLI entry point (~1213 lines)
│   ├── config.py            #   Secrets & config management
│   ├── profiles.py          #   Profile loading with fallthrough
│   ├── proxy.py             #   LiteLLM proxy lifecycle (~2101 lines)
│   ├── front_proxy.py       #   Always-on reverse proxy (:4443 → LiteLLM :4444)
│   ├── watchdog.py          #   Self-healing daemon keeping both proxies alive
│   ├── state.py             #   JSON state persistence
│   ├── agent_runner.py      #   Agent execution wrapper
│   ├── litellm_proxy.py     #   LiteLLM proxy helpers
│   ├── opencode_cli.py      #   OpenCode CLI integration
│   └── models.yaml          #   Base model definitions (user-overridable)
├── scripts/                 # Utility scripts
│   ├── run-litellm-local    #   Run LiteLLM locally
│   └── run-litellm-proxy    #   Run LiteLLM as proxy
├── templates/               # direnv templates
│   ├── envrc.tmpl           #   .envrc template (auto-generated)
│   └── envrc.user.tmpl      #   .envrc.user template (user-editable)
├── tests/                   # Test suite
│   ├── test_cli.py          #   CLI command tests
│   ├── test_callbacks.py    #   Callback system tests
│   ├── test_hooks.py        #   Hook system tests
│   ├── test_front_proxy.py  #   Front proxy tests
│   ├── test_watchdog.py     #   Watchdog daemon tests
│   └── test_proxy_logging.py#   Proxy logging tests
├── .gitmodules              # Submodule references (repos/litellm)
├── .python-version          # Python version pin
├── .tool-versions           # asdf/mise tool versions
├── CLAUDE.md                # Claude Code project instructions
├── Makefile                 # Build automation (test, install, coverage)
├── profiles.yaml            # Profile definitions (14+ built-in profiles)
├── pyproject.toml           # Python project config (hatchling)
├── uv.lock                  # Dependency lockfile
├── README.md                # User guide
├── SECRETS.md               # Secrets configuration guide
├── SECRETS_ADVANCED.md      # Advanced secrets management
├── SECRETS_QUICKSTART.md    # Quick reference for secrets
└── with-agent-shim          # Wrapper script for running with profiles
```

## XDG Runtime Paths

| Type | Default Path | Contents |
|------|--------------|----------|
| Config | `~/.config/run-claude/` | `.secrets`, `.env`, profiles, models, `.initialized` marker |
| State | `~/.local/state/run-claude/` | `state.json`, `proxy.pid`, `proxy.log`, `litellm_config.yaml` |

## Generated Files

Files created by `run-claude set-folder <profile>`:

```
<project>/
├── .envrc              # Auto-generated direnv config
├── .envrc.user         # User-editable profile selection
└── .gitignore          # Updated to exclude .envrc.user
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `~/.config/run-claude/.secrets` | Create with API keys (see SECRETS_QUICKSTART.md) |
| `~/.config/run-claude/.env` | Auto-generated from .secrets by `run-claude secrets export` |
| Shell hook | Run `hooks/install.sh` to enable auto-switching |
