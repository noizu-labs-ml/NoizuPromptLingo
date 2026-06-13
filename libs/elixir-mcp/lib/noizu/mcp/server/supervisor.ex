defmodule Noizu.MCP.Server.Supervisor do
  @moduledoc """
  Supervision tree for one logical MCP server: a session registry, a dynamic
  supervisor for per-client sessions, a task supervisor for handler execution,
  and (when `transport: :stdio`) the stdio transport with its single implicit
  session.

  Started for you by `use Noizu.MCP.Server` — add the server module to your
  application's supervision tree:

      children = [{MyApp.MCP, transport: :stdio}]
  """

  use Supervisor

  @doc false
  def start_link(server, opts \\ []) do
    Supervisor.start_link(__MODULE__, {server, opts}, name: server)
  end

  @impl true
  def init({server, opts}) do
    children =
      [
        {Registry, keys: :unique, name: Module.concat(server, Registry)},
        {Task.Supervisor, name: Module.concat(server, TaskSupervisor)},
        {DynamicSupervisor,
         name: Module.concat(server, SessionSupervisor), strategy: :one_for_one},
        {Noizu.MCP.Server.EventStore, server: server}
      ] ++ transport_children(server, opts)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp transport_children(server, opts) do
    case Keyword.get(opts, :transport) do
      nil ->
        []

      :stdio ->
        [{Noizu.MCP.Transport.Stdio, Keyword.put(opts, :server, server)}]

      other ->
        raise ArgumentError, "unknown MCP server transport: #{inspect(other)}"
    end
  end

  @doc """
  Start a new session for `server`. Used by transports; `opts` must include
  `:sink` and may include `:session_id` and `:transport`.
  """
  @spec start_session(module(), keyword()) :: DynamicSupervisor.on_start_child()
  def start_session(server, opts) do
    DynamicSupervisor.start_child(
      Module.concat(server, SessionSupervisor),
      {Noizu.MCP.Server.Session, Keyword.put(opts, :server, server)}
    )
  end

  @doc "List the pids of all live sessions for `server`."
  @spec sessions(module()) :: [pid()]
  def sessions(server) do
    Registry.select(Module.concat(server, Registry), [
      {{{:session, :_}, :"$1", :_}, [], [:"$1"]}
    ])
  end
end
