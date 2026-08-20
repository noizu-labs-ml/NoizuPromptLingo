defmodule NoizuPromptLinguaWeb.WellKnownController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Public discovery documents for MCP OAuth.

  - `GET /.well-known/jwks.json` — MCP JWT verification keys
  - `GET /.well-known/oauth-authorization-server` — RFC 8414 AS metadata
  - `GET /.well-known/oauth-protected-resource` — RFC 9728 (root host)
  - `GET /.well-known/oauth-protected-resource/*path` — RFC 9728 path-scoped

  The path-scoped form matters for MCP endpoints that are not at `/mcp`:
  the custom-scope gateway lives at `/custom/<slug>/mcp` and audience-binds
  tokens to *that* URL, so advertising the root `/mcp` resource to clients
  would hand them a token the gateway then rejects as `:bad_aud`.
  """

  alias NoizuPromptLingua.OAuth.{AuthorizationServer, Jwks}

  def jwks(conn, _params) do
    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(Jwks.document())
  end

  def oauth_authorization_server(conn, _params) do
    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(AuthorizationServer.metadata())
  end

  def oauth_protected_resource(conn, params) do
    base = AuthorizationServer.issuer_url() |> String.trim_trailing("/")
    host = conn.host

    # RFC 9728 path-scoped metadata: the resource path is appended to the
    # well-known prefix, so `/custom/<slug>/mcp` is discovered at
    # `/.well-known/oauth-protected-resource/custom/<slug>/mcp`.
    path =
      case params["resource_path"] do
        segments when is_list(segments) and segments != [] -> "/" <> Enum.join(segments, "/")
        _ -> "/mcp"
      end

    resource =
      if host in [nil, ""] do
        "#{base}#{path}"
      else
        scheme = if conn.scheme == :https, do: "https", else: public_scheme()
        "#{scheme}://#{host}#{path}"
      end

    doc = %{
      "resource" => resource,
      "authorization_servers" => [base],
      "scopes_supported" => ["mcp", "openid"],
      "bearer_methods_supported" => ["header"]
    }

    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(doc)
  end

  defp public_scheme do
    Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    |> Keyword.get(:public_scheme, "https")
  end
end

