defmodule NoizuPromptLinguaWeb.Plugs.MockMCPGatewaySurfaceTest do
  @moduledoc """
  Complements mock_mcp_gateway_test with the transport edges: HTTP method
  routing (GET/DELETE/other), raw-body parse handling (empty body, malformed
  JSON, non-2.0 payloads), JSON-RPC envelope errors (notifications, missing
  id/params), the module-implementation pending refusal, and the LLM-backed
  tool/resource/prompt error normalization (no provider configured in tests
  ⇒ the gateway must answer with a JSON-RPC error, never a raise).
  """

  use NoizuPromptLingua.DataCase, async: true
  import Plug.Test
  import Plug.Conn, only: [get_resp_header: 2]

  alias NoizuPromptLinguaWeb.Plugs.MockMCPGateway
  alias NoizuPromptLingua.Domains.MockMCP

  setup do
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["gw2-org-#{System.unique_integer([:positive])}", "GW2 Org"]
      )

    org_id = Ecto.UUID.load!(raw_id)
    uniq = System.unique_integer([:positive])

    slug = "gw2-mock-#{uniq}"

    {:ok, def_} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: slug,
        title: "Surface Mock",
        prompt: "Testing the gateway surface."
      })

    {:ok, _} =
      MockMCP.set_surface(def_.id, %{
        "tools" => [
          %{
            "name" => "echo",
            "description" => "Echo",
            "inputSchema" => %{"type" => "object"},
            "handler" => "echo the args"
          },
          %{
            "name" => "mod_tool",
            "description" => "Module-implemented",
            "inputSchema" => %{"type" => "object"},
            "impl" => "module"
          }
        ],
        "resources" => [
          %{"uri" => "mock://res", "name" => "res", "handler" => "produce contents"}
        ],
        "prompts" => [
          %{"name" => "greet", "description" => "Greet", "handler" => "greet the caller"}
        ]
      })

    # a bare mock with no surface at all (nil tools/resources/prompts)
    bare_slug = "gw2-bare-#{uniq}"

    {:ok, _} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: bare_slug,
        title: "Bare Mock",
        prompt: "No surface."
      })

    {:ok, _} = MockMCP.activate(slug)
    {:ok, _} = MockMCP.activate(bare_slug)

    # Deterministic offline LLM failure: a dead local endpoint makes the
    # agent loop fail fast (connection refused) without touching the network.
    {:ok, llm} =
      MockMCP.create_llm(%{
        organization_id: org_id,
        label: "dead-endpoint",
        provider: "openai",
        model: "gpt-4o-mini",
        endpoint: "http://127.0.0.1:1/v1",
        api_key: "test-key"
      })

    {:ok, _} = MockMCP.update(def_.id, %{active_llm_id: llm.id})

    %{slug: slug, bare_slug: bare_slug}
  end

  defp rpc(slug, payload, opts \\ []) do
    method = Keyword.get(opts, :method, "POST")
    body = Keyword.get(opts, :body, payload)

    conn(method, "/mcp/#{slug}/mcp", body)
    |> Map.put(:path_params, %{"slug" => slug})
    |> Map.put(:params, %{"slug" => slug})
    |> MockMCPGateway.call([])
  end

  defp decode(conn), do: Jason.decode!(conn.resp_body)

  # ── HTTP method routing ────────────────────────────────────────────────────

  test "GET is a 501 (SSE unsupported), DELETE an empty 200, others a 405", %{slug: slug} do
    assert %{status: 501} = rpc(slug, "", method: "GET")
    assert %{status: 200, resp_body: ""} = rpc(slug, "", method: "DELETE")
    assert %{status: 405} = rpc(slug, "", method: "PATCH")
  end

  # ── raw-body parse handling ───────────────────────────────────────────────

  test "an empty body yields a -32600 Invalid Request", %{slug: slug} do
    conn = rpc(slug, "")
    assert decode(conn)["error"]["code"] == -32600
  end

  test "malformed JSON is a -32700 parse error", %{slug: slug} do
    conn = rpc(slug, "{not json", body: "{not json")
    assert decode(conn)["error"]["code"] == -32700
  end

  test "valid JSON without the jsonrpc envelope is -32600", %{slug: slug} do
    conn = rpc(slug, ~s({"a": 1}), body: ~s({"a": 1}))
    assert decode(conn)["error"]["code"] == -32600
  end

  # ── envelope errors ────────────────────────────────────────────────────────

  test "notifications are acknowledged with 202 and no body", %{slug: slug} do
    conn =
      rpc(slug, %{"jsonrpc" => "2.0", "method" => "notifications/initialized"})

    assert conn.status == 202
  end

  test "a request without an id (and not a notification) is -32600", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "method" => "ping"})
    assert decode(conn)["error"]["code"] == -32600
  end

  # ── params validation ─────────────────────────────────────────────────────

  test "tools/call without a name is -32602", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 1, "method" => "tools/call", "params" => %{}})
    assert decode(conn)["error"]["code"] == -32602
  end

  test "resources/read without a uri and prompts/get without a name are -32602", %{slug: slug} do
    conn =
      rpc(slug, %{"jsonrpc" => "2.0", "id" => 2, "method" => "resources/read", "params" => %{}})

    assert decode(conn)["error"]["code"] == -32602

    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 3, "method" => "prompts/get", "params" => %{}})
    assert decode(conn)["error"]["code"] == -32602
  end

  test "missing resources/prompts answer -32002/-32602", %{slug: slug} do
    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 4,
        "method" => "resources/read",
        "params" => %{"uri" => "mock://ghost"}
      })

    assert decode(conn)["error"]["code"] == -32002

    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 5,
        "method" => "prompts/get",
        "params" => %{"name" => "ghost"}
      })

    assert decode(conn)["error"]["code"] == -32602
  end

  test "a surface-less mock lists nothing and rejects calls via find_by(nil)", %{
    bare_slug: bare_slug
  } do
    conn = rpc(bare_slug, %{"jsonrpc" => "2.0", "id" => 6, "method" => "tools/list"})
    assert decode(conn)["result"]["tools"] == []

    conn =
      rpc(bare_slug, %{
        "jsonrpc" => "2.0",
        "id" => 7,
        "method" => "tools/call",
        "params" => %{"name" => "anything", "arguments" => %{}}
      })

    assert decode(conn)["error"]["code"] == -32602
  end

  # ── module-implemented tools: the pending refusal ─────────────────────────

  test "module-implemented tools refuse loudly with -32000 (not silently LLM-served)", %{
    slug: slug
  } do
    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 8,
        "method" => "tools/call",
        "params" => %{"name" => "mod_tool", "arguments" => %{}}
      })

    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "mod_tool"
  end

  # ── LLM-backed calls degrade to JSON-RPC errors on provider failure ───────

  test "an LLM tool call whose provider fails normalizes to -32000", %{slug: slug} do
    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 9,
        "method" => "tools/call",
        "params" => %{"name" => "echo", "arguments" => %{"x" => 1}}
      })

    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "Tool call failed"
  end

  test "resource reads without provider config normalize to -32000", %{slug: slug} do
    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 10,
        "method" => "resources/read",
        "params" => %{"uri" => "mock://res"}
      })

    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "Resource read failed"
  end

  test "prompt gets without provider config normalize to -32000", %{slug: slug} do
    conn =
      rpc(slug, %{
        "jsonrpc" => "2.0",
        "id" => 11,
        "method" => "prompts/get",
        "params" => %{"name" => "greet", "arguments" => %{"who" => "world"}}
      })

    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "Prompt get failed"
  end

  # ── inactive mocks across methods ─────────────────────────────────────────

  test "inactive mocks answer every method with the not-active error", %{bare_slug: bare_slug} do
    # bare_slug is activated by setup; (re)create a never-activated mock instead
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["gw2-org2-#{System.unique_integer([:positive])}", "GW2 Org2"]
      )

    org_id = Ecto.UUID.load!(raw_id)
    inactive_slug = "gw2-inactive-#{System.unique_integer([:positive])}"

    {:ok, _} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: inactive_slug,
        title: "Inactive Mock",
        prompt: "Never activated."
      })

    for method <- ["initialize", "tools/list", "resources/list", "prompts/list"] do
      conn = rpc(inactive_slug, %{"jsonrpc" => "2.0", "id" => 12, "method" => method})
      body = decode(conn)
      assert body["error"]["code"] == -32000
      assert body["error"]["message"] =~ "not active"
    end

    # the activated bare mock still answers normally
    conn = rpc(bare_slug, %{"jsonrpc" => "2.0", "id" => 14, "method" => "resources/list"})
    assert decode(conn)["result"]["resources"] == []
  end

  test "the initialize result carries a session id header", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 13, "method" => "initialize"})
    assert [session_id] = get_resp_header(conn, "mcp-session-id")
    assert byte_size(session_id) == 32
  end
end
