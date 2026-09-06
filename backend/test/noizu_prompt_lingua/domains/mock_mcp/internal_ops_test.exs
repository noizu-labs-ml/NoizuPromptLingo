defmodule NoizuPromptLingua.Domains.MockMCP.InternalOpsTest do
  @moduledoc """
  The agent's PRIVATE data ops. Redis is exercised for real (it's up in the test
  env); the DB path is checked for the unprovisioned guard (provisioning creates a
  real database, exercised in live smoke rather than the unit suite).
  """
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Domains.MockMCP.InternalOps

  defp def_(provisioned? \\ false) do
    %{
      slug: "iops-#{System.unique_integer([:positive])}",
      db_provisioned: provisioned?,
      db_name: nil
    }
  end

  test "op?/1 recognises the data ops" do
    for op <- ~w(redis_get redis_set redis_del redis_keys db_query db_execute) do
      assert InternalOps.op?(op)
    end

    refute InternalOps.op?("echo")
  end

  test "available/1 reflects DB provisioning" do
    refute InternalOps.available(def_(false)) =~ "db_query"
    assert InternalOps.available(def_(false)) =~ "redis_get"
    assert InternalOps.available(def_(true)) =~ "db_query"
  end

  test "redis ops round-trip against the mock keyspace" do
    d = def_()
    key = "k-#{System.unique_integer([:positive])}"

    assert {:ok, %{"ok" => true}} =
             InternalOps.exec(d, "redis_set", %{"key" => key, "value" => "v1"})

    assert {:ok, %{"result" => "v1"}} = InternalOps.exec(d, "redis_get", %{"key" => key})
    assert {:ok, %{"result" => keys}} = InternalOps.exec(d, "redis_keys", %{"pattern" => "*"})
    assert key in keys
    assert {:ok, _} = InternalOps.exec(d, "redis_del", %{"key" => key})
    assert {:ok, %{"result" => nil}} = InternalOps.exec(d, "redis_get", %{"key" => key})
  end

  test "db ops error when no database is provisioned" do
    assert {:error, msg} = InternalOps.exec(def_(false), "db_query", %{"sql" => "SELECT 1"})
    assert msg =~ "no database provisioned"
  end

  test "unknown op is rejected" do
    assert {:error, _} = InternalOps.exec(def_(), "frobnicate", %{})
  end

  # ── argument validation + weaviate/call_tool ops ──────────────────────────

  test "op?/1 also recognises weaviate and call_tool ops" do
    for op <- ~w(weaviate_add weaviate_query call_tool) do
      assert InternalOps.op?(op)
    end
  end

  test "missing required arguments are rejected per op family" do
    d = def_()

    assert {:error, "missing required 'sql' argument"} =
             InternalOps.exec(d, "db_query", %{})

    assert {:error, "missing required 'sql' argument"} =
             InternalOps.exec(d, "db_execute", %{})

    assert {:error, "missing required arguments"} = InternalOps.exec(d, "redis_get", %{})

    assert {:error, msg} = InternalOps.exec(d, "weaviate_add", %{})
    assert msg =~ "missing required arguments"

    assert {:error, msg} = InternalOps.exec(d, "weaviate_query", %{"collection" => "x"})
    assert msg =~ "missing required arguments"

    assert {:error, "missing required 'tool' argument"} = InternalOps.exec(d, "call_tool", %{})
  end

  test "redis_set honours a ttl argument" do
    d = def_()
    key = "ttl-#{System.unique_integer([:positive])}"

    assert {:ok, %{"ok" => true}} =
             InternalOps.exec(d, "redis_set", %{"key" => key, "value" => "v", "ttl" => 60})

    assert {:ok, %{"result" => "v"}} = InternalOps.exec(d, "redis_get", %{"key" => key})
  end

  test "available/1 reports no tools / no collections for a bare definition" do
    text = InternalOps.available(%{slug: "bare"})
    assert text =~ "no Weaviate collections designed"
    assert text =~ "no other tools to call"
  end

  test "weaviate ops reject undesigned collections" do
    d = def_()

    assert {:error, msg} =
             InternalOps.exec(d, "weaviate_add", %{"collection" => "Nope", "text" => "t"})

    assert msg =~ "unknown collection 'Nope'"

    assert {:error, msg} =
             InternalOps.exec(d, "weaviate_query", %{"collection" => "Nope", "query" => "q"})

    assert msg =~ "unknown collection 'Nope'"
  end

  defmodule CallToolLLMStub do
    def init(opts), do: opts

    def call(conn, _opts) do
      {:ok, _body, conn} = Plug.Conn.read_body(conn)

      body =
        Jason.encode!(%{
          "choices" => [
            %{"message" => %{"content" => Jason.encode!(%{"type" => "text", "text" => "nested"})}}
          ]
        })

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, body)
    end
  end

  test "call_tool op composes another of the mock's tools (LLM-backed)", %{} do
    # local Bandit stub for the nested tool's LLM call
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    {:ok, pid} =
      Bandit.start_link(plug: CallToolLLMStub, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    on_exit(fn ->
      if Process.alive?(pid), do: Process.exit(pid, :shutdown)
    end)

    d = %{
      slug: "iops-ct-#{System.unique_integer([:positive])}",
      prompt: "a composing mock",
      tools_json: [%{"name" => "greet", "impl" => "llm", "handler" => "h"}],
      db_provisioned: false,
      db_name: nil
    }

    opts = [endpoint: "http://127.0.0.1:#{port}/nested"]

    assert {:ok, %{"content" => [%{"type" => "text", "text" => "nested"}]}} =
             InternalOps.exec(
               d,
               "call_tool",
               %{"tool" => "greet", "arguments" => %{"a" => 1}},
               opts
             )
  end

  test "call_tool op surfaces unknown-tool errors" do
    d = %{slug: "iops-#{System.unique_integer([:positive])}", tools_json: []}

    assert {:error, "unknown tool: ghost"} =
             InternalOps.exec(d, "call_tool", %{"tool" => "ghost", "arguments" => %{}})
  end
end
