defmodule NoizuPromptLinguaWeb.Plugs.MockMCPGatewayTest do
  @moduledoc """
  Exercises the dynamic mock-MCP JSON-RPC gateway plumbing end-to-end. The
  generated tool-call / resource-read / prompt-get → LLM paths are covered by the
  Agent contract and live smoke tests (need provider keys); here we verify the
  surface listing, built-in (real) Redis tools, capabilities, and error paths.
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
        ["gw-org-#{System.unique_integer([:positive])}", "GW Org"]
      )

    org_id = Ecto.UUID.load!(raw_id)
    slug = "gw-mock-#{System.unique_integer([:positive])}"

    {:ok, def_} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: slug,
        title: "Gateway Mock",
        prompt: "An MCP server for testing the gateway."
      })

    {:ok, _} =
      MockMCP.set_surface(def_.id, %{
        "tools" => [
          %{"name" => "echo", "description" => "Echo input",
            "inputSchema" => %{"type" => "object"}, "handler" => "echo the args verbatim"}
        ],
        "resources" => [
          %{"uri" => "mock://hello", "name" => "hello", "description" => "A greeting",
            "mimeType" => "text/plain", "handler" => "return a greeting"}
        ],
        "prompts" => [
          %{"name" => "greet", "description" => "Greeting prompt",
            "arguments" => [%{"name" => "who", "required" => true}], "handler" => "ask to greet"}
        ]
      })

    {:ok, slug: slug}
  end

  defp rpc(slug, payload) do
    conn(:post, "/mcp/#{slug}/mcp")
    |> Map.put(:path_params, %{"slug" => slug})
    |> Map.put(:params, %{"slug" => slug})
    |> Map.put(:body_params, payload)
    |> MockMCPGateway.call([])
  end

  defp decode(conn), do: Jason.decode!(conn.resp_body)

  test "initialize fails until the mock is active, then succeeds", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 1, "method" => "initialize"})
    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "not active"

    {:ok, _} = MockMCP.activate(slug)

    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 2, "method" => "initialize"})
    body = decode(conn)
    assert body["result"]["serverInfo"]["name"] == "mock-#{slug}"
    # capabilities advertise the full surface
    assert body["result"]["capabilities"]["tools"]
    assert body["result"]["capabilities"]["resources"]
    assert body["result"]["capabilities"]["prompts"]
    assert get_resp_header(conn, "mcp-session-id") != []
  end

  test "tools/list exposes ONLY generated tools — datastore is private", %{slug: slug} do
    {:ok, _} = MockMCP.activate(slug)

    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 3, "method" => "tools/list"})
    tools = decode(conn)["result"]["tools"]
    names = Enum.map(tools, & &1["name"])

    assert names == ["echo"]
    # the agent's private datastore ops must NEVER be exposed to consumers
    refute "redis_set" in names
    refute "redis_get" in names
    refute "db_query" in names
    refute "db_execute" in names
    # private handler must never reach clients
    echo = Enum.find(tools, &(&1["name"] == "echo"))
    refute Map.has_key?(echo, "handler")
  end

  test "calling a private data op as a tool is rejected (unknown tool)", %{slug: slug} do
    {:ok, _} = MockMCP.activate(slug)

    conn =
      rpc(slug, %{"jsonrpc" => "2.0", "id" => 11, "method" => "tools/call",
        "params" => %{"name" => "redis_set", "arguments" => %{"key" => "x", "value" => "y"}}})

    assert decode(conn)["error"]["code"] == -32602
  end

  test "resources/list and prompts/list expose the surface without handlers", %{slug: slug} do
    {:ok, _} = MockMCP.activate(slug)

    res = decode(rpc(slug, %{"jsonrpc" => "2.0", "id" => 7, "method" => "resources/list"}))
    assert [%{"uri" => "mock://hello", "name" => "hello"} = r] = res["result"]["resources"]
    refute Map.has_key?(r, "handler")

    pr = decode(rpc(slug, %{"jsonrpc" => "2.0", "id" => 8, "method" => "prompts/list"}))
    assert [%{"name" => "greet", "arguments" => [%{"name" => "who"}]} = p] = pr["result"]["prompts"]
    refute Map.has_key?(p, "handler")
  end

  test "ping returns an empty result", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 4, "method" => "ping"})
    assert decode(conn)["result"] == %{}
  end

  test "unknown method returns -32601", %{slug: slug} do
    conn = rpc(slug, %{"jsonrpc" => "2.0", "id" => 5, "method" => "bogus/method"})
    assert decode(conn)["error"]["code"] == -32601
  end

  test "unknown slug initialize returns not found" do
    conn = rpc("does-not-exist", %{"jsonrpc" => "2.0", "id" => 6, "method" => "initialize"})
    body = decode(conn)
    assert body["error"]["code"] == -32000
    assert body["error"]["message"] =~ "not found"
  end
end
