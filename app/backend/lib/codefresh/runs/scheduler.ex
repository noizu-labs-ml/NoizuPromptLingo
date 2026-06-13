defmodule Codefresh.Runs.Scheduler do
  @moduledoc """
  Scheduler for recurring runs (US-069).

  Schedules are stored in the `scheduled_runs` table; each row pins a
  `script_version` + `agent_version` and a 5-field cron expression
  (minute hour day-of-month month day-of-week).

  This module provides:

    * `schedule_run/3` — create a `ScheduledRun` row
    * `list_schedules/2` — list schedules for an org
    * `due?/2` + `next_run_after/2` — pure helpers for tick logic
    * `tick/1` — scan enabled schedules, enqueue runs for any due

  The ticker itself (`Codefresh.Runs.Scheduler.Ticker`) runs under the
  application supervisor and calls `tick/1` every 60s in non-test envs.
  """

  import Ecto.Query, only: [from: 2]
  alias Codefresh.Repo
  alias Codefresh.Runs
  alias Codefresh.Runs.ScheduledRun
  alias Codefresh.Scripts.{Script, ScriptVersion}
  alias Codefresh.Agents.{Agent, AgentVersion}

  @doc """
  Create a schedule. `cron_expression` is a 5-field cron string
  (e.g. `"0 2 * * *"` — every day at 02:00 UTC).

  Options:
    * `:timezone` — IANA zone string, default `"Etc/UTC"`
    * `:enabled` — default `true`
    * `:created_by_user_id` — optional user id
    * `:metadata` — opaque map
  """
  def schedule_run(script_version_id, agent_version_id, cron_expression, opts \\ [])
      when is_binary(script_version_id) and is_binary(agent_version_id) and
             is_binary(cron_expression) do
    with {:ok, script_version} <- load_script_version(script_version_id),
         {:ok, agent_version} <- load_agent_version(agent_version_id),
         :ok <- same_org(script_version, agent_version),
         {:ok, next_at} <- compute_next(cron_expression, DateTime.utc_now()) do
      attrs = %{
        organization_id: script_version.organization_id,
        script_version_id: script_version.id,
        agent_version_id: agent_version.id,
        cron_expression: cron_expression,
        timezone: opts[:timezone] || "Etc/UTC",
        enabled: Keyword.get(opts, :enabled, true),
        next_run_at: next_at,
        created_by_user_id: opts[:created_by_user_id],
        metadata: opts[:metadata] || %{}
      }

      %ScheduledRun{}
      |> ScheduledRun.create_changeset(attrs)
      |> Repo.insert()
    end
  end

  defp load_script_version(id) do
    case Repo.get(ScriptVersion, id) do
      nil -> {:error, :script_version_not_found}
      v -> {:ok, v}
    end
  end

  defp load_agent_version(id) do
    case Repo.get(AgentVersion, id) do
      nil -> {:error, :agent_version_not_found}
      v -> {:ok, v}
    end
  end

  defp same_org(%ScriptVersion{organization_id: org}, %AgentVersion{organization_id: org}),
    do: :ok

  defp same_org(_, _), do: {:error, :cross_org}

  def list_schedules(organization_id, opts \\ []) do
    include_disabled = Keyword.get(opts, :include_disabled, true)

    q =
      from s in ScheduledRun,
        where: s.organization_id == ^organization_id,
        order_by: [asc: s.next_run_at]

    q =
      if include_disabled, do: q, else: from(s in q, where: s.enabled == true)

    Repo.all(q)
  end

  def get_schedule(organization_id, id) do
    Repo.one(
      from s in ScheduledRun,
        where: s.organization_id == ^organization_id and s.id == ^id
    )
  end

  def update_schedule(%ScheduledRun{} = sr, attrs) do
    sr
    |> ScheduledRun.update_changeset(attrs)
    |> Repo.update()
  end

  def disable_schedule(%ScheduledRun{} = sr), do: update_schedule(sr, %{enabled: false})
  def enable_schedule(%ScheduledRun{} = sr), do: update_schedule(sr, %{enabled: true})

  def delete_schedule(%ScheduledRun{} = sr), do: Repo.delete(sr)

  # ──────────────────────────────────────────────────────────────────────────
  # Tick: find due schedules, trigger runs, advance next_run_at
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Find all enabled, due schedules and trigger runs. Returns a list of
  `{:ok, run} | {:error, reason}` tuples (one per schedule processed).
  """
  def tick(now \\ DateTime.utc_now()) do
    due = due_schedules(now)

    Enum.map(due, fn sr ->
      run_result = trigger_schedule(sr)
      advance_schedule(sr, now, run_result)
      run_result
    end)
  end

  defp due_schedules(now) do
    Repo.all(
      from s in ScheduledRun,
        where: s.enabled == true,
        where: not is_nil(s.next_run_at) and s.next_run_at <= ^DateTime.truncate(now, :second),
        order_by: [asc: s.next_run_at]
    )
  end

  defp trigger_schedule(%ScheduledRun{} = sr) do
    with {:ok, script_head} <- resolve_script_head(sr.script_version_id),
         {:ok, agent_head} <- resolve_agent_head(sr.agent_version_id) do
      Runs.trigger_run(script_head, agent_head.id,
        trigger_source: "scheduled",
        run_config: %{
          "scheduled_run_id" => sr.id,
          "cron_expression" => sr.cron_expression
        }
      )
    end
  end

  defp resolve_script_head(script_version_id) do
    case Repo.get(ScriptVersion, script_version_id) do
      nil ->
        {:error, :script_version_missing}

      %ScriptVersion{script_id: sid} ->
        case Repo.get(Script, sid) do
          nil -> {:error, :script_missing}
          s -> {:ok, s}
        end
    end
  end

  defp resolve_agent_head(agent_version_id) do
    case Repo.get(AgentVersion, agent_version_id) do
      nil ->
        {:error, :agent_version_missing}

      %AgentVersion{agent_id: aid} ->
        case Repo.get(Agent, aid) do
          nil -> {:error, :agent_missing}
          a -> {:ok, a}
        end
    end
  end

  defp advance_schedule(%ScheduledRun{} = sr, now, run_result) do
    {:ok, next_at} = compute_next(sr.cron_expression, DateTime.add(now, 60, :second))

    attrs =
      case run_result do
        {:ok, %Codefresh.Runs.Run{id: rid}} ->
          %{
            next_run_at: next_at,
            last_triggered_at: DateTime.truncate(now, :second),
            last_run_id: rid
          }

        _ ->
          # Missed-runs policy per US-069: don't backfill. Just bump next.
          %{
            next_run_at: next_at,
            last_triggered_at: DateTime.truncate(now, :second)
          }
      end

    update_schedule(sr, attrs)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Minimal 5-field cron parser + next-fire calculator
  # Format: minute hour day-of-month month day-of-week
  # Supports: `*`, `N`, `A,B,C`, `N-M`, `*/step`, `A-B/step`. Day-of-week: 0-6.
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Parse a 5-field cron expression into a set-of-values spec.
  Returns `{:ok, %{minute: MapSet, hour: MapSet, dom: MapSet, month: MapSet, dow: MapSet}}`
  or `{:error, message}`.
  """
  def parse_cron(expr) when is_binary(expr) do
    parts = expr |> String.trim() |> String.split(~r/\s+/)

    case parts do
      [min, hr, dom, mon, dow] ->
        with {:ok, minutes} <- parse_field(min, 0, 59),
             {:ok, hours} <- parse_field(hr, 0, 23),
             {:ok, doms} <- parse_field(dom, 1, 31),
             {:ok, months} <- parse_field(mon, 1, 12),
             {:ok, dows} <- parse_field(dow, 0, 6) do
          {:ok,
           %{
             minute: minutes,
             hour: hours,
             dom: doms,
             month: months,
             dow: dows
           }}
        end

      _ ->
        {:error, "expected 5 space-separated fields"}
    end
  end

  @doc """
  Compute the next DateTime at which `cron_expression` will fire, strictly
  after `from` (UTC). Returns `{:ok, DateTime.t}` | `{:error, reason}`.

  Minute-granularity; searches up to ~4 years ahead.
  """
  def compute_next(expr, %DateTime{} = from) do
    with {:ok, spec} <- parse_cron(expr) do
      # Start at from + 1 minute, truncated to the minute boundary.
      start =
        from
        |> DateTime.add(60, :second)
        |> zero_second()

      case find_next(spec, start, 60 * 24 * 366 * 4) do
        {:ok, dt} -> {:ok, dt}
        :none -> {:error, :no_next_fire_within_window}
      end
    end
  end

  defp zero_second(%DateTime{} = dt), do: %{dt | second: 0, microsecond: {0, 0}}

  defp find_next(_spec, _dt, 0), do: :none

  defp find_next(spec, %DateTime{} = dt, budget) do
    if matches?(spec, dt) do
      {:ok, dt}
    else
      find_next(spec, DateTime.add(dt, 60, :second), budget - 1)
    end
  end

  defp matches?(spec, %DateTime{} = dt) do
    %{minute: m, hour: h, dom: dom, month: mon, dow: dow} = spec
    # Elixir Date.day_of_week returns 1 (Mon) … 7 (Sun); cron uses 0 (Sun) … 6 (Sat).
    cron_dow = rem(Date.day_of_week(DateTime.to_date(dt)), 7)

    MapSet.member?(m, dt.minute) and
      MapSet.member?(h, dt.hour) and
      MapSet.member?(dom, dt.day) and
      MapSet.member?(mon, dt.month) and
      MapSet.member?(dow, cron_dow)
  end

  # Field parser: "*", "N", "A,B", "A-B", "*/step", "A-B/step"
  defp parse_field(field, min, max) do
    parts = String.split(field, ",", trim: true)

    case parts do
      [] ->
        {:error, "empty cron field"}

      many ->
        try do
          values =
            Enum.flat_map(many, fn part ->
              parse_part!(part, min, max)
            end)

          {:ok, MapSet.new(values)}
        catch
          {:bad_field, msg} -> {:error, msg}
        end
    end
  end

  defp parse_part!(part, min, max) do
    cond do
      part == "*" ->
        Enum.to_list(min..max)

      String.contains?(part, "/") ->
        [range_str, step_str] = String.split(part, "/", parts: 2)
        step = parse_int!(step_str, "bad step in cron field")

        if step <= 0, do: throw({:bad_field, "step must be > 0"})

        base =
          if range_str == "*" do
            Enum.to_list(min..max)
          else
            parse_range!(range_str, min, max)
          end

        base
        |> Enum.with_index()
        |> Enum.filter(fn {_v, i} -> rem(i, step) == 0 end)
        |> Enum.map(fn {v, _} -> v end)

      String.contains?(part, "-") ->
        parse_range!(part, min, max)

      true ->
        v = parse_int!(part, "bad integer in cron field")
        unless v in min..max, do: throw({:bad_field, "value #{v} out of range #{min}..#{max}"})
        [v]
    end
  end

  defp parse_range!(range_str, min, max) do
    case String.split(range_str, "-", parts: 2) do
      [a, b] ->
        ai = parse_int!(a, "bad range in cron field")
        bi = parse_int!(b, "bad range in cron field")

        if ai < min or bi > max or ai > bi,
          do: throw({:bad_field, "range #{ai}-#{bi} out of #{min}..#{max}"})

        Enum.to_list(ai..bi)

      [single] ->
        v = parse_int!(single, "bad integer in cron field")
        unless v in min..max, do: throw({:bad_field, "value #{v} out of range"})
        [v]
    end
  end

  defp parse_int!(str, err_msg) do
    case Integer.parse(str) do
      {n, ""} -> n
      _ -> throw({:bad_field, err_msg})
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Ticker GenServer (optional) — started by Application only in non-test envs.
  # ──────────────────────────────────────────────────────────────────────────

  defmodule Ticker do
    @moduledoc false
    use GenServer

    alias Codefresh.Runs.Scheduler

    @interval_ms 60_000

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    @impl true
    def init(_opts) do
      schedule_tick()
      {:ok, %{}}
    end

    @impl true
    def handle_info(:tick, state) do
      _results =
        try do
          Scheduler.tick()
        rescue
          e ->
            require Logger
            Logger.warning("Scheduler tick failed: #{inspect(e)}")
            []
        end

      schedule_tick()
      {:noreply, state}
    end

    defp schedule_tick do
      Process.send_after(self(), :tick, @interval_ms)
    end
  end
end
