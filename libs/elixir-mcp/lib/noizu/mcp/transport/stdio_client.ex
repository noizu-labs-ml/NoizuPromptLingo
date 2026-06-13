defmodule Noizu.MCP.Transport.Stdio.Client do
  @moduledoc """
  stdio client transport: spawns an MCP server as a subprocess and speaks
  newline-delimited JSON-RPC over its stdin/stdout.

      {Noizu.MCP.Client,
       transport: {:stdio, command: "npx", args: ["-y", "@modelcontextprotocol/server-everything"]}}

  Options: `:command` (required), `:args`, `:cd`, `:env` (map or keyword of
  string pairs).

  > Erlang ports cannot half-close stdin, so shutdown is `Port.close/1`
  > followed by a best-effort SIGTERM to the OS pid. Subprocess stderr is
  > inherited (passes through to the BEAM's stderr).
  """

  use GenServer

  @behaviour Noizu.MCP.Transport.Client

  @impl Noizu.MCP.Transport.Client
  def start_link(owner, opts) do
    GenServer.start_link(__MODULE__, {owner, opts})
  end

  @impl Noizu.MCP.Transport.Client
  def send_message(transport, iodata, _routing) do
    GenServer.call(transport, {:send, iodata})
  end

  @impl Noizu.MCP.Transport.Client
  def close(transport), do: GenServer.stop(transport, :normal)

  @impl GenServer
  def init({owner, opts}) do
    command = Keyword.fetch!(opts, :command)

    executable =
      System.find_executable(command) ||
        raise ArgumentError, "MCP stdio client: executable not found: #{command}"

    port_opts =
      [
        :binary,
        :exit_status,
        :hide,
        {:line, 1_048_576},
        {:args, Keyword.get(opts, :args, [])}
      ]
      |> maybe_add(:cd, opts[:cd] && String.to_charlist(opts[:cd]))
      |> maybe_add(:env, opts[:env] && encode_env(opts[:env]))

    port = Port.open({:spawn_executable, executable}, port_opts)
    os_pid = port |> Port.info(:os_pid) |> then(fn {:os_pid, pid} -> pid end)

    send(owner, {:mcp_transport, self(), {:up, %{os_pid: os_pid}}})

    {:ok, %{owner: owner, port: port, os_pid: os_pid, buffer: []}}
  end

  @impl GenServer
  def handle_call({:send, iodata}, _from, state) do
    Port.command(state.port, [iodata, ?\n])
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info({port, {:data, {:eol, chunk}}}, %{port: port} = state) do
    line = IO.iodata_to_binary(Enum.reverse([chunk | state.buffer]))

    if String.trim(line) != "" do
      send(state.owner, {:mcp_transport, self(), {:message, line, %{}}})
    end

    {:noreply, %{state | buffer: []}}
  end

  def handle_info({port, {:data, {:noeol, chunk}}}, %{port: port} = state) do
    {:noreply, %{state | buffer: [chunk | state.buffer]}}
  end

  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    send(state.owner, {:mcp_transport, self(), {:down, {:exit_status, status}}})
    {:stop, :normal, %{state | port: nil}}
  end

  def handle_info(_other, state), do: {:noreply, state}

  @impl GenServer
  def terminate(_reason, state) do
    if state.port && Port.info(state.port), do: Port.close(state.port)

    # Best-effort: ports can't half-close stdin, so nudge the subprocess.
    if state.os_pid do
      System.cmd("kill", ["-TERM", Integer.to_string(state.os_pid)], stderr_to_stdout: true)
    end

    :ok
  catch
    _, _ -> :ok
  end

  defp maybe_add(opts, _key, nil), do: opts
  defp maybe_add(opts, key, value), do: opts ++ [{key, value}]

  defp encode_env(env) do
    Enum.map(env, fn {key, value} ->
      {String.to_charlist(to_string(key)), String.to_charlist(to_string(value))}
    end)
  end
end
