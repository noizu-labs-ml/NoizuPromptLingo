defmodule NoizuPromptLingua.Domains.Dashboard do
  @moduledoc """
  Org-scoped usage / activity stats for the product dashboard.

  Counts and series are computed in the database (no list-limit truncation).
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Artifact
  alias NoizuPromptLingua.Schema.ChatRoom
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Review
  alias NoizuPromptLingua.Schema.Sessions.Session
  alias NoizuPromptLingua.Schema.Ticket

  @valid_ranges [7, 14, 30]
  @default_range 14

  @doc """
  Aggregate dashboard stats for `org_id`.

  Options:
  - `:range` — 7 | 14 | 30 calendar days for daily series (default 14)
  """
  def stats(org_id, opts \\ []) when is_binary(org_id) do
    range = normalize_range(range_opt(opts))
    since = since_datetime(range)
    week_since = since_datetime(28)

    %{
      range: range,
      counts: counts(org_id),
      by_status: %{
        sessions: count_by_field(Session, org_id, :status),
        tickets: count_by_field(Ticket, org_id, :status)
      },
      by_kind: %{
        artifacts: count_by_field(Artifact, org_id, :kind)
      },
      daily: daily_series(org_id, range, since),
      weekly: weekly_series(org_id, week_since),
      heatmap: heatmap(org_id),
      attention: attention(org_id),
      recent: recent(org_id)
    }
  end

  # `opts[:range] || opts["range"]` crashed on the keyword form the controller
  # passes: Access on a keyword list rejects string keys (ArgumentError). Read
  # per-shape instead — keyword opts, string-keyed map params, or neither.
  defp range_opt(opts) when is_list(opts), do: opts[:range]
  defp range_opt(opts) when is_map(opts), do: opts[:range] || opts["range"]
  defp range_opt(_), do: nil

  defp normalize_range(r) when r in @valid_ranges, do: r

  defp normalize_range(r) when is_binary(r) do
    case Integer.parse(r) do
      {n, _} when n in @valid_ranges -> n
      _ -> @default_range
    end
  end

  defp normalize_range(_), do: @default_range

  defp since_datetime(days) do
    DateTime.utc_now()
    |> DateTime.add(-(days - 1) * 86_400, :second)
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp counts(org_id) do
    %{
      projects: aggregate_count(Project, org_id),
      sessions: aggregate_count(Session, org_id),
      artifacts: aggregate_count(Artifact, org_id),
      reviews: aggregate_count(Review, org_id),
      tickets: aggregate_count(Ticket, org_id),
      chat_rooms: aggregate_count(ChatRoom, org_id)
    }
  end

  defp aggregate_count(schema, org_id) do
    schema
    |> where([r], r.organization_id == ^org_id)
    |> Repo.aggregate(:count, :id)
  end

  defp count_by_field(schema, org_id, field) do
    schema
    |> where([r], r.organization_id == ^org_id)
    |> group_by([r], field(r, ^field))
    |> select([r], {field(r, ^field), count(r.id)})
    |> Repo.all()
    |> Enum.reduce(%{}, fn
      {nil, n}, acc -> Map.put(acc, "unknown", n)
      {k, n}, acc when is_binary(k) -> Map.put(acc, k, n)
      {k, n}, acc -> Map.put(acc, to_string(k), n)
    end)
  end

  defp daily_series(org_id, range, since) do
    keys = day_keys(range)

    %{
      keys: keys,
      sessions: fill_days(keys, daily_counts(Session, org_id, since)),
      artifacts: fill_days(keys, daily_counts(Artifact, org_id, since)),
      chat_rooms: fill_days(keys, daily_counts(ChatRoom, org_id, since)),
      tickets: fill_days(keys, daily_counts(Ticket, org_id, since)),
      reviews: fill_days(keys, daily_counts(Review, org_id, since)),
      projects: fill_days(keys, daily_counts(Project, org_id, since))
    }
  end

  defp daily_counts(schema, org_id, since) do
    schema
    |> where([r], r.organization_id == ^org_id and r.inserted_at >= ^since)
    |> group_by([r], fragment("date_trunc('day', ?)::date", r.inserted_at))
    |> select([r], {fragment("date_trunc('day', ?)::date", r.inserted_at), count(r.id)})
    |> Repo.all()
    |> Map.new(fn {day, n} -> {Date.to_iso8601(to_date(day)), n} end)
  end

  defp weekly_series(org_id, since) do
    # Last 4 calendar weeks ending today, labeled W1..W4 (oldest → newest).
    today = Date.utc_today()

    Enum.map(3..0//-1, fn offset ->
      end_day = Date.add(today, -offset * 7)
      start_day = Date.add(end_day, -6)
      start_dt = DateTime.new!(start_day, ~T[00:00:00], "Etc/UTC")
      end_dt = DateTime.new!(end_day, ~T[23:59:59], "Etc/UTC")

      # Ensure we don't query before `since` (safety for very old data windows)
      _ = since

      %{
        week: "W#{4 - offset}",
        sessions: count_between(Session, org_id, start_dt, end_dt),
        artifacts: count_between(Artifact, org_id, start_dt, end_dt),
        chat: count_between(ChatRoom, org_id, start_dt, end_dt),
        tickets: count_between(Ticket, org_id, start_dt, end_dt)
      }
    end)
  end

  defp count_between(schema, org_id, start_dt, end_dt) do
    schema
    |> where(
      [r],
      r.organization_id == ^org_id and r.inserted_at >= ^start_dt and r.inserted_at <= ^end_dt
    )
    |> Repo.aggregate(:count, :id)
  end

  defp heatmap(org_id) do
    # rows Mon=0..Sun=6; cols 6×4h buckets from inserted_at across domains
    rows =
      [
        Session,
        Artifact,
        ChatRoom,
        Ticket,
        Review,
        Project
      ]
      |> Enum.flat_map(fn schema ->
        schema
        |> where([r], r.organization_id == ^org_id)
        |> select(
          [r],
          {fragment("EXTRACT(DOW FROM ?)::int", r.inserted_at),
           fragment("EXTRACT(HOUR FROM ?)::int", r.inserted_at)}
        )
        |> Repo.all()
      end)

    cells =
      for _ <- 0..6 do
        for _ <- 0..5, do: 0
      end

    Enum.reduce(rows, cells, fn {dow, hour}, acc ->
      # Postgres DOW: 0=Sunday … 6=Saturday → FE Mon-first: Mon=0 … Sun=6
      row = if dow == 0, do: 6, else: dow - 1
      col = min(div(hour || 0, 4), 5)
      update_in(acc, [Access.at(row), Access.at(col)], &(&1 + 1))
    end)
  end

  defp attention(org_id) do
    open_reviews =
      Review
      |> where([r], r.organization_id == ^org_id and r.status in ["open", "in_progress"])
      |> order_by([r], desc: r.updated_at)
      |> limit(6)
      |> select([r], %{
        id: r.id,
        title: r.title,
        status: r.status,
        updated_at: r.updated_at
      })
      |> Repo.all()
      |> Enum.map(&serialize_attention/1)

    blocked_tickets =
      Ticket
      |> where([t], t.organization_id == ^org_id and t.status in ["blocked", "in_review"])
      |> order_by([t], desc: t.updated_at)
      |> limit(6)
      |> select([t], %{
        id: t.id,
        title: t.title,
        status: t.status,
        updated_at: t.updated_at
      })
      |> Repo.all()
      |> Enum.map(&serialize_attention/1)

    %{open_reviews: open_reviews, blocked_tickets: blocked_tickets}
  end

  defp serialize_attention(row) do
    %{
      id: row.id,
      title: row.title,
      status: row.status,
      updated_at: datetime_iso(row.updated_at)
    }
  end

  defp recent(org_id) do
    take = 4

    projects =
      Project
      |> where([p], p.organization_id == ^org_id)
      |> order_by([p], desc: p.updated_at)
      |> limit(^take)
      |> select([p], %{type: "project", id: p.id, title: p.name, at: p.updated_at})
      |> Repo.all()

    sessions =
      Session
      |> where([s], s.organization_id == ^org_id)
      |> order_by([s], desc: s.updated_at)
      |> limit(^take)
      |> select([s], %{type: "session", id: s.id, title: s.title, at: s.updated_at})
      |> Repo.all()

    artifacts =
      Artifact
      |> where([a], a.organization_id == ^org_id)
      |> order_by([a], desc: a.updated_at)
      |> limit(^take)
      |> select([a], %{type: "artifact", id: a.id, title: a.title, at: a.updated_at})
      |> Repo.all()

    reviews =
      Review
      |> where([r], r.organization_id == ^org_id)
      |> order_by([r], desc: r.updated_at)
      |> limit(^take)
      |> select([r], %{type: "review", id: r.id, title: r.title, at: r.updated_at})
      |> Repo.all()

    tickets =
      Ticket
      |> where([t], t.organization_id == ^org_id)
      |> order_by([t], desc: t.updated_at)
      |> limit(^take)
      |> select([t], %{type: "ticket", id: t.id, title: t.title, at: t.updated_at})
      |> Repo.all()

    (projects ++ sessions ++ artifacts ++ reviews ++ tickets)
    |> Enum.sort_by(& &1.at, {:desc, DateTime})
    |> Enum.take(8)
    |> Enum.map(fn row ->
      %{
        type: row.type,
        id: row.id,
        title: row.title,
        at: datetime_iso(row.at)
      }
    end)
  end

  defp day_keys(range) do
    today = Date.utc_today()

    Enum.map((range - 1)..0//-1, fn offset ->
      Date.add(today, -offset) |> Date.to_iso8601()
    end)
  end

  defp fill_days(keys, map) do
    Enum.map(keys, fn k -> Map.get(map, k, 0) end)
  end

  defp to_date(%Date{} = d), do: d
  defp to_date(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_date(ndt)
  defp to_date(%DateTime{} = dt), do: DateTime.to_date(dt)
  defp to_date({{y, m, d}, _}), do: Date.new!(y, m, d)
  defp to_date({y, m, d}) when is_integer(y), do: Date.new!(y, m, d)

  defp datetime_iso(nil), do: nil
  defp datetime_iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp datetime_iso(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt) <> "Z"
  defp datetime_iso(other), do: to_string(other)
end
