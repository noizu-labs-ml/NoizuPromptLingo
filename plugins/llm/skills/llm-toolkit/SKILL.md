---
name: llm-toolkit
description: Vendored llm-toolkit CLI — search, browse, and extract Claude Code conversations. Not an MCP server.
---

# llm-toolkit

Companion CLI vendored at `plugins/llm/llm-toolkit` (squash subtree of `the-robot-lives/llm-toolkit`). It is **not** one of this plugin's MCP servers.

```bash
cd plugins/llm/llm-toolkit
pnpm install
llm-toolkit recent
llm-toolkit search "query"
```

## Local services

Upcoming: `llm-toolkit services` — manage local MCP servers and coordinator daemons (interactive TUI).

```bash
llm-toolkit services            # interactive TUI
llm-toolkit services --list     # list registered services
llm-toolkit services --start NAME
llm-toolkit services --stop NAME
llm-toolkit services --restart NAME
llm-toolkit services --all      # start all enabled+autostart services
```

Services are registered in layered YAML config; the llm-toolkit web UI (Services page) and the TUI both manage enable/disable and start/stop/restart.

Config paths and precedence (lowest → highest):

1. built-in defaults
2. user `~/.config/npl/npl-plugin.config.yaml`
3. per-project `./.npl/npl-plugin.config.yaml`

Services with `enabled: true` + `autostart: true` start when the llm-toolkit API boots.

Service schema:

| Field | Description |
| --- | --- |
| `name` | service name |
| `command` | executable path |
| `args` | command arguments |
| `cwd` | working directory |
| `env` | environment variables |
| `transport` | `stdio` or `http` |
| `url` | endpoint URL (http only) |
| `health_url` | health-check endpoint |
| `enabled` | enable flag |
| `autostart` | start on llm-toolkit API boot |
| `sync_to_stores` | opt-in sync of enable state into Claude MCP config files via `mcp_sync.targets` |

See `plugins/llm/skills/llm-toolkit/examples/npl-plugin.config.yaml` for a full example.

See `plugins/llm/llm-toolkit/README.md`.
