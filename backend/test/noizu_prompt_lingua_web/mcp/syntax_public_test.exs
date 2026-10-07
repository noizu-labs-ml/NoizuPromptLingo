defmodule NoizuPromptLinguaWeb.MCP.SyntaxPublicTest do
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Tools.Catalog

  @initialize %{
    "jsonrpc" => "2.0",
    "id" => 1,
    "method" => "initialize",
    "params" => %{
      "protocolVersion" => "2025-11-25",
      "capabilities" => %{},
      "clientInfo" => %{"name" => "npl-test", "version" => "0.0.0"}
    }
  }

  test "initialize succeeds without Authorization", %{conn: conn} do
    conn =
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json, text/event-stream")
      |> post("/mcp", @initialize)

    refute conn.status == 401
    assert conn.status in [200, 202]
  end

  test "root catalog is NPLLoad and NPLSpec only" do
    names =
      Catalog.build(NoizuPromptLingua.MCP)
      |> Enum.reject(& &1.hidden)
      |> Enum.map(& &1.name)
      |> Enum.sort()

    assert names == ["NPLLoad", "NPLSpec"]
  end
end
