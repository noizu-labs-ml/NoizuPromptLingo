defmodule Noizu.MCP.Server.Tool do
  @moduledoc """
  Define an MCP tool as a module.

      defmodule MyApp.MCP.GetWeather do
        use Noizu.MCP.Server.Tool,
          description: "Get current weather for a location",
          annotations: [read_only_hint: true]

        input do
          field :location, :string, required: true, description: "City name or zip"
          field :units, :enum, values: [:celsius, :fahrenheit], default: :celsius
          field :days, :integer, min: 1, max: 14, default: 1
        end

        output do
          field :temperature, :number, required: true
          field :conditions, :string, required: true
        end

        @impl true
        def call(%{location: location, units: units, days: days}, ctx) do
          Noizu.MCP.Ctx.report_progress(ctx, 0.5)
          {:ok, %{temperature: 21.0, conditions: "clear"}}
        end
      end

  ## `use` options

    * `:name` — wire name; defaults to the module basename underscored
      (`MyApp.MCP.GetWeather` → `"get_weather"`)
    * `:description` — tells the model when and why to use the tool
    * `:title` — human-readable display name
    * `:annotations` — keyword list of behavior hints (`:read_only_hint`,
      `:destructive_hint`, `:idempotent_hint`, `:open_world_hint`, `:title`)
    * `:icons`, `:meta` — passed through to the wire definition
    * `:hidden` — when `true`, the tool is omitted from `tools/list` responses
      but remains callable. Useful for internal or privileged tools.
    * `:category` — free-form grouping label. Rides on the wire in
      `_meta.category` (merged into `:meta`) and is filterable through the
      built-in `Noizu.MCP.Server.Tools.Catalog` tool.

  Need several small tools in one module? See `Noizu.MCP.Server.Toolkit`.

  ## Schemas

  `input do ... end` declares the input schema with the `field` DSL — see the
  Tools & Schemas guide for field types. Arguments are validated against the
  compiled JSON Schema before `c:call/2` runs (failures become `isError: true`
  results the model can correct), then delivered **atom-keyed** with defaults
  applied and `:enum` values cast to atoms.

  Prefer raw JSON Schema? Use the escape hatch — arguments are then validated
  but delivered **string-keyed**, uncast:

      input_schema %{
        "type" => "object",
        "properties" => %{"query" => %{"type" => "string"}},
        "required" => ["query"]
      }

  `input_schema`/`output_schema` also accept the schema as **raw JSON text**
  (decoded at compile time — malformed JSON is a compile error):

      input_schema \"\"\"
      {"type": "object", "properties": {"query": {"type": "string"}}, "required": ["query"]}
      \"\"\"

  `output do ... end` (or `output_schema %{...}`) declares `outputSchema`; map
  return values are validated against it and sent as `structuredContent`.

  ## Return values from `c:call/2`

    * `{:ok, String.t()}` — single text content block
    * `{:ok, map()}` — structured content (requires/uses output schema if declared)
    * `{:ok, Content.t() | [Content.t()]}` — explicit content blocks
    * `{:ok, ToolResult.t()}` — full control
    * `{:error, String.t() | Content.t() | [Content.t()]}` — tool *execution*
      error (`isError: true`, visible to the model)
    * `{:error, Noizu.MCP.Error.t()}` — protocol error
  """

  alias Noizu.MCP.Types

  @doc "Execute the tool. See the module docs for argument and return contracts."
  @callback call(args :: map(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, term()} | {:error, term()}

  @doc "The wire definition advertised by `tools/list`."
  @callback definition() :: Types.Tool.t()

  @doc "Normalized runtime descriptor(s) — one-element list for classic tool modules."
  @callback __mcp_tools__() :: [Noizu.MCP.Server.Tool.Spec.t()]

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Noizu.MCP.Server.Tool
      import Noizu.MCP.Server.Tool,
        only: [input: 1, output: 1, input_schema: 1, output_schema: 1]

      @__mcp_tool_opts__ opts
      @__mcp_input_schema__ nil
      @__mcp_input_cast_plan__ nil
      @__mcp_output_schema__ nil

      @before_compile Noizu.MCP.Server.Tool
    end
  end

  @doc "Declare the input schema with the `field` DSL."
  defmacro input(do: block) do
    fields = Noizu.MCP.Server.Tool.Fields.extract(block, __CALLER__)
    schema = Noizu.MCP.Server.Tool.Fields.to_json_schema(fields)
    cast_plan = Noizu.MCP.Server.Tool.Fields.to_cast_plan(fields)

    quote do
      @__mcp_input_schema__ unquote(Macro.escape(schema))
      @__mcp_input_cast_plan__ unquote(Macro.escape(cast_plan))
    end
  end

  @doc "Declare the input schema as a raw JSON Schema map (string keys)."
  defmacro input_schema(schema) do
    quote do
      @__mcp_input_schema__ unquote(schema)
      @__mcp_input_cast_plan__ nil
    end
  end

  @doc "Declare the output schema with the `field` DSL."
  defmacro output(do: block) do
    fields = Noizu.MCP.Server.Tool.Fields.extract(block, __CALLER__)
    schema = Noizu.MCP.Server.Tool.Fields.to_json_schema(fields)

    quote do
      @__mcp_output_schema__ unquote(Macro.escape(schema))
    end
  end

  @doc "Declare the output schema as a raw JSON Schema map (string keys)."
  defmacro output_schema(schema) do
    quote do
      @__mcp_output_schema__ unquote(schema)
    end
  end

  defmacro __before_compile__(env) do
    opts = Module.get_attribute(env.module, :__mcp_tool_opts__)

    default_name =
      env.module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    name = Keyword.get(opts, :name, default_name)

    input_schema =
      case Module.get_attribute(env.module, :__mcp_input_schema__) do
        nil ->
          %{"type" => "object"}

        schema ->
          Noizu.MCP.Server.Tool.Fields.decode_schema!(
            schema,
            "#{inspect(env.module)} input_schema"
          )
      end

    output_schema =
      case Module.get_attribute(env.module, :__mcp_output_schema__) do
        nil ->
          nil

        schema ->
          Noizu.MCP.Server.Tool.Fields.decode_schema!(
            schema,
            "#{inspect(env.module)} output_schema"
          )
      end

    meta =
      case {opts[:meta], opts[:category]} do
        {nil, nil} -> nil
        {meta, nil} -> meta
        {meta, category} -> Map.put(meta || %{}, "category", category)
      end

    definition = %Noizu.MCP.Types.Tool{
      name: name,
      title: opts[:title],
      description: opts[:description],
      input_schema: input_schema,
      output_schema: output_schema,
      annotations: opts[:annotations],
      icons: opts[:icons],
      meta: meta
    }

    spec = %Noizu.MCP.Server.Tool.Spec{
      module: env.module,
      fun: :call,
      arity: 2,
      definition: definition,
      cast_plan: Module.get_attribute(env.module, :__mcp_input_cast_plan__),
      output_schema: output_schema,
      hidden: opts[:hidden] == true
    }

    quote do
      @impl Noizu.MCP.Server.Tool
      def definition, do: unquote(Macro.escape(definition))

      @impl Noizu.MCP.Server.Tool
      def __mcp_tools__, do: unquote(Macro.escape([spec]))
    end
  end
end
