defmodule NoizuPromptLinguaWeb.CustomMCPGatewayParamTest do
  @moduledoc """
  Alacarte `?t=` URL tool-selection parameter over the custom-scope gateway
  (legacy `/custom/:slug/mcp` surface):

    * decode happens BEFORE the transport plug — garbage fails closed with a
      400 (even unauthenticated) instead of opening a session;
    * a white-list shapes `tools/list` (and re-enables a stored-disabled tool);
    * the re-enabled tool is also DISPATCHABLE (ToolGuard seam);
    * an excluded tool's call is rejected;
    * no-param behavior is byte-identical (stored config governs);
    * the param is a session SNAPSHOT — follow-ups without the query keep the
      initialize-time layer.

  async: false (shared sandbox): the transport's session process reads the DB.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Token

  # sessions group with Session_Get stored-disabled — the param's re-enable
  # target (Session_Get is NOT statically hidden; Session_List/Session_Archive
  # are, and registration-level visibility is out of the param's reach).
  defp create_scope(slug) do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => slug,
        "name" => "Param Scope",
        "kind" => "custom",
        "config" => %{
          "groups" => %{"sessions" => %{"tools" => %{"Session_Get" => %{"disabled" => true}}}}
        }
      })

    scope
  end

  defp create_user do
    n = System.unique_integer([:positive])

    Repo.insert!(%User{
      id: Ecto.UUID.generate(),
      email: "param-gw-#{n}@example.com",
      user_name: "paramgw#{n}",
      handle: "paramgwh#{n}",
      status: :active,
      verified: false,
      flagged: false
    })
  end

  defp create_api_key(user_id) do
    Repo.insert!(%McpApiKey{
      id: Ecto.UUID.generate(),
      user_id: user_id,
      key_prefix: "mcp_t",
      key_hash: Ecto.UUID.generate(),
      status: "active"
    })
  end

  defp key_caller do
    user = create_user()
    key = create_api_key(user.id)

    {:ok, token, _exp} =
      Token.mint(%{id: user.id, email: user.email, name: user.user_name}, %{id: key.id},
        alg: :hs256
      )

    token
  end

  defp encode_query(spec),
    do: "?t=" <> Base.url_encode64(Jason.encode!(spec), padding: false)

  defp rpc_req(conn, token, path, body) do
    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
    |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> post(path, body)
  end

  defp initialize(token, path, query) do
    body =
      Jason.encode!(%{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2024-11-05",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "param-test", "version" => "1.0"}
        }
      })

    conn = rpc_req(build_conn(), token, path <> query, body)
    session = conn |> Plug.Conn.get_resp_header("mcp-session-id") |> List.first()

    # Standard MCP handshake: the peer only accepts requests after the
    # notifications/initialized notification.
    if session do
      build_conn()
      |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_req_header("mcp-session-id", session)
      |> post(path, Jason.encode!(%{"jsonrpc" => "2.0", "method" => "notifications/initialized"}))
    end

    {conn, session}
  end

  defp follow_up(token, path, session, method, id, params \\ %{}) do
    build_conn()
    |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
    |> Plug.Conn.put_req_header("accept", "application/json, text/event-stream")
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> Plug.Conn.put_req_header("mcp-session-id", session)
    |> post(
      path,
      Jason.encode!(%{"jsonrpc" => "2.0", "id" => id, "method" => method, "params" => params})
    )
    |> json_response(200)
  end

  defp listed_tools(token, path, session) do
    follow_up(token, path, session, "tools/list", 2)
    |> get_in(["result", "tools"])
    |> Enum.map(& &1["name"])
  end

  setup do
    uniq = System.unique_integer([:positive])
    slug = "param-gw-#{uniq}"
    scope = create_scope(slug)
    token = key_caller()

    %{scope: scope, slug: slug, token: token, path: "/custom/#{slug}/mcp"}
  end

  # ── decode-before-transport: fail-closed 400s ───────────────────────────────

  describe "invalid parameter → 400 before the transport" do
    test "garbage charset is rejected even unauthenticated", %{path: path} do
      conn =
        build_conn()
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> post(path <> "?t=!!!not-base64url", Jason.encode!(%{"jsonrpc" => "2.0"}))

      assert conn.status == 400

      assert %{"error" => "invalid tool selection parameter", "detail" => detail} =
               json_response(conn, 400)

      assert is_binary(detail) and detail != ""
    end

    test "bad base64 padding is rejected", %{token: token, path: path} do
      conn =
        rpc_req(build_conn(), token, path <> "?t=abcde", Jason.encode!(%{"jsonrpc" => "2.0"}))

      assert conn.status == 400
      assert %{"detail" => "invalid_base64"} = json_response(conn, 400)
    end

    test "unknown preset is rejected with a detail", %{token: token, path: path} do
      conn =
        rpc_req(
          build_conn(),
          token,
          path <> encode_query(%{"default" => "nope"}),
          Jason.encode!(%{"jsonrpc" => "2.0", "id" => 1, "method" => "initialize", "params" => %{}})
        )

      assert conn.status == 400
      assert %{"detail" => "unknown preset: nope"} = json_response(conn, 400)
    end
  end

  # ── listing + dispatch through the session ──────────────────────────────────

  describe "param-shaped serving" do
    test "white-list shapes tools/list and re-enables a stored-disabled tool", %{
      token: token,
      path: path
    } do
      query = encode_query(%{"white-list" => %{"Session_Get" => true, "Session_Manifest" => true}})
      {conn, session} = initialize(token, path, query)
      assert conn.status == 200

      names = listed_tools(token, path, session)

      # stored-disabled Session_Get: re-enabled by the white-list
      assert "Session_Get" in names
      assert "Session_Manifest" in names

      # absent-from-set → disabled → dropped from the listing
      refute "Session_Create" in names
      refute "Session_Update" in names

      # the Discovery browsing plane stays ungated
      assert "ToolSummary" in names
    end

    test "re-enabled tool is dispatchable; excluded tool call is rejected", %{
      token: token,
      path: path
    } do
      query = encode_query(%{"white-list" => %{"Session_Get" => true}})
      {_conn, session} = initialize(token, path, query)

      # the re-enabled tool passes the toolset guard: whatever the handler
      # answers, the response must NOT be a toolset denial or an unknown-tool
      body =
        follow_up(token, path, session, "tools/call", 3, %{
          "name" => "Session_Get",
          "arguments" => %{}
        })

      text = inspect(body)
      refute text =~ "tool_disabled_for_key"
      refute text =~ "Unknown tool"

      # the excluded tool is not even dispatchable (dropped from the catalog)
      denied =
        follow_up(token, path, session, "tools/call", 4, %{
          "name" => "Session_Create",
          "arguments" => %{}
        })

      assert denied["error"] != nil or get_in(denied, ["result", "isError"]) == true
      assert inspect(denied) =~ "Unknown tool"
    end

    test "no-param behavior is unchanged (stored config governs)", %{token: token, path: path} do
      {conn, session} = initialize(token, path, "")
      assert conn.status == 200

      names = listed_tools(token, path, session)

      # stored-disabled Session_Get stays off; the enabled sessions tools serve.
      # (Session_List/Session_Archive are statically hidden — registration-level
      # visibility survives no-op states, param or not.)
      refute "Session_Get" in names
      assert "Session_Create" in names
      assert "Session_Update" in names
      assert "Session_Manifest" in names
      assert "ToolSummary" in names
    end

    test "the param is an initialize-time snapshot: follow-ups without the query keep it", %{
      token: token,
      path: path
    } do
      query = encode_query(%{"white-list" => %{"Session_Get" => true}})
      {conn, session} = initialize(token, path, query)
      assert conn.status == 200

      # same session, no ?t= on this request
      names = listed_tools(token, path, session)
      assert "Session_Get" in names
      refute "Session_Create" in names
    end
  end
end
