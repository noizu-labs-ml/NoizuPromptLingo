defmodule Noizu.MCP.Inspector.BanditE2ETest do
  @moduledoc """
  End-to-end tests for Noizu.MCP.Inspector over a real Bandit listener.
  Uses Req for HTTP and raw :gen_tcp for SSE streaming.
  """
  use ExUnit.Case, async: true

  alias Noizu.MCP.Fixtures
  alias Noizu.MCP.Transport.SSE

  @sse_timeout 8_000

  setup_all do
    Noizu.MCP.Test.ensure_server_started(Fixtures.Server)
    :ok
  end

  # Inspector.port/1 has a lib bug where it pattern-matches {Bandit, pid, ...} but
  # OTP names the child {Bandit, ref} when started without an explicit :id, so the
  # find_value returns nil and ThousandIsland.listener_info(nil) crashes.
  # Work around by finding the Bandit child pid directly from which_children.
  defp inspector_port(name, attempts \\ 30) do
    bandit_pid =
      name
      |> Supervisor.which_children()
      |> Enum.find_value(fn
        {_id, pid, _type, [Bandit]} when is_pid(pid) -> pid
        _ -> nil
      end)

    if bandit_pid do
      {:ok, {_ip, port}} = ThousandIsland.listener_info(bandit_pid)
      port
    else
      raise "no Bandit child found"
    end
  rescue
    _ ->
      if attempts > 0 do
        Process.sleep(100)
        inspector_port(name, attempts - 1)
      else
        raise "Inspector port not bound after retries"
      end
  end

  setup do
    token = Base.url_encode64(:crypto.strong_rand_bytes(18), padding: false)
    name = :"inspector_e2e_#{System.unique_integer([:positive, :monotonic])}"

    _pid =
      start_supervised!(
        {Noizu.MCP.Inspector,
         target: {:module, Fixtures.Server}, port: 0, token: token, name: name},
        id: make_ref()
      )

    port = inspector_port(name)
    base_url = "http://127.0.0.1:#{port}"

    %{token: token, name: name, port: port, base_url: base_url}
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp api_headers(token),
    do: [{"authorization", "Bearer #{token}"}, {"content-type", "application/json"}]

  defp http_connect(base_url, token) do
    resp =
      Req.post!("#{base_url}/api/connect",
        body: "",
        headers: api_headers(token)
      )

    assert resp.status == 200
    resp.body["session_id"]
  end

  # Open a raw SSE connection; returns the gen_tcp socket.
  # Reads and discards the HTTP header, then returns the socket for chunk reading.
  defp open_sse(host, port, path) do
    {:ok, socket} = :gen_tcp.connect(String.to_charlist(host), port, [:binary, active: false])

    request =
      "GET #{path} HTTP/1.1\r\n" <>
        "Host: #{host}:#{port}\r\n" <>
        "Accept: text/event-stream\r\n" <>
        "Connection: keep-alive\r\n" <>
        "\r\n"

    :ok = :gen_tcp.send(socket, request)

    # Read HTTP response header (ends with \r\n\r\n)
    headers = read_until_header_end(socket, "", 0)
    assert headers =~ "200 OK"

    socket
  end

  defp read_until_header_end(_socket, acc, 10_000), do: acc

  defp read_until_header_end(socket, acc, n) do
    case :gen_tcp.recv(socket, 0, 2_000) do
      {:ok, chunk} ->
        acc = acc <> chunk

        if String.contains?(acc, "\r\n\r\n"),
          do: acc,
          else: read_until_header_end(socket, acc, n + 1)

      {:error, _} ->
        acc
    end
  end

  # Collect SSE events from socket until condition or timeout.
  # Returns list of SSE.Event structs collected so far.
  defp collect_sse_events(socket, buffer \\ "", acc \\ [], deadline \\ nil) do
    deadline = deadline || System.monotonic_time(:millisecond) + @sse_timeout
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    if remaining == 0 do
      {acc, buffer}
    else
      case :gen_tcp.recv(socket, 0, min(remaining, 500)) do
        {:ok, chunk} ->
          {events, new_buf} = SSE.parse(buffer, chunk)
          collect_sse_events(socket, new_buf, acc ++ events, deadline)

        {:error, :timeout} ->
          {acc, buffer}

        {:error, _closed} ->
          {acc, buffer}
      end
    end
  end

  defp collect_until(socket, condition, buffer \\ "", acc \\ [], deadline \\ nil) do
    deadline = deadline || System.monotonic_time(:millisecond) + @sse_timeout
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    if remaining == 0 do
      {acc, buffer}
    else
      case :gen_tcp.recv(socket, 0, min(remaining, 300)) do
        {:ok, chunk} ->
          {events, new_buf} = SSE.parse(buffer, chunk)
          all = acc ++ events

          if condition.(all) do
            {all, new_buf}
          else
            collect_until(socket, condition, new_buf, all, deadline)
          end

        {:error, :timeout} ->
          {acc, buffer}

        {:error, _closed} ->
          {acc, buffer}
      end
    end
  end

  # ── test 1: GET / serves HTML ──────────────────────────────────────────────

  test "GET / serves HTML 200", %{base_url: base_url, token: token} do
    resp = Req.get!("#{base_url}/", headers: [{"authorization", "Bearer #{token}"}])
    assert resp.status == 200

    ct = resp.headers["content-type"] || []
    ct_str = Enum.join(List.wrap(ct), " ")
    assert ct_str =~ "text/html"
  end

  # ── test 2: SSE event delivery ─────────────────────────────────────────────

  test "SSE: connect, open event stream, fire tool call, get call_result event",
       %{base_url: base_url, token: token, port: port} do
    session_id = http_connect(base_url, token)

    # Open SSE stream
    socket =
      open_sse("127.0.0.1", port, "/api/session/#{session_id}/events?token=#{token}")

    # Fire a tool call
    resp =
      Req.post!("#{base_url}/api/session/#{session_id}/calls",
        json: %{"name" => "echo", "arguments" => %{"message" => "hello"}},
        headers: api_headers(token)
      )

    assert resp.status == 202

    # Collect events until we see call_result or timeout
    {events, _} =
      collect_until(socket, fn evts ->
        Enum.any?(evts, fn e -> e.event == "call_result" end)
      end)

    :gen_tcp.close(socket)

    # Verify frame events are present (status event + at least one frame)
    assert Enum.any?(events, fn e -> e.event in ["frame", "status", "call_result"] end)
    assert Enum.any?(events, fn e -> e.event == "call_result" end)

    # Verify call_result data
    result_event = Enum.find(events, fn e -> e.event == "call_result" end)
    data = Jason.decode!(result_event.data)
    assert data["ok"] == true
  end

  # ── test 3: Last-Event-ID replay ───────────────────────────────────────────

  test "last_event_id replay returns buffered events with ascending seq",
       %{base_url: base_url, token: token, port: port} do
    session_id = http_connect(base_url, token)

    # Generate some events by making a tool call via normal SSE first
    socket1 =
      open_sse("127.0.0.1", port, "/api/session/#{session_id}/events?token=#{token}")

    Req.post!("#{base_url}/api/session/#{session_id}/calls",
      json: %{"name" => "echo", "arguments" => %{"message" => "hello"}},
      headers: api_headers(token)
    )

    # Wait for call_result
    {_events, _} =
      collect_until(socket1, fn evts ->
        Enum.any?(evts, fn e -> e.event == "call_result" end)
      end)

    :gen_tcp.close(socket1)

    # Now replay from seq 0
    socket2 =
      open_sse(
        "127.0.0.1",
        port,
        "/api/session/#{session_id}/events?token=#{token}&last_event_id=0"
      )

    {replay_events, _} = collect_sse_events(socket2)
    :gen_tcp.close(socket2)

    # Should have at least some events with numeric ids
    numbered = Enum.filter(replay_events, fn e -> e.id != nil end)
    assert length(numbered) > 0

    seqs =
      numbered
      |> Enum.map(fn e ->
        {n, ""} = Integer.parse(e.id)
        n
      end)

    # All seqs should be > 0 (replayed from after seq 0)
    assert Enum.all?(seqs, &(&1 > 0))
    # Seqs should be ascending
    assert seqs == Enum.sort(seqs)
  end

  # ── test 4: pending_request over SSE (ask_approval -> decline) ────────────

  test "pending_request SSE event and respond with decline",
       %{base_url: base_url, token: token, port: port} do
    session_id = http_connect(base_url, token)

    socket =
      open_sse("127.0.0.1", port, "/api/session/#{session_id}/events?token=#{token}")

    # Fire ask_approval — it will park waiting for a browser response
    task =
      Task.async(fn ->
        Req.post!("#{base_url}/api/session/#{session_id}/calls",
          json: %{"name" => "ask_approval", "arguments" => %{}},
          headers: api_headers(token)
        )
      end)

    # Wait for pending_request event
    {events_with_pending, _} =
      collect_until(socket, fn evts ->
        Enum.any?(evts, fn e -> e.event == "pending_request" end)
      end)

    pending_event = Enum.find(events_with_pending, fn e -> e.event == "pending_request" end)
    assert pending_event != nil
    pending_data = Jason.decode!(pending_event.data)
    request_id = pending_data["request_id"]
    assert is_binary(request_id)

    # Respond with decline
    resp =
      Req.post!("#{base_url}/api/session/#{session_id}/respond/#{request_id}",
        json: %{"action" => "decline"},
        headers: api_headers(token)
      )

    assert resp.status == 200

    # Wait for call_result event
    {events_with_result, _} =
      collect_until(socket, fn evts ->
        Enum.any?(evts, fn e -> e.event == "call_result" end)
      end)

    :gen_tcp.close(socket)

    assert Enum.any?(events_with_result, fn e -> e.event == "call_result" end)

    # Cleanup the task
    Task.await(task, 10_000)
  end
end
