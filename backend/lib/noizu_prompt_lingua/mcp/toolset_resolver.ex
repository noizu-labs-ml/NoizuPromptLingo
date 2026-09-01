defmodule NoizuPromptLingua.MCP.ToolsetResolver do
  @moduledoc """
  Per-request toolset selection for the tool-set gateway (PRD-N3 §4.3, lib
  PRD-3 §4.7 MFA contract). Wired as `toolset: {ToolsetResolver, :resolve, []}`
  on `NoizuPromptLingua.MCP.ToolSetEndpoint`; the lib session invokes
  `resolve(ctx, opts)` per request.

  Resolution order (D1 — one resolver, no module scans; D4 — explicit context
  lookups only):

    1. The principal from `ctx.auth` (guaranteed — the resolver runs after
       principal mapping; `nil` falls through to `:none`).
    2. `metadata.set_slug` present (route-addressed set) —
       `MCP.ToolSets.get_for_request(org_id, set_slug)` (active-only +
       unexpired) → `MCP.ToolSets.assemble_custom/2`, the real
       `%Noizu.MCP.Toolset.Custom{}`.
    3. Else `metadata.profile_slug` — profile-style sets: the N2a profile DATA
       (`Toolsets.Profiles.get/1`) wrapped as an immutable slicing-only
       `%Toolset.Custom{}` (N2b owns the permanent `Profiles.custom/1`).
    4. Else the authenticator binding seam (`tool_set_slug` claim stashed in
       metadata — forward-looking; no key/client binding surface exists yet).
    5. No binding ⇒ `:none` — the endpoint's static surface (empty by design:
       the gateway endpoint carries no tools of its own).

  D5 (fail-closed per set, fail-open per server): a nil/inactive set or an
  unknown profile NEVER raises — it logs a warning and returns `:none`. The
  gateway's 404 audience gate has already filtered unknown slugs, so a
  resolver miss is a race/staleness case, not an authorization signal.
  """

  require Logger

  alias Noizu.MCP.Toolset.Custom
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCP.Toolsets.Profiles

  @doc "lib `toolset:` MFA entry point: `resolve(ctx, args)`."
  def resolve(ctx, _opts \\ [])

  def resolve(ctx, _opts) do
    metadata = principal_metadata(ctx)

    cond do
      slug = metadata[:set_slug] ->
        resolve_set(metadata, slug, ctx)

      slug = metadata[:profile_slug] ->
        resolve_profile(slug)

      slug = metadata[:tool_set_slug] ->
        # Authenticator-binding seam (§4.3 step 4): claims-carried set binding.
        resolve_set(metadata, slug, ctx)

      true ->
        :none
    end
  end

  defp principal_metadata(%{auth: %Noizu.MCP.Auth.Principal{metadata: metadata}})
       when is_map(metadata),
       do: metadata

  defp principal_metadata(_), do: %{}

  defp resolve_set(metadata, slug, ctx) do
    case metadata[:set_org_id] && ToolSets.get_for_request(metadata[:set_org_id], slug) do
      nil ->
        Logger.warning(
          "[ToolsetResolver] set #{inspect(slug)} not resolvable for org " <>
            "#{inspect(metadata[:set_org_id])} (race/staleness after the gateway 404 gate) — :none"
        )

        :none

      %NoizuPromptLingua.Schema.MCPToolSet{} = tool_set ->
        ToolSets.assemble_custom(tool_set, ctx)
    end
  end

  defp resolve_profile(slug) do
    case Profiles.get(slug) do
      nil ->
        Logger.warning("[ToolsetResolver] unknown profile #{inspect(slug)} — :none (D5)")
        :none

      profile ->
        groups = profile.groups || []

        %Custom{
          slug: "profile:#{slug}",
          base: NoizuPromptLingua.MCP.UniverseToolset,
          title: title(profile),
          description: nil,
          immutable: true,
          include: ToolSets.universe_include(groups),
          tools: %{},
          metadata: %{profile: slug}
        }
    end
  end

  defp title(profile) do
    Map.get(profile, :title) || Map.get(profile, :slug) || "profile"
  end
end
