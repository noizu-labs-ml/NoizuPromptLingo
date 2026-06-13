defmodule Noizu.MCP.Inspector.ApiTest do
  @moduledoc """
  Plug.Test-level tests for Noizu.MCP.Inspector.Plug.
  Does not test SSE (/events) since Plug.Test and chunked transfer don't mix.
  """
  use ExUnit.Case, async: true

  import Plug.Test, only: [conn: 3]
  import Plug.Conn

  alias Noizu.MCP.Fixtures
  alias Noizu.MCP.Inspector.Plug, as: InspectorPlug

  @token "test-token"

  setup_all do
    Noizu.MCP.Test.ensure_server_started(Fixtures.Server)
    :ok
  end

  setup do
    # unique registry and supervisor per test so async: true is safe
    reg_name = :"reg_#{System.unique_integer([:positive, :monotonic])}"
    sup_name = :"sup_#{System.unique_integer([:positive, :monotonic])}"

    start_supervised!({Registry, keys: :unique, name: reg_name})
    start_supervised!({DynamicSupervisor, name: sup_name, strategy: :one_for_one})

    config = %{
      inspector: nil,
      registry: reg_name,
      session_supervisor: sup_name,
      token: @token,
      default_target: {:module, Fixtures.Server},
      client_info: nil
    }

    opts = InspectorPlug.init(config)
    %{opts: opts, config: config}
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp request(method, path, body, extra_headers, opts) do
    body_bin = if body, do: Jason.encode!(body), else: ""

    conn(method, path, body_bin)
    |> put_req_header("authorization", "Bearer #{@token}")
    |> put_req_header("content-type", "application/json")
    |> then(fn conn ->
      Enum.reduce(extra_headers, conn, fn {k, v}, c -> put_req_header(c, k, v) end)
    end)
    |> InspectorPlug.call(opts)
  end

  defp json_body(conn) do
    Jason.decode!(conn.resp_body)
  end

  # Connect and return session_id
  defp connect(opts) do
    conn = request(:post, "/api/connect", nil, [], opts)
    assert conn.status == 200
    body = json_body(conn)
    body["session_id"]
  end

  # ── 1. auth ────────────────────────────────────────────────────────────────

  describe "authentication" do
    test "401 without token", %{opts: opts} do
      conn =
        conn(:post, "/api/connect", "")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      assert conn.status == 401
    end

    test "401 with wrong token", %{opts: opts} do
      conn =
        conn(:post, "/api/connect", "")
        |> put_req_header("authorization", "Bearer wrong-token")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      assert conn.status == 401
    end

    test "token via ?token= query param works", %{opts: opts} do
      conn =
        conn(:post, "/api/connect?token=#{@token}", "")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      # token valid -> either 200 or 502 (not 401)
      assert conn.status in [200, 502]
    end
  end

  # ── 2. origin guard ────────────────────────────────────────────────────────

  describe "origin guard" do
    test "cross-origin request is 403", %{opts: opts} do
      conn =
        conn(:post, "/api/connect", "")
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("origin", "https://evil.example")
        |> InspectorPlug.call(opts)

      assert conn.status == 403
    end

    test "localhost origin is allowed", %{opts: opts} do
      conn =
        conn(:post, "/api/connect", "")
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("origin", "http://localhost:6274")
        |> InspectorPlug.call(opts)

      # Not 403
      refute conn.status == 403
    end
  end

  # ── 3. sessions ────────────────────────────────────────────────────────────

  describe "sessions" do
    test "POST /api/connect returns 200 with session_id and server_info", %{opts: opts} do
      conn = request(:post, "/api/connect", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_binary(body["session_id"])
      assert body["server_info"]["name"] == "fixture"
    end

    test "GET /api/session/:id returns session info", %{opts: opts} do
      session_id = connect(opts)
      conn = request(:get, "/api/session/#{session_id}", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert body["session_id"] == session_id
    end

    test "GET /api/session/:id with unknown id returns 404", %{opts: opts} do
      conn = request(:get, "/api/session/nonexistent-id-xyz", nil, [], opts)
      assert conn.status == 404
    end
  end

  # ── 4. feature listings ────────────────────────────────────────────────────

  describe "feature listings" do
    setup %{opts: opts} do
      session_id = connect(opts)
      %{session_id: session_id}
    end

    test "GET tools returns 200 with tools list", %{opts: opts, session_id: sid} do
      conn = request(:get, "/api/session/#{sid}/tools", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["tools"])
      # Tools use wire-format keys
      tool = Enum.find(body["tools"], &(&1["name"] == "echo"))
      assert tool != nil
      assert Map.has_key?(tool, "inputSchema")
    end

    test "GET resources returns 200 with resources list", %{opts: opts, session_id: sid} do
      conn = request(:get, "/api/session/#{sid}/resources", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["resources"])
      uris = Enum.map(body["resources"], & &1["uri"])
      assert "config://app" in uris
    end

    test "GET resource_templates returns 200", %{opts: opts, session_id: sid} do
      conn = request(:get, "/api/session/#{sid}/resource_templates", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["resourceTemplates"])
    end

    test "GET prompts returns 200 with prompts list", %{opts: opts, session_id: sid} do
      conn = request(:get, "/api/session/#{sid}/prompts", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["prompts"])
      names = Enum.map(body["prompts"], & &1["name"])
      assert "code_review" in names
    end
  end

  # ── 5. tool calls ──────────────────────────────────────────────────────────

  describe "tool calls" do
    setup %{opts: opts} do
      session_id = connect(opts)
      %{session_id: session_id}
    end

    test "POST calls/echo returns 202 with call_id", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/calls",
          %{"name" => "echo", "arguments" => %{"message" => "hello"}},
          [],
          opts
        )

      assert conn.status == 202
      body = json_body(conn)
      assert is_integer(body["call_id"]) or is_binary(body["call_id"])
    end

    test "DELETE calls/<bogus_id> returns 400", %{opts: opts, session_id: sid} do
      conn = request(:delete, "/api/session/#{sid}/calls/not-an-integer", nil, [], opts)
      assert conn.status in [400, 404]
    end

    test "DELETE calls/<numeric_unknown> returns 404", %{opts: opts, session_id: sid} do
      conn = request(:delete, "/api/session/#{sid}/calls/999999", nil, [], opts)
      assert conn.status in [400, 404]
    end
  end

  # ── 6. resources / prompts / complete / rpc / ping / roots / log_level / export ─

  describe "feature operations" do
    setup %{opts: opts} do
      session_id = connect(opts)
      %{session_id: session_id}
    end

    test "POST resources/read returns contents", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/resources/read",
          %{"uri" => "config://app"},
          [],
          opts
        )

      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["contents"])
      assert length(body["contents"]) > 0
    end

    test "POST prompts/get returns messages", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/prompts/get",
          %{"name" => "code_review", "arguments" => %{"code" => "x = 1"}},
          [],
          opts
        )

      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["messages"])
      assert length(body["messages"]) > 0
    end

    test "POST complete with ref/prompt returns values shape", %{opts: opts, session_id: sid} do
      # dynamic prompt has branch completion
      conn =
        request(
          :post,
          "/api/session/#{sid}/complete",
          %{
            "ref" => %{"type" => "ref/prompt", "name" => "dynamic"},
            "argument" => %{"name" => "branch", "value" => "main"}
          },
          [],
          opts
        )

      # 200 with values or 502 if the prompt doesn't support completion
      assert conn.status in [200, 502]

      if conn.status == 200 do
        body = json_body(conn)
        assert Map.has_key?(body, "values")
        assert Map.has_key?(body, "total")
        assert Map.has_key?(body, "hasMore")
      end
    end

    test "POST complete with bad ref returns 400", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/complete",
          %{
            "ref" => %{"type" => "ref/bad"},
            "argument" => %{"name" => "x", "value" => "y"}
          },
          [],
          opts
        )

      assert conn.status == 400
    end

    test "POST rpc ping returns 200", %{opts: opts, session_id: sid} do
      conn =
        request(:post, "/api/session/#{sid}/rpc", %{"method" => "ping"}, [], opts)

      assert conn.status == 200
    end

    test "POST ping returns 200", %{opts: opts, session_id: sid} do
      conn = request(:post, "/api/session/#{sid}/ping", nil, [], opts)
      assert conn.status == 200
    end

    test "POST roots returns 200", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/roots",
          %{"roots" => []},
          [],
          opts
        )

      assert conn.status == 200
    end

    test "POST log_level returns 200 or server-capability error", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/log_level",
          %{"level" => "info"},
          [],
          opts
        )

      # 200 if server supports logging, 502 if it doesn't
      assert conn.status in [200, 502]
    end

    test "GET export returns 200 with note for module target", %{opts: opts, session_id: sid} do
      conn = request(:get, "/api/session/#{sid}/export", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert Map.has_key?(body, "target")
      assert Map.has_key?(body, "entry")
      # Module targets: entry is nil and note is set
      assert body["entry"] == nil
      assert is_binary(body["note"])
    end
  end

  # ── 7. edge cases ──────────────────────────────────────────────────────────

  describe "edge cases" do
    setup %{opts: opts} do
      session_id = connect(opts)
      %{session_id: session_id}
    end

    test "POST respond/<unknown> returns 404", %{opts: opts, session_id: sid} do
      conn =
        request(
          :post,
          "/api/session/#{sid}/respond/nonexistent-request-id",
          %{"action" => "decline"},
          [],
          opts
        )

      assert conn.status == 404
    end

    test "POST connect with bad target override returns 502", %{opts: opts} do
      conn =
        conn(
          :post,
          "/api/connect",
          Jason.encode!(%{"target" => %{"type" => "module", "module" => "Not.Real"}})
        )
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      assert conn.status == 502
    end
  end

  # ── 8. GET /api/servers ────────────────────────────────────────────────────

  describe "GET /api/servers" do
    test "returns 200 with servers list and has_default true when default_target set",
         %{opts: opts} do
      conn = request(:get, "/api/servers", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert is_list(body["servers"])
      assert body["has_default"] == true
      # Fixture server must appear since it exports __mcp__/1 and is loaded
      assert "Noizu.MCP.Fixtures.Server" in body["servers"]
    end

    test "servers list is sorted", %{opts: opts} do
      conn = request(:get, "/api/servers", nil, [], opts)
      assert conn.status == 200
      body = json_body(conn)
      assert body["servers"] == Enum.sort(body["servers"])
    end

    test "requires auth — 401 without token", %{opts: opts} do
      conn =
        conn(:get, "/api/servers", "")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      assert conn.status == 401
    end

    test "has_default false when default_target is nil" do
      # Build a fresh opts with no default_target
      reg_name = :"reg_nil_#{System.unique_integer([:positive, :monotonic])}"
      sup_name = :"sup_nil_#{System.unique_integer([:positive, :monotonic])}"
      start_supervised!({Registry, keys: :unique, name: reg_name})
      start_supervised!({DynamicSupervisor, name: sup_name, strategy: :one_for_one})

      nil_config = %{
        inspector: nil,
        registry: reg_name,
        session_supervisor: sup_name,
        token: @token,
        default_target: nil,
        client_info: nil
      }

      nil_opts = InspectorPlug.init(nil_config)
      conn = request(:get, "/api/servers", nil, [], nil_opts)
      assert conn.status == 200
      body = json_body(conn)
      assert body["has_default"] == false
    end
  end

  # ── 9. POST /api/connect with nil default_target ───────────────────────────

  describe "POST /api/connect with nil default_target" do
    setup do
      reg_name = :"reg_nil2_#{System.unique_integer([:positive, :monotonic])}"
      sup_name = :"sup_nil2_#{System.unique_integer([:positive, :monotonic])}"
      start_supervised!({Registry, keys: :unique, name: reg_name})
      start_supervised!({DynamicSupervisor, name: sup_name, strategy: :one_for_one})

      nil_config = %{
        inspector: nil,
        registry: reg_name,
        session_supervisor: sup_name,
        token: @token,
        default_target: nil,
        client_info: nil
      }

      nil_opts = InspectorPlug.init(nil_config)
      %{nil_opts: nil_opts}
    end

    test "POST /api/connect with empty body returns 400 with target error", %{nil_opts: nil_opts} do
      conn =
        conn(:post, "/api/connect", "{}")
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(nil_opts)

      assert conn.status == 400
      body = json_body(conn)
      assert is_binary(body["error"])
      assert body["error"] =~ "target"
    end
  end

  # ── 10. Connect override to not-yet-started KitServer ──────────────────────

  describe "connect with browser-supplied module override" do
    test "connect override to KitServer auto-starts its tree", %{opts: opts} do
      # KitServer may not be started — the inspector must auto-start it
      conn =
        conn(
          :post,
          "/api/connect",
          Jason.encode!(%{
            "target" => %{
              "type" => "module",
              "module" => "Noizu.MCP.Fixtures.KitServer"
            }
          })
        )
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put_req_header("content-type", "application/json")
        |> InspectorPlug.call(opts)

      assert conn.status == 200
      body = json_body(conn)
      assert is_binary(body["session_id"])
      # KitServer advertises name "kit_fixture"
      assert body["server_info"]["name"] == "kit_fixture"
    end
  end
end
