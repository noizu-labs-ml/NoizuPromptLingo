# Toolkits, Categories & Hidden Tools

One module per tool (`Noizu.MCP.Server.Tool`) is the right shape for tools
with real logic. For a bundle of small, related tools it is ceremony —
`use Noizu.MCP.Server.Toolkit` turns plain functions into tools with an
`@mcp` annotation:

```elixir
defmodule MyApp.Toolkit do
  use Noizu.MCP.Server.Toolkit, category: "Utility"   # optional default category

  @mcp name: "files.read", category: "Files", description: "Read a file",
       input: [path: [type: :string, required: true]]
  def read_file(%{path: path}, _ctx) do
    case File.read(path) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, "read failed: #{reason}"}
    end
  end

  @mcp description: "Server time (name derives from the function)"
  def server_time, do: {:ok, to_string(DateTime.utc_now())}

  @mcp visible: false   # omitted from tools/list, still callable
  @mcp input: """
  {"type": "object", "properties": {"q": {"type": "string"}}}
  """
  def lookup(args, _ctx), do: {:ok, args["q"] || ""}
end
```

One registration exposes every annotated function:

```elixir
defmodule MyApp.MCP do
  use Noizu.MCP.Server, name: "myapp", version: "1.0.0"

  tool MyApp.Toolkit
end
```

## `@mcp` options

| Option | Meaning |
|--------|---------|
| `:name` | Wire name; defaults to the function name (`server_time` → `"server_time"`) |
| `:title` | Human-readable display name |
| `:description` | Tells the model when and why to use the tool |
| `:category` | Grouping label; defaults to the toolkit-level `category:` `use` option |
| `:input` | Input schema: data-form field spec, raw JSON Schema map, or JSON text |
| `:output` | Output schema, same three forms |
| `:input_schema` / `:output_schema` | Raw schema only (map or JSON text); never interpreted as a field spec |
| `:annotations` | Behavior hints (`:read_only_hint`, `:destructive_hint`, ...) |
| `:icons`, `:meta` | Passed through to the wire definition |
| `:hidden` | `true` omits the tool from `tools/list` (still callable) |
| `:visible` | `visible: false` is an alias for `hidden: true` |

Multiple `@mcp` lines before one function **merge** into a single option set;
later lines win on key conflict. That makes it easy to keep a long schema on
its own line:

```elixir
@mcp name: "report.weekly", category: "Reports"
@mcp description: "Generate the weekly report"
@mcp input: [week: [type: :integer, min: 1, max: 53]]
def weekly_report(args, ctx), do: ...
```

### Arity rules

Annotated functions are public `def`s of arity 0, 1, or 2. The runtime
invokes them with the standard `(args, ctx)` pair trimmed to the declared
arity:

| Arity | Invocation |
|-------|------------|
| 0 | `fun()` — no inputs needed |
| 1 | `fun(args)` — validated arguments only |
| 2 | `fun(args, ctx)` — arguments plus the `Noizu.MCP.Ctx` handler context |

Return values follow the exact contract of `c:Noizu.MCP.Server.Tool.call/2`
(see the Tools & Schemas guide): `{:ok, text | map | Content | ToolResult}` or
`{:error, ...}`; structured map results are checked against the declared
output schema.

### Compile-time validation

Toolkits fail fast at compile time:

- `@mcp` on a `defp` (or any non-`def`) — compile error
- arity above 2 — compile error
- two tools resolving to the same wire name within one toolkit — compile error
- malformed JSON text or invalid field specs in `:input`/`:output` — compile
  error naming the tool

## Three schema forms

`:input` (and `:output`) accept the schema in whichever form is most
convenient.

**1. Data-form field spec** — a keyword list, the data equivalent of the
classic `input do ... end` DSL. Same types, same options, same runtime
behavior — arguments arrive **atom-keyed**, defaults applied, enums cast to
atoms:

```elixir
@mcp input: [
  message: [type: :string, required: true, description: "Message to echo"],
  repeat:  [type: :integer, min: 1, max: 10, default: 1],
  mode:    [type: :enum, values: [:plain, :loud], default: :plain],
  address: [type: :object, fields: [street: [type: :string]]],
  tags:    [type: {:array, :string}],
  rows:    [type: {:array, :object}, fields: [id: [type: :integer]]],
  note:    :string                     # shorthand: bare type
]
```

`:type` is required (or use the bare-type shorthand); `:fields` carries the
children of `:object` / `{:array, :object}` entries; everything else
(`required:`, `default:`, `min:`, `values:`, ...) passes through exactly as
in the macro DSL.

**2. Raw JSON Schema map** — for shapes the field DSL can't express
(`oneOf`, dynamic keys). Arguments are validated but delivered
**string-keyed**, uncast:

```elixir
@mcp input: %{
  "type" => "object",
  "properties" => %{"q" => %{"type" => "string", "minLength" => 2}},
  "required" => ["q"]
}
```

**3. Raw JSON text** — paste a schema block straight from the spec or another
tool's definition. It is decoded **at compile time** (malformed JSON is a
compile error), then behaves exactly like a raw map:

```elixir
@mcp input: """
{"type": "object", "properties": {"q": {"type": "string"}}, "required": ["q"]}
"""
```

The JSON-text form also works in the classic single-tool macros — the
`input_schema`/`output_schema` macros of `Noizu.MCP.Server.Tool` accept a
string and decode it at compile time.

## Category metadata

`category:` attaches a free-form grouping label to a tool. It is not a
first-class MCP field — it rides on the wire inside `_meta.category`, so any
client sees it without protocol extensions:

```json
{"name": "files.read", "inputSchema": {...}, "_meta": {"category": "Files"}}
```

A category can come from four places, most specific wins:

```elixir
# 1. toolkit-wide default
use Noizu.MCP.Server.Toolkit, category: "Utility"

# 2. per-tool override
@mcp name: "files.read", category: "Files"

# 3. classic single-tool modules take it as a `use` option
use Noizu.MCP.Server.Tool, name: "search", category: "Docs", description: "..."

# 4. registration-level override (applies to every tool in a toolkit)
tool MyApp.Toolkit, category: "Admin"
```

The built-in catalog tool (below) surfaces categories top-level and lets
agents filter by them.

## Hidden tools

Mark any tool, prompt, resource, or resource template `hidden: true` to omit
it from `tools/list` / `prompts/list` / `resources/list` while keeping it
fully callable by name — internal, privileged, or agent-only surface that
shouldn't crowd the default listing:

```elixir
# definition level
use Noizu.MCP.Server.Tool, name: "internal", description: "...", hidden: true
@mcp visible: false                 # toolkit alias

# registration level (overrides the module default in either direction)
tool MyApp.Tools.GetWeather, hidden: true
tool MyApp.Toolkit, hidden: true    # hides every tool in the kit
```

Precedence at the registration site: an explicit `hidden:` key wins, then
`visible:` (inverted), then the definition-level flag. **Call dispatch never
consults the hidden flag** — `tools/call`, `prompts/get`, and
`resources/read` resolve hidden items exactly like visible ones.

## The catalog tool

`Noizu.MCP.Server.Tools.Catalog` is a built-in discovery tool: it returns the
full wire definitions (input schemas included) of *everything* registered —
hidden or not — so agents can find and call unpublished items. Register it
like any tool; registering it hidden keeps the catalog itself out of
`tools/list`:

```elixir
tool Noizu.MCP.Server.Tools.Catalog, hidden: true
```

Arguments:

| Argument | Meaning |
|----------|---------|
| `type` | `"tools"` \| `"prompts"` \| `"resources"` \| `"resource_templates"` \| `"all"` (default) |
| `query` | Case-insensitive substring filter on name, description, and URI |
| `category` | Exact case-insensitive category match; entries without a category are dropped |
| `include_hidden` | `true` (default) includes hidden items; `false` for visible-only |

The result is structured content with one key per requested section; each
entry is the item's wire definition plus a `"hidden"` flag, and tool entries
carry a top-level `"category"` when one was declared:

```json
{
  "tools": [
    {"name": "files.read", "inputSchema": {...}, "hidden": false, "category": "Files"},
    {"name": "internal", "inputSchema": {...}, "hidden": true}
  ],
  "prompts": [...],
  "resources": [...],
  "resource_templates": [...]
}
```

The catalog reads the host server's DSL registries (`__mcp__/1`), so it works
on any server built with `tool`/`prompt`/`resource`/`resource_template`
declarations — including default generated handlers.

## Session-gated visibility

Hidden flags are static. For visibility that depends on session state — an
"unlock" flow, per-tenant tool sets — override the list callback and decide
per request via `Noizu.MCP.Ctx` assigns, passing `include_hidden:` to the
listing helper:

```elixir
defmodule MyApp.MCP do
  use Noizu.MCP.Server, name: "myapp", version: "1.0.0"

  tool MyApp.Tools.Public
  tool MyApp.Tools.PowerUser, hidden: true

  @impl true
  def handle_list_tools(cursor, ctx) do
    Noizu.MCP.Server.Features.Tools.list_registered(
      __mcp__(:tools),
      cursor,
      include_hidden: ctx.assigns[:unlocked] == true
    )
  end
end
```

Flip the gate from any handler, then tell connected clients the list changed:

```elixir
Noizu.MCP.Ctx.put_session(ctx, :unlocked, true)
MyApp.MCP.notify_changed(:tools)
```

Clients that honor `listChanged` re-fetch `tools/list` and see the expanded
surface. Remember hidden tools were callable all along — gating the *listing*
is UX, not authorization. Enforce real permissions inside `call/2` (e.g. via
`ctx.assigns[:auth_claims]`).

## Under the hood: `__mcp_tools__/0` and `Tool.Spec`

Every tool module — classic and toolkit alike — exports `__mcp_tools__/0`
returning a list of `Noizu.MCP.Server.Tool.Spec` structs, the normalized
runtime descriptor the server actually executes:

| Field | Meaning |
|-------|---------|
| `module` / `fun` / `arity` | How `tools/call` invokes the handler |
| `definition` | The `Noizu.MCP.Types.Tool` advertised by `tools/list` |
| `cast_plan` | Argument casting instructions (`nil` for raw schemas) |
| `output_schema` | Structured-output check target |
| `hidden` | Definition-level visibility |

A classic `use Noizu.MCP.Server.Tool` module yields one spec
(`fun: :call, arity: 2`); a toolkit yields one per annotated function.
`Noizu.MCP.Server.Features.Tools.expand/1` flattens a `[{module, opts}]`
registration list into specs with registration overrides applied — useful in
custom `handle_list_tools/2` implementations that need more than
`include_hidden:`:

```elixir
def handle_list_tools(_cursor, ctx) do
  tools =
    __mcp__(:tools)
    |> Noizu.MCP.Server.Features.Tools.expand()
    |> Enum.reject(& &1.hidden)
    |> Enum.filter(&allowed?(&1.definition, ctx))
    |> Enum.map(& &1.definition)

  {:ok, tools, nil}
end
```

Note: `:name`/`:description` registration overrides only apply to single-tool
modules — for toolkit registrations they would be ambiguous and raise; set
them per tool in the `@mcp` annotation instead.
