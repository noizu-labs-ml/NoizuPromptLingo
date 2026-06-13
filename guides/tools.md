# Tools & Schemas

A tool is a module using `Noizu.MCP.Server.Tool`, registered on the server
with `tool MyModule`. The `use` options describe the tool; the `input`/`output`
blocks define schemas; `call/2` does the work.

```elixir
defmodule MyApp.Tools.Search do
  use Noizu.MCP.Server.Tool,
    name: "search_docs",                       # defaults to the module-derived snake_case name
    description: "Full-text search over project documentation",
    annotations: [read_only_hint: true, idempotent_hint: true]

  input do
    field :query, :string, required: true, min_length: 2,
      description: "Search terms"
    field :limit, :integer, min: 1, max: 50, default: 10
    field :scope, :enum, values: [:all, :guides, :api], default: :all
  end

  @impl true
  def call(%{query: query, limit: limit, scope: scope}, _ctx) do
    {:ok, "#{length(run_search(query, limit, scope))} hits"}
  end
end
```

Annotations are written snake_case and emitted camelCase on the wire
(`read_only_hint` → `readOnlyHint`; also `destructive_hint`,
`idempotent_hint`, `open_world_hint`, `title`).

Per-registration overrides let you expose one module under several names:

```elixir
tool MyApp.Tools.Search
tool MyApp.Tools.Search, name: "search", description: "Alias for search_docs"
```

## The field DSL

| Type | Options | JSON Schema |
|------|---------|-------------|
| `:string` | `min_length`, `max_length`, `pattern`, `format` | `"string"` + constraints |
| `:integer` / `:number` | `min`, `max` | `"integer"`/`"number"` + `minimum`/`maximum` |
| `:boolean` | — | `"boolean"` |
| `:enum` | `values: [:a, :b]` (required) | `"string"` + `"enum"` |
| `:object` | `do` block of nested fields | nested object schema |
| `{:array, inner}` | `min`/`max` → `minItems`/`maxItems` | `"array"` + `"items"` |

Every field also accepts `required: true`, `description: "..."`, and
`default: value`. Nested objects and arrays of objects take a `do` block:

```elixir
input do
  field :filters, :object do
    field :tags, {:array, :string}, max: 16
    field :authors, {:array, :object} do
      field :name, :string, required: true
    end
  end
end
```

The schema is compiled **at compile time** to JSON Schema 2020-12 and
validated on every call with [JSV](https://hex.pm/packages/jsv). Your handler
receives arguments that are:

- **atom-keyed** — only field names you declared are atomized (safe),
- **default-applied** — absent optional fields get their `default`,
- **enum-cast** — `"loud"` arrives as `:loud`.

## Raw schema escape hatch

When the DSL can't express your schema (e.g. `oneOf`, dynamic shapes), pass
JSON Schema directly. Raw-schema tools receive **string-keyed** arguments,
validated but otherwise untouched:

```elixir
use Noizu.MCP.Server.Tool, name: "raw", description: "..."

input_schema %{
  "type" => "object",
  "properties" => %{"query" => %{"type" => "string", "minLength" => 2}},
  "required" => ["query"]
}

@impl true
def call(%{"query" => query}, _ctx), do: {:ok, "found: #{query}"}
```

`output_schema %{...}` is the equivalent for structured output.

## Return contract

`call/2` may return:

| Return | Result |
|--------|--------|
| `{:ok, binary}` | one text content block |
| `{:ok, map}` | `structuredContent` (validated against `output`) + JSON text block |
| `{:ok, [%Content{}]}` or `{:ok, %Content{}}` | the given content blocks |
| `{:ok, %Noizu.MCP.Types.ToolResult{}}` | passed through verbatim |
| `{:error, binary}` | execution error: `isError: true` text result |
| `{:error, %Noizu.MCP.Error{}}` | JSON-RPC protocol error |
| raise / exit | sanitized `isError: true` result (details go to `Logger`) |

Build richer content with `Noizu.MCP.Types.Content` (`:text`, `:image`,
`:audio`, `:resource_link`, embedded `:resource`) and
`Noizu.MCP.Types.ToolResult.ok/structured/error`.

## Validation failures are results, not errors

Per [SEP-1303](https://modelcontextprotocol.io) (2025-11-25), arguments that
fail schema validation produce an `isError: true` **tool result** describing
the violation — visible to the model so it can self-correct — rather than a
`-32602` protocol error. Calling a tool that doesn't exist is still `-32602`.

## Dynamic tools (no DSL)

The macros compile down to two callbacks you can write by hand — useful when
the tool list is computed at runtime:

```elixir
defmodule MyApp.DynamicMCP do
  use Noizu.MCP.Server, name: "dyn", version: "1.0.0"

  @impl true
  def handle_list_tools(_cursor, ctx) do
    tools =
      for plugin <- MyApp.Plugins.for_tenant(ctx.assigns.tenant) do
        %Noizu.MCP.Types.Tool{
          name: plugin.slug,
          description: plugin.description,
          input_schema: plugin.json_schema
        }
      end

    {:ok, tools, nil}
  end

  @impl true
  def handle_call_tool(name, args, ctx),
    do: MyApp.Plugins.dispatch(name, args, ctx)
end
```

Hand-written `handle_call_tool/3` receives raw string-keyed arguments — no
validation is applied unless you do it yourself (`Noizu.MCP.Schema` exposes
the same JSV plumbing the DSL uses). See `examples/no_dsl_server` for a
complete behaviour-only server.
