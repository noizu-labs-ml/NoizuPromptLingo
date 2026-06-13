defmodule Noizu.MCP.Transport do
  @moduledoc """
  Transport behaviours.

  Transports are **message-level**, not socket-level: they move encoded
  JSON-RPC binaries between a session/connection process and the remote peer.

  ## Server side

  A server session holds a *sink* — `{module, term}` — and calls
  `c:Noizu.MCP.Transport.Server.send_message/3` on it for every outbound
  message. `routing.related_request_id` identifies the inbound request that
  caused the message (progress notifications, server-initiated requests made
  mid-call, and the final response), which the Streamable HTTP transport uses
  to pick the right SSE stream. stdio ignores routing.

  ## Client side

  A client connection owns a transport process implementing
  `Noizu.MCP.Transport.Client`. The transport delivers inbound traffic to its
  owner as:

      {:mcp_transport, transport_pid, {:message, binary, meta}}
      {:mcp_transport, transport_pid, {:up, info}}
      {:mcp_transport, transport_pid, {:down, reason}}
  """

  @type routing :: %{optional(:related_request_id) => Noizu.MCP.JsonRpc.id() | nil}

  defmodule Server do
    @moduledoc "Server-side transport sink behaviour. See `Noizu.MCP.Transport`."

    @callback send_message(sink :: term(), iodata(), Noizu.MCP.Transport.routing()) ::
                :ok | {:error, term()}
    @callback close_session(sink :: term()) :: :ok
  end

  defmodule Client do
    @moduledoc "Client-side transport behaviour. See `Noizu.MCP.Transport`."

    @callback start_link(owner :: pid(), opts :: keyword()) :: GenServer.on_start()
    @callback send_message(transport :: pid(), iodata(), Noizu.MCP.Transport.routing()) ::
                :ok | {:error, term()}
    @callback close(transport :: pid()) :: :ok
  end
end
