defmodule NoizuPromptLingua.TRP.Cache do
  @moduledoc """
  ETS-backed read cache for TRP responses (spec §5). No new deps.

  - Rows: `{key, value, expires_at}`; keys are lists (e.g. `[:item, org_id, id]`)
    so prefix eviction is a cheap fold.
  - Lazy expiry on read; `get_stale/1` ignores expiry for fail-soft reads.
  - `bust_prefix/1` evicts every key starting with the given prefix (write-bust).
  - `stats/0` for cheap introspection; hit/miss counters live in the same table.
  """

  use GenServer

  @table :noizu_trp_cache
  @infinity :infinity

  # --- API ---------------------------------------------------------------

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "`{:ok, value}` on fresh hit, `:miss` otherwise."
  @spec get(term()) :: {:ok, term()} | :miss
  def get(key) do
    table()

    case :ets.lookup(@table, key) do
      [{^key, value, expires_at}] ->
        if fresh?(expires_at) do
          bump(:hits)
          {:ok, value}
        else
          bump(:misses)
          :miss
        end

      [] ->
        bump(:misses)
        :miss
    end
  end

  @doc "Hit regardless of TTL — fail-soft fallback when TRP is unreachable."
  @spec get_stale(term()) :: {:ok, term()} | :miss
  def get_stale(key) do
    table()

    case :ets.lookup(@table, key) do
      [{^key, value, _}] -> {:ok, value}
      [] -> :miss
    end
  end

  @spec put(term(), term(), pos_integer()) :: true
  def put(key, value, ttl_ms) when is_integer(ttl_ms) and ttl_ms > 0 do
    table()
    :ets.insert(@table, {key, value, now() + ttl_ms})
  end

  @doc "Evict an exact key."
  @spec bust(term()) :: true
  def bust(key) do
    table()
    :ets.delete(@table, key)
  end

  @doc "Evict every cached key whose list-key starts with `prefix`."
  @spec bust_prefix(list()) :: non_neg_integer()
  def bust_prefix(prefix) when is_list(prefix) do
    table()

    doomed =
      :ets.foldl(
        fn {key, _, _}, acc ->
          if is_list(key) and starts_with?(key, prefix), do: [key | acc], else: acc
        end,
        [],
        @table
      )

    Enum.each(doomed, &:ets.delete(@table, &1))
    length(doomed)
  end

  @doc "Drop everything (including stats)."
  def clear do
    table()

    :ets.foldl(fn {k, _, _}, acc -> [k | acc] end, [], @table)
    |> Enum.each(&:ets.delete(@table, &1))

    :ok
  end

  @doc "Cheap introspection: `%{entries, hits, misses}`."
  def stats do
    table()

    entries =
      :ets.foldl(
        fn {k, _, _}, acc ->
          case k do
            {ctr, _} when is_atom(ctr) -> acc
            _ -> acc + 1
          end
        end,
        0,
        @table
      )

    %{entries: entries, hits: counter(:hits), misses: counter(:misses)}
  end

  @doc """
  Read-through helper. `fetch` returns a value (cached), `nil` (not cached),
  or `{:error, term()}` (not cached). Transport failures fail soft to stale.
  """
  @spec cached_get(term(), pos_integer(), (-> term())) :: term()
  def cached_get(key, ttl, fetch) do
    case get(key) do
      {:ok, value} ->
        value

      :miss ->
        case fetch.() do
          {:error, {:transport, _}} = err ->
            case get_stale(key) do
              {:ok, stale} ->
                require Logger
                Logger.warning("TRP unreachable; serving stale cache for #{inspect(key)}")
                stale

              :miss ->
                err
            end

          {:error, _} = err ->
            err

          nil ->
            nil

          value ->
            put(key, value, ttl)
            value
        end
    end
  end

  # --- Internals ----------------------------------------------------------

  defp table do
    # No-op when the GenServer owns the table (supervised); self-heals in
    # tests that exercise the cache without the app tree.
    if :ets.whereis(@table) == :undefined, do: ensure_table()
    :ok
  end

  defp fresh?(@infinity), do: true
  defp fresh?(expires_at), do: expires_at > now()

  defp now, do: System.system_time(:millisecond)

  defp starts_with?(key, prefix) do
    length(key) >= length(prefix) and Enum.take(key, length(prefix)) == prefix
  end

  defp bump(counter) do
    ensure_counter(counter)
    :ets.update_counter(@table, {counter, 0}, 1)
    :ok
  end

  defp counter(counter) do
    ensure_counter(counter)
    :ets.lookup_element(@table, {counter, 0}, 2)
  end

  defp ensure_counter(counter) do
    case :ets.lookup(@table, {counter, 0}) do
      [_] -> :ok
      [] -> :ets.insert(@table, {{counter, 0}, 0, @infinity})
    end

    true
  end

  defp ensure_table do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    end

    :ok
  end

  @impl true
  def init(_opts) do
    ensure_table()
    {:ok, %{}}
  end
end
