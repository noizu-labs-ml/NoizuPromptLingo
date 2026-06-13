defmodule Noizu.MCP.Inspector.Session do
  @moduledoc """
  One inspector session: owns a `Noizu.MCP.Client` connected to the target
  server (through `Noizu.MCP.Inspector.TapTransport`), buffers an event stream
  for the browser (raw frames, notifications, progress, async call results,
  pending sampling/elicitation requests), and parks server-initiated requests
  until a human answers them in the UI.

  Fast request/response operations (list/read/get_prompt/...) do not go
  through this process — the HTTP layer calls `Noizu.MCP.Client` directly via
  `client/1` so a slow call never delays event fan-out.
  """

  # :temporary — a session that fails to connect (or dies) must never be
  # auto-restarted: the browser owns its lifecycle, and a permanent restart
  # loop would exhaust the DynamicSupervisor and kill every other session.
  use GenServer, restart: :temporary
  require Logger

  alias Noizu.MCP.{Client, Error}
  alias Noizu.MCP.Inspector.{Handler, TapTransport}

  @max_events 500
  @frame_limit 64 * 1024
  @frame_preview 4 * 1024

  # ── API ────────────────────────────────────────────────────────────────────

  @doc """
  Options: `:id` (session id string), `:transport` — `{module, opts}` inner
  client transport spec, `:descriptor` — JSON-safe map describing the target
  (echoed back for display/config export), `:client_info`, `:roots`.
  """
  def start_link(opts) do
    case Keyword.fetch(opts, :name) do
      {:ok, name} -> GenServer.start_link(__MODULE__, opts, name: name)
      :error -> GenServer.start_link(__MODULE__, opts)
    end
  end

  @doc "The underlying `Noizu.MCP.Client` pid (for direct feature calls)."
  def client(session), do: GenServer.call(session, :client)

  @doc "Server info / capabilities / instructions / target descriptor."
  def info(session), do: GenServer.call(session, :info, 30_000)

  @doc "Start an async tool call; result arrives as a `call_result` event."
  def call_tool(session, name, args), do: GenServer.call(session, {:call_tool, name, args})

  @doc "Cancel an in-flight tool call."
  def cancel_call(session, call_id), do: GenServer.call(session, {:cancel_call, call_id})

  @doc "Answer a parked sampling/elicitation request."
  def respond_pending(session, request_id, response),
    do: GenServer.call(session, {:respond_pending, request_id, response})

  @doc """
  Subscribe the caller to session events (`{:inspector_event, event}` messages,
  where event is `%{seq: n, event: type, data: map}`). Returns events with
  `seq > last_seq` for replay. The subscriber is monitored.
  """
  def subscribe_events(session, last_seq \\ nil),
    do: GenServer.call(session, {:subscribe, self(), last_seq})

  def get_roots(session), do: GenServer.call(session, :get_roots)
  def set_roots(session, roots), do: GenServer.call(session, {:set_roots, roots})

  @doc "Block until the session reaches `:ready` (or error)."
  def await_ready(session, timeout \\ 15_000),
    do: GenServer.call(session, :await_ready, timeout)

  @doc "Block until the parked sampling/elicitation request map is non-empty or timeout."
  def pending(session), do: GenServer.call(session, :pending)

  # Called from Handler tasks; blocks until the browser responds.
  @doc false
  def park_pending(session, kind, params),
    do: GenServer.call(session, {:park_pending, kind, params}, :infinity)

  # ── GenServer ──────────────────────────────────────────────────────────────

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)
    inner = Keyword.fetch!(opts, :transport)

    client_opts = [
      transport: {TapTransport, inner: inner, tap: self()},
      handler: {Handler, self()},
      on_notification: self(),
      client_info:
        Keyword.get(opts, :client_info, %{
          name: "noizu-mcp-inspector",
          version: to_string(Application.spec(:noizu_mcp, :vsn) || "0.0.0")
        })
    ]

    case Client.start_link(client_opts) do
      {:ok, client} ->
        state = %{
          id: Keyword.fetch!(opts, :id),
          client: client,
          descriptor: Keyword.get(opts, :descriptor, %{}),
          seq: 0,
          events: [],
          subscribers: %{},
          pending: %{},
          calls: %{},
          awaiters: %{},
          roots: Keyword.get(opts, :roots, []),
          status: :connecting,
          ready_waiters: []
        }

        {:ok, state, {:continue, :await_ready}}

      {:error, reason} ->
        {:stop, {:connect_failed, reason}}
    end
  end

  @impl true
  def handle_continue(:await_ready, state) do
    # Non-blocking: spawn a task that waits for the Client handshake and
    # reports back. This keeps the GenServer responsive to info/1, subscribe,
    # etc. while the connection is still in progress.
    client = state.client
    session = self()

    spawn_link(fn ->
      result =
        try do
          Client.await_ready(client, 30_000)
        catch
          :exit, reason -> {:error, reason}
        end

      send(session, {:connect_result, result})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call(:await_ready, from, %{status: :connecting} = state) do
    {:noreply, %{state | ready_waiters: [from | Map.get(state, :ready_waiters, [])]}}
  end

  def handle_call(:await_ready, _from, %{status: :ready} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:await_ready, _from, state) do
    {:reply, {:error, state.status}, state}
  end

  def handle_call(:client, _from, state), do: {:reply, state.client, state}

  def handle_call(:info, _from, %{status: :connecting} = state) do
    # The handshake task may have already finished (in-process targets are
    # instant) but the :connect_result message hasn't been processed yet.
    # Drain it first so the initial connect response includes server info.
    state = drain_connect_result(state)

    {:reply, {:ok, build_info(state)}, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, {:ok, build_info(state)}, state}
  end

  def handle_call({:call_tool, name, args}, _from, state) do
    session = self()
    params = %{"name" => name, "arguments" => args || %{}}

    progress = fn progress_params ->
      send(session, {:call_progress, name, progress_params})
    end

    case Client.async(state.client, "tools/call", params, timeout: :infinity, progress: progress) do
      {:ok, call_id} ->
        client = state.client
        {_pid, ref} = spawn_monitor(fn -> awaiter(session, client, call_id) end)

        state = %{
          state
          | calls: Map.put(state.calls, call_id, %{name: name}),
            awaiters: Map.put(state.awaiters, ref, call_id)
        }

        {:reply, {:ok, call_id}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:cancel_call, call_id}, _from, state) do
    if Map.has_key?(state.calls, call_id) do
      Client.cancel(state.client, call_id, "cancelled from inspector")
      {:reply, :ok, state}
    else
      {:reply, {:error, :unknown_call}, state}
    end
  end

  def handle_call({:park_pending, kind, params}, from, state) do
    request_id = "pr-#{state.seq + 1}-#{System.unique_integer([:positive])}"
    pending = Map.put(state.pending, request_id, %{from: from, kind: kind})

    data = %{
      "request_id" => request_id,
      "kind" => to_string(kind),
      "params" => json_safe(params)
    }

    {:noreply, emit(%{state | pending: pending}, "pending_request", data)}
  end

  def handle_call({:respond_pending, request_id, response}, _from, state) do
    case Map.fetch(state.pending, request_id) do
      :error ->
        {:reply, {:error, :unknown_request}, state}

      {:ok, %{from: from, kind: kind}} ->
        case normalize_response(kind, response) do
          {:ok, reply} ->
            GenServer.reply(from, reply)
            state = %{state | pending: Map.delete(state.pending, request_id)}
            {:reply, :ok, emit(state, "pending_resolved", %{"request_id" => request_id})}

          :error ->
            {:reply, {:error, :bad_response}, state}
        end
    end
  end

  def handle_call({:subscribe, pid, last_seq}, _from, state) do
    ref = Process.monitor(pid)
    state = %{state | subscribers: Map.put(state.subscribers, pid, ref)}

    replay =
      state.events
      |> Enum.take_while(fn event -> last_seq == nil or event.seq > last_seq end)
      |> Enum.reverse()

    {:reply, {:ok, replay}, state}
  end

  def handle_call(:get_roots, _from, state), do: {:reply, state.roots, state}

  def handle_call({:set_roots, roots}, _from, state) do
    state = %{state | roots: roots}
    Client.set_roots(state.client, roots)
    {:reply, :ok, state}
  end

  def handle_call(:pending, _from, state) do
    pending =
      Enum.map(state.pending, fn {request_id, %{kind: kind}} ->
        %{"request_id" => request_id, "kind" => to_string(kind)}
      end)

    {:reply, {:ok, pending}, state}
  end

  @impl true
  def handle_info({:connect_result, :ok}, state) do
    for waiter <- Map.get(state, :ready_waiters, []), do: GenServer.reply(waiter, :ok)
    state = state |> Map.put(:ready_waiters, []) |> Map.put(:status, :ready)
    {:noreply, emit(state, "status", %{"state" => "ready"})}
  end

  def handle_info({:connect_result, {:error, reason}}, state) do
    for waiter <- Map.get(state, :ready_waiters, []),
        do: GenServer.reply(waiter, {:error, reason})

    state =
      state
      |> Map.put(:ready_waiters, [])
      |> Map.put(:status, :closed)
      |> emit("status", %{
        "state" => "error",
        "error" => connect_error_message(reason)
      })

    {:stop, {:shutdown, {:connect_failed, reason}}, state}
  end

  def handle_info({:inspector_frame, dir, binary}, state) do
    message =
      cond do
        byte_size(binary) > @frame_limit ->
          %{
            "truncated" => true,
            "size" => byte_size(binary),
            "preview" => String.slice(binary, 0, @frame_preview)
          }

        true ->
          case Jason.decode(binary) do
            {:ok, decoded} -> decoded
            {:error, _} -> %{"raw" => binary}
          end
      end

    {:noreply, emit(state, "frame", %{"dir" => to_string(dir), "message" => message})}
  end

  def handle_info({:mcp_notification, "notifications/progress", _params}, state) do
    # Per-call progress is emitted via the progress callback with call context;
    # the raw frame log still carries any unmatched progress traffic.
    {:noreply, state}
  end

  def handle_info({:mcp_notification, method, params}, state) do
    {:noreply, emit(state, "notification", %{"method" => method, "params" => json_safe(params)})}
  end

  def handle_info({:call_progress, name, params}, state) do
    params = json_safe(params) || %{}
    call_id = call_id_for_token(params["progressToken"])

    data = %{"call_id" => call_id, "name" => name, "params" => params}
    {:noreply, emit(state, "progress", data)}
  end

  def handle_info({:call_finished, call_id, result}, state) do
    data =
      case result do
        {:ok, result_map} ->
          %{"call_id" => call_id, "ok" => true, "result" => json_safe(result_map)}

        {:error, reason} ->
          %{"call_id" => call_id, "ok" => false, "error" => error_json(reason)}
      end

    state = %{state | calls: Map.delete(state.calls, call_id)}
    {:noreply, emit(state, "call_result", data)}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    cond do
      Map.has_key?(state.awaiters, ref) ->
        {call_id, awaiters} = Map.pop(state.awaiters, ref)
        state = %{state | awaiters: awaiters}

        if reason == :normal or not Map.has_key?(state.calls, call_id) do
          {:noreply, state}
        else
          state = %{state | calls: Map.delete(state.calls, call_id)}

          data = %{"call_id" => call_id, "ok" => false, "error" => error_json(reason)}
          {:noreply, emit(state, "call_result", data)}
        end

      Map.has_key?(state.subscribers, pid) ->
        {:noreply, %{state | subscribers: Map.delete(state.subscribers, pid)}}

      true ->
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, pid, reason}, %{client: pid} = state) do
    state =
      emit(%{state | status: :closed}, "status", %{
        "state" => "closed",
        "reason" => error_json(reason)
      })

    {:stop, {:shutdown, {:client_down, reason}}, state}
  end

  def handle_info(_other, state), do: {:noreply, state}

  defp awaiter(session, client, call_id) do
    result = Client.await(client, call_id, :infinity)
    send(session, {:call_finished, call_id, result})
  end

  # The client derives progress tokens as "pt-<request id>"; the request id is
  # also our call id (see Noizu.MCP.Client.async/4).
  defp call_id_for_token("pt-" <> id) do
    case Integer.parse(id) do
      {call_id, ""} -> call_id
      _ -> nil
    end
  end

  defp call_id_for_token(_), do: nil

  # ── events ─────────────────────────────────────────────────────────────────

  defp emit(state, type, data) do
    seq = state.seq + 1
    event = %{seq: seq, event: type, data: data}

    for {pid, _ref} <- state.subscribers, do: send(pid, {:inspector_event, event})

    %{state | seq: seq, events: Enum.take([event | state.events], @max_events)}
  end

  # ── normalization ──────────────────────────────────────────────────────────

  defp normalize_response(:sampling, %{"result" => %{} = result}), do: {:ok, {:ok, result}}
  defp normalize_response(:sampling, %{"error" => error}), do: {:ok, {:error, to_string(error)}}

  defp normalize_response(:elicitation, %{"action" => "accept"} = response),
    do: {:ok, {:ok, :accept, response["content"] || %{}}}

  defp normalize_response(:elicitation, %{"action" => "decline"}), do: {:ok, {:ok, :decline}}
  defp normalize_response(:elicitation, %{"action" => "cancel"}), do: {:ok, {:ok, :cancel}}
  defp normalize_response(_kind, _response), do: :error

  defp server_info_map(nil), do: nil
  defp server_info_map(info), do: Noizu.MCP.Types.Implementation.to_map(info)

  defp build_info(state) do
    %{
      "session_id" => state.id,
      "status" => to_string(state.status),
      "target" => state.descriptor,
      "server_info" => server_info_map(Client.server_info(state.client)),
      "capabilities" => json_safe(Client.server_capabilities(state.client)),
      "instructions" => Client.instructions(state.client),
      "roots" => state.roots
    }
  end

  defp drain_connect_result(state) do
    receive do
      {:connect_result, :ok} ->
        for w <- Map.get(state, :ready_waiters, []), do: GenServer.reply(w, :ok)

        state
        |> Map.put(:ready_waiters, [])
        |> Map.put(:status, :ready)
        |> emit("status", %{"state" => "ready"})

      {:connect_result, {:error, _reason}} ->
        state
    after
      100 -> state
    end
  end

  defp connect_error_message({:timeout, {GenServer, :call, [_pid, :await_ready, _timeout]}}),
    do:
      "Connection timed out — the server did not complete the MCP handshake. " <>
        "If this is an SSE-transport server, note that noizu_mcp speaks " <>
        "Streamable HTTP (2025-06-18+), not the legacy SSE transport."

  defp connect_error_message({:shutdown, {:transport_down, reason}}),
    do: "Transport error: #{inspect(reason)}"

  defp connect_error_message({:noproc, _}), do: "Server process not found"
  defp connect_error_message(reason), do: inspect(reason)

  defp error_json(%Error{} = error),
    do: %{"code" => error.code, "message" => error.message, "data" => json_safe(error.data)}

  defp error_json(:timeout), do: %{"message" => "timeout"}
  defp error_json(:cancelled), do: %{"message" => "cancelled"}
  defp error_json(reason) when is_binary(reason), do: %{"message" => reason}
  defp error_json(reason), do: %{"message" => inspect(reason)}

  defp json_safe(nil), do: nil
  defp json_safe(%_{} = struct), do: struct |> Map.from_struct() |> json_safe()

  defp json_safe(%{} = map) do
    map
    |> Enum.reject(fn {_key, value} -> value == nil end)
    |> Map.new(fn {key, value} -> {key, json_safe(value)} end)
  end

  defp json_safe(list) when is_list(list), do: Enum.map(list, &json_safe/1)
  defp json_safe(tuple) when is_tuple(tuple), do: tuple |> Tuple.to_list() |> json_safe()
  defp json_safe(other), do: other
end
