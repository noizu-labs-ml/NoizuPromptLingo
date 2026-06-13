# no_dsl_server

A `noizu_mcp` stdio server written **without any DSL macros** — just
`use Noizu.MCP.Server` plus hand-implemented behaviour callbacks:

- `handle_list_tools/2` / `handle_call_tool/3` — two tools: `upcase`
  (text → uppercased text block) and `add` (two numbers → structured
  `{"sum": n}` result), with hand-written JSON-Schema maps on plain
  `%Noizu.MCP.Types.Tool{}` structs
- `handle_list_resources/2` / `handle_read_resource/2` — one static resource,
  `readme://about`

Implementing a callback is what enables the corresponding capability — no
registration needed. See `examples/echo_stdio` for the same idea expressed
with the `tool` DSL.

## When to skip the DSL

The `tool`/`resource` macros generate these exact callbacks at compile time.
Implement them by hand when your component list isn't known at compile time:

- tools generated at runtime from a database, config, or upstream API
- proxying/aggregating another server's tool list
- per-session tool sets (vary the list off `ctx` assigns seeded in `init/2`)

Trade-off: behaviour-level handlers receive **string-keyed, unvalidated**
arguments — schema validation, defaults, and atom casting are DSL features.
Return `{:error, "message"}` for execution errors (`isError: true`) the model
can retry from, or `{:error, %Noizu.MCP.Error{}}` for protocol errors.

Return-value contracts for `handle_call_tool/3`:

| return | wire result |
| --- | --- |
| `{:ok, binary}` | single text content block |
| `{:ok, map}` | `structuredContent` + JSON text block |
| `{:ok, %Content{}}` / list | content blocks as given |
| `{:ok, %ToolResult{}}` | passed through |
| `{:error, binary}` | execution error (`isError: true`) |
| `{:error, %Error{}}` | JSON-RPC protocol error |

## Run it

```sh
mix deps.get
mix run --no-halt
```

The server speaks MCP on stdin/stdout (logs go to stderr).

## Use it from Claude Code

```sh
claude mcp add no-dsl -- mix run --no-halt
# or with an absolute project dir:
claude mcp add no-dsl -- sh -c 'cd /path/to/examples/no_dsl_server && mix run --no-halt'
```

Or in `.mcp.json`:

```json
{
  "mcpServers": {
    "no-dsl": {
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/path/to/examples/no_dsl_server"
    }
  }
}
```

## Smoke test by hand

```sh
{ printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"t","version":"1"}}}\n{"jsonrpc":"2.0","method":"notifications/initialized"}\n{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"upcase","arguments":{"text":"hi"}}}\n'; sleep 3; } | mix run --no-halt
```

You should see the initialize result followed by a tool result containing
`"HI"`.
