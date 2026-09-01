defmodule NoizuPromptLingua.MCP.ToolSetEndpoint do
  @moduledoc """
  Tool set gateway endpoint (per-set surface) — PRD-N3 §4.1.

  TRANSITIONAL (deleted at N5): carries NO tools of its own — the static
  surface is empty and every listing/dispatch resolves the per-request
  `toolset:` MFA (`NoizuPromptLingua.MCP.ToolsetResolver`) through the LIB
  protocol path (`protocol_list`/`protocol_call`). Serves all three set
  shapes (org / project / group) through `NoizuPromptLinguaWeb.MCPSetGatewayController`.

  `providers:` (persistence + ACL wiring) arrive with N2b — at N3 the lib ACL
  layer is inert without a registered provider (lib PRD-2 §4.6 "no provider,
  inert"), so the endpoint serves the static/pass composition; N2b adds
  `acl: NoizuPromptLingua.MCP.AclProvider` here.

  `toolset_cache` honors NPL's 45s policy (PRD-N3 open question 4 — the lib
  opt accepts `[ttl: ms]`).
  """

  # Toolset-layer passthroughs — declared BEFORE `use` so the lib's injected
  # behaviour defaults are skipped (defines? filter) and a direct
  # `Toolset.catalog(ToolSetEndpoint, ctx, [])` agrees with the HTTP wire
  # surface (FR-3-2): both resolve the per-request toolset first.
  def catalog(toolset, ctx, opts \\ []) do
    case Noizu.MCP.Server.Features.Tools.select_toolset(toolset, ctx) do
      %Noizu.MCP.Toolset.Custom{} = selected -> Noizu.MCP.Toolset.catalog(selected, ctx, opts)
      _ -> Noizu.MCP.Toolset.Behaviour.catalog(toolset, ctx, opts)
    end
  end

  def resolve(toolset, name, ctx, opts \\ []) do
    case Noizu.MCP.Server.Features.Tools.select_toolset(toolset, ctx) do
      %Noizu.MCP.Toolset.Custom{} = selected ->
        Noizu.MCP.Toolset.resolve(selected, name, ctx, opts)

      _ ->
        Noizu.MCP.Toolset.Behaviour.resolve(toolset, name, ctx, opts)
    end
  end

  def invoke(toolset, effective, args, ctx, opts \\ []) do
    case Noizu.MCP.Server.Features.Tools.select_toolset(toolset, ctx) do
      %Noizu.MCP.Toolset.Custom{} = selected ->
        Noizu.MCP.Toolset.invoke(selected, effective, args, ctx, opts)

      _ ->
        Noizu.MCP.Toolset.Behaviour.invoke(toolset, effective, args, ctx, opts)
    end
  end

  use NoizuPromptLingua.MCP.Server,
    name: "tobor_toolset",
    version: "0.1.0",
    instructions: "Tool set gateway endpoint (per-set surface).",
    toolset: {NoizuPromptLingua.MCP.ToolsetResolver, :resolve, []},
    principal: {NoizuPromptLingua.MCP.PrincipalMapper, :from_claims, []},
    toolset_cache: [ttl: 45_000]
end
