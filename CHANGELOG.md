# Changelog

## Unreleased

- Default grant is read-only; mutations require `DROPBOX_MCP_WRITES=1` (or `:writes`)
- `dropbox_delete` requires `confirm=true`
- Path prefix jail when `DROPBOX_MCP_ROOT` / `:default_root` is set
- Six-client stdio install docs (Claude Code, Desktop, Codex, Cursor, VS Code, Grok)

## 0.1.0

- Initial Dropbox filesystem MCP server on Noizu.MCP
- Tools: list, metadata, read, write, mkdir, move, copy, delete, search, share link, account
- Resources: `dropbox://` path templates
- Stdio transport by default
