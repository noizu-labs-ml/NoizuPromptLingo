defmodule NoizuPromptLingua.MCP.OAuthToolsets do
  @moduledoc """
  W8: per-OAuth-client MCP toolset filtering for the gateway.

  Reads the `toolset_config` narrowing captured at consent time
  (`oauth_clients.toolset_config`, shape-identical to `mcp_api_keys.toolset_config`;
  see `NoizuPromptLingua.MCP.OAuth.ConsentManifest`) and applies the SAME
  `disabled`/`hidden` semantics as `NoizuPromptLingua.MCP.KeyToolsets`
  (delegated — the two share flag resolution verbatim):

    * `disabled: true` — blocks EXECUTION (enforced by ToolGuard/EffectiveToolset
      post-F2-merge; see INTEGRATION-NOTES.md) and drops the tool from listings.
    * `hidden: true` — blocks LISTING/DISCOVERY only.

  The client is resolved server-side from `ctx.assigns.auth_claims["client_id"]`
  (minted into the MCP JWT at `TokenService.mint_tokens/1`). Tokens with no
  client_id, unknown/revoked clients, and clients with `%{}`/nil config are
  UNGATED — existing standing-consent grants behave exactly as before.

  ## F2 swap point

  This module is deliberately thin so it can be replaced by
  `NoizuPromptLingua.MCP.EffectiveToolset` after the F2 branch merges:

      EffectiveToolset.resolve(scope, %{
        id: client.id, kind: :oauth_client, toolset_config: client.toolset_config
      }, user_ref)

  Until then `apply_hidden/3` implements the local filter with the identical
  flag semantics (absent = enabled + visible).
  """

  require Logger

  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.OAuthClient

  @doc """
  The calling OAuth client's toolset config (normalized), or `nil` when the
  request carries no client_id (API-key / system principal), the client is
  unknown or revoked, or the client has no stored narrowing.
  """
  def config_for(ctx) do
    with client_id when is_binary(client_id) <- oauth_client_id(ctx),
         %OAuthClient{status: "active"} = client <- Repo.get_by(OAuthClient, client_id: client_id),
         config when is_map(config) <- client.toolset_config,
         true <- config != %{} do
      KeyToolsets.normalize(config)
    else
      _ -> nil
    end
  rescue
    e ->
      Logger.warning("[OAuthToolsets] config resolution failed: #{Exception.message(e)}")
      nil
  end

  @doc "OAuth client_id from the MCP JWT claims in ctx.assigns."
  def oauth_client_id(ctx) do
    claims = get_in(ctx, [Access.key(:assigns, %{}), Access.key(:auth_claims, %{})]) || %{}
    claims["client_id"]
  end

  # Flag resolution is shared verbatim with API keys (same config shape).
  defdelegate state_from_config(config, group_id, tool_name), to: KeyToolsets

  @doc """
  Apply per-client `hidden`/`disabled` listing rules to expanded tool specs,
  mirroring `KeyToolsets.apply_hidden/3`. `group_id` is the owning MCP group
  when the caller knows it; pass `nil` to resolve per spec via
  `MCPServers.group_id_for_tool_module/1`. No-op (specs unchanged) when the
  calling client carries no narrowing.
  """
  def apply_hidden(specs, ctx, group_id) when is_list(specs) do
    config = config_for(ctx)

    if config == nil do
      specs
    else
      Enum.reject(specs, fn spec ->
        KeyToolsets.ungated_category?(KeyToolsets.tool_category(spec)) or ungated?(spec, config, group_id)
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
end
