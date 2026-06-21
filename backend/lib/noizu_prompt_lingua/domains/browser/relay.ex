defmodule NoizuPromptLingua.Domains.Browser.Relay do
  @moduledoc """
  Correlation hub between cloud `Browser.*` MCP tools and the user's local
  browser controller.

  A tool calls `dispatch/3`, which broadcasts a `command` to the per-org
  channel topic (`browser:<org_id>`) and blocks awaiting the matching
  `command_result`. The `BrowserChannel` registers/unregisters the connected
  controller and, on receiving a result, calls `reply/2` to hand the payload
  back to the blocked caller.

  Commands are ephemeral and held in memory only — no DB persistence in v1.
  State:

    * `pending` — `request_id => GenServer.from` for in-flight commands.
    * `controllers` — `org_id => channel_pid` for currently-connected controllers.

  v1 keeps a single controller per org (last writer wins); see module docs in
  the channel for multi-session follow-ups.
  """

  use GenServer

  @default_timeout 30_000

  # ── Client API ────────────────────────────────────────────────────────────

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc "True when a local controller is currently connected for the org."
  def connected?(org_id) do
    GenServer.call(__MODULE__, {:connected?, org_id})
  end

  @doc """
  Push a command to the org's controller and block until it replies (or
  timeout). Returns `{:ok, data}` on success, or `{:error, reason}` when no
  controller is connected, the controller reports an error, or the wait times
  out.

  `command` is a map like `%{action: "navigate", params: %{url: "..."}}`.
  """
  def dispatch(org_id, command, timeout \\ @default_timeout) do
    case GenServer.call(__MODULE__, {:dispatch, org_id, command, timeout}, timeout + 1_000) do
      {:ok, request_id} ->
        await_result(request_id, timeout)

      {:error, _} = err ->
        err
    end
  end

  @doc "Register the controller channel pid as the active controller for an org."
  def register(org_id, channel_pid) do
    GenServer.call(__MODULE__, {:register, org_id, channel_pid})
  end

  @doc "Hand a controller's result back to the blocked caller for `request_id`."
  def reply(request_id, result) do
    GenServer.cast(__MODULE__, {:reply, request_id, result})
  end

  # ── Server ────────────────────────────────────────────────────────────────

  @impl true
  def init(:ok) do
    {:ok, %{pending: %{}, controllers: %{}}}
  end

  @impl true
  def handle_call({:connected?, org_id}, _from, state) do
    {:reply, Map.has_key?(state.controllers, org_id), state}
  end

  def handle_call({:register, org_id, channel_pid}, _from, state) do
    Process.monitor(channel_pid)
    {:reply, :ok, put_in(state.controllers[org_id], channel_pid)}
  end

  def handle_call({:dispatch, org_id, command, _timeout}, from, state) do
    case Map.get(state.controllers, org_id) do
      nil ->
        {:reply, {:error, :no_controller}, state}

      channel_pid ->
        request_id = Ecto.UUID.generate()
        send(channel_pid, {:browser_command, Map.put(command, :request_id, request_id)})
        state = put_in(state.pending[request_id], from)
        {:reply, {:ok, request_id}, state}
    end
  end

  @impl true
  def handle_cast({:reply, request_id, result}, state) do
    # The blocked caller waits on its own receive (see await_result/2); we send
    # the result directly to the caller pid captured in `from`.
    case Map.pop(state.pending, request_id) do
      {nil, _} ->
        {:noreply, state}

      {{caller_pid, _tag}, pending} ->
        send(caller_pid, {:browser_result, request_id, result})
        {:noreply, %{state | pending: pending}}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    controllers =
      state.controllers
      |> Enum.reject(fn {_org, p} -> p == pid end)
      |> Map.new()

    {:noreply, %{state | controllers: controllers}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  # ── Internal ──────────────────────────────────────────────────────────────

  # `dispatch/3` returns the request_id from the GenServer call, then the caller
  # blocks here. The result is delivered to the caller's mailbox by the cast
  # handler (which has the caller pid via `from`), so we receive on it directly.
  defp await_result(request_id, timeout) do
    receive do
      {:browser_result, ^request_id, result} -> result
    after
      timeout -> {:error, :timeout}
    end
  end
end
