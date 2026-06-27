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

  def resolve_alias(name) do
    name
  end

  def build(server \\ NoizuPromptLingua.MCP, ctx \\ nil) do
    specs = specs(server, ctx)

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
    specs = specs(server, ctx)

    case Enum.find(specs, &(&1.definition.name == name)) do
      nil ->
        {:error, "Tool '#{name}' not found"}

      %{hidden: false} ->
        {:mcp, "Tool '#{name}' is MCP-visible — call it directly via MCP protocol"}

      spec ->
        # Forward the caller's ctx so the dispatched tool keeps the auth context
        # (assigns.auth_claims, etc.). Only fabricate a bare ctx when invoked
        # without one (e.g. internal/non-request callers).
        ctx = dispatch_ctx(ctx, server)
        args = cast_arguments(spec, arguments || %{})
        spec.module.call(args, ctx)
    end
  end

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
