defmodule NoizuPromptLingua.Domains.DashboardTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Dashboard
  alias NoizuPromptLingua.Schema.Artifact
  alias NoizuPromptLingua.Schema.ChatRoom
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Review
  alias NoizuPromptLingua.Schema.Sessions.Session
  alias NoizuPromptLingua.Schema.Ticket

  # EXTRACT(DOW/HOUR FROM timestamptz) follows the DB session timezone; the
  # cluster runs at +07. Pin the sandbox transaction to UTC so heatmap buckets
  # are deterministic (SET LOCAL rolls back with the sandbox transaction).
  setup do
    Repo.query!("SET LOCAL TIME ZONE 'UTC'")
    :ok
  end

  # Microsecond precision is required by the *_usec timestamp types.
  @now DateTime.utc_now()
  @today DateTime.new!(DateTime.to_date(@now), ~T[10:00:00.000000], "Etc/UTC")
  @today_pm DateTime.new!(DateTime.to_date(@now), ~T[15:00:00.000000], "Etc/UTC")
  @yesterday @today |> DateTime.add(-86_400, :second)
  @three_days_ago @today |> DateTime.add(-3 * 86_400, :second)
  @forty_days_ago @today |> DateTime.add(-40 * 86_400, :second)

  # Ticket/Artifact/ChatRoom/Review use second-precision :utc_datetime.
  @today_sec DateTime.truncate(@today, :second)
  @today_pm_sec DateTime.truncate(@today_pm, :second)
  @three_days_ago_sec DateTime.truncate(@three_days_ago, :second)

  defp session!(org, attrs) do
    Repo.insert!(struct!(Session, Map.merge(%{organization_id: org, title: "s"}, Map.new(attrs))))
  end

  defp ticket!(org, attrs) do
    # Direct struct merge (not struct!/2) so explicit nils — e.g. status — win
    # over schema defaults.
    Map.merge(%Ticket{organization_id: org, title: "t", ticket_type: "task"}, Map.new(attrs))
    |> Repo.insert!()
  end

  defp artifact!(org, attrs) do
    Repo.insert!(struct!(Artifact, Map.merge(%{organization_id: org, title: "a"}, Map.new(attrs))))
  end

  defp chat_room!(org, attrs) do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    Repo.insert!(
      struct!(
        ChatRoom,
        Map.merge(
          %{organization_id: org, name: "room", slug: "room-#{suffix}"},
          Map.new(attrs)
        )
      )
    )
  end

  defp review!(org, attrs) do
    Repo.insert!(
      struct!(
        Review,
        Map.merge(
          %{
            organization_id: org,
            title: "r",
            reviewer_persona: "w1a",
            artifact_id: Ecto.UUID.generate(),
            revision_id: Ecto.UUID.generate()
          },
          Map.new(attrs)
        )
      )
    )
  end

  defp project!(org, attrs) do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    Repo.insert!(
      struct!(
        Project,
        Map.merge(%{organization_id: org, name: "proj", slug: "proj-#{suffix}"}, Map.new(attrs))
      )
    )
  end

  # A fully-populated org covering every series/count/attention surface.
  defp seed!(org) do
    # Today @10:00 — lands in heatmap column 2 (div(10, 4)).
    session!(org, status: "active", inserted_at: @today, updated_at: @today)
    session!(org, status: "completed", inserted_at: @today, updated_at: @today)
    artifact!(org, kind: "doc", inserted_at: @today_sec, updated_at: @today_sec)
    artifact!(org, kind: "note", inserted_at: @today_sec, updated_at: @today_sec)
    chat_room!(org, inserted_at: @today_sec, updated_at: @today_sec)
    chat_room!(org, inserted_at: @today_sec, updated_at: @today_sec)
    ticket!(org, status: "open", inserted_at: @today_sec, updated_at: @today_sec)
    ticket!(org, status: "open", inserted_at: @today_sec, updated_at: @today_sec)
    review!(org, status: "open", inserted_at: @today_sec, updated_at: @today_sec)

    review!(org, status: "in_progress",
            inserted_at: @today_pm_sec, updated_at: @today_pm_sec)

    project!(org, inserted_at: @today, updated_at: @today)

    # Older rows — outside the default daily window where noted.
    session!(org, status: "active", inserted_at: @yesterday, updated_at: @yesterday)
    ticket!(org, status: "blocked",
            inserted_at: @three_days_ago_sec, updated_at: @three_days_ago_sec)

    ticket!(org, status: "in_review",
            inserted_at: @three_days_ago_sec, updated_at: @three_days_ago_sec)

    review!(org, status: "done",
            inserted_at: @three_days_ago_sec, updated_at: @three_days_ago_sec)

    session!(org, status: "archived",
             inserted_at: @forty_days_ago, updated_at: @forty_days_ago)
  end

  describe "stats/2" do
    test "returns the full aggregate shape for a populated org" do
      org = Ecto.UUID.generate()
      seed!(org)

      stats = Dashboard.stats(org)

      assert stats.range == 14

      assert stats.counts == %{
               projects: 1,
               sessions: 4,
               artifacts: 2,
               reviews: 3,
               tickets: 4,
               chat_rooms: 2
             }

      assert stats.by_status.sessions == %{"active" => 2, "completed" => 1, "archived" => 1}
      assert stats.by_status.tickets == %{"open" => 2, "blocked" => 1, "in_review" => 1}
      assert stats.by_kind.artifacts == %{"doc" => 1, "note" => 1}

      # Daily series: 14 ISO day keys ending today; 40-day-old session excluded.
      assert length(stats.daily.keys) == 14
      assert List.last(stats.daily.keys) == Date.to_iso8601(Date.utc_today())
      assert Enum.at(stats.daily.sessions, -1) == 2
      assert Enum.at(stats.daily.sessions, -2) == 1
      assert Enum.at(stats.daily.sessions, -3) == 0
      assert Enum.at(stats.daily.tickets, -1) == 2
      assert Enum.at(stats.daily.reviews, -1) == 2
      assert Enum.at(stats.daily.projects, -1) == 1
      assert Enum.at(stats.daily.chat_rooms, -1) == 2
      assert Enum.at(stats.daily.artifacts, -1) == 2

      # Weekly series: W1..W4 oldest → newest; current week (W4) holds the
      # rows from the last 7 calendar days.
      weeks = Enum.map(stats.weekly, & &1.week)
      assert weeks == ["W1", "W2", "W3", "W4"]
      w4 = List.last(stats.weekly)
      assert w4.sessions == 3
      assert w4.artifacts == 2
      assert w4.chat == 2
      # today's 2 open + the 3-days-ago blocked/in_review pair.
      assert w4.tickets == 4

      # Heatmap: 7 rows (Mon-first) × 6 four-hour buckets. All today's rows sit
      # at 10:00/15:00 → buckets 2 and 3 of today's row.
      heatmap = stats.heatmap
      assert length(heatmap) == 7
      assert Enum.all?(heatmap, &length(&1) == 6)

      pg_dow =
        @today
        |> DateTime.to_date()
        |> Date.day_of_week()
        |> case do
          7 -> 6
          d -> d - 1
        end

      assert Enum.at(heatmap, pg_dow) |> Enum.at(2) == 10
      assert Enum.at(heatmap, pg_dow) |> Enum.at(3) == 1
      assert List.flatten(heatmap) |> Enum.sum() == 16

      # Attention surfaces.
      assert length(stats.attention.open_reviews) == 2
      assert Enum.map(stats.attention.open_reviews, & &1.status) |> Enum.uniq() |> length() == 2
      assert length(stats.attention.blocked_tickets) == 2

      # Recent: capped at 8, newest first, ISO datetimes. Instants are compared
      # parsed — the five schemas serialize at mixed precisions
      # (:utc_datetime vs :utc_datetime_usec).
      assert length(stats.recent) == 8
      ats = Enum.map(stats.recent, & &1.at)
      parsed = Enum.map(ats, &(&1 |> DateTime.from_iso8601() |> elem(1)))
      assert parsed == Enum.sort(parsed, {:desc, DateTime})

      assert String.starts_with?(
               Enum.at(stats.recent, 0).at,
               Date.to_iso8601(DateTime.to_date(@today_pm)) <> "T15:00:00"
             )
      assert Enum.all?(stats.recent, fn r ->
               r.type in ~w(project session artifact review ticket) and is_binary(r.title)
             end)
    end

    test "returns zeros for an org with no data" do
      org = Ecto.UUID.generate()
      stats = Dashboard.stats(org)

      assert stats.counts == %{
               projects: 0,
               sessions: 0,
               artifacts: 0,
               reviews: 0,
               tickets: 0,
               chat_rooms: 0
             }

      assert stats.by_status.sessions == %{}
      assert stats.by_status.tickets == %{}
      assert stats.by_kind.artifacts == %{}
      assert Enum.all?(stats.daily.sessions, &(&1 == 0))
      assert List.flatten(stats.heatmap) |> Enum.all?(&(&1 == 0))
      assert stats.attention == %{open_reviews: [], blocked_tickets: []}
      assert stats.recent == []
    end

    test "is scoped to the given organization only" do
      mine = Ecto.UUID.generate()
      theirs = Ecto.UUID.generate()
      seed!(mine)
      session!(theirs, inserted_at: @today, updated_at: @today)

      stats = Dashboard.stats(mine)
      assert stats.counts.sessions == 4
      assert stats.counts.chat_rooms == 2
    end

    # NOTE: there is no test for count_by_field's `{nil, _} → "unknown"`
    # clause — sessions.status, tickets.status, and artifacts.kind are all
    # NOT NULL DEFAULT '…' in the schema, so a NULL can never reach it. The
    # clause (and its non-binary to_string fallback) is defensive dead code
    # under the current constraints.

    test "range option: valid integers pass through" do
      org = Ecto.UUID.generate()
      assert Dashboard.stats(org, range: 7).range == 7
      assert Dashboard.stats(org, range: 30).range == 30
      assert Dashboard.stats(org, range: 14).range == 14
      assert length(Dashboard.stats(org, range: 30).daily.keys) == 30
    end

    test "range option: binary integers are parsed" do
      org = Ecto.UUID.generate()
      assert Dashboard.stats(org, range: "7").range == 7
      assert Dashboard.stats(org, range: "30").range == 30
      assert length(Dashboard.stats(org, range: "30").daily.keys) == 30
    end

    test "range option: anything else falls back to the 14-day default" do
      org = Ecto.UUID.generate()
      assert Dashboard.stats(org, range: "banana").range == 14
      assert Dashboard.stats(org, range: :nope).range == 14
      assert Dashboard.stats(org, range: 999).range == 14
      assert Dashboard.stats(org).range == 14
    end
  end
end
