defmodule NoizuPromptLingua.Tools.Catalog do
  @moduledoc """
  Tool catalog built from the MCP server's registered tools.

  Provides lookup, search, and category grouping over all tools
  (including hidden ones) registered on the NoizuPromptLingua.MCP server.
  """

  @type tool_param :: %{
          name: String.t(),
          type: String.t(),
          required: boolean(),
          description: String.t()
        }

  @type tool_entry :: %{
          name: String.t(),
          category: String.t(),
          description: String.t(),
          parameters: [tool_param()],
          hidden: boolean()
        }

  @doc """
  Canonical tool name for a caller-supplied identifier. Dotted spellings
  (`Session.Create`) are aliases; the canonical form is `Session_Create`
  (see `NoizuPromptLingua.MCP.ToolNames`).
  """
  def resolve_alias(name), do: NoizuPromptLingua.MCP.ToolNames.canonical(name)

  def build(server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    specs =
      specs(server, ctx)
      |> NoizuPromptLingua.MCP.ToolNames.canonical_specs()
      |> NoizuPromptLingua.MCP.KeyToolsets.apply_hidden(ctx, nil)

    Enum.map(specs, fn spec ->
      defn = spec.definition
      category = (defn.meta && defn.meta["category"]) || "Uncategorized"

      %{
        name: defn.name,
        category: category,
        description: defn.description || "",
        parameters: schema_to_params(defn.input_schema),
        hidden: spec.hidden
      }
    end)
  end

  def specs(server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    cond do
      is_atom(server) and function_exported?(server, :catalog_specs, 1) ->
        apply(server, :catalog_specs, [ctx])

      is_atom(server) and function_exported?(server, :__mcp__, 1) ->
        server.__mcp__(:tools) |> Noizu.MCP.Server.Features.Tools.expand()

      true ->
        []
    end
  end

  def get_tool(name, server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    name = resolve_alias(name)
    Enum.find(build(server, ctx), &(&1.name == name))
  end

  def get_tools_by_category(category, server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    Enum.filter(build(server, ctx), &(&1.category == category))
  end

  def categories(server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    build(server, ctx)
    |> Enum.group_by(& &1.category)
    |> Enum.map(fn {name, tools} ->
      %{name: name, tool_count: length(tools)}
    end)
    |> Enum.sort_by(& &1.name)
  end

  def call_hidden_tool(name, arguments, server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    name = resolve_alias(name)

    # B14: on a tool-set surface the inner universe is the RESOLVED set
    # (select_toolset → %Toolset.Custom{}), not the endpoint's static registry
    # (empty by design) — ToolCall answered "not found" for every tool there.
    # The set's own ceiling still applies: effective entries only, callable
    # only, visible tools refused (call them directly), everything else absent.
    case Noizu.MCP.Server.Features.Tools.select_toolset(server, ctx) do
      %Noizu.MCP.Toolset.Custom{} = selected ->
        call_on_set(selected, name, arguments, ctx)

      _ ->
        call_on_static(name, arguments, server, ctx)
    end
  end

  # Root/legacy path: the server's static registry (hidden tools dispatchable,
  # MCP-visible refused, per-key KeyToolset disables honored).
  defp call_on_static(name, arguments, server, ctx) do
    # Canonicalize specs so dotted catalog names match the canonical lookup.
    specs = NoizuPromptLingua.MCP.ToolNames.canonical_specs(specs(server, ctx))

    case Enum.find(specs, &(&1.definition.name == name)) do
      nil ->
        {:error, "Tool '#{name}' not found"}

      spec ->
        group_id = NoizuPromptLingua.MCPServers.group_id_for_tool_module(spec.module)

        case NoizuPromptLingua.MCP.KeyToolsets.state(group_id, name, ctx) do
          %{disabled: true} ->
            {:error, "Tool '#{name}' is disabled for this API key"}

          _ ->
            if spec.hidden == false do
              {:mcp, "Tool '#{name}' is MCP-visible — call it directly via MCP protocol"}
            else
              # Forward the caller's ctx so the dispatched tool keeps the auth context
              # (assigns.auth_claims, etc.). Only fabricate a bare ctx when invoked
              # without one (e.g. internal/non-request callers).
              ctx = dispatch_ctx(ctx, server)
              args = cast_arguments(spec, arguments || %{})
              spec.module.call(args, ctx)
            end
        end
    end
  end

  # Set-surface path (B14): match the canonical name over the resolved set's
  # EFFECTIVE entries (dotted wire spellings are aliases), then dispatch hidden
  # ones through the lib pipeline so the effective schema/plan/overrides apply.
  # Visibility/callability come pre-folded (overrides + ACL) — a non-callable
  # entry is indistinguishable from an absent one (existence-hiding).
  defp call_on_set(%Noizu.MCP.Toolset.Custom{} = selected, name, arguments, ctx) do
    case effective_entry(selected, name, ctx) do
      %{visible: true, definition: %{name: wire_name}} ->
        {:mcp, "Tool '#{wire_name}' is MCP-visible — call it directly via MCP protocol"}

      %{definition: %{name: wire_name}} ->
        dispatch_on_set(selected, wire_name, arguments, ctx)

      # Absent AND non-callable both land here — no discovery oracle.
      nil ->
        {:error, "Tool '#{name}' not found"}
    end
  end

  defp effective_entry(selected, name, ctx) do
    case Noizu.MCP.Toolset.catalog(selected, ctx, []) do
      {:ok, entries, _version} ->
        Enum.find(entries, fn entry ->
          entry.callable == true and
            NoizuPromptLingua.MCP.ToolNames.canonical(entry.definition.name) == name
        end)

      _ ->
        nil
    end
  end

  defp dispatch_on_set(selected, wire_name, arguments, ctx) do
    with {:ok, effective} <- Noizu.MCP.Toolset.resolve(selected, wire_name, ctx, []) do
      case Noizu.MCP.Toolset.invoke(selected, effective, arguments || %{}, ctx, []) do
        %Noizu.MCP.Types.ToolResult{} = result ->
          unwrap_tool_result(result)

        {:error, %Noizu.MCP.Error{message: message}} ->
          {:error, message}

        other ->
          other
      end
    end
  end

  # Map the lib's normalized result back onto ToolCall's {:ok, _}/{:error, _}
  # contract so the outer response shape matches the static path.
  defp unwrap_tool_result(%Noizu.MCP.Types.ToolResult{} = result) do
    if result.is_error do
      {:error, result_text(result)}
    else
      {:ok, result.structured || result_text(result)}
    end
  end

  defp result_text(%Noizu.MCP.Types.ToolResult{content: [%{text: text} | _]})
       when is_binary(text),
       do: text

  defp result_text(_), do: nil

  defp dispatch_ctx(%Noizu.MCP.Ctx{} = ctx, server), do: %{ctx | server: ctx.server || server}
  defp dispatch_ctx(_none, server), do: %Noizu.MCP.Ctx{server: server}

  defp cast_arguments(_, args), do: args

  @json_type_map %{
    "string" => "str",
    "integer" => "int",
    "boolean" => "bool",
    "number" => "float",
    "array" => "list",
    "object" => "dict"
  }

  defp schema_to_params(nil), do: []

  defp schema_to_params(%{"type" => "object"} = schema) do
    properties = Map.get(schema, "properties", %{})
    required = MapSet.new(Map.get(schema, "required", []))

    Enum.map(properties, fn {name, prop} ->
      json_type = Map.get(prop, "type", "string")

      json_type =
        case json_type do
          types when is_list(types) ->
            Enum.find(types, "string", &(&1 != "null"))

          t ->
            t
        end

      %{
        name: name,
        type: Map.get(@json_type_map, json_type, "str"),
        required: MapSet.member?(required, name),
        description: Map.get(prop, "description", "")
      }
    end)
  end

  defp schema_to_params(_), do: []
end
