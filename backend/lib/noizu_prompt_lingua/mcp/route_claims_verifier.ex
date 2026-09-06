defmodule NoizuPromptLingua.MCP.RouteClaimsVerifier do
  @moduledoc """
  Bearer verifier wrapper that merges the gateway's route metadata into the
  verified claims (PRD-N3 §4.4 "route metadata → Principal.metadata").

  Delegates authentication entirely to `NoizuPromptLingua.MCP.DualTokenVerifier`
  — on success the `opts[:route_metadata]` map (string-keyed: `set_org_slug`,
  `set_project_slug`, `set_slug`, `set_org_id`) is merged OVER the claims. The
  transport session then hands those claims to the server's `principal:` MFA
  (`NoizuPromptLingua.MCP.PrincipalMapper`), which copies the coordinates into
  `Principal.metadata` — the only set-coordinate source the toolset resolver
  reads (FR-3-3).

  The gateway builds a FRESH verifier tuple per request (the metadata is bound
  to that request's route params), passing this module as the `verifier:`
  while keeping every `DualTokenVerifier` opt intact.
  """

  @behaviour Noizu.MCP.Auth.TokenVerifier

  alias NoizuPromptLingua.MCP.DualTokenVerifier

  @impl true
  def verify(token, conn_info, opts) do
    case DualTokenVerifier.verify(token, conn_info, opts) do
      {:ok, claims} -> {:ok, Map.merge(claims, route_metadata(opts))}
      other -> other
    end
  end

  defp route_metadata(opts) do
    opts
    |> Keyword.get(:route_metadata, %{})
    |> case do
      map when is_map(map) -> map
      _ -> %{}
    end
  end
end
