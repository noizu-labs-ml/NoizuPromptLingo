# echo_stdio

Minimal `noizu_mcp` stdio server with two tools (`echo`, `system_time`).

## Run it

```sh
mix deps.get
mix run --no-halt
```

The server speaks MCP on stdin/stdout (logs go to stderr).

## Use it from Claude Code

```sh
claude mcp add echo-stdio -- mix run --no-halt
# or with an absolute project dir:
claude mcp add echo-stdio -- sh -c 'cd /path/to/examples/echo_stdio && mix run --no-halt'
```

Or in `.mcp.json`:

```json
{
  "mcpServers": {
    "echo-stdio": {
      "command": "mix",
      "args": ["run", "--no-halt"],
      "cwd": "/path/to/examples/echo_stdio"
    }
  }
}
```

> For production servers prefer an OTP release over `mix run` — releases start
> faster and don't risk compiler output on stdout. See the noizu_mcp docs.
