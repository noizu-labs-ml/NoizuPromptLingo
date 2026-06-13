# Resources, Templates & Prompts

## Static resources

A resource is a module with a fixed URI and a `read/2`:

```elixir
defmodule MyApp.Resources.Config do
  use Noizu.MCP.Server.Resource,
    uri: "config://app",
    name: "App Config",
    description: "Application configuration",
    mime_type: "application/json",
    subscribable: true

  @impl true
  def read("config://app", _ctx), do: {:ok, Jason.encode!(MyApp.Config.current())}
end
```

Register it with `resource MyApp.Resources.Config` on the server. `read/2`
returns:

- `{:ok, binary}` — text contents with the declared MIME type
- `{:ok, {:blob, binary}}` — binary contents (base64-encoded on the wire)
- `{:ok, %Noizu.MCP.Types.ResourceContents{}}` or a list of them — full control
- `{:error, Noizu.MCP.Error.resource_not_found(uri)}` — the spec's `-32002`

## Subscriptions

Declare `subscribable: true` and clients can `resources/subscribe`. When the
underlying data changes, notify subscribers from anywhere in your app —
the server module exports a fan-out helper:

```elixir
MyApp.MCP.notify_resource_updated("config://app")
```

Every session subscribed to that URI receives
`notifications/resources/updated`. Similarly, when the *set* of
tools/resources/prompts changes:

```elixir
MyApp.MCP.notify_changed(:tools)      # or :resources, :prompts
```

## Resource templates (RFC 6570)

Templates expose URI families. Matched variables arrive as an atom-keyed map:

```elixir
defmodule MyApp.Resources.TableSchema do
  use Noizu.MCP.Server.ResourceTemplate,
    uri_template: "db://{table}/schema",
    name: "Table Schema",
    mime_type: "application/json"

  @impl true
  def read(_uri, %{table: table}, _ctx) do
    case MyApp.Repo.table_schema(table) do
      {:ok, schema} -> {:ok, Jason.encode!(schema)}
      :error -> {:error, Noizu.MCP.Error.resource_not_found("db://#{table}/schema")}
    end
  end

  # Optional: argument completion for editors/clients
  @impl true
  def complete(:table, prefix, _ctx),
    do: {:ok, Enum.filter(MyApp.Repo.table_names(), &String.starts_with?(&1, prefix))}

  # Optional: enumerate concrete instances in resources/list
  @impl true
  def list(_ctx) do
    {:ok,
     for table <- MyApp.Repo.table_names() do
       %Noizu.MCP.Types.Resource{uri: "db://#{table}/schema", name: "#{table} schema"}
     end}
  end
end
```

Register with `resource_template MyApp.Resources.TableSchema`.

## Prompts

```elixir
defmodule MyApp.Prompts.CodeReview do
  use Noizu.MCP.Server.Prompt,
    name: "code_review",
    description: "Review code for quality issues"

  arguments do
    arg :code, required: true, description: "The code to review"
    arg :style, description: "Review style", complete: ["strict", "friendly"]
  end

  @impl true
  def get(%{"code" => code} = args, _ctx) do
    style = args["style"] || "strict"

    {:ok,
     [
       Noizu.MCP.Types.PromptMessage.user("Review this code (style: #{style}):"),
       Noizu.MCP.Types.PromptMessage.user(code)
     ]}
  end
end
```

- Prompt arguments arrive **string-keyed** (they are free-form spec-side).
- `PromptMessage.user/1` and `assistant/1` accept a string or
  `Noizu.MCP.Types.Content` structs.
- Return `{:ok, messages}` or `{:ok, messages, description: "..."}` to
  override the description per call.

## Completion

`completion/complete` requests are routed automatically:

- `complete: ["a", "b"]` on an `arg` — static prefix-filtered suggestions
- `def complete(arg_name, prefix, ctx)` on a prompt or resource-template
  module — dynamic; return `{:ok, values}` or
  `{:ok, values, has_more: bool, total: n}`

Responses are capped at 100 values per the spec.

## Pagination

All `list` endpoints paginate automatically with opaque cursors when a
DSL-registered collection is large, and hand-written `handle_list_*`
callbacks receive `cursor` and return `{:ok, items, next_cursor | nil}` —
see [Tools & Schemas](tools.md) for the behaviour-only pattern.
