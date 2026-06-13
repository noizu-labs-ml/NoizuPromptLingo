defmodule Noizu.MCP.Server.Features.Tools do
  @moduledoc false
  # Feature glue for tools/list and tools/call: pagination, schema validation
  # (per SEP-1303 input-validation failures are isError execution results, not
  # protocol errors), argument casting for DSL tools, and normalization of
  # handler return values to wire maps.

  alias Noizu.MCP.{Error, Schema}
  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.Tool.Fields
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

  @doc "Default `handle_list_tools` over the registered tool modules."
  def list_registered(registered, cursor, page_size \\ Pagination.default_page_size()) do
    definitions = Enum.map(registered, fn {module, opts} -> definition(module, opts) end)
    Pagination.paginate(definitions, cursor, page_size)
  end

  @doc "A tool module's effective definition with per-registration overrides applied."
  def definition(module, opts) do
    definition = module.definition()

    Enum.reduce(opts, definition, fn
      {:name, name}, acc -> %{acc | name: name}
      {:description, description}, acc -> %{acc | description: description}
      {_other, _}, acc -> acc
    end)
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

  @doc "Default `handle_call_tool`: dispatch to a registered tool module."
  def dispatch(registered, name, args, ctx) do
    case find_tool(registered, name) do
      nil ->
        {:error, Error.invalid_params("Unknown tool: #{name}")}

      {module, opts} ->
        run_tool(module, opts, args, ctx)
    end
  end

  defp find_tool(registered, name) do
    Enum.find(registered, fn {module, opts} ->
      definition(module, opts).name == name
    end)
  end

  defp run_tool(module, _opts, args, ctx) do
    definition = module.definition()

    case Schema.validate(definition.input_schema, args) do
      :ok ->
        args =
          case module.__mcp_tool__(:cast_plan) do
            nil -> args
            plan -> Fields.cast(plan, args)
          end

        module.call(args, ctx) |> normalize(module.__mcp_tool__(:output_schema))

      {:error, message} ->
        # SEP-1303: validation failures are execution errors the model can fix.
        ToolResult.error("Invalid arguments for tool #{definition.name}: #{message}")
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
