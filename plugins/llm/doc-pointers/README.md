# doc-pointers

Mint durable, code-stable citations for a source locus: a **UUIDv5** identity plus a
**4-glyph hieroglyph token** you can paste into docs.

Line numbers rot. `⟦𓳔𔐮𔘟𔄵⟧` does not.

Elixir `~> 1.18` Mix app (`:doc_pointers`). Two surfaces share one store:

- **MCP** — stdio (preferred) or loopback Streamable HTTP
- **Library** — `DocPointers.generate/3,4` for Elixir callers

Default MCP tools are read-only (`doc-pointer/lookup`, `doc-pointer/list`).
`generate` / `update` stay off unless you pass `--write` or `confirm=true`.

## Quick start

```bash
mix deps.get
mix test
mix compile
mix doc_pointers.mcp.stdio --root /path/to/project
```

`--root` defaults to `DOC_POINTERS_ROOT` or cwd. Add `--write` to list and allow
generate/update without a per-call `confirm=true`. Same flag on the HTTP task.

HTTP (optional, binds `127.0.0.1` only, no auth):

```bash
mix doc_pointers.mcp.server --port 4242 --root /path/to/project
```

`cwd` in the snippets below must be this Mix project (or any Mix project that
depends on `:doc_pointers`). Compile once (`mix compile`) so Mix does not print
to stdout and corrupt the stdio stream.

## MCP client install

Replace `/ABS/doc-pointers` with this checkout. Default is lookup/list only;
append `--write` (or set `DOC_POINTERS_MCP_WRITES=1`) to expose generate/update.

### Claude Code

```bash
claude mcp add doc-pointers -- mix doc_pointers.mcp.stdio
# writes:
# claude mcp add doc-pointers -- mix doc_pointers.mcp.stdio --write
```

From another directory:

```bash
claude mcp add-json doc-pointers '{
  "command": "mix",
  "args": ["doc_pointers.mcp.stdio"],
  "cwd": "/ABS/doc-pointers"
}'
```

### Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json` (macOS;
`%APPDATA%\Claude\claude_desktop_config.json` on Windows):

```json
{
  "mcpServers": {
    "doc-pointers": {
      "command": "mix",
      "args": ["doc_pointers.mcp.stdio"],
      "cwd": "/ABS/doc-pointers"
    }
  }
}
```

### Codex

`~/.codex/config.toml` (or project `.codex/config.toml`):

```toml
[mcp_servers.doc-pointers]
command = "mix"
args = ["doc_pointers.mcp.stdio"]
cwd = "/ABS/doc-pointers"
startup_timeout_sec = 60
```

### Cursor

`.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (user):

```json
{
  "mcpServers": {
    "doc-pointers": {
      "command": "mix",
      "args": ["doc_pointers.mcp.stdio"],
      "cwd": "/ABS/doc-pointers"
    }
  }
}
```

### VS Code

`.vscode/mcp.json`:

```json
{
  "servers": {
    "doc-pointers": {
      "type": "stdio",
      "command": "mix",
      "args": ["doc_pointers.mcp.stdio"],
      "cwd": "/ABS/doc-pointers"
    }
  }
}
```

### Grok

```bash
grok mcp add doc-pointers -- mix doc_pointers.mcp.stdio
```

`~/.grok/config.toml` (or project `.grok/config.toml`). Grok has no `cwd` field —
run `grok` from a Mix project that depends on this app, or wrap the command:

```toml
[mcp_servers.doc-pointers]
command = "sh"
args = ["-c", "cd /ABS/doc-pointers && exec mix doc_pointers.mcp.stdio"]
startup_timeout_sec = 60
```

## What a pointer is

Each pointer is a pair:

| Piece | Role |
|-------|------|
| UUIDv5 | Stable identity; YAML map key |
| 4-glyph token | Human/doc face (Egyptian / Meroitic / Anatolian blocks) |

Markers in prose:

```text
⟦𓳔𔐮𔘟𔄵⟧
⟦𓳔𔐮𔘟𔄵⟧ TestPointer :: Golden vector
```

Generation is deterministic from `file_path` + `function` (+ optional `salt`). The name
hashed under a fixed namespace is:

```text
doc-pointers:{file_path}::{function}[:salt][:attempt]
```

If the derived token is already taken, the attempt suffix increments (max 10 000).

Golden vector (`mix test`):

```text
name  doc-pointers:TestPointer
uuid  5c692577-ad0c-51f1-992c-759b5e5fffb5
token 𓳔𔐮𔘟𔄵
```

Namespace: `64e9408c-37a7-5f92-8893-f149cbde01c0`.

## MCP tools

| Tool | Mutates? | Default listed? | Required | Does |
|------|----------|-----------------|----------|------|
| `doc-pointer/lookup` | no | yes | one of `token`, `uuid`, `file_path`, `function_name` | Find existing pointers |
| `doc-pointer/list` | no | yes | — | Paginated list (`limit` default 50, max 500) |
| `doc-pointer/generate` | yes | `--write` only | `file_path`, `function_name`, `description` | Mint UUID + token; persist; return `marker` / `declaration` |
| `doc-pointer/update` | yes | `--write` only | `uuid` or `token` | Metadata only (`description`, `class`, `line`, `file_path`) |

Write tools also accept `confirm=true` when the server was started without `--write`
(clients that support elicitation may be prompted instead).

Optional on generate: `class`, `line`, `salt`, `name_override`.

Optional on list: `file_prefix`, `class`, `limit`, `offset`.

## Elixir API

```elixir
{:ok, pointer} =
  DocPointers.generate("lib/my_app/auth.ex", "login/2", "OIDC login entry",
    class: "MyApp.Auth",
    line: 42
  )

pointer.uuid   # hyphenated UUIDv5
pointer.token  # 4-glyph string

DocPointers.Hieroglyph.marker(pointer.token)
# "⟦…⟧"

DocPointers.Hieroglyph.declaration(pointer.token, "login/2", "OIDC login entry")
# "⟦…⟧ login/2 :: OIDC login entry"
```

Returns `{:ok, %DocPointers.Pointer{}}` or `{:error, :max_attempts}`.

## Storage

Pointers live at `{root}/.meta/pointers.yaml`, keyed by UUID.

If `{root}` has a `.gitmodules`, a pointer whose `file_path` falls under a submodule is
written to **that submodule’s** `.meta/pointers.yaml` (longest-path match; prefix stripped).

When YAML is empty, the store will import legacy `{root}/docs/doc-pointer-db.json` once
(the older Rust CLI format).

## Configuration

| Flag / env | Default | Meaning |
|------------|---------|---------|
| `--root` / `DOC_POINTERS_ROOT` | cwd | Project root for `.meta/` |
| `--write` / `DOC_POINTERS_MCP_WRITES` | off | List and allow generate/update |
| `--port` / `DOC_POINTERS_PORT` | `4242` | Loopback HTTP port (`mix doc_pointers.mcp.server`) |
| `config :doc_pointers, root: …` | — | OTP app env, used if the env var is unset |

## Mix dependency (git)

This is **not** a Hex package. From another Mix project:

```elixir
def deps do
  [
    {:doc_pointers, git: "git@github.com:the-robot-lives/doc-pointers.git"}
  ]
end
```

Then `mix doc_pointers.mcp.stdio` from that project (cwd can be the consumer).

## Not in this repo

- Scanning trees for `⟦…⟧` markers, or CI that enforces them
- Auth on the HTTP MCP endpoint (loopback-only; prefer stdio)
- Multi-node store clustering
- Target-project `.meta/` files (they belong in the annotated repo)
- Mix artifacts (`_build/`, `deps/`)

A Rust CLI with the same encode pipeline (scan / mint / git hook, not MCP) lives in
[`the-robot-lives/util-misc`](https://github.com/the-robot-lives/util-misc) as `doc-pointers`.

## Docs

| Doc | Role |
|-----|------|
| [docs/PROJ-ARCH.md](docs/PROJ-ARCH.md) | Design, mint pipeline, data model |
| [docs/PROJ-ARCH.summary.md](docs/PROJ-ARCH.summary.md) | Short architecture digest |
| [docs/PROJ-LAYOUT.md](docs/PROJ-LAYOUT.md) | Directory map and setup |
| [docs/PROJ-LAYOUT.summary.md](docs/PROJ-LAYOUT.summary.md) | Tree-only companion |
