---
name: run-claude
description: Vendored run-claude CLI — per-directory model routing and local LLM gateway. Not an MCP server.
---

# run-claude

Companion CLI vendored at `plugins/llm/run-claude` (squash subtree of `noizu/run-claude`). It is **not** one of this plugin's MCP servers.

Use it to bind a project directory to a model profile and route Claude Code / OpenCode through a local gateway.

```bash
cd plugins/llm/run-claude
make install
run-claude set-folder <profile>   # from a target project dir
run-claude status --health
```

See `plugins/llm/run-claude/README.md`.
