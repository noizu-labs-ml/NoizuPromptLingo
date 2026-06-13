# agent_client

A `Noizu.MCP.Client` demo that spawns the sibling
[`echo_stdio`](../echo_stdio) example as a subprocess over the **stdio
transport** and drives it end to end:

1. connect (`transport: {:stdio, command: "mix", args: ["run", "--no-halt"], cd: ...}`)
   and `await_ready/2`
2. print the server's `serverInfo` and `instructions`
3. `list_tools/1` and print each tool's name + description
4. `call_tool/4` on `echo` (with a `progress:` callback) and `system_time`,
   printing text and structured results
5. `close/1` — the transport SIGTERMs the subprocess

It also installs an `AgentClient.Handler` (`Noizu.MCP.Client.Handler`) that
auto-accepts elicitation requests and mirrors server notifications to stderr.
Implementing `handle_elicitation/2` is what advertises the `elicitation`
capability — `echo_stdio` never elicits, but a server that does could ask this
client questions mid-tool-call.

## Run it

```sh
# one-time: make sure the server example can boot
(cd ../echo_stdio && mix deps.get)

mix deps.get
mix agent.demo
# or equivalently
mix run -e AgentClient.main
```

Expected output (stderr lines like `[progress] ...` interleave):

```
connected to: echo_stdio v0.1.0
instructions: Demo server. Use `echo` to reflect text and `system_time` for the clock.

tools (2):
  - echo: Echo a message back. Set mode=loud to upcase it.
  - system_time: Get the server's current UTC time as ISO 8601.

calling echo(message: "hello mcp", repeat: 2, mode: loud)…
echo -> HELLO MCP HELLO MCP

calling system_time()…
system_time -> {"utc":"2026-06-13T00:00:00.000000Z"}
structured  -> %{"utc" => "2026-06-13T00:00:00.000000Z"}

closed.
```

## Notes

- The server directory is resolved at compile time
  (`Path.expand("../../echo_stdio", __DIR__)`), so the demo works from any
  cwd. The stdio client transport supports `:command`, `:args`, `:cd`, and
  `:env`.
- The first run may take a while: the spawned `mix run --no-halt` compiles
  `echo_stdio` before speaking MCP, so `await_ready` uses a generous timeout.
- For a long-lived client, put `{Noizu.MCP.Client, name: MyApp.Echo,
  transport: ..., handler: ...}` in your supervision tree instead of
  `start_link/1`.
