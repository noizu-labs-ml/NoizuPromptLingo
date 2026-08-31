# llm plugin (Noizu Prompt Lingua)

First-party Grok/Claude plugin that vendors local LLM MCP servers and companion harness tools into NPL as **squashed git subtrees**.

MCP servers (stdio wrappers in `bin/`):

- `doc-pointers` → `bin/doc-pointers-mcp` (`mix doc_pointers.mcp.stdio`)
- `noizu-google` → `bin/noizu-google-mcp` (`mix run --no-halt`)
- `dropbox` → `bin/dropbox-mcp` (`mix run --no-halt`)

Vendored companion tools (not MCP servers):

- `run-claude/` — per-directory model routing / local LLM gateway CLI
- `llm-toolkit/` — conversation search, browse, extract CLI (`llm-toolkit`)

Subtree remotes, squash policy, and pull recipe: [SUBTREES.md](SUBTREES.md).

## Mix deps

From this directory (Elixir 1.18+, `mix` on PATH):

```bash
make deps
```

That runs `mix deps.get` in `doc-pointers/`, `elixir-google-mcp/`, and `dropbox-mcp/`. `_build/` and `deps/` are gitignored.

NPL overlay: `dropbox-mcp/mix.exs` uses Hex (`noizu_mcp ~> 0.1.5`, `noizu_dropbox ~> 0.1.0`) instead of upstream monorepo path deps.

## Enable the plugin

From the NPL product repo root:

```
grok plugin marketplace add .
grok plugin install llm --trust
```

Claude Code (same catalog via `.claude-plugin/marketplace.json`):

```
/plugin marketplace add .
/plugin install llm@Noizu Prompt Lingua
```

or, from a checkout path:

```
claude plugin marketplace add .
claude plugin install llm --scope user
```

Hosts typically spawn from the plugin directory; wrappers still `cd` via `BASH_SOURCE` if invoked with an absolute path. Run `make deps` before first MCP attach.

## Environment (names only)

Set these in the host environment (never commit values):

| Name | Used by |
| --- | --- |
| `DOC_POINTERS_ROOT` | doc-pointers project root for `.meta/` storage |
| `DOC_POINTERS_MCP_WRITES` | enable generate/update tools (`1`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Google MCP service account JSON path |
| `GOOGLE_MCP_WRITES` | enable Google write tools (`1`) |
| `DROPBOX_ACCESS_TOKEN` | Dropbox MCP |
| `DROPBOX_MCP_WRITES` | enable Dropbox write tools (`1`) |
