defmodule Noizu.MCP.Inspector.SessionTest do
  @moduledoc """
  Integration tests for Noizu.MCP.Inspector.Session, TapTransport, and the
  Inspector.resolve_target/1 helpers.
  """
  use ExUnit.Case, async: true

  alias Noizu.MCP.Inspector
  alias Noizu.MCP.Inspector.Session
  alias Noizu.MCP.Client
  alias Noizu.MCP.Fixtures

  # ── helpers ────────────────────────────────────────────────────────────────

  defp start_session(opts \\ []) do
    :ok = Noizu.MCP.Test.ensure_server_started(Fixtures.Server)

    server = Keyword.get(opts, :server, Fixtures.Server)
    {:ok, transport, _desc} = Inspector.resolve_target({:module, server})

    id = "test-#{System.unique_integer([:positive])}"
    extra = Keyword.drop(opts, [:server])

    session =
      start_supervised!(
        {Session, [id: id, transport: transport] ++ extra},
        id: make_ref()
      )

    {:ok, _replay} = Session.subscribe_events(session)
    :ok = Session.await_ready(session)
    session
  end

  # Drain the mailbox looking for an inspector_event whose `:event` field
  # equals `type` AND for which `matcher.(event)` returns true.
  # Skips non-matching events; raises on timeout.
  defp assert_event(type, matcher \\ fn _ -> true end, timeout \\ 2_000) do
    deadline = System.monotonic_time(:millisecond) + timeout
    do_assert_event(type, matcher, deadline)
  end

  defp do_assert_event(type, matcher, deadline) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining <= 0 do
      flunk("Timed out waiting for inspector_event type=#{inspect(type)}")
    end

    receive do
      {:inspector_event, %{event: ^type} = event} ->
        if matcher.(event) do
          event
        else
          do_assert_event(type, matcher, deadline)
        end

      {:inspector_event, _other} ->
        do_assert_event(type, matcher, deadline)
    after
      remaining ->
        flunk("Timed out waiting for inspector_event type=#{inspect(type)}")
    end
  end

  # ── 1. connect + info ─────────────────────────────────────────────────────

  describe "connect and info" do
    test "Session.info returns ready status with server details" do
      session = start_session()
      {:ok, info} = Session.info(session)

      assert info["status"] == "ready"

      # server_info is json_safe'd from Implementation struct → atom keys
      server_info = info["server_info"]
      assert is_map(server_info)
      name = server_info["name"] || server_info[:name]
      assert name == "fixture"

      assert is_map(info["capabilities"])
      assert is_binary(info["instructions"])
    end
  end

  # ── 2. direct client feature calls ────────────────────────────────────────

  describe "client feature calls" do
    test "list_tools returns expected tools" do
      session = start_session()
      client = Session.client(session)

      assert {:ok, tools} = Client.list_tools(client)
      tool_names = Enum.map(tools, & &1.name)
      assert "echo" in tool_names
      assert "get_weather" in tool_names
      assert "slow" in tool_names
    end

    test "list_resources returns expected resources" do
      session = start_session()
      client = Session.client(session)

      assert {:ok, resources} = Client.list_resources(client)
      uris = Enum.map(resources, & &1.uri)
      assert "config://app" in uris
    end

    test "list_prompts returns expected prompts" do
      session = start_session()
      client = Session.client(session)

      assert {:ok, prompts} = Client.list_prompts(client)
      names = Enum.map(prompts, & &1.name)
      assert "code_review" in names
      assert "dynamic" in names
    end
  end

  # ── 3. call_tool echo ─────────────────────────────────────────────────────

  describe "call_tool" do
    test "echo returns call_result with echoed text" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "echo", %{"message" => "hi"})

      event =
        assert_event("call_result", fn %{data: data} ->
          data["call_id"] == call_id
        end)

      assert event.data["ok"] == true
      assert event.data["call_id"] == call_id

      # result contains content with echoed text
      result = event.data["result"]
      content = result["content"] || []
      assert Enum.any?(content, fn item -> item["text"] =~ "hi" end)
    end
  end

  # ── 4. frames ─────────────────────────────────────────────────────────────

  describe "frames" do
    test "tx and rx frame events are emitted for each call" do
      session = start_session()
      {:ok, _call_id} = Session.call_tool(session, "echo", %{"message" => "frame_test"})

      # Expect at least one tx frame containing tools/call
      assert_event("frame", fn %{data: data} ->
        data["dir"] == "tx" and
          get_in(data, ["message", "method"]) == "tools/call"
      end)

      # Expect at least one rx frame (response)
      assert_event("frame", fn %{data: data} ->
        data["dir"] == "rx" and is_map(data["message"])
      end)
    end
  end

  # ── 5. progress ───────────────────────────────────────────────────────────

  describe "progress events" do
    test "weather tool emits progress events before call_result" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "get_weather", %{"location" => "NYC"})

      # Progress must arrive before call_result
      progress_event =
        assert_event("progress", fn %{data: data} ->
          data["call_id"] == call_id
        end)

      assert progress_event.data["name"] == "get_weather"

      # call_result still arrives
      result_event =
        assert_event("call_result", fn %{data: data} ->
          data["call_id"] == call_id
        end)

      assert result_event.data["ok"] == true
      assert progress_event.seq < result_event.seq
    end
  end

  # ── 6. cancel ─────────────────────────────────────────────────────────────

  describe "cancel" do
    test "cancelling a slow tool yields call_result with ok=false" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "slow", %{"ms" => 30_000})
      :ok = Session.cancel_call(session, call_id)

      event =
        assert_event(
          "call_result",
          fn %{data: data} -> data["call_id"] == call_id end,
          3_000
        )

      assert event.data["ok"] == false
      error_msg = get_in(event.data, ["error", "message"]) || ""
      assert error_msg =~ ~r/cancel/i
    end

    test "cancel_call with unknown id returns error" do
      session = start_session()
      assert {:error, :unknown_call} = Session.cancel_call(session, 999_999)
    end
  end

  # ── 7. error shapes ───────────────────────────────────────────────────────

  describe "error shapes" do
    test "fail tool returns isError result (execution error surfaced as tool error)" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "fail", %{})

      event =
        assert_event("call_result", fn %{data: data} ->
          data["call_id"] == call_id
        end)

      # fail/0 returns {:error, "..."} — the Tools feature wraps this as
      # an isError=true content result (MCP execution error convention), so
      # ok=true at the transport level but isError in the result body.
      # If the implementation surfaces it differently, we accept ok=false too.
      cond do
        event.data["ok"] == true ->
          result = event.data["result"]
          assert result["isError"] == true

        event.data["ok"] == false ->
          assert is_map(event.data["error"])

        true ->
          flunk("Expected ok=true with isError or ok=false, got: #{inspect(event.data)}")
      end
    end

    test "crash tool returns call_result with ok=false or isError" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "crash", %{})

      event =
        assert_event("call_result", fn %{data: data} ->
          data["call_id"] == call_id
        end)

      # crash raises inside the tool; should surface as error
      cond do
        event.data["ok"] == false ->
          assert is_map(event.data["error"])

        event.data["ok"] == true ->
          assert get_in(event.data, ["result", "isError"]) == true

        true ->
          flunk("Expected error result for crash tool, got: #{inspect(event.data)}")
      end
    end
  end

  # ── 8. elicitation round-trip ─────────────────────────────────────────────

  describe "elicitation" do
    test "accept path: pending_request + respond_pending + pending_resolved + call_result" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "ask_approval", %{})

      pending_event =
        assert_event(
          "pending_request",
          fn %{data: data} ->
            data["kind"] == "elicitation"
          end,
          3_000
        )

      request_id = pending_event.data["request_id"]
      assert is_binary(request_id)

      :ok =
        Session.respond_pending(session, request_id, %{
          "action" => "accept",
          "content" => %{"confirm" => true}
        })

      assert_event("pending_resolved", fn %{data: data} ->
        data["request_id"] == request_id
      end)

      result_event =
        assert_event(
          "call_result",
          fn %{data: data} ->
            data["call_id"] == call_id
          end,
          3_000
        )

      assert result_event.data["ok"] == true
      content = get_in(result_event.data, ["result", "content"]) || []
      assert Enum.any?(content, fn item -> item["text"] == "approved" end)
    end

    test "decline path: session responds decline, tool sees :decline" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "ask_approval", %{})

      pending_event =
        assert_event(
          "pending_request",
          fn %{data: data} ->
            data["kind"] == "elicitation"
          end,
          3_000
        )

      request_id = pending_event.data["request_id"]

      :ok = Session.respond_pending(session, request_id, %{"action" => "decline"})

      assert_event("pending_resolved", fn %{data: data} ->
        data["request_id"] == request_id
      end)

      result_event =
        assert_event(
          "call_result",
          fn %{data: data} ->
            data["call_id"] == call_id
          end,
          3_000
        )

      assert result_event.data["ok"] == true
      content = get_in(result_event.data, ["result", "content"]) || []
      assert Enum.any?(content, fn item -> item["text"] == "declined" end)
    end
  end

  # ── 9. sampling round-trip ────────────────────────────────────────────────

  describe "sampling" do
    test "consult tool: pending_request kind sampling, respond with result, call_result has reply" do
      session = start_session()

      {:ok, call_id} = Session.call_tool(session, "consult", %{"question" => "meaning of life?"})

      pending_event =
        assert_event(
          "pending_request",
          fn %{data: data} ->
            data["kind"] == "sampling"
          end,
          3_000
        )

      request_id = pending_event.data["request_id"]

      :ok =
        Session.respond_pending(session, request_id, %{
          "result" => %{
            "role" => "assistant",
            "content" => %{"type" => "text", "text" => "42"},
            "model" => "test"
          }
        })

      assert_event("pending_resolved", fn %{data: data} ->
        data["request_id"] == request_id
      end)

      result_event =
        assert_event(
          "call_result",
          fn %{data: data} ->
            data["call_id"] == call_id
          end,
          3_000
        )

      assert result_event.data["ok"] == true
      content = get_in(result_event.data, ["result", "content"]) || []
      assert Enum.any?(content, fn item -> String.contains?(item["text"] || "", "42") end)
    end
  end

  # ── 10. roots ─────────────────────────────────────────────────────────────

  describe "roots" do
    test "set_roots + where_am_i returns the configured root" do
      session = start_session()

      :ok = Session.set_roots(session, [%{"uri" => "file:///tmp", "name" => "tmp"}])

      {:ok, call_id} = Session.call_tool(session, "where_am_i", %{})

      result_event =
        assert_event(
          "call_result",
          fn %{data: data} ->
            data["call_id"] == call_id
          end,
          3_000
        )

      assert result_event.data["ok"] == true
      content = get_in(result_event.data, ["result", "content"]) || []

      assert Enum.any?(content, fn item -> String.contains?(item["text"] || "", "file:///tmp") end)
    end
  end

  # ── 11. respond_pending error cases ───────────────────────────────────────

  describe "respond_pending errors" do
    test "unknown request_id returns {:error, :unknown_request}" do
      session = start_session()

      assert {:error, :unknown_request} =
               Session.respond_pending(session, "nonexistent", %{"action" => "accept"})
    end

    test "bad response shape for sampling returns {:error, :bad_response}" do
      session = start_session()

      {:ok, _call_id} = Session.call_tool(session, "consult", %{"question" => "?"})

      pending_event =
        assert_event(
          "pending_request",
          fn %{data: data} ->
            data["kind"] == "sampling"
          end,
          3_000
        )

      request_id = pending_event.data["request_id"]

      # A response with no "result" or "error" key is a bad shape for sampling
      assert {:error, :bad_response} =
               Session.respond_pending(session, request_id, %{"garbage" => true})

      # Clean up by sending a valid response so the tool task doesn't linger
      Session.respond_pending(session, request_id, %{
        "result" => %{
          "role" => "assistant",
          "content" => %{"type" => "text", "text" => "cleanup"},
          "model" => "test"
        }
      })
    end
  end

  # ── 12. replay ────────────────────────────────────────────────────────────

  describe "subscribe_events replay" do
    test "nil last_seq returns all events in ascending seq order" do
      session = start_session()

      # generate some activity
      {:ok, cid} = Session.call_tool(session, "echo", %{"message" => "replay_test"})
      assert_event("call_result", fn %{data: d} -> d["call_id"] == cid end)

      {:ok, replay} = Session.subscribe_events(session, nil)
      assert is_list(replay)
      assert length(replay) > 0

      seqs = Enum.map(replay, & &1.seq)
      assert seqs == Enum.sort(seqs)
    end

    test "last_seq filter returns only events with seq > last_seq" do
      session = start_session()

      {:ok, cid1} = Session.call_tool(session, "echo", %{"message" => "first"})
      assert_event("call_result", fn %{data: d} -> d["call_id"] == cid1 end)

      {:ok, mid_replay} = Session.subscribe_events(session, nil)
      mid_seq = Enum.map(mid_replay, & &1.seq) |> Enum.max()

      {:ok, cid2} = Session.call_tool(session, "echo", %{"message" => "second"})
      assert_event("call_result", fn %{data: d} -> d["call_id"] == cid2 end)

      {:ok, later_replay} = Session.subscribe_events(session, mid_seq)
      assert is_list(later_replay)
      assert Enum.all?(later_replay, fn e -> e.seq > mid_seq end)
      assert length(later_replay) > 0
    end
  end

  # ── 13. resolve_target ────────────────────────────────────────────────────

  describe "resolve_target" do
    test "{:module, NotAServer} returns error" do
      assert {:error, _} = Inspector.resolve_target({:module, String})
    end

    test "{:module, Fixtures.Server} resolves successfully" do
      :ok = Noizu.MCP.Test.ensure_server_started(Fixtures.Server)
      assert {:ok, {_mod, _opts}, desc} = Inspector.resolve_target({:module, Fixtures.Server})
      assert desc["type"] == "module"
    end

    test "map descriptor with module string resolves" do
      :ok = Noizu.MCP.Test.ensure_server_started(Fixtures.Server)

      assert {:ok, _transport, desc} =
               Inspector.resolve_target(%{
                 "type" => "module",
                 "module" => "Noizu.MCP.Fixtures.Server"
               })

      assert desc["type"] == "module"
    end

    test "map descriptor with unknown module string returns error" do
      assert {:error, _} =
               Inspector.resolve_target(%{
                 "type" => "module",
                 "module" => "DoesNotExist.AtAll"
               })
    end

    test "map descriptor with url type resolves when StreamableHTTP client is loaded" do
      result = Inspector.resolve_target(%{"type" => "url", "url" => "http://localhost:8080"})

      case Code.ensure_loaded(Noizu.MCP.Transport.StreamableHTTP.Client) do
        {:module, _} ->
          assert {:ok, _transport, desc} = result
          assert desc["type"] == "url"

        {:error, _} ->
          assert {:error, :req_not_available} = result
      end
    end

    test "invalid target returns error" do
      assert {:error, {:invalid_target, _}} = Inspector.resolve_target(:not_valid)
      assert {:error, {:invalid_target, _}} = Inspector.resolve_target(%{"type" => "unknown"})
    end
  end
end
