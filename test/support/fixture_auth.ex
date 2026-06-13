defmodule Noizu.MCP.Fixtures.TokenVerifier do
  @moduledoc false
  @behaviour Noizu.MCP.Auth.TokenVerifier

  @impl true
  def verify("valid-token", _conn_info, _opts), do: {:ok, %{"sub" => "user-1", "scope" => "mcp"}}
  def verify("refreshed-token", _conn_info, _opts), do: {:ok, %{"sub" => "user-1r"}}

  def verify("lowscope-token", _conn_info, _opts),
    do: {:error, :insufficient_scope, %{"scope" => "mcp:admin"}}

  def verify(_other, _conn_info, _opts), do: {:error, :invalid_token}
end

defmodule Noizu.MCP.Fixtures.AuthRouter do
  @moduledoc false
  # One Bandit listener that plays all three roles for OAuth tests:
  # the protected MCP endpoint, the RFC 9728 resource metadata document, and
  # a stub OAuth authorization server (RFC 8414 metadata + token endpoint).
  #
  # The base URL isn't known until the listener binds, so it is resolved per
  # request from the Host header.

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @expected_code "stub-auth-code"

  forward("/mcp",
    to: Noizu.MCP.Transport.StreamableHTTP.Plug,
    init_opts: [
      server: Noizu.MCP.Fixtures.Server,
      # No :resource_metadata here — the listener port isn't known at compile
      # time; clients fall back to RFC 9728 default discovery on the MCP origin.
      auth: [verifier: {Noizu.MCP.Fixtures.TokenVerifier, []}]
    ]
  )

  get "/.well-known/oauth-protected-resource" do
    base = base_url(conn)

    json(conn, 200, %{
      "resource" => base <> "/mcp",
      "authorization_servers" => [base],
      "scopes_supported" => ["mcp"]
    })
  end

  get "/.well-known/oauth-authorization-server" do
    base = base_url(conn)

    json(conn, 200, %{
      "issuer" => base,
      "authorization_endpoint" => base <> "/authorize",
      "token_endpoint" => base <> "/token",
      "code_challenge_methods_supported" => ["S256"]
    })
  end

  post "/token" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    params = URI.decode_query(body)

    cond do
      params["grant_type"] == "authorization_code" and params["code"] == @expected_code and
        is_binary(params["code_verifier"]) and is_binary(params["resource"]) ->
        json(conn, 200, %{
          "access_token" => "valid-token",
          "token_type" => "Bearer",
          "refresh_token" => "stub-refresh",
          "expires_in" => 3600
        })

      params["grant_type"] == "refresh_token" and params["refresh_token"] == "stub-refresh" ->
        json(conn, 200, %{
          "access_token" => "refreshed-token",
          "token_type" => "Bearer",
          "expires_in" => 3600
        })

      true ->
        json(conn, 400, %{"error" => "invalid_grant", "got" => params})
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def expected_code, do: @expected_code

  defp base_url(conn) do
    host = conn |> Plug.Conn.get_req_header("host") |> List.first()
    "http://#{host}"
  end

  defp json(conn, status, body) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(body))
  end
end
