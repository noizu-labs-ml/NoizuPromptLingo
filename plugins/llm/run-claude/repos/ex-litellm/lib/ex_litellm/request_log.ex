defmodule ExLiteLLM.RequestLog do
  @moduledoc """
  Request logging — records every gateway request's timing, sizes, target, and
  outcome to the `request_logs` table.

  Writes are **asynchronous** (a cast to a single writer GenServer) so the
  request hot path never blocks on SQLite. The writer also prunes old rows
  periodically so the log can't grow unbounded.

  Reads (`recent/1`, `stats/1`) back the status page's request browser.
  """
  use GenServer

  import Ecto.Query
  require Logger

  alias ExLiteLLM.Schema.{Repo, RequestLog, Repo}

  @name __MODULE__
  @max_rows 20_000
  @prune_every_ms 10 * 60 * 1000

  # --- write path ---

  @doc """
  Record one request (fire-and-forget). `fields`: :method, :path, :model,
  :target, :status, :duration_ms, :req_bytes, :resp_bytes, :stream, :error.
  """
  @spec record(map()) :: :ok
  def record(fields) when is_map(fields) do
    GenServer.cast(@name, {:record, Map.put(fields, :inserted_at, DateTime.utc_now())})
  catch
    # Logger not up (early boot / tests without the app) — drop silently.
    :exit, _ -> :ok
  end

  # --- read path (status page) ---

  @doc "Most recent requests, newest first. Options: :limit (default 100), :errors_only, :path_filter."
  @spec recent(keyword()) :: [map()]
  def recent(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    ExLiteLLM.Schema.RequestLog
    |> order_by(desc: :id)
    |> limit(^limit)
    |> maybe_errors_only(Keyword.get(opts, :errors_only, false))
    |> maybe_path_filter(Keyword.get(opts, :path_filter))
    |> Repo.all()
    |> Enum.map(&to_map/1)
  rescue
    _ -> []
  end

  @doc "Aggregate stats over the last `minutes` (default 60): count, errors, avg/max duration, bytes."
  @spec stats(non_neg_integer()) :: map()
  def stats(minutes \\ 60) do
    since = DateTime.add(DateTime.utc_now(), -minutes * 60, :second)

    row =
      from(r in RequestLog,
        where: r.inserted_at >= ^since,
        select: %{
          count: count(r.id),
          errors: sum(fragment("CASE WHEN ? >= 400 OR ? IS NOT NULL THEN 1 ELSE 0 END", r.status, r.error)),
          avg_ms: avg(r.duration_ms),
          max_ms: max(r.duration_ms),
          req_bytes: sum(r.req_bytes),
          resp_bytes: sum(r.resp_bytes)
        }
      )
      |> Repo.one()

    %{
      window_minutes: minutes,
      count: row.count || 0,
      errors: row.errors || 0,
      avg_ms: round_or_zero(row.avg_ms),
      max_ms: row.max_ms || 0,
      req_bytes: row.req_bytes || 0,
      resp_bytes: row.resp_bytes || 0
    }
  rescue
    _ -> %{window_minutes: minutes, count: 0, errors: 0, avg_ms: 0, max_ms: 0, req_bytes: 0, resp_bytes: 0}
  end

  # --- server ---

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts, name: @name)

  @impl true
  def init(_opts) do
    Process.send_after(self(), :prune, @prune_every_ms)
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:record, fields}, state) do
    %RequestLog{}
    |> struct(clean(fields))
    |> Repo.insert()
    |> case do
      {:ok, _} -> :ok
      {:error, reason} -> Logger.warning("[request-log] insert failed: #{inspect(reason)}")
    end

    {:noreply, state}
  rescue
    e ->
      Logger.warning("[request-log] insert crashed: #{Exception.message(e)}")
      {:noreply, state}
  end

  @impl true
  def handle_info(:prune, state) do
    # Keep the newest @max_rows; delete the tail.
    cutoff =
      RequestLog
      |> order_by(desc: :id)
      |> offset(@max_rows)
      |> limit(1)
      |> select([r], r.id)
      |> Repo.one()

    if cutoff, do: Repo.delete_all(from(r in RequestLog, where: r.id <= ^cutoff))

    Process.send_after(self(), :prune, @prune_every_ms)
    {:noreply, state}
  rescue
    _ ->
      Process.send_after(self(), :prune, @prune_every_ms)
      {:noreply, state}
  end

  # --- helpers ---

  defp clean(fields) do
    fields
    |> Map.take([
      :method,
      :path,
      :model,
      :target,
      :status,
      :duration_ms,
      :req_bytes,
      :resp_bytes,
      :stream,
      :error,
      :inserted_at
    ])
    |> Map.update(:error, nil, &truncate/1)
  end

  defp truncate(nil), do: nil
  defp truncate(err) when is_binary(err), do: String.slice(err, 0, 500)
  defp truncate(err), do: err |> inspect() |> String.slice(0, 500)

  defp maybe_errors_only(query, true),
    do: where(query, [r], r.status >= 400 or not is_nil(r.error))

  defp maybe_errors_only(query, _), do: query

  defp maybe_path_filter(query, nil), do: query

  defp maybe_path_filter(query, path) when is_binary(path),
    do: where(query, [r], like(r.path, ^("%" <> path <> "%")))

  defp round_or_zero(nil), do: 0
  defp round_or_zero(%Decimal{} = d), do: d |> Decimal.to_float() |> round()
  defp round_or_zero(n) when is_float(n), do: round(n)
  defp round_or_zero(n), do: n

  defp to_map(%RequestLog{} = r) do
    %{
      id: r.id,
      at: r.inserted_at,
      method: r.method,
      path: r.path,
      model: r.model,
      target: r.target,
      status: r.status,
      duration_ms: r.duration_ms,
      req_bytes: r.req_bytes,
      resp_bytes: r.resp_bytes,
      stream: r.stream,
      error: r.error
    }
  end
end
