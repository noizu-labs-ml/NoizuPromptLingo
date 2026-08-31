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

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCPCustomScopes

  @discovery_tools [
    {NoizuPromptLingua.Tools.ToolSummary, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolSearch, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolDefinition, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolCall, [category: "Discovery"]},
    {NoizuPromptLingua.Tools.ToolHelp, [category: "Discovery"]}
  ]

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
      # Effective state for the scope layer (client layer is applied later by
      # MCP.Server.list_tools via KeyToolsets/EffectiveToolset with the ctx).
      states = EffectiveToolset.resolve(scope, nil, nil)

      scope.config
      |> MCPCustomScopes.normalize_config(scope.kind)
      |> Map.fetch!("groups")
      |> Enum.flat_map(fn {group_id, group_config} ->
        group_specs(group_id, group_config, states)
      end)
    else
      _ -> []
    end
  end

  defp group_specs(_group_id, %{"disabled" => true}, _states), do: []

  defp group_specs(group_id, _group_config, states) do
    with module when is_atom(module) and not is_nil(module) <-
           NoizuPromptLingua.MCPServers.server_module(group_id) do
      module.__mcp__(:tools)
      |> Tools.expand()
      |> Enum.reject(&(tool_category(&1) == "Discovery"))
      |> Enum.map(fn spec ->
        EffectiveToolset.apply_state(spec, EffectiveToolset.lookup(states, spec.definition.name))
      end)
      |> Enum.reject(&is_nil/1)
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
      scope.kind == "all_in_one" or
        scope.slug == MCPCustomScopes.default_package_slug() or
        scope.source_template_slug == MCPCustomScopes.default_package_slug() or
        scope.name == MCPCustomScopes.account_default_name() or
        not is_nil(scope.user_id) or
        not is_nil(scope.organization_id)
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
end
