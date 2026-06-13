defmodule Noizu.MCP.Server.Features.Tools do
  @moduledoc """
  Tools feature plumbing: the helpers behind the generated
  `handle_list_tools/2` and `handle_call_tool/3` defaults.

  Most servers never call this module directly. Reach for it when you
  hand-write those callbacks but still want the registry-driven behavior —
  e.g. session-gated visibility:

      @impl true
      def handle_list_tools(cursor, ctx) do
        Noizu.MCP.Server.Features.Tools.list_registered(
          __mcp__(:tools),
          cursor,
          include_hidden: ctx.assigns[:unlocked] == true
        )
      end

  For finer control, `expand/1` flattens the `__mcp__(:tools)` registration
  list into normalized `Noizu.MCP.Server.Tool.Spec` structs you can filter or
  remap before building the response.

  Also handled here: pagination, JSON Schema validation (per SEP-1303,
  input-validation failures are `isError` execution results, not protocol
  errors), argument casting for DSL tools, and normalization of handler
  return values to wire maps.
  """

  alias Noizu.MCP.{Error, Schema}
  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.Tool.{Fields, Spec}
  alias Noizu.MCP.Types.{Content, Tool, ToolResult}

  require Logger

  # ── tools/list ────────────────────────────────────────────────────────────

  def list(server, params, ctx) do
    cursor = (params || %{})["cursor"]

    case server.handle_list_tools(cursor, ctx) do
      {:ok, tools, next_cursor} ->
        result = %{"tools" => Enum.map(tools, &Tool.to_map/1)}
        result = if next_cursor, do: Map.put(result, "nextCursor", next_cursor), else: result
        {:ok, result}

      {:error, %Error{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Expand a `[{module, opts}]` registration list into flat `[%Spec{}]`.

  Every tool module exports `__mcp_tools__/0` — classic
  `use Noizu.MCP.Server.Tool` modules yield one spec,
  `use Noizu.MCP.Server.Toolkit` modules yield one per `@mcp`-annotated
  function. Registration opts are applied per spec:

    * `:hidden` / `:visible` — override visibility (`visible: false` ≡
      `hidden: true`; an explicit `:hidden` key wins when both are given)
    * `:category` — merged into the definition's `meta` as `"category"`
    * `:name` / `:description` — definition overrides, single-tool modules
      only (raises `ArgumentError` for multi-tool registrations, where the
      override would be ambiguous)
  """
  def expand(registered) do
    Enum.flat_map(registered, fn {module, opts} ->
      apply_registration_opts(module.__mcp_tools__(), module, opts)
    end)
  end

  defp apply_registration_opts(specs, module, opts) do
    if length(specs) > 1 and
         (Keyword.has_key?(opts, :name) or Keyword.has_key?(opts, :description)) do
      raise ArgumentError,
            ":name/:description registration overrides are ambiguous for multi-tool " <>
              "module #{inspect(module)} — set them per tool in the @mcp annotation"
    end

    Enum.map(specs, fn spec ->
      spec
      |> override_definition(opts)
      |> override_hidden(opts)
    end)
  end

  defp override_definition(spec, opts) do
    definition =
      Enum.reduce(opts, spec.definition, fn
        {:name, name}, acc ->
          %{acc | name: name}

        {:description, description}, acc ->
          %{acc | description: description}

        {:category, category}, acc ->
          %{acc | meta: Map.put(acc.meta || %{}, "category", category)}

        {_other, _}, acc ->
          acc
      end)

    %{spec | definition: definition}
  end

  defp override_hidden(spec, opts) do
    hidden =
      cond do
        Keyword.has_key?(opts, :hidden) -> opts[:hidden] == true
        Keyword.has_key?(opts, :visible) -> opts[:visible] == false
        true -> spec.hidden
      end

    %{spec | hidden: hidden}
  end

  @doc "Default `handle_list_tools` over the registered tool modules."
  def list_registered(registered, cursor, opts \\ []) do
    page_size = Keyword.get(opts, :page_size, Pagination.default_page_size())
    include_hidden = Keyword.get(opts, :include_hidden, false)

    definitions =
      registered
      |> expand()
      |> then(&if include_hidden, do: &1, else: Enum.reject(&1, fn spec -> spec.hidden end))
      |> Enum.map(& &1.definition)

    Pagination.paginate(definitions, cursor, page_size)
  end

  # ── tools/call ────────────────────────────────────────────────────────────

  def call(server, params, ctx) do
    name = (params || %{})["name"]
    args = (params || %{})["arguments"] || %{}

    if is_binary(name) do
      case server.handle_call_tool(name, args, ctx) |> normalize(nil) do
        {:error, %Error{} = error} -> {:error, error}
        %ToolResult{} = result -> {:ok, ToolResult.to_map(result)}
      end
    else
      {:error, Error.invalid_params("tools/call requires a tool name")}
    end
  end

  @doc "Default `handle_call_tool`: dispatch to a registered tool spec."
  def dispatch(registered, name, args, ctx) do
    case registered |> expand() |> Enum.find(&(&1.definition.name == name)) do
      nil -> {:error, Error.invalid_params("Unknown tool: #{name}")}
      spec -> run_spec(spec, args, ctx)
    end
  end

  defp run_spec(%Spec{} = spec, args, ctx) do
    case Schema.validate(spec.definition.input_schema, args) do
      :ok ->
        args =
          case spec.cast_plan do
            nil -> args
            plan -> Fields.cast(plan, args)
          end

        call_args =
          case spec.arity do
            0 -> []
            1 -> [args]
            2 -> [args, ctx]
          end

        apply(spec.module, spec.fun, call_args) |> normalize(spec.output_schema)

      {:error, message} ->
        # SEP-1303: validation failures are execution errors the model can fix.
        ToolResult.error("Invalid arguments for tool #{spec.definition.name}: #{message}")
    end
  end

  # ── return normalization ──────────────────────────────────────────────────

  @doc "Normalize a tool handler return value to a `ToolResult`."
  def normalize(result, output_schema)

  # Already normalized (e.g. by the DSL dispatch path) — pass through.
  def normalize(%ToolResult{} = result, _), do: result
  def normalize({:error, %Error{}} = error, _), do: error

  def normalize({:ok, %ToolResult{} = result}, output_schema) do
    check_output(result.structured, output_schema)
    result
  end

  def normalize({:ok, %Content{} = content}, _), do: ToolResult.ok(content)
  def normalize({:ok, text}, _) when is_binary(text), do: ToolResult.ok(text)

  def normalize({:ok, [%Content{} | _] = content}, _), do: ToolResult.ok(content)

  def normalize({:ok, %{} = structured}, output_schema) do
    check_output(structured, output_schema)
    ToolResult.structured(structured)
  end

  def normalize({:error, text}, _) when is_binary(text), do: ToolResult.error(text)
  def normalize({:error, %Content{} = content}, _), do: ToolResult.error(content)
  def normalize({:error, [%Content{} | _] = content}, _), do: ToolResult.error(content)

  def normalize(other, _) do
    raise ArgumentError,
          "invalid tool return value: #{inspect(other)} — expected {:ok, _} | {:error, _} " <>
            "(see Noizu.MCP.Server.Tool docs)"
  end

  defp check_output(_structured, nil), do: :ok
  defp check_output(nil, _schema), do: :ok

  defp check_output(structured, schema) do
    # Output is the server author's own contract — log loudly rather than fail
    # the call in production.
    case Schema.validate(schema, normalize_json(structured)) do
      :ok ->
        :ok

      {:error, message} ->
        Logger.warning("MCP tool structured content does not match its outputSchema: #{message}")
    end
  end

  # Round-trip through JSON encoding rules so atom keys/values compare like
  # they will appear on the wire.
  defp normalize_json(value), do: value |> Jason.encode!() |> Jason.decode!()
end
