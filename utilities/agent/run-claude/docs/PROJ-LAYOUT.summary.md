# Project Layout Summary

```
run-claude/
├── .claude/                 # Claude Code config (agents, commands, settings)
├── dep/                     # Docker infrastructure (TimescaleDB, LiteLLM Dockerfile)
│   └── config/timescaledb/  #   DB init scripts
├── docs/                    # Documentation
│   ├── arch/                #   Architecture details (data-flows, design-patterns, infrastructure)
│   └── layout/              #   Layout details (run-claude-package, docs, claude-config)
├── hooks/                   # Shell integration (bash/zsh hooks, installer)
├── playground/              # Test directories for profile switching
├── repos/                   # Third-party source (git submodules)
│   └── litellm/             #   LiteLLM upstream (pinned)
├── run_claude/              # Main Python package
│   ├── callbacks/           #   Provider compatibility layer
│   ├── defaults/            #   Built-in config files (models, profiles, hooks)
│   ├── hooks/               #   Lifecycle hook system (chain, loader, builtins)
│   ├── cli.py               #   CLI entry point
│   ├── config.py            #   Secrets and config management
│   ├── profiles.py          #   Profile loading with fallthrough
│   ├── proxy.py             #   LiteLLM proxy lifecycle
│   ├── state.py             #   JSON state persistence
│   ├── agent_runner.py      #   Agent execution wrapper
│   ├── litellm_proxy.py     #   LiteLLM proxy helpers
│   └── opencode_cli.py      #   OpenCode CLI integration
├── scripts/                 # Utility scripts (proxy runners)
├── templates/               # direnv templates
├── tests/                   # Test suite (cli, callbacks, hooks)
├── CLAUDE.md                # Claude Code project instructions
├── Makefile                 # Build automation
├── profiles.yaml            # Profile definitions
└── pyproject.toml           # Python project config
```
