defmodule Noizu.MCP.Server.Toolkit do
  @moduledoc """
  Define several MCP tools in one module by annotating functions with `@mcp`.

      defmodule MyApp.Toolkit do
        use Noizu.MCP.Server.Toolkit, category: "Utility"   # optional default category

        @mcp name: "files.read", category: "Files", description: "Read a file",
             input: [path: [type: :string, required: true]],
             output: [data: [type: :string, required: true]]
        def read_file(%{path: path}, _ctx) do
          case File.read(path) do
            {:ok, data} -> {:ok, %{data: data}}
            {:error, reason} -> {:error, "read failed: \#{reason}"}
          end
        end

        @mcp description: "Server time (name derives from the function)"
        def server_time, do: {:ok, to_string(DateTime.utc_now())}

        @mcp visible: false
        @mcp input: \"\"\"
        {"type": "object", "properties": {"q": {"type": "string"}}}
        \"\"\"
        def lookup(args, _ctx), do: {:ok, args["q"] || ""}
      end

  Register the whole kit on a server with a single `tool` declaration —
  every annotated function becomes a tool:

      defmodule MyApp.MCP do
        use Noizu.MCP.Server, name: "myapp", version: "1.0.0"

        tool MyApp.Toolkit
        # registration opts apply to every tool in the kit:
        #   tool MyApp.Toolkit, hidden: true
        #   tool MyApp.Toolkit, category: "Admin"
        # (`name:`/`description:` overrides are not supported for toolkits —
        #  they are ambiguous across multiple tools)
      end

  ## `@mcp` options

    * `:name` — wire name; defaults to the function name (`server_time` →
      `"server_time"`)
    * `:title` — human-readable display name
    * `:description` — tells the model when and why to use the tool
    * `:category` — grouping label; defaults to the toolkit-level
      `category:` `use` option. Rides on the wire in `_meta.category`.
    * `:input` — input schema as a data-form field spec (keyword list, see
      below), a raw JSON Schema map, or raw JSON text
    * `:output` — output schema in the same three forms
    * `:input_schema` / `:output_schema` — raw schema only (map or JSON
      text); never interpreted as a field spec
    * `:annotations` — behavior-hint keyword list (`:read_only_hint`, ...)
    * `:icons`, `:meta` — passed through to the wire definition
    * `:hidden` — `true` omits the tool from `tools/list` (still callable)
    * `:visible` — `visible: false` is an alias for `hidden: true`
      (an explicit `:hidden` key wins when both are given)

  Multiple `@mcp` lines before one function merge into a single option set
  (later lines win on key conflict).

  ## Input forms

  A **keyword list** is the data-form field spec — the data equivalent of the
  classic `input do ... end` DSL:

      input: [
        message: [type: :string, required: true, description: "..."],
        repeat:  [type: :integer, min: 1, max: 10, default: 1],
        mode:    [type: :enum, values: [:plain, :loud], default: :plain],
        address: [type: :object, fields: [street: [type: :string]]],
        tags:    [type: {:array, :string}],
        rows:    [type: {:array, :object}, fields: [id: [type: :integer]]],
        note:    :string                     # shorthand: bare type
      ]

  Arguments are then validated and delivered **atom-keyed** with defaults
  applied and enum values cast to atoms, exactly like the classic DSL.

  A **map** is a raw JSON Schema (string keys); a **binary** is raw JSON text
  decoded at compile time (malformed JSON is a compile error). With raw
  schemas arguments are validated but delivered **string-keyed**, uncast.

  ## Annotated functions

  Annotated functions must be public (`def`) with arity 0, 1 (`args`), or 2
  (`args, ctx`) — the runtime trims the standard `(args, ctx)` invocation to
  the declared arity. Return values follow the same contract as
  `c:Noizu.MCP.Server.Tool.call/2`: `{:ok, text | map | Content | ToolResult}`
  or `{:error, ...}`; structured map results are checked against the output
  schema when one is declared.

  Tool names must be unique within a toolkit — duplicates are a compile error.
  """

  alias Noizu.MCP.Server.Tool.Fields
  alias Noizu.MCP.Server.Tool.Spec

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      Module.register_attribute(__MODULE__, :mcp, accumulate: true)
      Module.register_attribute(__MODULE__, :__mcp_toolkit_tools__, accumulate: true)
      @__mcp_toolkit_opts__ opts

      @on_definition Noizu.MCP.Server.Toolkit
      @before_compile Noizu.MCP.Server.Toolkit
    end
  end

  @doc false
  def __on_definition__(env, kind, fun, args, _guards, _body) do
    case Module.get_attribute(env.module, :mcp) do
      attrs when attrs in [nil, []] ->
        :ok

      attrs ->
        arity = length(args)

        cond do
          kind != :def ->
            raise CompileError,
              file: env.file,
              line: env.line,
              description:
                "@mcp is only allowed on public functions (def) — #{fun}/#{arity} is #{kind}"

          arity > 2 ->
            raise CompileError,
              file: env.file,
              line: env.line,
              description:
                "@mcp tool #{fun}/#{arity}: annotated functions take at most (args, ctx) — " <>
                  "arity must be 0, 1, or 2"

          true ->
            merged = merge_attrs(env, fun, attrs)
            Module.put_attribute(env.module, :__mcp_toolkit_tools__, {fun, arity, merged})
            # Clear so later clauses of this function (and the next def) start clean.
            Module.delete_attribute(env.module, :mcp)
        end
    end
  end

  # @mcp accumulates in reverse declaration order; merge so later lines win.
  defp merge_attrs(env, fun, attrs) do
    Enum.each(attrs, fn attr ->
      unless Keyword.keyword?(attr) do
        raise CompileError,
          file: env.file,
          line: env.line,
          description: "@mcp on #{fun} must be a keyword list, got: #{inspect(attr)}"
      end
    end)

    attrs |> Enum.reverse() |> Enum.reduce([], &Keyword.merge(&2, &1))
  end

  defmacro __before_compile__(env) do
    toolkit_opts = Module.get_attribute(env.module, :__mcp_toolkit_opts__) || []

    specs =
      env.module
      |> Module.get_attribute(:__mcp_toolkit_tools__)
      |> Enum.reverse()
      |> Enum.map(&build_spec(env, toolkit_opts, &1))

    names = Enum.map(specs, & &1.definition.name)
    duplicates = Enum.uniq(names -- Enum.uniq(names))

    if duplicates != [] do
      raise CompileError,
        file: env.file,
        description:
          "duplicate tool name(s) in #{inspect(env.module)}: #{Enum.join(duplicates, ", ")}"
    end

    quote do
      @doc "Normalized runtime descriptors for every `@mcp`-annotated function."
      def __mcp_tools__, do: unquote(Macro.escape(specs))
    end
  end

  defp build_spec(env, toolkit_opts, {fun, arity, opts}) do
    name = to_string(opts[:name] || fun)

    {input_schema, cast_plan} = build_input(env, name, opts)
    output_schema = build_output(env, name, opts)

    hidden =
      cond do
        Keyword.has_key?(opts, :hidden) -> opts[:hidden] == true
        Keyword.has_key?(opts, :visible) -> opts[:visible] == false
        true -> false
      end

    category = Keyword.get(opts, :category, toolkit_opts[:category])

    meta =
      case {opts[:meta], category} do
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

    %Spec{
      module: env.module,
      fun: fun,
      arity: arity,
      definition: definition,
      cast_plan: cast_plan,
      output_schema: output_schema,
      hidden: hidden
    }
  end

  defp build_input(env, name, opts) do
    cond do
      Keyword.has_key?(opts, :input_schema) ->
        {raw_schema!(env, name, :input_schema, opts[:input_schema]), nil}

      Keyword.has_key?(opts, :input) ->
        case opts[:input] do
          spec when is_list(spec) ->
            fields = fields_from_spec!(env, name, :input, spec)
            {Fields.to_json_schema(fields), Fields.to_cast_plan(fields)}

          other ->
            {raw_schema!(env, name, :input, other), nil}
        end

      true ->
        {%{"type" => "object"}, nil}
    end
  end

  defp build_output(env, name, opts) do
    cond do
      Keyword.has_key?(opts, :output_schema) ->
        raw_schema!(env, name, :output_schema, opts[:output_schema])

      Keyword.has_key?(opts, :output) ->
        case opts[:output] do
          spec when is_list(spec) ->
            fields_from_spec!(env, name, :output, spec) |> Fields.to_json_schema()

          other ->
            raw_schema!(env, name, :output, other)
        end

      true ->
        nil
    end
  end

  defp fields_from_spec!(env, name, key, spec) do
    Fields.from_spec(spec)
  rescue
    e in ArgumentError ->
      raise CompileError,
        file: env.file,
        description: "@mcp tool #{name} #{key}: #{Exception.message(e)}"
  end

  defp raw_schema!(env, name, key, value) do
    Fields.decode_schema!(value, "@mcp tool #{name} #{key}")
  rescue
    e in ArgumentError ->
      raise CompileError, file: env.file, description: Exception.message(e)
  end
end
