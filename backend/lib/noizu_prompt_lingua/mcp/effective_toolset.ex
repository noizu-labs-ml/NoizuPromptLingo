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

  ## ACL layer (debt D2 — per-user FINAL override)

  When `user_ref` is present, an ACL pass runs AFTER the config cascade and
  acts as the final override layer (`NoizuPromptLingua.Acl`, action
  `"mcp.tool"`):

    * per-tool resource: `{:ref, Schema.McpTool, canonical_tool_name}` — a
      matching `deny` rule HIDES + DISABLES that tool for that user
      (`enabled: false, visible: false`); kind wildcard
      `{:ref, Schema.McpTool, :any}` covers every tool, `{:ref, :any, :any}`
      globally.
    * scope-wide resource: `{:ref, Schema.MCPCustomScope, scope.id}` — a
      matching `deny` disables EVERY tool the scope serves.
    * `allow` verdicts and no-matches (resolved with `default: :allow`) are
      NO-OPS — the config cascade's state survives untouched. Explicit allow
      never overrides a config `disabled`/`hidden`.
    * users with NO rules match nothing => no-op, so nothing changes for
      anyone without ACL rules. `user_ref` absent => no ACL pass at all
      (legacy behavior byte-identical).

  `user_ref` normalization: an ERP ref passes through as-is, any entity struct
  via the ERP protocol, a bare binary is treated as a
  `NoizuPromptLingua.Users.User` id.

  Group membership comes free via `Acl.resolve` (transitive BFS expansion):
  W6's "permission group assignment" = adding the user's ref to an `acl_group`
  whose rules target tool/scope resources (`subject_ref = group.ref`).

  Enforcement seams: `resolve/4` (listings, Session.Manifest) and `state/6`
  (the hot path — ToolGuard via `KeyToolsets.state/3`, `apply_to_specs`).
  Root-only Discovery/NPL tools stay ungated, matching the existing
  toolset-gating policy.

  Semantics preserved from the pre-refactor split:

    * `enabled: false` — blocks EXECUTION (`ToolGuard` via `KeyToolsets.state/3`,
      before RBAC, independent of `:mcp_authz_mode`) and drops from listings.
    * `visible: false` — blocks LISTING/DISCOVERY only; still callable unless
      also disabled.
    * Clients never ADD tools: with a scope present the include set is the
      scope's group set; client config only flips flags on those groups.
  """

  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.ToolsetCache
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.MCP.Window
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.OAuthClient
  alias NoizuPromptLingua.Schema.McpTool
  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  require Logger

  # ACL action for the toolset override layer (debt D2): subject performs
  # `mcp.tool` on a tool (or scope) resource; deny hides + disables.
  @acl_action "mcp.tool"

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
  merge). When `user_ref_or_nil` is present, the ACL override layer (see
  "ACL layer" in the moduledoc) applies as the final pass — per-user denies
  hide + disable tools; absent user or no rules => config cascade unchanged.
  """
  @spec resolve(scope, client, term(), DateTime.t()) :: %{String.t() => tool_state()}
  def resolve(scope, client, user_ref_or_nil, at \\ DateTime.utc_now())

  def resolve(scope, client, user_ref, at) do
    template = template_config()
    scope_cfg = scope_config(scope)
    client_cfg = normalize_config(client_config(client))

    groups = include_groups(scope_cfg, template, client_cfg)

    states =
      groups
      |> Enum.flat_map(fn group_id ->
        tool_names(group_id, [client_cfg, scope_cfg, template])
        |> Enum.uniq()
        |> Map.new(fn tool_name ->
          {canonical(tool_name),
           cascade_state(group_id, tool_name, template, scope_cfg, client_cfg, at)}
        end)
      end)
      |> Enum.into(%{})

    apply_acl(states, scope, at, user_ref)
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
  tools) is ungated: inherit-everything. No user context (5th arg is `at`) =>
  no ACL pass.
  """
  @spec state(String.t() | nil, String.t(), scope, client, DateTime.t()) :: tool_state()
  def state(group_id, tool_name, scope, client, at \\ DateTime.utc_now())

  def state(group_id, tool_name, scope, client, at)
      when is_binary(group_id) and is_binary(tool_name) do
    template = template_config()
    scope_cfg = scope_config(scope)
    client_cfg = normalize_config(client_config(client))

    cascade_state(group_id, tool_name, template, scope_cfg, client_cfg, at)
  end

  def state(nil, _tool_name, _scope, _client, _at), do: @default_state

  @doc """
  Single-tool state WITH the per-user ACL override (debt D2) — the
  enforcement hot path (ToolGuard via `KeyToolsets.state/3`, `apply_to_specs`).
  Same cascade as `state/5`, then the ACL pass for `user_ref` (ERP ref, user
  struct, or bare `Users.User` id; nil => no ACL pass — identical to `state/5`).
  """
  @spec state(String.t() | nil, String.t(), scope, client, term(), DateTime.t()) :: tool_state()
  def state(group_id, tool_name, scope, client, user_ref, at)

  def state(group_id, tool_name, scope, client, user_ref, at)
      when is_binary(group_id) and is_binary(tool_name) do
    template = template_config()
    scope_cfg = scope_config(scope)
    client_cfg = normalize_config(client_config(client))

    cascade_state(group_id, tool_name, template, scope_cfg, client_cfg, at)
    |> apply_acl_tool(scope, at, user_ref, tool_name)
  end

  def state(nil, _tool_name, _scope, _client, _user_ref, _at), do: @default_state

  # Cascade across [client, scope, template]: per key, the most specific layer
  # with an opinion wins; within a layer, the tool entry beats the group flag.
  defp cascade_state(group_id, tool_name, template, scope_cfg, client_cfg, at) do
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

    {window_visible, expires_at} =
      entries
      |> Enum.reverse()
      |> Enum.reduce(%{}, fn {group, tool}, acc -> acc |> Map.merge(group) |> Map.merge(tool) end)
      |> Window.evaluate(at)

    base_visible = hidden != true

    %{
      enabled: disabled != true,
      visible: if(is_boolean(window_visible), do: base_visible and window_visible, else: base_visible),
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

  # ── ACL override layer (debt D2) ───────────────────────────────────────────

  @doc "The ACL action the toolset layer resolves (`\"mcp.tool\"`; `\"*\"` also matches)."
  def acl_action, do: @acl_action

  @doc "ACL resource ref for a canonical tool name (action `#{inspect(@acl_action)}`)."
  def tool_resource(tool_name), do: McpTool.ref(canonical(tool_name))

  @doc """
  The ACL subject for a request ctx: `MCP.Resolve.current_user_id/1` claims
  normalized to a `NoizuPromptLingua.Users.User` ref — nil (=> no ACL pass)
  for API-key-only/service principals and unauthenticated calls.
  """
  def user_for_ctx(ctx) do
    case NoizuPromptLingua.MCP.Resolve.current_user_id(ctx) do
      id when is_binary(id) and id != "" -> R.ref(module: NoizuPromptLingua.Users.User, id: id)
      _ -> nil
    end
  end

  # Final override pass over resolved states: deny hides + disables; allow and
  # no-match (`default: :allow`) are no-ops. nil user => identity (legacy).
  defp apply_acl(states, _scope, _at, nil), do: states

  defp apply_acl(states, scope, at, user_ref) do
    case acl_subject(user_ref) do
      nil ->
        states

      subject ->
        if match?({:deny, _}, scope_verdict(subject, scope, opts(at))) do
          Map.new(states, fn {name, st} -> {name, %{st | enabled: false, visible: false}} end)
        else
          Map.new(states, fn
            # Already blocked by the cascade — nothing an ACL pass could add.
            {name, %{enabled: false} = st} ->
              {name, st}

            {name, st} ->
              {name, apply_acl_tool(st, subject, at, name)}
          end)
        end
    end
  end

  # Single-tool ACL override (hot path). 4-arity: scope verdict already
  # resolved (map pass); 5-arity entry resolves it (state/6).
  defp apply_acl_tool(%{enabled: false} = ts, _subject, _at, _tool_name), do: ts

  defp apply_acl_tool(ts, subject, at, tool_name) do
    case Acl.resolve(subject, @acl_action, tool_resource(tool_name), opts(at)) do
      {:deny, _} -> %{ts | enabled: false, visible: false}
      _ -> ts
    end
  end

  defp apply_acl_tool(ts, _scope, _at, nil, _tool_name), do: ts

  defp apply_acl_tool(ts, scope, at, user_ref, tool_name) do
    case acl_subject(user_ref) do
      nil ->
        ts

      subject ->
        if match?({:deny, _}, scope_verdict(subject, scope, opts(at))) do
          %{ts | enabled: false, visible: false}
        else
          apply_acl_tool(ts, subject, at, tool_name)
        end
    end
  end

  defp opts(at), do: [default: :allow, at: at]

  # Scope-wide knob: `mcp.tool` on the scope's own ref denies every tool the
  # scope serves (kind/global wildcards apply via the standard rule matching).
  defp scope_verdict(_subject, nil, _opts), do: {:allow, :default}

  defp scope_verdict(subject, scope, opts) do
    case scope do
      %{id: id} when is_binary(id) ->
        Acl.resolve(subject, @acl_action, R.ref(module: MCPCustomScope, id: id), opts)

      %{"id" => id} when is_binary(id) ->
        Acl.resolve(subject, @acl_action, R.ref(module: MCPCustomScope, id: id), opts)

      _ ->
        {:allow, :default}
    end
  end

  # Normalize the caller-supplied user: ERP ref as-is, entity struct via the
  # protocol (Acl casts it), bare binary = Users.User id, anything else => nil
  # (no ACL pass rather than a bogus subject lookup).
  defp acl_subject(R.ref() = ref), do: ref
  defp acl_subject(subject) when is_struct(subject), do: subject
  defp acl_subject(id) when is_binary(id), do: R.ref(module: NoizuPromptLingua.Users.User, id: id)
  defp acl_subject(_), do: nil

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
  hidden/disabled specs (config cascade + per-user ACL override, debt D2).
  Discovery/NPL categories are never gated. `group_id` pins the owning group
  when the caller knows it.
  """
  def apply_to_specs(specs, ctx, group_id \\ nil) when is_list(specs) do
    client = client_for_ctx(ctx)
    scope = scope_from_ctx(ctx)
    user_ref = user_for_ctx(ctx)

    if client == nil and scope == nil do
      specs
    else
      Enum.reject(specs, fn spec ->
        if ungated_category?(spec) do
          true
        else
          gid = group_id || MCPServers.group_id_for_tool_module(spec.module)
          ts = state(gid, spec.definition.name, scope, client, user_ref, DateTime.utc_now())
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
  The calling client resolved from `ctx.assigns.auth_claims`, cached via
  `ToolsetCache` (positives only):

    * the active API key (`"api_key_id"`, minted into the MCP JWT at token
      time) with its `toolset_config`, or
    * the active OAuth client (`"client_id"`, W8 consent narrowing in
      `oauth_clients.toolset_config`) — `%{}`/nil config stays
      `toolset_config: nil` (ungated, legacy-grant semantics), or
    * nil when the request carries neither (system principal / unauthenticated).
  """
  def client_for_ctx(ctx) do
    claims = get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}

    with api_key_id when is_binary(api_key_id) <- claims["api_key_id"],
         %McpApiKey{status: "active"} = key <-
           ToolsetCache.fetch(:api_key, api_key_id, fn -> Repo.get(McpApiKey, api_key_id) end) do
      config = if is_map(key.toolset_config) and key.toolset_config != %{}, do: key.toolset_config
      %{id: key.id, kind: :api_key, toolset_config: config}
    else
      _ -> oauth_client_for_ctx(claims)
    end
  rescue
    e ->
      Logger.warning("[EffectiveToolset] client resolution failed: #{Exception.message(e)}")
      nil
  end

  # W8 swap: OAuth clients flow through the same cascade as API keys. Active
  # clients only (revoked/unknown => nil, ungated); an empty stored narrowing
  # keeps `toolset_config: nil` so standing-consent grants stay identity no-ops.
  defp oauth_client_for_ctx(claims) do
    with client_id when is_binary(client_id) <- claims["client_id"],
         %OAuthClient{status: "active"} = client <-
           ToolsetCache.fetch(:oauth_client, client_id, fn ->
             Repo.get_by(OAuthClient, client_id: client_id)
           end) do
      config =
        if is_map(client.toolset_config) and client.toolset_config != %{},
          do: client.toolset_config

      %{id: client.id, kind: :oauth_client, toolset_config: config}
    else
      _ -> nil
    end
  end

  @doc "The custom scope serving this request (ctx assigns), or nil. Cached via `ToolsetCache`."
  def scope_from_ctx(ctx) do
    assigns = get_in(ctx, [Access.key(:assigns, %{})]) || %{}
    slug = assigns[:custom_scope_slug] || assigns["custom_scope_slug"]

    with slug when is_binary(slug) <- slug do
      ToolsetCache.fetch(:scope, slug, fn -> MCPCustomScopes.get_by_slug(slug) end)
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
  # (drift repair stays on the ensure_* paths that own the template). Cached
  # under the template's slug; scope writes bump the generation.
  defp template_config do
    slug = MCPCustomScopes.default_package_slug()

    ToolsetCache.fetch(:scope, slug, fn ->
      case MCPCustomScopes.get_by_slug(slug) do
        %{config: config} when is_map(config) -> normalize_config(config)
        _ -> nil
      end
    end)
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
