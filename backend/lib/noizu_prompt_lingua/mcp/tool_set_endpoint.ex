defmodule NoizuPromptLingua.MCP.ToolSetEndpoint do
  @moduledoc """
  Tool set gateway endpoint (per-set surface) — PRD-N3 §4.1.

  TRANSITIONAL (deleted at N5): carries NO tools of its own — the static
  surface is empty and every listing/dispatch resolves the per-request
  `toolset:` MFA (`NoizuPromptLingua.MCP.ToolsetResolver`) through the LIB
  protocol path (`protocol_list`/`protocol_call`). Serves all three set
  shapes (org / project / group) through `NoizuPromptLinguaWeb.MCPSetGatewayController`.

  `providers:` (N2b): the persistence + ACL seam is wired —
  `NoizuPromptLingua.MCP.ToolsetProvider` (NPL-owned storage; the lib tables
  stay empty, Decision 2) and `NoizuPromptLingua.MCP.AclProvider` (always-answers
  ACL over `NoizuPromptLingua.Acl.resolve/4`). At N3 the ACL layer was inert
  without a registered provider (lib PRD-2 §4.6 "no provider, inert").

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
    providers: [
      persistence: NoizuPromptLingua.MCP.ToolsetProvider,
      acl: NoizuPromptLingua.MCP.AclProvider
    ],
    toolset_cache: [ttl: 45_000]
end
