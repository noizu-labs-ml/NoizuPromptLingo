defmodule NoizuPromptLingua.MCP.PrincipalMapper do
  @moduledoc """
  Claims → `%Noizu.MCP.Auth.Principal{}` mapping (PRD-N3 §4.2, lib PRD-2 §4.5
  contract). Wired per-server via the `principal:` opt; the transport session
  invokes it per message as `from_claims(claims, opts)`.

  Shapes (verifier output — `NoizuPromptLingua.MCP.DualTokenVerifier`):

    * API-key path — compound JWT carrying `"api_key_id"`: subject is the api
      key id, `authenticator: :api_key`, metadata carries `"key"` (NPL API
      keys carry no scope field, so `granted_scopes` stays empty — a deliberate
      delta from the PRD sketch, recorded in the PRD-N3 implementation notes).
    * OAuth path — asymmetric JWT: subject is the `"client_id"` when present,
      else the `"sub"` user id; `granted_scopes` from the `"scope"` claim
      (space-separated); `"sub"` is stashed in metadata as the membership
      identity (PRD-N3 gating resolves group/org membership against it).
    * Anything else — `{:error, :invalid_claims}`; the session logs a warning
      and treats the request as anonymous (lib PRD-2 §4.5 fail-open — the
      verifier is the authentication gate; a mapping error can never 401).

  Route metadata — `set_org_slug`, `set_project_slug`, `set_slug` (plus
  `set_org_id` and the legacy `custom_scope_slug`) — arrives IN the claims,
  injected per-request by `NoizuPromptLingua.MCP.RouteClaimsVerifier` from the
  gateway's `route_metadata:` opt. The mapper copies those keys into
  `Principal.metadata`, which is the ONLY set-coordinate source
  `NoizuPromptLingua.MCP.ToolsetResolver` reads (FR-3-3 / AP-13).
  """

  alias Noizu.MCP.Auth.Principal

  @route_keys ~w(set_org_slug set_project_slug set_slug set_org_id custom_scope_slug)
  @claim_route_keys @route_keys ++ ~w(tool_set_slug)

  @doc "MFA entry point (lib PRD-2 §4.4 `{m, f, args}` shape): `from_claims(claims, args)`."
  def from_claims(claims, _opts \\ [])

  def from_claims(claims, _opts) when is_map(claims) and map_size(claims) > 0 do
    base =
      cond do
        api_key_claims?(claims) -> api_key_principal(claims)
        oauth_claims?(claims) -> oauth_principal(claims)
        true -> nil
      end

    case base do
      nil -> {:error, :invalid_claims}
      %Principal{} = principal -> {:ok, stash_route_metadata(principal, claims)}
    end
  end

  def from_claims(_claims, _opts), do: {:error, :invalid_claims}

  # ── paths ─────────────────────────────────────────────────────────────────

  defp api_key_claims?(%{"api_key_id" => id}) when is_binary(id) and id != "", do: true
  defp api_key_claims?(_), do: false

  defp oauth_claims?(%{"client_id" => id}) when is_binary(id) and id != "", do: true

  defp oauth_claims?(%{"sub" => sub}) when is_binary(sub) and sub != "", do: true

  defp oauth_claims?(_), do: false

  # API keys have no scope column (Schema.MCPApiKey) — granted_scopes stays
  # empty; the effective toolset cascade, not scopes, narrows key surfaces.
  defp api_key_principal(claims) do
    key_id = claims["api_key_id"]

    %Principal{
      subject: key_id,
      authenticator: :api_key,
      token_id: key_id,
      claims: claims,
      granted_scopes: MapSet.new(),
      metadata: %{
        "key" => key_id,
        "user_id" => claims["sub"]
      }
    }
  end

  defp oauth_principal(claims) do
    client_id = claims["client_id"]
    subject = if is_binary(client_id) and client_id != "", do: client_id, else: claims["sub"]

    %Principal{
      subject: subject,
      authenticator: :oauth,
      token_id: claims["jti"],
      claims: claims,
      granted_scopes: granted_scopes(claims),
      metadata: %{
        "user_id" => claims["sub"],
        "client_id" => client_id
      }
    }
  end

  defp granted_scopes(%{"scope" => scope}) when is_binary(scope) do
    scope |> String.split(~r/\s+/, trim: true) |> MapSet.new()
  end

  defp granted_scopes(%{"scp" => scopes}) when is_list(scopes), do: MapSet.new(scopes)
  defp granted_scopes(_), do: MapSet.new()

  # Route coordinates (set/profile slugs + org) ride the claims via the
  # RouteClaimsVerifier enrichment; they are copied into Principal.metadata so
  # downstream resolvers never read session assigns (FR-3-3).
  defp stash_route_metadata(%Principal{metadata: metadata} = principal, claims) do
    route_metadata =
      @claim_route_keys
      |> Map.new(fn key ->
        {String.to_atom(key), claims[key]}
      end)
      |> Map.reject(fn {_key, value} -> is_nil(value) end)

    %Principal{principal | metadata: Map.merge(metadata, route_metadata)}
  end
end
