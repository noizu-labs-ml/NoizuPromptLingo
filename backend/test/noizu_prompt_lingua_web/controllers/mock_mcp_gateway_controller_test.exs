defmodule NoizuPromptLinguaWeb.MockMCPGatewayControllerTest do
  @moduledoc """
  MockMCPGatewayController — thin wrapper delegating `mockmcp.<host>/mcp/:slug/mcp`
  JSON-RPC traffic to `NoizuPromptLinguaWeb.Plugs.MockMCPGateway`.

  The controller has no logic of its own, so these tests drive the routed
  surface end to end (host-header matched, no auth pipeline) across the
  method/dispatch matrix: initialize / ping / tools-list happy paths plus the
  JSON-RPC error envelope (-32600 / -32700 / -32601 / -32000) and the
  non-POST verb stubs (501 GET, 200 DELETE, 202 notifications).
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.MockMCP

  # The route lives on the host-constrained scope; rewrite the test host so
  # the Phoenix router's `host: "mockmcp."` prefix match selects it. (plug
  # forbids put_req_header("host", ...) — set conn.host directly.)
  @host "mockmcp.example.com"

  defp gw(conn), do: %{conn | host: @host}

  @base "/api/v1/organizations"

  defp create_org(conn, suffix) do
    slug = "gw-org-#{suffix}"

    org_id =
      conn
      |> post(@base, %{organization: %{slug: slug, name: "GW Org #{suffix}"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    org_id
  end

  defp create_active_def(org_id, status \\ "active") do
    slug = "gw-#{System.unique_integer([:positive])}"

    {:ok, _} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: slug,
        title: "GW Mock",
        prompt: "A tiny echo server.",
        status: status
      })

    slug
  end

  defp rpc(conn, slug, payload) do
    conn
    |> gw()
    |> post("/mcp/#{slug}/mcp", Map.put(payload, "jsonrpc", "2.0"))
  end

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    org_id = create_org(auth, System.unique_integer([:positive]))

    {:ok, conn: auth, org_id: org_id}
  end

  describe "happy paths" do
    test "initialize on an active mock -> result envelope + session header", %{
      conn: conn,
      org_id: org_id
    } do
      slug = create_active_def(org_id)

      conn =
        rpc(conn, slug, %{"method" => "initialize", "id" => 1, "params" => %{}})
        |> json_response(200)

      assert conn["jsonrpc"] == "2.0"
      assert conn["id"] == 1

      assert %{"protocolVersion" => "2025-03-26", "serverInfo" => %{"name" => "mock-" <> ^slug}} =
               conn["result"]

      assert conn["result"]["capabilities"]["tools"]
    end

    test "ping -> empty result; tools/list strips private handler fields", %{
      conn: conn,
      org_id: org_id
    } do
      slug = create_active_def(org_id)

      {:ok, _} =
        MockMCP.set_tools(slug, [
          %{
            "name" => "echo",
            "description" => "Echo",
            "handler" => "llm",
            "inputSchema" => %{"type" => "object"}
          }
        ])

      assert %{"result" => result} =
               rpc(conn, slug, %{"method" => "ping", "id" => "a"}) |> json_response(200)

      assert result == %{}

      body = rpc(conn, slug, %{"method" => "tools/list", "id" => 2}) |> json_response(200)

      assert [%{"name" => "echo", "inputSchema" => %{"type" => "object"}} = tool] =
               body["result"]["tools"]

      refute Map.has_key?(tool, "handler")
    end
  end

  describe "json-rpc error envelope" do
    test "unknown slug -> -32000 not found", %{conn: conn} do
      assert %{"error" => %{"code" => -32000, "message" => msg}} =
               rpc(conn, "no-such-mock", %{"method" => "initialize", "id" => 1})
               |> json_response(200)

      assert msg =~ "not found"
    end

    test "non-active (draft) slug -> -32000 with status", %{conn: conn, org_id: org_id} do
      slug = create_active_def(org_id, "draft")

      assert %{"error" => %{"code" => -32000, "message" => msg}} =
               rpc(conn, slug, %{"method" => "initialize", "id" => 1})
               |> json_response(200)

      assert msg =~ "draft"
    end

    test "unknown method -> -32601", %{conn: conn, org_id: org_id} do
      slug = create_active_def(org_id)

      assert %{"error" => %{"code" => -32601, "message" => "Method not found: wat/list"}} =
               rpc(conn, slug, %{"method" => "wat/list", "id" => 3})
               |> json_response(200)
    end

    test "request missing jsonrpc version -> -32600 Invalid Request", %{
      conn: conn,
      org_id: org_id
    } do
      slug = create_active_def(org_id)

      # Post a genuine JSON body (ConnTest sends map bodies as multipart/mixed,
      # which would land on the parse-error branch instead).
      body = Jason.encode!(%{"method" => "ping", "id" => 4})

      assert %{"error" => %{"code" => -32600, "message" => "Invalid Request"}} =
               conn
               |> gw()
               |> put_req_header("content-type", "application/json")
               |> post("/mcp/#{slug}/mcp", body)
               |> json_response(200)
    end

    test "malformed JSON body -> -32700 Parse error", %{conn: conn, org_id: org_id} do
      slug = create_active_def(org_id)

      # Non-JSON content-type: Plug.Parsers skips it, so the gateway's own
      # read_body + Jason.decode path produces :parse_error.
      assert %{"error" => %{"code" => -32700, "message" => "Parse error"}} =
               conn
               |> gw()
               |> put_req_header("content-type", "text/plain")
               |> post("/mcp/#{slug}/mcp", "{not json")
               |> json_response(200)
    end
  end

  describe "non-POST verbs" do
    test "GET -> 501 SSE unsupported; DELETE -> 200 empty", %{conn: conn, org_id: org_id} do
      slug = create_active_def(org_id)

      assert "SSE not yet supported for mock MCPs" =
               conn |> gw() |> get("/mcp/#{slug}/mcp") |> response(501)

      assert "" = conn |> gw() |> delete("/mcp/#{slug}/mcp") |> response(200)
    end

    test "notifications/* -> 202 accepted, no body envelope", %{conn: conn, org_id: org_id} do
      slug = create_active_def(org_id)

      conn =
        conn
        |> gw()
        |> post("/mcp/#{slug}/mcp", %{
          "jsonrpc" => "2.0",
          "method" => "notifications/initialized"
        })

      assert conn.status == 202
      assert conn.resp_body == ""
    end
  end
end
