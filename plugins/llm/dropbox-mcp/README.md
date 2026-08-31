# Dropbox MCP

MCP server for **Dropbox filesystem** operations over **stdio** (no HTTP OAuth).
Built on [`noizu_mcp`](../../libs/elixir-mcp) and [`noizu_dropbox`](../../libs/integrations/elixir-dropbox).

Default grant is **read-only**. Mutating tools need `DROPBOX_MCP_WRITES=1`.
`dropbox_delete` also requires `confirm=true`. Optional path jail:
`DROPBOX_MCP_ROOT` (or config `:default_root`).

## Tools

| Tool | Purpose |
|------|---------|
| `dropbox_list_folder` | List path (optional recursive / all pages) |
| `dropbox_list_folder_continue` | Continue pagination via cursor |
| `dropbox_get_metadata` | File/folder metadata |
| `dropbox_read_file` | Download file (utf8 or base64) |
| `dropbox_write_file` | Upload / create file (**writes**) |
| `dropbox_create_folder` | `mkdir` (**writes**) |
| `dropbox_move` | Move / rename (**writes**) |
| `dropbox_copy` | Copy (**writes**) |
| `dropbox_delete` | Delete; trash when available (**writes** + `confirm=true`) |
| `dropbox_search` | Search |
| `dropbox_get_temporary_link` | Temporary direct link |
| `dropbox_create_shared_link` | Shared link (**writes**) |
| `dropbox_list_shared_links` | List links |
| `dropbox_get_current_account` | Account profile |
| `dropbox_get_space_usage` | Quota usage |

## Resources

- Template: `dropbox://{path}` — read file contents (jailed when a root is set)

## Setup

```bash
export DROPBOX_ACCESS_TOKEN=sl.your_token
# optional: DROPBOX_REFRESH_TOKEN + DROPBOX_APP_KEY + DROPBOX_APP_SECRET
cd /absolute/path/to/dropbox-mcp
mix deps.get
mix test
mix run --no-halt   # stdio MCP
```

Interactive Dropbox OAuth (prints env exports for `.envrc`; not an MCP HTTP server):

```bash
mix dropbox.auth
```

### Least privilege

| Variable / config | Default | Effect |
|-------------------|---------|--------|
| `DROPBOX_MCP_WRITES` or `:writes` | off | Enables write/move/delete/mkdir/copy/share |
| `DROPBOX_MCP_ROOT` or `:default_root` | unset (account root) | Empty path maps here; other paths must stay under this prefix (`..` collapsed) |

`dropbox_write_file` defaults to `mode=overwrite` once writes are on.

## Install (stdio)

Replace `/absolute/path/to/dropbox-mcp` and the token. Omit
`DROPBOX_MCP_WRITES` (or set `0`) for read-only. Set `DROPBOX_MCP_ROOT` to jail
paths, e.g. `/Apps/mcp`.

### Claude Code

```bash
claude mcp add dropbox \
  --env DROPBOX_ACCESS_TOKEN=sl.your_token \
  -- bash -lc 'cd /absolute/path/to/dropbox-mcp && mix run --no-halt'
```

### Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or
`%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "dropbox": {
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/absolute/path/to/dropbox-mcp",
      "env": {
        "DROPBOX_ACCESS_TOKEN": "sl.your_token"
      }
    }
  }
}
```

### Codex

```bash
codex mcp add dropbox \
  --env DROPBOX_ACCESS_TOKEN=sl.your_token \
  -- bash -lc 'cd /absolute/path/to/dropbox-mcp && mix run --no-halt'
```

Or `~/.codex/config.toml`:

```toml
[mcp_servers.dropbox]
command = "mix"
args = ["run", "--no-halt"]
cwd = "/absolute/path/to/dropbox-mcp"

[mcp_servers.dropbox.env]
DROPBOX_ACCESS_TOKEN = "sl.your_token"
```

### Cursor

Project `.cursor/mcp.json` or `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "dropbox": {
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/absolute/path/to/dropbox-mcp",
      "env": {
        "DROPBOX_ACCESS_TOKEN": "sl.your_token"
      }
    }
  }
}
```

### VS Code

Workspace `.vscode/mcp.json` (Copilot Agent):

```json
{
  "servers": {
    "dropbox": {
      "type": "stdio",
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/absolute/path/to/dropbox-mcp",
      "env": {
        "DROPBOX_ACCESS_TOKEN": "sl.your_token"
      }
    }
  }
}
```

### Grok

```bash
grok mcp add dropbox \
  --env DROPBOX_ACCESS_TOKEN=sl.your_token \
  -- bash -lc 'cd /absolute/path/to/dropbox-mcp && mix run --no-halt'
```

Or `~/.grok/config.toml` / project `.grok/config.toml`:

```toml
[mcp_servers.dropbox]
command = "mix"
args = ["run", "--no-halt"]
cwd = "/absolute/path/to/dropbox-mcp"
env = { DROPBOX_ACCESS_TOKEN = "sl.your_token" }
```

Hosts without a `cwd` field should use the `bash -lc 'cd … && mix run --no-halt'` form.

### Config

```elixir
# config/runtime.exs (optional)
config :noizu_dropbox,
  access_token: System.get_env("DROPBOX_ACCESS_TOKEN"),
  refresh_token: System.get_env("DROPBOX_REFRESH_TOKEN"),
  app_key: System.get_env("DROPBOX_APP_KEY"),
  app_secret: System.get_env("DROPBOX_APP_SECRET")

config :dropbox_mcp,
  start_stdio: true,
  writes: false,
  default_root: "",
  max_text_bytes: 1_000_000
```

## Development

```elixir
# test/support stubs Finch; in-process MCP tests use Noizu.MCP.Test
mix test
```

## License

MIT
