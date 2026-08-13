defmodule NoizuPromptLingua.MCP.Custom do
  @moduledoc """
  Dynamic MCP server that exposes a DB-configured include set of existing
  domain MCP tools as one endpoint.
  """
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_custom",
    version: "0.1.0",
    instructions:
      "Custom Noizu Prompt Lingua MCP scope. Use Discovery tools to inspect the enabled tool set."

  alias Noizu.MCP.{Error, Schema}
  alias Noizu.MCP.Server.Features.{Pagination, Tools}
  alias Noizu.MCP.Server.Tool.{Fields, Spec}
  alias NoizuPromptLingua.MCPCustomScopes

  @discovery_tools [
    {NoizuPromptLingua.Tools.ToolSummary, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolSearch, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolDefinition, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolCall, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolHelp, [category: "Discovery"]}
  ]

  @impl true
  def handle_list_tools(cursor, ctx) do
    definitions =
      ctx
      |> catalog_specs()
      |> Enum.reject(& &1.hidden)
      |> Enum.map(& &1.definition)

    Pagination.paginate(definitions, cursor)
  end

  @impl true
  def handle_call_tool(name, args, ctx) do
    case Enum.find(catalog_specs(ctx), &(&1.definition.name == name)) do
      nil -> {:error, Error.invalid_params("Unknown tool: #{name}")}
      spec -> run_spec(spec, args || %{}, ctx)
    end
  end

  def catalog_specs(ctx) do
    custom_specs(ctx) ++ npl_specs(ctx) ++ discovery_specs() ++ overview_specs()
  end

  # Hidden overview tool (auto-registered like the discovery block). Its scope is
  # taken from ctx assigns (`custom_scope_slug`) at call time.
  defp overview_specs do
    Tools.expand([{NoizuPromptLingua.Tools.McpOverview, [category: "Discovery"]}])
  end

  def custom_specs(ctx) do
    with slug when is_binary(slug) <- scope_slug(ctx),
         scope when not is_nil(scope) <- MCPCustomScopes.get_by_slug(slug) do
      scope.config
      |> MCPCustomScopes.normalize_config(scope.kind)
      |> Map.fetch!("groups")
      |> Enum.flat_map(fn {group_id, group_config} ->
        group_specs(group_id, group_config)
      end)
    else
      _ -> []
    end
  end

  defp group_specs(_group_id, %{"disabled" => true}), do: []

  defp group_specs(group_id, group_config) do
    with module when is_atom(module) and not is_nil(module) <-
           NoizuPromptLingua.MCPServers.server_module(group_id) do
      group_hidden = Map.get(group_config, "hidden")
      tool_config = Map.get(group_config, "tools") || %{}

      module.__mcp__(:tools)
      |> Tools.expand()
      |> Enum.reject(&(tool_category(&1) == "Discovery"))
      |> Enum.reject(fn spec ->
        get_in(tool_config, [spec.definition.name, "disabled"]) == true
      end)
      |> Enum.map(fn spec ->
        tool_hidden = get_in(tool_config, [spec.definition.name, "hidden"])

        cond do
          is_boolean(tool_hidden) -> %{spec | hidden: tool_hidden}
          is_boolean(group_hidden) -> %{spec | hidden: group_hidden}
          true -> spec
        end
      end)
    else
      _ -> []
    end
  end

  defp discovery_specs do
    Tools.expand(@discovery_tools)
  end

  # NPL load/spec live on the root aggregator, not a selectable group. Include
  # them on the default all-in-one package so one endpoint covers the daily set.
  @npl_tools [
    {NoizuPromptLingua.Tools.NPLLoad, [category: "NPL"]},
    {NoizuPromptLingua.Tools.NPLSpec, [category: "NPL"]}
  ]

  defp npl_specs(ctx) do
    if include_npl?(ctx), do: Tools.expand(@npl_tools), else: []
  end

  defp include_npl?(ctx) do
    with slug when is_binary(slug) <- scope_slug(ctx),
         scope when not is_nil(scope) <- MCPCustomScopes.get_by_slug(slug) do
      scope.kind == "all_in_one" or scope.slug == MCPCustomScopes.default_package_slug()
    else
      _ -> false
    end
  end

  defp tool_category(spec) do
    (spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized"
  end

  defp scope_slug(%Noizu.MCP.Ctx{assigns: assigns}) do
    assigns[:custom_scope_slug] || assigns["custom_scope_slug"]
  end

  defp scope_slug(_), do: nil

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

        apply(spec.module, spec.fun, call_args) |> Tools.normalize(spec.output_schema)

      {:error, message} ->
        Noizu.MCP.Types.ToolResult.error(
          "Invalid arguments for tool #{spec.definition.name}: #{message}"
        )
    end
  end
end
