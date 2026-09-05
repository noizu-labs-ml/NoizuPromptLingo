defmodule NoizuPromptLinguaWeb.MCP.JsonRpcGuardTest do
  use NoizuPromptLinguaWeb.ConnCase, async: false

  @moduledoc """
  B4 regression — JSON-RPC bodies with a legacy (`"1.0"`) or missing `jsonrpc`
  version must get an IMMEDIATE `-32600 Invalid Request` reply instead of
  hanging the connection in the transport session (the pinned lib plug's
  classify/1 accepts them as requests; the session never resolves a reply).

  Unit tests pin the guard contract; the gateway-integration tests prove the
  mount seam answers pre-auth (the gate pipeline defers anonymous callers to
  the transport, and the guard sits in front of it) without a session.
  async: false — flips :tool_sets_enabled.
  """

  import Plug.Conn

  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.TestStub
  alias NoizuPromptLinguaWeb.MCP.JsonRpcGuard
  alias NoizuPromptLinguaWeb.MCPSetGatewayController

  @host "tobor.locker"

  # ── unit: guard contract ──────────────────────────────────────────────────

  describe "check/1 (POST bodies)" do
    test "jsonrpc \"1.0\" ⇒ halt 400 with the -32600 envelope (id echoed)" do
      conn = json_conn(~s({"jsonrpc":"1.0","id":603,"method":"tools/list"}))

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400

      assert Jason.decode!(conn.resp_body) == %{
               "jsonrpc" => "2.0",
               "id" => 603,
               "error" => %{"code" => -32600, "message" => "Invalid Request"}
             }
    end

    test "missing jsonrpc ⇒ halt 400 -32600 (id null when absent)" do
      conn = json_conn(~s({"id":"abc","method":"tools/list"}))

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400

      body = Jason.decode!(conn.resp_body)
      assert body["error"]["code"] == -32600
      assert body["id"] == "abc"
    end

    test "missing jsonrpc on an id-less notification ⇒ still -32600 (MCP requires it)" do
      conn = json_conn(~s({"method":"tools/list"}))

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["error"]["code"] == -32600
    end

    test "wrong version with body_params pre-fetched by the endpoint parser ⇒ -32600" do
      conn =
        json_conn("")
        |> Map.put(:body_params, %{"jsonrpc" => "1.1", "id" => 7, "method" => "ping"})

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["id"] == 7
    end

    test "well-framed 2.0 request ⇒ pass-through with the body reattached" do
      body = ~s({"jsonrpc":"2.0","id":1,"method":"tools/list"})
      conn = json_conn(body)

      assert {:ok, conn} = JsonRpcGuard.check(conn)
      assert conn.body_params == %{"jsonrpc" => "2.0", "id" => 1, "method" => "tools/list"}
      refute conn.status
    end

    test "client-response objects (no method) are out of scope ⇒ pass through" do
      conn = json_conn(~s({"jsonrpc":"1.0","id":2,"result":{"ok":true}}))

      assert {:ok, _conn} = JsonRpcGuard.check(conn)
    end

    test "unparseable body ⇒ the transport's own 400 Invalid JSON body" do
      conn = json_conn("{nope")

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400
      assert conn.resp_body == "Invalid JSON body"
    end

    test "batch array ⇒ the transport's own 400 Not a JSON-RPC message" do
      conn = json_conn(~s([{"jsonrpc":"2.0","id":1,"method":"ping"}]))

      assert {:halt, conn} = JsonRpcGuard.check(conn)
      assert conn.status == 400
      assert conn.resp_body == "Not a JSON-RPC message"
    end

    test "GET passes through untouched" do
      conn =
        Plug.Test.conn(:get, "/mcp")
        |> Map.replace!(:host, @host)

      assert {:ok, ^conn} = JsonRpcGuard.check(conn)
    end
  end

  # ── integration: the set-gateway mount seam answers pre-auth ─────────────

  describe "set gateway mount (B4 e2e)" do
    setup do
      Application.put_env(:noizu_prompt_lingua, :tool_sets_enabled, true)
      on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :tool_sets_enabled) end)

      org =
        Repo.insert!(%Organization{
          name: "Guard Org",
          # UUID-suffixed: localhost Redis outlives the VM; a repeated slug
          # would resolve to a previous run's rolled-back org via the 1h cache.
          slug: "guard-org-#{Ecto.UUID.generate()}"
        })

      TestStub.seed_org(org.id, org.slug)
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs, :list])

      {:ok, set} =
        ToolSets.create(%{
          "organization_id" => org.id,
          "slug" => "guarded-set",
          "display_name" => "guarded-set"
        })

      %{org: org, set: set}
    end

    test "jsonrpc \"1.0\" ⇒ prompt 400 -32600, no session, no hang", %{org: org, set: set} do
      conn =
        gateway_conn(org.slug, set.slug, ~s({"jsonrpc":"1.0","id":603,"method":"tools/list"}))

      assert %Plug.Conn{} = conn
      assert conn.status == 400

      assert Jason.decode!(conn.resp_body)["error"]["code"] == -32600
    end

    test "missing jsonrpc ⇒ prompt 400 -32600", %{org: org, set: set} do
      conn = gateway_conn(org.slug, set.slug, ~s({"id":9,"method":"tools/list"}))

      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["id"] == 9
    end

    test "a well-framed 2.0 body is NOT eaten by the guard (defers to transport)", %{
      org: org,
      set: set
    } do
      conn = gateway_conn(org.slug, set.slug, ~s({"jsonrpc":"2.0","id":1,"method":"tools/list"}))

      case conn do
        %Plug.Conn{} = c ->
          refute c.status == 400
          refute c.resp_body =~ "-32600"

        {:serving_reached, _msg} ->
          # Crashed inside transport session serving = guard passed it on.
          :ok
      end
    end
  end

  # ── helpers ──────────────────────────────────────────────────────────────

  defp json_conn(raw) do
    Plug.Test.conn(:post, "/mcp", raw)
    |> Map.replace!(:host, @host)
    |> put_req_header("content-type", "application/json")
  end

  defp gateway_conn(org_slug, set_slug, raw) do
    conn =
      Plug.Test.conn(:post, "/org/#{org_slug}/set/#{set_slug}/mcp", raw)
      |> Map.replace!(:host, @host)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "")

    MCPSetGatewayController.handle_org(conn, %{
      "org_slug" => org_slug,
      "set_slug" => set_slug
    })
  end
end
