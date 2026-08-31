defmodule NoizuPromptLingua.MCP.KeyToolsets do
  @moduledoc """
  Per-API-key MCP toolset resolution for the gateway.

  Every MCP consumer API key may carry its own toolset config
  (`mcp_api_keys.toolset_config`, shape-identical to custom-scope configs:

      %{"groups" => %{"<group_id>" => %{
           "disabled" => boolean, "hidden" => boolean,
           "tools" => %{"<Tool.Name>" => %{"disabled" => boolean, "hidden" => boolean}}}}}

  Resolution cascade (most specific wins; absent field = inherit):

    1. global `tobor` template →
    2. custom-scope config (per-user/org default endpoint or named preset) →
    3. **key overrides** (this module).

  Semantics:

    * `disabled: true` — blocks EXECUTION. Enforced in
      `NoizuPromptLingua.MCP.ToolGuard` (before RBAC, independent of
      `:mcp_authz_mode` — this is hard capability config, not RBAC rollout)
      and in `NoizuPromptLingua.Tools.Catalog.call_hidden_tool/4`.
    * `hidden: true` — blocks LISTING/DISCOVERY only. Enforced in
      `handle_list_tools` (via `NoizuPromptLingua.MCP.Server`) and
      `NoizuPromptLingua.Tools.Catalog.build/2`. A hidden tool can still be
      called directly unless also `disabled`.
    * Keys never ADD tools: on the main servers all tools are included by
      default, on `/custom/:slug/mcp` the scope's include set still governs —
      key config only flips flags.

  The key is resolved server-side from `ctx.assigns.auth_claims["api_key_id"]`
  (minted into the MCP JWT at token time). OAuth-only tokens without an
  api_key_id inherit everything (no overrides).
  """

  require Logger

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.MCPServers

  @empty %{"groups" => %{}}

  @doc """
  The calling key's toolset config (normalized), or `nil` when the request
  carries no API key (OAuth-only / system principal) or the key is unknown.
  """
  def config_for(ctx) do
    with api_key_id when is_binary(api_key_id) <- api_key_id(ctx),
         %McpApiKey{status: "active"} = key <- Repo.get(McpApiKey, api_key_id),
         config when is_map(config) <- key.toolset_config,
         true <- config != %{} do
      normalize(config)
    else
      _ -> nil
    end
  rescue
    e ->
      Logger.warning("[KeyToolsets] config resolution failed: #{Exception.message(e)}")
      nil
  end

  @doc "api_key_id from the MCP JWT claims in ctx.assigns."
  def api_key_id(ctx) do
    claims = get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}
    claims["api_key_id"]
  end

  # Discovery/NPL tool modules are registered on every domain server as the
  # browsing plane — they are never key-gated (their OUTPUT respects per-key
  # hidden/disabled via Catalog). Groups resolve via the tool module.
  @ungated_categories ["Discovery", "NPL"]

  def ungated_category?(category) when category in @ungated_categories, do: true
  def ungated_category?(_), do: false

  def tool_category(spec) do
    (spec.definition && spec.definition.meta && spec.definition.meta["category"]) || nil
  end

  @doc """
  Resolve the per-key flags for a (group, tool) pair from the calling ctx.

    * `:disabled` — blocks EXECUTION. Enforced in
      `NoizuPromptLingua.MCP.ToolGuard` (before RBAC; independent of
      `:mcp_authz_mode` — this is capability config, not RBAC rollout) and in
      `NoizuPromptLingua.Tools.Catalog.call_hidden_tool/4`.
    * `hidden` — blocks LISTING/DISCOVERY only; the tool remains callable
      directly unless also disabled.
  """
  def state(group_id, tool_name, ctx) when is_binary(group_id) and is_binary(tool_name) do
    case config_for(ctx) do
      nil -> %{disabled: false, hidden: false}
      config -> state_from_config(config, group_id, tool_name)
    end
  end

  # Unresolvable group (root-only tools: Discovery, NPL) is ungated.
  def state(_group_id, tool_name, _ctx) when is_binary(tool_name),
    do: %{disabled: false, hidden: false}

  @doc "Resolve flags for (group, tool) against a concrete config (no ctx)."
  def state_from_config(config, group_id, tool_name) when is_map(config) do
    groups = Map.get(normalize(config), "groups", %{})
    group = Map.get(groups, group_id) || %{}
    tools = Map.get(group, "tools") || %{}
    tool = Map.get(tools, tool_name) || %{}

    %{
      disabled: flag(group, tool, "disabled"),
      hidden: flag(group, tool, "hidden")
    }
  end

  def state_from_config(_, _, _), do: %{disabled: false, hidden: false}

  # More specific wins: a boolean on the tool entry overrides the group's flag;
  # otherwise the group flag governs (absent = false = inherit/no restriction).
  defp flag(group, tool, key) do
    case Map.get(tool, key) do
      value when is_boolean(value) -> value
      _ -> Map.get(group, key) == true
    end
  end

  @doc """
  Overlay a key's toolset config ON TOP OF a custom scope's config: key flags
  win per group and per tool, absent key fields inherit the scope value. The
  scope's include set is preserved (groups never added or removed by keys).
  Returns a config in the same shape as the scope input.
  """
  def overlay(scope_config, key_config) when is_map(scope_config) and is_map(key_config) do
    key_groups = Map.get(normalize(key_config), "groups", %{})
    scope_groups = Map.get(scope_config, "groups") || Map.get(scope_config, :groups) || %{}

    merged =
      Map.new(scope_groups, fn {group_id, group_cfg} ->
        group_id = to_string(group_id)
        key_group = Map.get(key_groups, group_id)

        case key_group do
          nil ->
            {group_id, group_cfg}

          overrides ->
            {group_id, overlay_group(group_cfg || %{}, overrides)}
        end
      end)

    base = Map.drop(scope_config, ["groups", :groups])
    Map.put(base, "groups", merged)
  end

  def overlay(scope_config, nil) when is_map(scope_config), do: scope_config
  def overlay(nil, _), do: %{}

  defp overlay_group(scope_group, key_group) do
    scope_group
    |> override_flag("disabled", key_group)
    |> override_flag("hidden", key_group)
    |> overlay_tools(key_group)
  end

  defp overlay_tools(scope_group, key_group) do
    key_tools = Map.get(key_group, "tools") || %{}
    scope_tools = Map.get(scope_group, "tools") || %{}

    merged =
      Map.new(scope_tools, fn {tool_name, tool_cfg} ->
        tool_name = to_string(tool_name)

        case Map.get(key_tools, tool_name) do
          nil -> {tool_name, tool_cfg}
          overrides -> {tool_name, overlay_tool(tool_cfg || %{}, overrides)}
        end
      end)

    Map.put(scope_group, "tools", merged)
  end

  defp overlay_tool(scope_tool, key_tool) do
    scope_tool
    |> override_flag("disabled", key_tool)
    |> override_flag("hidden", key_tool)
  end

  defp override_flag(map, flag, overrides) do
    case Map.get(overrides, flag) do
      value when is_boolean(value) -> Map.put(map, flag, value)
      _ -> map
    end
  end

  @doc """
  Apply per-key `hidden`/`disabled` listing rules to expanded tool specs.

  `group_id` is the owning MCP group when the caller knows it (a static
  subdomain server); pass `nil` to resolve per spec via the tool's module
  (`MCPServers.group_id_for_tool_module/1`). Disabled tools are dropped from
  the listing as well as denied at call time.
  """
  def apply_hidden(specs, ctx, group_id) when is_list(specs) do
    config = config_for(ctx)

    if config == nil do
      specs
    else
      Enum.reject(specs, fn spec ->
        ungated_category?(tool_category(spec)) or ungated?(spec, config, group_id)
      end)
    end
  end

  def apply_hidden(specs, _ctx, _group_id), do: specs

  defp ungated?(spec, config, group_id) do
    name = spec.definition.name
    gid = group_id || MCPServers.group_id_for_tool_module(spec.module)
    flags = state_from_config(config, gid, name)
    flags.hidden == true or flags.disabled == true
  end

  @doc "Normalize a key toolset config (delegates to the key context's normalizer)."
  def normalize(config), do: NoizuPromptLingua.MCPApiKeys.normalize_toolset(config)

  @doc "The empty (inherit-everything) config."
  def empty, do: @empty
end
