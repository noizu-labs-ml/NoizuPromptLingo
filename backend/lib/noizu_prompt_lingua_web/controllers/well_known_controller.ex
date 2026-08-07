defmodule NoizuPromptLinguaWeb.WellKnownController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Public discovery documents for MCP OAuth.

  - `GET /.well-known/jwks.json` — MCP JWT verification keys
  - `GET /.well-known/oauth-authorization-server` — RFC 8414 AS metadata
  - `GET /.well-known/oauth-protected-resource` — RFC 9728 (root host)
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

  def oauth_protected_resource(conn, _params) do
    base = AuthorizationServer.issuer_url() |> String.trim_trailing("/")
    host = conn.host

    resource =
      if host in [nil, ""] do
        "#{base}/mcp"
      else
        scheme = if conn.scheme == :https, do: "https", else: public_scheme()
        "#{scheme}://#{host}/mcp"
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

