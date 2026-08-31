defmodule NoizuPromptLingua.MCP.KeyToolsets do
  @moduledoc """
  Per-API-key MCP toolset resolution — THIN CALLER over
  `NoizuPromptLingua.MCP.EffectiveToolset` (contract §2).

  The cascade itself (custom-scope config → client
  `toolset_config`) lives in EffectiveToolset; the global `tobor` template is
  not a layer (clones freeze it at creation — I10); this module keeps the
  key-shaped API the gateway grew up on:

    * `state/3` (group, tool, ctx) → `%{disabled:, hidden:}` — consumed by
      `ToolGuard` (execution) and `Tools.Catalog` (hidden-tool calls).
    * `apply_hidden/3` — listing filter consumed by `MCP.Server.list_tools`
      and `Tools.Catalog.build/2`.
    * `overlay/2`, `state_from_config/3` — config-shape helpers reused by the
      component registry gating.

  Semantics (unchanged):

    * `disabled: true` — blocks EXECUTION. Enforced in
      `NoizuPromptLingua.MCP.ToolGuard` (before RBAC, independent of
      `:mcp_authz_mode`) and in `NoizuPromptLingua.Tools.Catalog.call_hidden_tool/4`.
    * `hidden: true` — blocks LISTING/DISCOVERY only. A hidden tool can still
      be called directly unless also disabled.
    * Keys never ADD tools: on the main servers all tools are included by
      default, on `/custom/:slug/mcp` the scope's include set still governs —
      key config only flips flags.

  The key is resolved server-side from `ctx.assigns.auth_claims["api_key_id"]`
  (minted into the MCP JWT at token time). OAuth-only tokens without an
  api_key_id inherit everything (no overrides) until W8 stores OAuth-client
  toolset jsonb.
  """

  alias NoizuPromptLingua.MCP.EffectiveToolset

  @doc """
  The calling key's toolset config (normalized), or `nil` when the request
  carries no API key (OAuth-only / system principal) or the key has no
  overrides.
  """
  def config_for(ctx), do: EffectiveToolset.config_for_ctx(ctx)

  @doc "api_key_id from the MCP JWT claims in ctx.assigns."
  def api_key_id(ctx) do
    claims = get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}
    claims["api_key_id"]
  end

  @doc """
  Resolve the effective (disabled, hidden) flags for a (group, tool) pair from
  the calling ctx — full EffectiveToolset cascade (client + scope + template)
  plus the per-user ACL override (debt D2: `mcp.tool` deny rules hide + disable
  the tool for that user; no rules => unchanged).

    * `disabled` — blocks EXECUTION (ToolGuard, pre-RBAC, both authz modes).
    * `hidden` — blocks LISTING/DISCOVERY only; the tool remains callable
      directly unless also disabled.
  """
  def state(group_id, tool_name, ctx) when is_binary(group_id) and is_binary(tool_name) do
    ts =
      EffectiveToolset.state(
        group_id,
        tool_name,
        EffectiveToolset.scope_from_ctx(ctx),
        EffectiveToolset.client_for_ctx(ctx),
        EffectiveToolset.user_for_ctx(ctx),
        DateTime.utc_now()
      )

    %{disabled: not ts.enabled, hidden: not ts.visible}
  end

  # Unresolvable group (root-only tools: Discovery, NPL) is ungated.
  def state(_group_id, tool_name, _ctx) when is_binary(tool_name),
    do: %{disabled: false, hidden: false}

  @doc "Resolve legacy (disabled, hidden) flags for (group, tool) against a concrete config (no ctx, no template)."
  defdelegate state_from_config(config, group_id, tool_name), to: EffectiveToolset

  @doc """
  Overlay a client toolset config ON TOP OF a base config (see
  `EffectiveToolset.overlay/2` — same function, kept here for call-site
  compatibility).
  """
  defdelegate overlay(scope_config, key_config), to: EffectiveToolset

  @doc """
  Apply per-client `hidden`/`disabled` listing rules to expanded tool specs.
  Delegates to `EffectiveToolset.apply_to_specs/3` (Discovery/NPL ungated;
  disabled tools are dropped from the listing as well as denied at call time).
  """
  def apply_hidden(specs, ctx, group_id) when is_list(specs),
    do: EffectiveToolset.apply_to_specs(specs, ctx, group_id)

  def apply_hidden(specs, _ctx, _group_id), do: specs

  @doc "Normalize a key toolset config (delegates to the key context's normalizer)."
  def normalize(config), do: NoizuPromptLingua.MCPApiKeys.normalize_toolset(config)

  @doc "The empty (inherit-everything) config."
  def empty, do: %{"groups" => %{}}
end
