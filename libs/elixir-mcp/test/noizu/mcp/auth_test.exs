defmodule Noizu.MCP.AuthTest do
  @moduledoc """
  Authorization tests: WWW-Authenticate codec, resource-server enforcement in
  the transport plug, RFC 9728 metadata plug, and the full OAuth 2.1
  discovery + PKCE flow against a stub IdP over Bandit.
  """
  use ExUnit.Case, async: true

  import Plug.Test, only: [conn: 3]
  import Plug.Conn

  alias Noizu.MCP.Auth.WWWAuthenticate
  alias Noizu.MCP.Fixtures
  alias Noizu.MCP.Transport.StreamableHTTP

  doctest Noizu.MCP.Auth.WWWAuthenticate

  setup_all do
    Noizu.MCP.Test.ensure_server_started(Fixtures.Server)
  end

  describe "WWWAuthenticate" do
    test "format round-trips through parse" do
      header =
        WWWAuthenticate.format([
          {"resource_metadata", "https://x/.well-known/oauth-protected-resource"},
          {"error", "invalid_token"}
        ])

      parsed = WWWAuthenticate.parse(header)
      assert parsed.scheme == "Bearer"
      assert parsed.params["error"] == "invalid_token"
    end

    test "parses bare scheme" do
      assert %WWWAuthenticate{scheme: "Bearer", params: %{}} = WWWAuthenticate.parse("Bearer")
    end
  end

  describe "resource-server enforcement (plug)" do
    @auth_opts StreamableHTTP.Plug.init(
                 server: Fixtures.Server,
                 auth: [
                   verifier: {Fixtures.TokenVerifier, []},
                   resource_metadata: "http://x/.well-known/oauth-protected-resource"
                 ]
               )

    defp auth_post(body, headers) do
      conn =
        conn(:post, "/", Jason.encode!(body))
        |> put_req_header("content-type", "application/json")

      headers
      |> Enum.reduce(conn, fn {key, value}, conn -> put_req_header(conn, key, value) end)
      |> StreamableHTTP.Plug.call(@auth_opts)
    end

    @initialize %{
      "jsonrpc" => "2.0",
      "id" => 1,
      "method" => "initialize",
      "params" => %{
        "protocolVersion" => "2025-11-25",
        "capabilities" => %{},
        "clientInfo" => %{"name" => "auth_test", "version" => "1.0.0"}
      }
    }

    test "missing token is 401 with a resource_metadata challenge" do
      conn = auth_post(@initialize, [])
      assert conn.status == 401

      [challenge] = get_resp_header(conn, "www-authenticate")
      parsed = WWWAuthenticate.parse(challenge)
      assert parsed.params["resource_metadata"] =~ "oauth-protected-resource"
      assert parsed.params["error"] == "invalid_request"
    end

    test "invalid token is 401 invalid_token" do
      conn = auth_post(@initialize, [{"authorization", "Bearer nope"}])
      assert conn.status == 401

      [challenge] = get_resp_header(conn, "www-authenticate")
      assert WWWAuthenticate.parse(challenge).params["error"] == "invalid_token"
    end

    test "insufficient scope is 403 with scope hint" do
      conn = auth_post(@initialize, [{"authorization", "Bearer lowscope-token"}])
      assert conn.status == 403

      [challenge] = get_resp_header(conn, "www-authenticate")
      parsed = WWWAuthenticate.parse(challenge)
      assert parsed.params["error"] == "insufficient_scope"
      assert parsed.params["scope"] == "mcp:admin"
    end

    test "valid token initializes and claims reach handler ctx" do
      conn = auth_post(@initialize, [{"authorization", "Bearer valid-token"}])
      assert conn.status == 200
      [session_id] = get_resp_header(conn, "mcp-session-id")

      assert auth_post(%{"jsonrpc" => "2.0", "method" => "notifications/initialized"}, [
               {"authorization", "Bearer valid-token"},
               {"mcp-session-id", session_id}
             ]).status == 202

      conn =
        auth_post(
          %{
            "jsonrpc" => "2.0",
            "id" => 2,
            "method" => "tools/call",
            "params" => %{"name" => "whoami", "arguments" => %{}}
          },
          [{"authorization", "Bearer valid-token"}, {"mcp-session-id", session_id}]
        )

      assert conn.status == 200

      assert %{"result" => %{"content" => [%{"text" => "sub=user-1"}]}} =
               Jason.decode!(conn.resp_body)
    end
  end

  describe "ProtectedResourceMetadataPlug" do
    test "serves the RFC 9728 document" do
      opts =
        Noizu.MCP.Auth.ProtectedResourceMetadataPlug.init(
          resource: "https://api.example.com/mcp",
          authorization_servers: ["https://auth.example.com"],
          scopes_supported: ["mcp"]
        )

      conn =
        conn(:get, "/", "")
        |> Noizu.MCP.Auth.ProtectedResourceMetadataPlug.call(opts)

      assert conn.status == 200

      assert %{
               "resource" => "https://api.example.com/mcp",
               "authorization_servers" => ["https://auth.example.com"],
               "scopes_supported" => ["mcp"]
             } = Jason.decode!(conn.resp_body)
    end
  end

  describe "static client strategy" do
    setup :start_auth_listener

    test "bearer token flows end to end", %{base: base} do
      client =
        start_supervised!(
          {Noizu.MCP.Client,
           transport:
             {:streamable_http,
              url: base <> "/mcp", auth: {Noizu.MCP.Auth.Static, token: "valid-token"}},
           client_info: %{name: "static", version: "1"}},
          id: make_ref()
        )

      assert :ok = Noizu.MCP.Client.await_ready(client, 15_000)

      assert {:ok, %{content: [%{text: "sub=user-1"}]}} =
               Noizu.MCP.Client.call_tool(client, "whoami", %{})
    end
  end

  describe "full OAuth 2.1 flow against the stub IdP" do
    setup :start_auth_listener

    test "401 → discovery → PKCE authorize → token → retry succeeds", %{base: base} do
      me = self()

      authorize_user = fn url ->
        send(me, {:authorize_url, url})
        query = URI.decode_query(URI.parse(url).query)

        {:ok, %{"code" => Fixtures.AuthRouter.expected_code(), "state" => query["state"]}}
      end

      client =
        start_supervised!(
          {Noizu.MCP.Client,
           transport:
             {:streamable_http,
              url: base <> "/mcp",
              auth:
                {Noizu.MCP.Auth.OAuth,
                 client_id: "test-client",
                 redirect_uri: "http://localhost:9/callback",
                 scope: "mcp",
                 authorize_user: authorize_user}},
           client_info: %{name: "oauth", version: "1"}},
          id: make_ref()
        )

      assert :ok = Noizu.MCP.Client.await_ready(client, 20_000)

      assert {:ok, %{content: [%{text: "sub=user-1"}]}} =
               Noizu.MCP.Client.call_tool(client, "whoami", %{})

      # The browser flow used PKCE + resource indicators.
      assert_received {:authorize_url, url}
      query = URI.decode_query(URI.parse(url).query)
      assert query["code_challenge_method"] == "S256"
      assert byte_size(query["code_challenge"]) > 20
      assert query["client_id"] == "test-client"
      assert query["resource"] == base <> "/mcp"
      assert query["scope"] == "mcp"
    end
  end

  defp start_auth_listener(_ctx) do
    pid =
      start_supervised!(
        {Bandit,
         plug: Fixtures.AuthRouter,
         port: 0,
         ip: :loopback,
         startup_log: false,
         thousand_island_options: [shutdown_timeout: 10]},
        id: make_ref()
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(pid)
    %{base: "http://127.0.0.1:#{port}"}
  end
end
