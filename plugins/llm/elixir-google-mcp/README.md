# Noizu Google MCP

[![Hex.pm](https://img.shields.io/hexpm/v/noizu_google_mcp.svg)](https://hex.pm/packages/noizu_google_mcp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/noizu_google_mcp/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/noizu-labs/elixir-google-mcp/blob/main/LICENSE)

MCP **server** wrapping [`:noizu_google`](https://hex.pm/packages/noizu_google)
for agent/terminal access to Google marketing APIs (Search Console, GA4
Admin/Data, AdSense, Google Ads).

Built on [`:noizu_mcp`](https://hex.pm/packages/noizu_mcp). Speaks MCP over
**stdio** when the application starts (`mix run --no-halt`). This package is
stdio-only — do not expose it over unauthenticated HTTP.

## Installation

```elixir
def deps do
  [
    {:noizu_google_mcp, "~> 0.1.1"}
  ]
end
```

Runtime dependencies are `:noizu_mcp`, `:noizu_google`, and Jason.

## Auth (environment)

| Variable | Purpose |
|----------|---------|
| `GOOGLE_ACCESS_TOKEN` | Bearer token (preferred for short sessions) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to a GCP service-account JSON key |
| `GOOGLE_CREDENTIALS_FILE` / `GOOGLE_SERVICE_ACCOUNT_FILE` | Aliases for the JSON path |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Inline service-account JSON object |
| `GOOGLE_SCOPES` | Space-separated scopes for the service-account grant (default: Search Console `webmasters`) |
| `GOOGLE_SUBJECT` / `GOOGLE_IMPERSONATE` | Domain-wide delegation subject |
| `GOOGLE_REFRESH_TOKEN` | Refresh when access token absent |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Required for refresh |
| `GOOGLE_MCP_WRITES` | Set to `1` to list and allow write tools (off by default) |

Aliases: `GOOGLE_MARKETING_*` for the user-OAuth keys.

Service-account auth signs a JWT and exchanges it at Google's token endpoint.
For Search Console, add the service-account email as a user on each property.

Google Ads tools also need a developer token (`GOOGLE_ADS_DEVELOPER_TOKEN`)
and, for MCC logins, `GOOGLE_ADS_LOGIN_CUSTOMER_ID`. Obtain user tokens with the
OAuth Mix tasks in `:noizu_google` (`mix google.oauth.authorize` /
`mix google.oauth.exchange`).

## Run (stdio)

From this project, or any Mix project that depends on it:

```sh
mix deps.get
export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/sa.json
# or: export GOOGLE_ACCESS_TOKEN=...
mix run --no-halt
```

A wrapper that `cd`s into this project lives at `bin/noizu-google-mcp`
(for hosts without a `cwd` field, such as Grok `config.toml`). First Mix
startup can exceed default MCP timeouts — raise them to ~60s, or compile
once with `mix deps.get && mix compile` before connecting.

The application starts `{Noizu.Google.MCP, transport: :stdio}` unless you set:

```elixir
config :noizu_google_mcp, start_stdio: false
```

Use that when embedding the server in your own supervisor (tests already
disable stdio so `mix test` does not attach to stdin).

## Client install

Stdio only. Copy the env block from [`.mcp.json.example`](.mcp.json.example)
and replace the absolute paths. Leave `GOOGLE_MCP_WRITES` empty (read tools
only) unless you intend to mutate. Hosts may auto-approve read tools; leave
writes behind the env flag (Ads still needs `dry_run=false` and
`confirm=true` for live applies).

CLI one-liners (wrapper needs no `cwd`):

```sh
claude mcp add noizu-google --env GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/sa.json -- /absolute/path/to/elixir-google-mcp/bin/noizu-google-mcp
codex mcp add noizu-google --env GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/sa.json -- /absolute/path/to/elixir-google-mcp/bin/noizu-google-mcp
grok mcp add noizu-google --env GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/sa.json -- /absolute/path/to/elixir-google-mcp/bin/noizu-google-mcp
```

### Claude Code / Claude Desktop

Project `.mcp.json` or Claude Desktop `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "noizu-google": {
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/absolute/path/to/elixir-google-mcp",
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/absolute/path/to/sa.json"
      }
    }
  }
}
```

### Cursor

Same `mcpServers` shape as Claude, in `.cursor/mcp.json` (project) or
`~/.cursor/mcp.json` (user).

### VS Code (GitHub Copilot)

`.vscode/mcp.json` uses `servers` (not `mcpServers`) and requires `type`:

```json
{
  "servers": {
    "noizu-google": {
      "type": "stdio",
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/absolute/path/to/elixir-google-mcp",
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/absolute/path/to/sa.json"
      }
    }
  }
}
```

### Codex

`~/.codex/config.toml` or project `.codex/config.toml`:

```toml
[mcp_servers.noizu-google]
command = "mix"
args = ["run", "--no-halt"]
cwd = "/absolute/path/to/elixir-google-mcp"
startup_timeout_sec = 60

[mcp_servers.noizu-google.env]
GOOGLE_APPLICATION_CREDENTIALS = "/absolute/path/to/sa.json"
# GOOGLE_MCP_WRITES = "1"
```

Hosts without `cwd` can set `command` to the `bin/noizu-google-mcp` wrapper
instead of `mix`.

### Grok

`~/.grok/config.toml` or project `.grok/config.toml`. Grok has no `cwd`
field — use the wrapper. Grok also loads project `.mcp.json` (Claude shape)
at lower priority.

```toml
[mcp_servers.noizu-google]
command = "/absolute/path/to/elixir-google-mcp/bin/noizu-google-mcp"
startup_timeout_sec = 60
env = { GOOGLE_APPLICATION_CREDENTIALS = "/absolute/path/to/sa.json" }
# env = { GOOGLE_APPLICATION_CREDENTIALS = "/absolute/path/to/sa.json", GOOGLE_MCP_WRITES = "1" }
```

## Tools

Read tools are **granted by default**. Write tools are omitted from
`tools/list` and rejected on `tools/call` unless `GOOGLE_MCP_WRITES=1`.
Ads write tools still default to `dry_run=true`; live applies need
`dry_run=false` **and** `confirm=true`. Destructive Search Console deletes
need `confirm=true` even with writes enabled.

| Tool | Category | Notes |
|------|----------|--------|
| `SearchConsole.SitesList` | SearchConsole | read |
| `SearchConsole.SitesGet` | SearchConsole | read |
| `SearchConsole.SitesAdd` | SearchConsole | write (`GOOGLE_MCP_WRITES=1`) |
| `SearchConsole.SitesDelete` | SearchConsole | write + destructive (`confirm`) |
| `SearchConsole.SearchAnalyticsQuery` | SearchConsole | read |
| `SearchConsole.SitemapsList` | SearchConsole | read |
| `SearchConsole.SitemapsSubmit` | SearchConsole | write (`GOOGLE_MCP_WRITES=1`) |
| `SearchConsole.SitemapsDelete` | SearchConsole | write + destructive (`confirm`) |
| `Analytics.PropertiesList` | Analytics | read |
| `Analytics.PropertiesGet` | Analytics | read |
| `Analytics.DataStreamsList` | Analytics | read |
| `Analytics.RunReport` | Analytics | read |
| `AdSense.AccountsList` | AdSense | read |
| `AdSense.AdUnitsList` | AdSense | read |
| `AdSense.ReportsGenerate` | AdSense | read |
| `Ads.ListCampaigns` | Ads | read; needs developer token |
| `Ads.ListConversionActions` | Ads | read; needs developer token |
| `Ads.Mutate` | Ads | write; **dry_run default**; live needs `confirm` |
| `Ads.CreateConversionAction` | Ads | write; **dry_run default**; live needs `confirm` |

Prefer read-only tools unless the user explicitly asks to mutate.

## Embed

```elixir
children = [
  {Noizu.Google.MCP, transport: :stdio}
]
```

Stdio only. Do not add an unauthenticated HTTP transport for this server.

`Noizu.Google.MCP.Auth.client/0` builds a `%Noizu.Google.Client{}` from the
environment / `:noizu_google` application config. It prefers a bearer token,
then a service-account JSON key, then an OAuth refresh token.

## Development

```sh
mix deps.get
mix test
mix docs
mix hex.build          # tarball only; does not publish
```

## License

[MIT](https://github.com/noizu-labs/elixir-google-mcp/blob/main/LICENSE)
