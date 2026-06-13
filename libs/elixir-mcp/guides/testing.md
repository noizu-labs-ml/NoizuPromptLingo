# Testing Your Server

`Noizu.MCP.Test` runs a real client session against your server over an
in-memory transport — full protocol semantics (handshake, capabilities,
validation, notifications) with no I/O. Connections are isolated per test:
`async: true` is safe.

```elixir
defmodule MyApp.MCPTest do
  use ExUnit.Case, async: true
  import Noizu.MCP.Test

  setup do
    %{client: connect(MyApp.MCP)}
  end

  test "search returns hits", %{client: client} do
    assert {:ok, result} = call_tool(client, "search_docs", %{"query" => "installation"})
    assert result.is_error == false
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "hits"
  end
end
```

`connect/2` starts the server's supervision tree on demand (no need to add
it to your test app's supervisor) and performs the initialize handshake.
Options include `protocol_version:` and client `capabilities:` overrides
for negotiation tests.

## The wrappers

Feature wrappers mirror the client API and return decoded structs:
`call_tool/4`, `list_tools/2`, `list_resources/2`,
`list_resource_templates/2`, `read_resource/3`, `subscribe/2`,
`unsubscribe/2`, `list_prompts/2`, `get_prompt/4`, `complete/4`,
`set_log_level/2`.

Lower-level escape hatches:

```elixir
{:ok, result} = request(client, "ping")                  # any method, decoded result
id = send_request(client, "tools/call", %{...})          # fire without waiting
{:ok, result} = await(client, id)                        # ... collect later
notify(client, "notifications/cancelled", %{"requestId" => id})
cancel(client, id, "reason")                             # sugar for the above
deliver_raw(client, ~s({"jsonrpc": "2.0"...}))           # malformed-input tests
```

## Notifications and progress

```elixir
test "subscription fan-out", %{client: client} do
  assert {:ok, _} = request(client, "resources/subscribe", %{"uri" => "config://app"})
  MyApp.MCP.notify_resource_updated("config://app")

  params = assert_notification(client, "notifications/resources/updated")
  assert params["uri"] == "config://app"
end

test "progress", %{client: client} do
  {:ok, _} = call_tool(client, "long_task", %{}, progress_token: "t1")
  params = assert_progress(client)
  assert params["progressToken"] == "t1"
end

test "silence", %{client: client} do
  {:ok, _} = call_tool(client, "quick", %{})
  refute_notification(client, "notifications/progress")
end
```

Matchers buffer out-of-order traffic per session, so interleaved
notifications don't flake.

## Testing sampling / elicitation / roots

Tools that call `Ctx.sample/elicit/list_roots` need a client that advertises
those capabilities — give `connect/2` a handler:

```elixir
defmodule StubHandler do
  @behaviour Noizu.MCP.Client.Handler

  @impl true
  def handle_sampling(_params, _state),
    do: {:ok, %{"role" => "assistant", "content" => %{"type" => "text", "text" => "stub"}, "model" => "stub"}}

  @impl true
  def handle_elicitation(_params, _state), do: {:ok, :accept, %{"confirm" => true}}
end

client = connect(MyApp.MCP, handler: StubHandler)
assert {:ok, result} = call_tool(client, "consult_llm", %{"question" => "?"})
```

## Testing toolkit and hidden tools

Toolkit tools (`use Noizu.MCP.Server.Toolkit` + `@mcp`) test exactly like
classic ones — `call_tool/4` by wire name. For hidden items, assert both
halves of the contract: excluded from listings, still callable:

```elixir
test "hidden tools are unlisted but callable", %{client: client} do
  {:ok, tools} = list_tools(client)
  refute "internal_tool" in Enum.map(tools, & &1.name)

  assert {:ok, result} = call_tool(client, "internal_tool", %{})
  assert result.is_error == false
end

test "catalog reveals hidden tools", %{client: client} do
  {:ok, result} = call_tool(client, "catalog", %{"type" => "tools"})
  entry = Enum.find(result.structured["tools"], &(&1["name"] == "internal_tool"))
  assert entry["hidden"] == true
end
```

The same pattern covers hidden prompts (`list_prompts/2` + `get_prompt/4`)
and hidden resources (`list_resources/2` + `read_resource/3`). For
session-gated visibility, flip the gate and assert the `list_changed`
notification:

```elixir
{:ok, _} = call_tool(client, "unlock", %{})        # sets the session assign
assert_notification(client, "notifications/tools/list_changed")
{:ok, tools} = list_tools(client)                  # now includes gated tools
```

## Conformance

The library's own suite validates wire output against the vendored official
JSON schema (`priv/spec/2025-11-25/schema.json`). If you extend the
protocol surface by hand (`request/3` with custom result shapes), consider
doing the same — see `test/noizu/mcp/conformance_test.exs` in the source
repo for the pattern.
