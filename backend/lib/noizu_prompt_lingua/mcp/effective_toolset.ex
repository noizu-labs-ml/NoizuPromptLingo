defmodule NoizuPromptLingua.MCP.EffectiveToolset do
  @moduledoc """
  THE toolset resolution interface (TOBOR-CONTRACTS §2).

  Answers one question: given scope + client + user + now, what is each tool's
  effective state? Everything downstream (listing, dispatch guard, manifests,
  OAuth consent) consumes THIS, not the DB shapes.

  Resolution cascade (most specific wins per key; absent field inherits; a
  tool absent from every layer is ENABLED + VISIBLE — inverted semantics):

    1. global `tobor` template config
    2. custom-scope config (`mcp_custom_scopes.config`)
    3. client `toolset_config` (API key today; OAuth client jsonb via W8)

  Per layer, a tool-level entry beats its group's flags (boolean overrides).

  Per-tool effective state:

      %{enabled: boolean,                  # execution (was `disabled`)
        visible: boolean,                  # discovery/listing (was `hidden`)
        name_override: String.t() | nil,   # W9 field — ships now
        description_override: String.t() | nil,
        expires_at: DateTime.t() | nil}    # temporal window, via MCP.Window

  Semantics preserved from the pre-refactor split:

    * `enabled: false` — blocks EXECUTION (`ToolGuard` via `KeyToolsets.state/3`,
      before RBAC, independent of `:mcp_authz_mode`) and drops from listings.
    * `visible: false` — blocks LISTING/DISCOVERY only; still callable unless
      also disabled.
    * Clients never ADD tools: with a scope present the include set is the
      scope's group set; client config only flips flags on those groups.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.Window
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey

  require Logger

  @type tool_state :: %{
          enabled: boolean(),
          visible: boolean(),
          name_override: String.t() | nil,
          description_override: String.t() | nil,
          expires_at: DateTime.t() | nil
        }

  @type scope :: NoizuPromptLingua.Schema.MCPCustomScope.t() | map() | nil
  @type client :: %{id: term(), kind: :api_key | :oauth_client, toolset_config: map() | nil} | nil

  @default_state %{
    enabled: true,
    visible: true,
    name_override: nil,
    description_override: nil,
    expires_at: nil
  }

  @doc "The inherit-everything state (absent = enabled + visible)."
  def default_state, do: @default_state

  # ── THE resolution contract ────────────────────────────────────────────────

  @doc """
  Resolve the effective toolset for `scope` + `client` at instant `at`.

  Returns a map keyed by canonical tool name (underscore form once F5 lands;
  dotted today — `canonical/1` picks up `MCP.ToolNames` automatically at
  merge). `user_ref_or_nil` is reserved for the F1 ACL layering (per-user
  denies/grants folded into the same map) and does not affect state yet.
  """
  @spec resolve(scope, client, term(), DateTime.t()) :: %{String.t() => tool_state()}
  def resolve(scope, client, user_ref_or_nil, at \\ DateTime.utc_now())

  def resolve(scope, client, _user_ref, at) do
    template = template_config()
    scope_cfg = scope_config(scope)
    client_cfg = normalize_config(client_config(client))

    groups = include_groups(scope_cfg, template, client_cfg)

    groups
    |> Enum.flat_map(fn group_id ->
      tool_names(group_id, [client_cfg, scope_cfg, template])
      |> Enum.uniq()
      |> Map.new(fn tool_name ->
        {canonical(tool_name), state(group_id, tool_name, template, scope_cfg, client_cfg, at)}
      end)
    end)
    |> Enum.into(%{})
  end

  # Include set: with a scope, the scope's groups govern (clients/templates only
  # flip flags). Without one (static subdomain servers, ToolGuard), union of
  # template + client groups — there is no scope include set to respect.
  defp include_groups(nil = _scope_cfg, template, client_cfg) do
    (Map.get(template || %{}, "groups") || %{})
    |> Map.merge(Map.get(client_cfg || %{}, "groups") || %{})
    |> Map.keys()
  end

  defp include_groups(scope_cfg, _template, _client_cfg),
    do: Map.keys(Map.get(scope_cfg, "groups") || %{})

  @doc """
  Single-tool state — the hot-path entry point (ToolGuard / Catalog). Same
  cascade as `resolve/4` but resolves one (group, tool) pair without
  enumerating the group's catalog. `group_id: nil` (root-only Discovery/NPL
  tools) is ungated: inherit-everything.
  """
  @spec state(String.t() | nil, String.t(), scope, client, DateTime.t()) :: tool_state()
  def state(group_id, tool_name, scope, client, at \\ DateTime.utc_now())

  def state(group_id, tool_name, scope, client, at)
      when is_binary(group_id) and is_binary(tool_name) do
    template = template_config()
    scope_cfg = scope_config(scope)
    client_cfg = normalize_config(client_config(client))

    state(group_id, tool_name, template, scope_cfg, client_cfg, at)
  end

  def state(nil, _tool_name, _scope, _client, _at), do: @default_state

  # Cascade across [client, scope, template]: per key, the most specific layer
  # with an opinion wins; within a layer, the tool entry beats the group flag.
  defp state(group_id, tool_name, template, scope_cfg, client_cfg, at) do
    entries =
      [client_cfg, scope_cfg, template]
      |> Enum.flat_map(fn layer ->
        case layer_entries(layer, group_id, tool_name) do
          nil -> []
          pair -> [pair]
        end
      end)

    build_state(entries, at)
  end

  defp layer_entries(nil, _group_id, _tool_name), do: nil

  defp layer_entries(config, group_id, tool_name) when is_map(config) do
    groups = Map.get(config, "groups") || %{}
    group = Map.get(groups, group_id)

    case group do
      nil ->
        nil

      group ->
        tools = Map.get(group, "tools") || %{}

        # F5 naming: configs may key tools dotted (Session.Create) or canonical
        # underscore (Session_Create) — probe both spellings so no read path is
        # dotted-only (contract ledger #4).
        tool =
          Map.get(tools, tool_name) || Map.get(tools, canonical(tool_name)) ||
            Map.get(tools, dotted(canonical(tool_name))) || %{}

        {group, tool}
    end
  end

  defp layer_entries(_, _, _), do: nil

  defp build_state(entries, at) do
    disabled = flag(entries, "disabled")
    hidden = flag(entries, "hidden")
    name_override = flag(entries, "name_override")
    description_override = flag(entries, "description_override")

    merged =
      entries
      |> Enum.reverse()
      |> Enum.reduce(%{}, fn {group, tool}, acc -> acc |> Map.merge(group) |> Map.merge(tool) end)

    {window_visible, expires_at} = Window.evaluate(merged, at)

    # F3 enforcement wiring: a LIVE enable_for_hours window LIFTS BOTH static
    # flags (disabled + hidden) while active; expired windows are no-ops
    # (evaluate degrades to {true, nil} and lifting? to false).
    lifted? = Window.lifting?(merged, at)

    base_visible = hidden != true

    %{
      enabled: lifted? or disabled != true,
      visible: lifted? or (base_visible and window_visible),
      name_override: string_or_nil(name_override),
      description_override: string_or_nil(description_override),
      expires_at: expires_at
    }
  end

  # First layer carrying the key wins; a present-but-false value IS an opinion
  # (so reduce_while, not find_value — find_value would skip explicit `false`).
  defp flag(entries, key) do
    Enum.reduce_while(entries, nil, fn {group, tool}, _acc ->
      cond do
        Map.has_key?(tool, key) -> {:halt, tool[key]}
        Map.has_key?(group, key) -> {:halt, group[key]}
        true -> {:cont, nil}
      end
    end)
  end

  defp string_or_nil(v) when is_binary(v), do: v
  defp string_or_nil(_), do: nil

  # ── consumers ──────────────────────────────────────────────────────────────

  @doc """
  Look up a tool's state in a resolved map, canonicalizing the key. Absent
  (not mentioned by any layer) => inherit-everything default.
  """
  def lookup(states, tool_name) when is_map(states) do
    Map.get(states, canonical(tool_name)) || @default_state
  end

  @doc """
  Apply a resolved state to an expanded tool spec for listing.

  Returns `nil` when the tool must be dropped (disabled), otherwise the spec
  with `hidden` set from `visible` and name/description overrides applied.
  A state equal to the inherit-everything default is a NO-OP so statically
  registered `hidden` flags survive when no config layer has an opinion.
  """
  def apply_state(spec, state)

  def apply_state(_spec, nil), do: nil

  def apply_state(spec, state) when is_map(state) do
    cond do
      state == @default_state ->
        spec

      state[:enabled] == false ->
        nil

      true ->
        definition =
          spec.definition
          |> maybe_override(:name, state[:name_override])
          |> maybe_override(:description, state[:description_override])

        %{spec | definition: definition, hidden: not state[:visible]}
    end
  end

  defp maybe_override(definition, _key, nil), do: definition
  defp maybe_override(definition, key, value), do: Map.put(definition, key, value)

  @doc """
  Listing filter for the shared server pipeline (`MCP.Server.list_tools`,
  `Tools.Catalog`): resolve the caller's client + scope states and drop
  hidden/disabled specs. Discovery/NPL categories are never gated. `group_id`
  pins the owning group when the caller knows it.
  """
  def apply_to_specs(specs, ctx, group_id \\ nil) when is_list(specs) do
    client = client_for_ctx(ctx)
    scope = scope_from_ctx(ctx)

    if client == nil and scope == nil do
      specs
    else
      Enum.reject(specs, fn spec ->
        if ungated_category?(spec) do
          true
        else
          gid = group_id || MCPServers.group_id_for_tool_module(spec.module)
          ts = state(gid, spec.definition.name, scope, client)
          not ts.visible or not ts.enabled
        end
      end)
    end
  end

  # Discovery/NPL tool modules are registered on every domain server as the
  # browsing plane — they are never gated (their OUTPUT respects per-client
  # flags via Catalog).
  @ungated_categories ["Discovery", "NPL"]

  def ungated_category?(spec) do
    category = spec.definition && spec.definition.meta && spec.definition.meta["category"]
    category in @ungated_categories
  end

  # ── ctx plumbing ───────────────────────────────────────────────────────────

  @doc """
  The calling client resolved from `ctx.assigns.auth_claims`: the active API
  key (minted into the MCP JWT at token time) with its `toolset_config`, or
  nil when the request carries no API key (OAuth-only / system principal —
  OAuth clients gain their jsonb overrides via W8).
  """
  def client_for_ctx(ctx) do
    claims = get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}

    with api_key_id when is_binary(api_key_id) <- claims["api_key_id"],
         %McpApiKey{status: "active"} = key <- Repo.get(McpApiKey, api_key_id) do
      config = if is_map(key.toolset_config) and key.toolset_config != %{}, do: key.toolset_config
      %{id: key.id, kind: :api_key, toolset_config: config}
    else
      _ -> nil
    end
  rescue
    e ->
      Logger.warning("[EffectiveToolset] client resolution failed: #{Exception.message(e)}")
      nil
  end

  @doc "The custom scope serving this request (ctx assigns), or nil."
  def scope_from_ctx(ctx) do
    assigns = get_in(ctx, [Access.key(:assigns, %{})]) || %{}
    slug = assigns[:custom_scope_slug] || assigns["custom_scope_slug"]

    with slug when is_binary(slug) <- slug do
      MCPCustomScopes.get_by_slug(slug)
    else
      _ -> nil
    end
  end

  @doc "Client toolset config from `ctx.assigns.auth_claims` (normalized), or nil."
  def config_for_ctx(ctx) do
    case client_for_ctx(ctx) do
      %{toolset_config: config} when is_map(config) -> MCPApiKeys.normalize_toolset(config)
      _ -> nil
    end
  end

  # ── legacy config helpers (shape-compatible with the pre-refactor API) ─────

  @doc "Resolve legacy (disabled, hidden) flags for (group, tool) against ONE concrete config — pure, no cascade, no DB."
  def state_from_config(config, group_id, tool_name) when is_map(config) do
    entries =
      case layer_entries(normalize_config(config), group_id, tool_name) do
        nil -> []
        pair -> [pair]
      end

    build_state(entries, DateTime.utc_now())
    |> then(&%{disabled: not &1.enabled, hidden: not &1.visible})
  end

  def state_from_config(_, _, _), do: %{disabled: false, hidden: false}

  @doc """
  Overlay a more-specific config ON TOP OF a base config: boolean/value
  overrides win per group and per tool, absent override fields inherit the
  base value. The base's include set is preserved (overrides never add or
  remove groups). Returns a config in the same shape as the base input.
  """
  def overlay(base, overrides) when is_map(base) and is_map(overrides) do
    ov_groups = Map.get(normalize_config(overrides), "groups") || %{}
    base_groups = Map.get(base, "groups") || Map.get(base, :groups) || %{}

    merged =
      Map.new(base_groups, fn {group_id, group_cfg} ->
        group_id = to_string(group_id)

        case Map.get(ov_groups, group_id) do
          nil -> {group_id, group_cfg}
          ov -> {group_id, overlay_group(group_cfg || %{}, ov)}
        end
      end)

    base
    |> Map.drop(["groups", :groups])
    |> Map.put("groups", merged)
  end

  def overlay(base, _overrides) when is_map(base), do: base
  def overlay(nil, _), do: %{}

  defp overlay_group(base_group, ov_group) do
    base_group
    |> override_flag("disabled", ov_group)
    |> override_flag("hidden", ov_group)
    |> override_value("name_override", ov_group)
    |> override_value("description_override", ov_group)
    |> overlay_tools(ov_group)
  end

  defp overlay_tools(base_group, ov_group) do
    ov_tools = Map.get(ov_group, "tools") || %{}
    base_tools = Map.get(base_group, "tools") || Map.get(base_group, :tools) || %{}

    merged =
      Map.new(base_tools, fn {tool_name, tool_cfg} ->
        tool_name = to_string(tool_name)

        case Map.get(ov_tools, tool_name) do
          nil -> {tool_name, tool_cfg}
          ov -> {tool_name, overlay_tool(tool_cfg || %{}, ov)}
        end
      end)

    Map.put(base_group, "tools", merged)
  end

  defp overlay_tool(base_tool, ov_tool) do
    base_tool
    |> override_flag("disabled", ov_tool)
    |> override_flag("hidden", ov_tool)
    |> override_value("name_override", ov_tool)
    |> override_value("description_override", ov_tool)
  end

  defp override_flag(map, flag, overrides) do
    case Map.get(overrides, flag) do
      value when is_boolean(value) -> Map.put(map, flag, value)
      _ -> map
    end
  end

  defp override_value(map, key, overrides) do
    case Map.get(overrides, key) do
      value when is_binary(value) -> Map.put(map, key, value)
      _ -> map
    end
  end

  # ── config layer readers ───────────────────────────────────────────────────

  # Raw read of the global `tobor` template — NO heal write on this hot path
  # (drift repair stays on the ensure_* paths that own the template).
  defp template_config do
    case MCPCustomScopes.get_by_slug(MCPCustomScopes.default_package_slug()) do
      %{config: config} when is_map(config) -> normalize_config(config)
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp scope_config(nil), do: nil

  defp scope_config(scope) do
    case scope do
      %{config: config} -> normalize_config(config)
      %{"config" => config} -> normalize_config(config)
      _ -> nil
    end
  end

  defp client_config(nil), do: nil
  defp client_config(%{toolset_config: config}), do: config
  defp client_config(%{"toolset_config" => config}), do: config
  defp client_config(_), do: nil

  # Light normalization: stringify keys (atom-tolerant) WITHOUT dropping
  # unknown entry keys — name/description overrides and temporal windows ride
  # the same entries as disabled/hidden and must survive. (The scope context's
  # normalizer is stricter; F3/W9 extend it for persistence.)
  defp normalize_config(nil), do: nil

  defp normalize_config(config) when is_map(config) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    %{"groups" => Map.new(groups, fn {gid, gcfg} -> {to_string(gid), normalize_group(gcfg)} end)}
  end

  defp normalize_config(_), do: nil

  defp normalize_group(gcfg) when is_map(gcfg) do
    tools = Map.get(gcfg, "tools") || Map.get(gcfg, :tools) || %{}

    gcfg
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
    |> Map.put("tools", Map.new(tools, &normalize_tool/1))
  end

  defp normalize_group(_), do: %{"tools" => %{}}

  defp normalize_tool({tool_name, tcfg}) when is_map(tcfg),
    do: {to_string(tool_name), Map.new(tcfg, fn {k, v} -> {to_string(k), v} end)}

  defp normalize_tool({tool_name, _}), do: {to_string(tool_name), %{}}

  # Canonical tool name (contract §4). F5 owns NoizuPromptLingua.MCP.ToolNames;
  # until that branch merges the dotted names in today's configs pass through
  # unchanged, and resolve/lookup pick the canonicalizer up automatically.
  defp canonical(name) when is_binary(name) do
    if Code.ensure_loaded?(NoizuPromptLingua.MCP.ToolNames) and
         function_exported?(NoizuPromptLingua.MCP.ToolNames, :canonical, 1) do
      apply(NoizuPromptLingua.MCP.ToolNames, :canonical, [name])
    else
      name
    end
  end

  defp canonical(name), do: name

  # Dotted alias of a canonical name (F5). Defensive shape mirrors canonical/1.
  defp dotted(name) when is_binary(name) do
    if Code.ensure_loaded?(NoizuPromptLingua.MCP.ToolNames) and
         function_exported?(NoizuPromptLingua.MCP.ToolNames, :dotted, 1) do
      apply(NoizuPromptLingua.MCP.ToolNames, :dotted, [name])
    else
      name
    end
  end

  defp dotted(name), do: name

  # ── group enumeration (full-map resolution) ────────────────────────────────

  defp tool_names(group_id, configs) do
    from_module =
      with module when is_atom(module) and not is_nil(module) <- MCPServers.server_module(group_id),
           true <- Code.ensure_loaded?(module),
           true <- function_exported?(module, :__mcp__, 1) do
        module.__mcp__(:tools) |> Tools.expand() |> Enum.map(& &1.definition.name)
      else
        _ -> []
      end

    from_config =
      Enum.flat_map(configs, fn config ->
        groups = Map.get(config || %{}, "groups") || %{}
        group = Map.get(groups, group_id) || %{}
        (Map.get(group, "tools") || %{}) |> Map.keys()
      end)

    Enum.uniq(from_module ++ from_config)
  end
end
