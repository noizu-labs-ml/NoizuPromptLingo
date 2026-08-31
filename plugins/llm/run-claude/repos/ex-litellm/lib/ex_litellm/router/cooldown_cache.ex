defmodule ExLiteLLM.Router.CooldownCache do
  @moduledoc """
  Per-deployment cooldown tracking — litellm's `CooldownCache` over its
  in-memory `DualCache` layer.

  When a deployment fails, it's cooled down for `cooldown_time` ms; the router
  skips cooled-down deployments during selection. Backed by an ETS table with
  absolute-expiry timestamps (checked lazily on read — no timers needed).

  Redis-backed sharing across instances (litellm's distributed cooldowns) is a
  later concern; for run-claude's single-host case the ETS layer is sufficient.
  """
  use GenServer

  @table :ex_litellm_cooldowns
  @name __MODULE__

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @doc "Cool down a deployment for `ms` milliseconds."
  @spec add(String.t(), term(), non_neg_integer()) :: :ok
  def add(model_id, reason, ms) when is_binary(model_id) do
    expires_at = System.monotonic_time(:millisecond) + ms
    :ets.insert(@table, {model_id, expires_at, reason})
    :ok
  end

  @doc "Is this deployment currently cooled down?"
  @spec cooled_down?(String.t() | nil) :: boolean()
  def cooled_down?(nil), do: false

  def cooled_down?(model_id) do
    case :ets.lookup(@table, model_id) do
      [{^model_id, expires_at, _reason}] ->
        if System.monotonic_time(:millisecond) < expires_at do
          true
        else
          :ets.delete(@table, model_id)
          false
        end

      [] ->
        false
    end
  end

  @doc "Clear a deployment's cooldown (e.g. after a successful call)."
  @spec clear(String.t()) :: :ok
  def clear(model_id) do
    :ets.delete(@table, model_id)
    :ok
  end

  @doc "All currently-cooled-down model_ids."
  @spec active() :: [String.t()]
  def active do
    now = System.monotonic_time(:millisecond)

    :ets.tab2list(@table)
    |> Enum.filter(fn {_id, expires_at, _} -> now < expires_at end)
    |> Enum.map(&elem(&1, 0))
  end

  @impl true
  def init(_opts) do
    # public + named so the hot path reads without going through the server.
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    {:ok, %{}}
  end
end
