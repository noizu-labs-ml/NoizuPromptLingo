defmodule NoizuPromptLinguaWeb.MCPConfig do
  @moduledoc """
  Shared options for mounting MCP servers via
  `Noizu.MCP.Transport.StreamableHTTP.Plug`.

  Requests must present a Bearer MCP JWT (minted at `POST /api/mcp/token` from
  an active MCP API key, or later via OAuth). `DualTokenVerifier` accepts:

  - Phase 0+ RS256 (JWKS) tokens with optional `aud`
  - Legacy HS256 compound JWTs (`api_key_id` + shared secret)

  Both paths require an active `api_key_id` when that claim is present.
  """

  @doc "Auth opts: dual-path MCP JWT verification."
  def auth_opts(extra_verifier_opts \\ []) do
    oauth = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])

    issuers =
      try do
        NoizuPromptLingua.OAuth.AuthorizationServer.jwt_issuers()
      rescue
        _ -> [NoizuPromptLingua.Token.issuer()]
      end

    issuer_url =
      try do
        NoizuPromptLingua.OAuth.AuthorizationServer.issuer_url()
      rescue
        _ -> nil
      end

    resource_metadata =
      Keyword.get(oauth, :resource_metadata_url) ||
        if issuer_url,
          do: "#{String.trim_trailing(issuer_url, "/")}/.well-known/oauth-protected-resource"

    verifier_opts =
      Keyword.merge(
        [
          secret: {NoizuPromptLingua.MCPAuth, :secret},
          issuer: issuers,
          validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1,
          require_aud: Keyword.get(oauth, :require_aud, false),
          public_scheme: Keyword.get(oauth, :public_scheme, "https")
        ],
        extra_verifier_opts
      )

    auth = [verifier: {NoizuPromptLingua.MCP.DualTokenVerifier, verifier_opts}]

    if is_binary(resource_metadata) and resource_metadata != "" do
      Keyword.put(auth, :resource_metadata, resource_metadata)
    else
      auth
    end
  end

  def plug_opts(server, extra_verifier_opts \\ [], auth_overrides \\ []) do
    auth = auth_opts(extra_verifier_opts) |> Keyword.merge(auth_overrides)
    [server: server, origins: :any, auth: auth]
  end

  @doc """
  Plug opts for the VFS WebSocket transport (`Noizu.MCP.Transport.VFSWS`)
  mounted at `/vfs` (Wave 0 substrate).

  Same `DualTokenVerifier` bearer pipeline as the MCP surface: the upgrade is
  rejected 401 without a valid token, and the in-band `vfs/auth` handshake
  (first frame) binds the verified claims to the connection `Ctx`. The
  transport consumes only `server:`, `auth:`, and `context:` — StreamableHTTP
  opts like `:origins` / `:resource_metadata` do not apply.
  """
  def vfs_plug_opts do
    # Keyword.put prepends, so probe :verifier by key, never by position.
    auth =
      case Keyword.get(auth_opts(), :verifier) do
        nil -> []
        verifier -> [verifier: verifier]
      end

    [
      server: NoizuPromptLingua.MCP.VFSServer,
      # Phoenix's `forward "/vfs", VFSWS` strips the matched prefix, so the
      # plug sees path_info == [] — mount it at "/" (direct-Bandit mounts pass
      # their own :path).
      path: "/",
      auth: auth,
      context: {NoizuPromptLingua.MCP.VFS.Principal, :context_assigns}
    ]
  end

  @doc """
  Plug opts for a tool-set gateway route (PRD-N3 FR-3-3): the verifier is
  wrapped in `NoizuPromptLingua.MCP.RouteClaimsVerifier` so the route's set
  coordinates (`route_metadata`, string-keyed) ride the verified claims into
  `Principal.metadata` — the only set-coordinate source the toolset resolver
  reads. A fresh wrapper tuple is built PER REQUEST (the metadata binds to
  that request's route params).
  """
  def plug_opts_for_tool_set(server, resource, path, route_metadata)
      when is_binary(resource) and is_binary(path) and is_map(route_metadata) do
    auth =
      auth_opts(expected_audience: resource)
      |> Keyword.update!(:verifier, fn
        {_verifier, vopts} ->
          # The original verifier's opts carry forward; the wrapper is
          # RouteClaimsVerifier by design (route metadata enrichment).
          {NoizuPromptLingua.MCP.RouteClaimsVerifier, vopts ++ [route_metadata: route_metadata]}

        other ->
          other
      end)
      |> Keyword.put(
        :resource_metadata,
        resource_metadata_url_for_path(host_from(resource), path)
      )

    [server: server, origins: :any, auth: auth]
  end

  defp host_from(resource) do
    case URI.parse(resource) do
      %URI{host: host} when is_binary(host) and host != "" -> host
      _ -> ""
    end
  end

  @doc """
  RFC 9728 metadata URL for an MCP endpoint mounted at `path`.

  The 401 challenge must point at the document describing *this* resource. The
  root document declares `<host>/mcp`; an endpoint that audience-binds to a
  different URL must advertise its own, or clients request a token for the
  wrong resource and are rejected as `:bad_aud`.
  """
  def resource_metadata_url_for_path(host, path) when is_binary(host) and is_binary(path) do
    scheme =
      Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
      |> Keyword.get(:public_scheme, "https")

    "#{scheme}://#{host}/.well-known/oauth-protected-resource#{path}"
  end

  @doc """
  Plug opts for a known MCP subdomain label (e.g. `"sessions"`).

  Pins `expected_audience` to `https://{label}.{base_host}/mcp` when the public
  base host is configured, so audience-bound OAuth tokens are enforced even
  before `require_aud` is globally enabled (tokens *with* aud must match).
  """
  def plug_opts_for_subdomain(server, subdomain_label)
      when is_binary(subdomain_label) do
    resource = resource_url_for_subdomain(subdomain_label)
    extra = if resource, do: [expected_audience: resource], else: []
    plug_opts(server, extra)
  end

  def resource_url_for_subdomain(label) when is_binary(label) do
    case public_base_host() do
      host when is_binary(host) and host != "" ->
        scheme =
          Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
          |> Keyword.get(:public_scheme, "https")

        "#{scheme}://#{label}.#{host}/mcp"

      _ ->
        nil
    end
  end

  def resource_url_for_subdomain(_), do: nil

  defp public_base_host do
    oauth = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])

    cond do
      host = Keyword.get(oauth, :public_base_host) ->
        host

      url = Keyword.get(oauth, :issuer_url) || System.get_env("MCP_ISSUER_URL") ->
        case URI.parse(url) do
          %URI{host: h} when is_binary(h) -> h
          _ -> nil
        end

      url = Application.get_env(:noizu_prompt_lingua, :frontend_url) ->
        case URI.parse(url) do
          %URI{host: h} when is_binary(h) -> h
          _ -> nil
        end

      true ->
        "tobor.locker"
    end
  end
end
