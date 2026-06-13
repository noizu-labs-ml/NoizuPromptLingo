defmodule Noizu.MCP.Server.EventStore do
  @moduledoc """
  Buffer for Streamable HTTP messages that had no live stream to deliver to,
  enabling SSE resumability via `Last-Event-ID`.

  The default implementation is a bounded per-session ETS ring buffer owned by
  the server's supervision tree (node-local — multi-node deployments need
  sticky sessions or a custom store).
  """

  use GenServer

  @max_events_per_session 1_000

  @type event_id :: String.t()

  # ── API ───────────────────────────────────────────────────────────────────

  def child_spec(opts) do
    server = Keyword.fetch!(opts, :server)
    %{id: __MODULE__, start: {__MODULE__, :start_link, [server]}}
  end

  def start_link(server) do
    GenServer.start_link(__MODULE__, server, name: name(server))
  end

  defp name(server), do: Module.concat(server, EventStore)
  defp table(server), do: Module.concat(server, EventStore.Table)

  @doc "Append a message; returns its event id."
  @spec append(module(), String.t(), binary()) :: event_id()
  def append(server, session_id, binary) do
    GenServer.call(name(server), {:append, session_id, binary})
  end

  @doc "All buffered `{event_id, binary}` for a session after `last_event_id` (nil = all)."
  @spec replay_after(module(), String.t(), event_id() | nil) :: [{event_id(), binary()}]
  def replay_after(server, session_id, last_event_id) do
    last_seq = parse_seq(last_event_id)

    table(server)
    |> :ets.lookup(session_id)
    |> Enum.map(fn {_session, seq, binary} -> {seq, binary} end)
    |> Enum.filter(fn {seq, _} -> last_seq == nil or seq > last_seq end)
    |> Enum.sort()
    |> Enum.map(fn {seq, binary} -> {encode_id(seq), binary} end)
  end

  @doc "Drop a session's buffered events (e.g. on session termination)."
  @spec drop(module(), String.t()) :: :ok
  def drop(server, session_id) do
    GenServer.call(name(server), {:drop, session_id})
  end

  @doc false
  def encode_id(seq), do: "s:#{seq}"

  @doc false
  def parse_seq(nil), do: nil

  def parse_seq("s:" <> seq) do
    case Integer.parse(seq) do
      {n, ""} -> n
      _ -> nil
    end
  end

  def parse_seq(_), do: nil

  # ── GenServer ─────────────────────────────────────────────────────────────

  @impl true
  def init(server) do
    table = :ets.new(table(server), [:bag, :named_table, :protected, read_concurrency: true])
    {:ok, %{server: server, table: table, seq: 0}}
  end

  @impl true
  def handle_call({:append, session_id, binary}, _from, state) do
    seq = state.seq + 1
    :ets.insert(state.table, {session_id, seq, binary})
    prune(state.table, session_id)
    {:reply, encode_id(seq), %{state | seq: seq}}
  end

  def handle_call({:drop, session_id}, _from, state) do
    :ets.delete(state.table, session_id)
    {:reply, :ok, state}
  end

  defp prune(table, session_id) do
    events = :ets.lookup(table, session_id)
    overflow = length(events) - @max_events_per_session

    if overflow > 0 do
      events
      |> Enum.sort_by(fn {_s, seq, _b} -> seq end)
      |> Enum.take(overflow)
      |> Enum.each(fn entry -> :ets.delete_object(table, entry) end)
    end
  end
end
