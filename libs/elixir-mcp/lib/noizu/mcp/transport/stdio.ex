defmodule Noizu.MCP.Transport.Stdio do
  @moduledoc """
  stdio server transport: newline-delimited JSON-RPC on stdin/stdout.

  Started automatically by the server supervisor when `transport: :stdio`.
  Creates the single implicit session, reads stdin line-by-line, and **owns
  stdout exclusively** for protocol traffic.

  > #### Logging and stdout {: .warning}
  >
  > Anything written to stdout that is not a JSON-RPC message corrupts the
  > stream and breaks the server in MCP clients. This transport reconfigures
  > the default `Logger` handler to write to **stderr** at startup. Avoid
  > `IO.puts/1` (and anything else that writes to stdout) in handler code; to
  > pin the behavior explicitly, configure:
  >
  >     config :logger, :default_handler, config: [type: :standard_error]
  """

  use GenServer
  require Logger

  @behaviour Noizu.MCP.Transport.Server

  # ── Transport.Server sink ─────────────────────────────────────────────────

  @impl Noizu.MCP.Transport.Server
  def send_message(:stdio, iodata, _routing) do
    # One binwrite is a single io-protocol request, so concurrent writers
    # cannot interleave within a message.
    IO.binwrite(:stdio, [iodata, ?\n])
  end

  @impl Noizu.MCP.Transport.Server
  def close_session(:stdio), do: :ok

  # ── Process ───────────────────────────────────────────────────────────────

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(opts) do
    # :transient — exiting :normal on stdin EOF must not trigger a restart.
    %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}, restart: :transient}
  end

  @impl GenServer
  def init(opts) do
    server = Keyword.fetch!(opts, :server)
    divert_logger_to_stderr()

    {:ok, session} =
      Noizu.MCP.Server.Supervisor.start_session(server,
        sink: {__MODULE__, :stdio},
        transport: :stdio,
        session_id: "stdio"
      )

    parent = self()
    reader = spawn_link(fn -> read_loop(parent) end)

    {:ok,
     %{
       server: server,
       session: session,
       reader: reader,
       on_eof: Keyword.get(opts, :on_eof, :system_stop)
     }}
  end

  @impl GenServer
  def handle_info({:stdio_line, line}, state) do
    Noizu.MCP.Server.Session.deliver(state.session, line)
    {:noreply, state}
  end

  def handle_info(:stdio_eof, state) do
    Logger.info("MCP stdio transport: stdin closed, shutting down")

    case state.on_eof do
      :system_stop -> System.stop(0)
      :noop -> :ok
    end

    {:stop, :normal, state}
  end

  def handle_info({:stdio_error, reason}, state) do
    Logger.error("MCP stdio transport: read error #{inspect(reason)}")
    {:stop, {:shutdown, {:stdio_error, reason}}, state}
  end

  defp read_loop(parent) do
    case IO.binread(:stdio, :line) do
      :eof ->
        send(parent, :stdio_eof)

      {:error, reason} ->
        send(parent, {:stdio_error, reason})

      line when is_binary(line) ->
        case String.trim(line) do
          "" -> :ok
          trimmed -> send(parent, {:stdio_line, trimmed})
        end

        read_loop(parent)
    end
  end

  defp divert_logger_to_stderr do
    case :logger.get_handler_config(:default) do
      {:ok, %{config: %{type: type}} = handler_config} when type != :standard_error ->
        # logger_std_h does not allow changing :type on a live handler, so
        # replace the handler wholesale, keeping its other settings.
        module = Map.get(handler_config, :module, :logger_std_h)

        replacement =
          handler_config
          |> Map.drop([:id, :module])
          |> Map.update!(:config, fn config ->
            config
            |> Map.put(:type, :standard_error)
            # File/device state from the old handler must not leak in.
            |> Map.drop([:file, :modes])
          end)

        with :ok <- :logger.remove_handler(:default),
             :ok <- :logger.add_handler(:default, module, replacement) do
          Logger.warning(
            "MCP stdio transport diverted the default Logger handler to stderr " <>
              "(stdout is reserved for protocol traffic)"
          )
        else
          error ->
            IO.write(
              :stderr,
              "noizu_mcp: could not divert default Logger handler to stderr " <>
                "(#{inspect(error)}); configure it manually: " <>
                "config :logger, :default_handler, config: [type: :standard_error]\n"
            )
        end

      _ ->
        :ok
    end
  end
end
