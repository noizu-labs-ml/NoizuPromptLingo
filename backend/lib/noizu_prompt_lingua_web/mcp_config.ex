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
        if issuer_url, do: "#{String.trim_trailing(issuer_url, "/")}/.well-known/oauth-protected-resource"

    verifier_opts =
      [
        secret: {NoizuPromptLingua.MCPAuth, :secret},
        issuer: issuers,
        validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1,
        require_aud: Keyword.get(oauth, :require_aud, false),
        public_scheme: Keyword.get(oauth, :public_scheme, "https")
      ] ++ extra_verifier_opts

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
