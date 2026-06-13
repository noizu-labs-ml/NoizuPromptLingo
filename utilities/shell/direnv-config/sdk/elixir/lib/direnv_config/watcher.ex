defmodule DirenvConfig.Watcher do
  use GenServer

  defstruct [:store_path, :callback, :interval_ms, :last_version]

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  @impl true
  def init(opts) do
    store_path = Keyword.fetch!(opts, :store_path)
    callback = Keyword.fetch!(opts, :callback)
    interval_ms = Keyword.get(opts, :interval_ms, 1000)

    state = %__MODULE__{
      store_path: store_path,
      callback: callback,
      interval_ms: interval_ms,
      last_version: DirenvConfig.Version.read(store_path)
    }

    schedule_poll(interval_ms)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    current = DirenvConfig.Version.read(state.store_path)

    new_state =
      if current != state.last_version do
        state.callback.(current)
        %{state | last_version: current}
      else
        state
      end

    schedule_poll(new_state.interval_ms)
    {:noreply, new_state}
  end

  defp schedule_poll(interval_ms) do
    Process.send_after(self(), :poll, interval_ms)
  end
end
