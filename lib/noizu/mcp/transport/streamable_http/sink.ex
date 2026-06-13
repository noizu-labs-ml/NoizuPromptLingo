defmodule Noizu.MCP.Transport.StreamableHTTP.Sink do
  @moduledoc false
  # Server-side sink for Streamable HTTP sessions. Routes outbound messages to
  # the right HTTP response stream:
  #
  #   1. the SSE stream of the request that caused the message
  #      (`routing.related_request_id`), else
  #   2. the session's general GET stream (with an event id for resumability),
  #      else
  #   3. the EventStore buffer, delivered on the next GET (with replay).
  #
  # Conn processes register themselves in the server's Registry as
  # `{:http_stream, session_id, request_id}` / `{:http_get, session_id}` and
  # receive `{:mcp_http, binary}` / `{:mcp_http_event, event_id, binary}`.

  @behaviour Noizu.MCP.Transport.Server

  alias Noizu.MCP.Server.EventStore

  @impl true
  def send_message({server, session_id}, iodata, routing) do
    binary = IO.iodata_to_binary(iodata)
    registry = Module.concat(server, Registry)

    request_stream =
      case routing[:related_request_id] do
        nil -> []
        request_id -> Registry.lookup(registry, {:http_stream, session_id, request_id})
      end

    case request_stream do
      [{pid, _} | _] ->
        send(pid, {:mcp_http, binary})
        :ok

      [] ->
        case Registry.lookup(registry, {:http_get, session_id}) do
          [{pid, _} | _] ->
            event_id = EventStore.append(server, session_id, binary)
            send(pid, {:mcp_http_event, event_id, binary})
            :ok

          [] ->
            EventStore.append(server, session_id, binary)
            :ok
        end
    end
  end

  @impl true
  def close_session({server, session_id}) do
    registry = Module.concat(server, Registry)

    for key <- [{:http_get, session_id}],
        {pid, _} <- Registry.lookup(registry, key) do
      send(pid, :mcp_http_close)
    end

    EventStore.drop(server, session_id)
    :ok
  end
end
