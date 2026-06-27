defmodule NoizuPromptLingua.Domains.Notifications.Presence do
  @moduledoc """
  Tracks which agents are "online". An agent is considered present while it is
  actively polling for notifications: each poll calls `touch/2`, which refreshes
  a Redis key `presence:<org>:<handle>` with a TTL of roughly twice the 180s poll
  window.

  Transitions are announced through `Dispatch.presence/2`:

    * absent → present (first touch / re-appearance) → `:online`
    * present → expired (TTL lapsed, detected by the ticker) → `:offline`

  Self-contained: a periodic ticker scans tracked handles and fires `:offline`
  for any whose Redis key has expired. All Redis/dispatch work is best-effort.
  """

  use GenServer
  require Logger

  alias NoizuPromptLingua.Redis
  alias NoizuPromptLingua.Domains.Notifications.Dispatch

  # ~2x the 180s poll window.
  @ttl_seconds 360
  # How often the ticker checks tracked handles for expiry.
  @scan_interval_ms 30_000

  # ------------------------------------------------------------------
  # API
  # ------------------------------------------------------------------

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Mark `handle` present in `org_id`. Best-effort; a no-op if the tracker isn't
  running. Fires an `:online` transition on absent → present.
  """
  def touch(nil, _handle), do: :ok
  def touch(_org_id, nil), do: :ok

  def touch(org_id, handle) do
    GenServer.cast(__MODULE__, {:touch, org_id, handle})
  catch
    _kind, _reason -> :ok
  end

  # ------------------------------------------------------------------
  # GenServer
  # ------------------------------------------------------------------

  @impl true
  def init(_opts) do
    schedule_tick()
    {:ok, %{tracked: %{}}}
  end

  @impl true
  def handle_cast({:touch, org_id, handle}, state) do
    key = key(org_id, handle)
    present_before = present?(key)

    safe(fn -> Redis.set(key, "1", ex: @ttl_seconds) end)

    unless present_before do
      safe(fn -> Dispatch.presence(handle, :online) end)
    end

    {:noreply, put_in(state.tracked[{org_id, handle}], true)}
  end

  @impl true
  def handle_info(:tick, state) do
    tracked =
      Enum.reduce(state.tracked, %{}, fn {{org_id, handle} = id, _}, acc ->
        if present?(key(org_id, handle)) do
          Map.put(acc, id, true)
        else
          safe(fn -> Dispatch.presence(handle, :offline) end)
          acc
        end
      end)

    schedule_tick()
    {:noreply, %{state | tracked: tracked}}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  # ------------------------------------------------------------------
  # Internals
  # ------------------------------------------------------------------

  defp key(org_id, handle), do: "presence:#{org_id}:#{handle}"

  defp present?(key) do
    case Redis.get(key) do
      {:ok, nil} -> false
      {:ok, _value} -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  defp schedule_tick, do: Process.send_after(self(), :tick, @scan_interval_ms)

  defp safe(fun) do
    fun.()
  rescue
    e -> Logger.warning("[Notifications.Presence] #{inspect(e)}")
  catch
    _kind, _reason -> :ok
  end
end
