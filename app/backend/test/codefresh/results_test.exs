defmodule Codefresh.ResultsTest do
  @moduledoc """
  Stage-6 Results + Dashboards coverage (US-025..US-032, US-077..US-080,
  US-129, US-130). All tests drive the worker synchronously via
  `Runs.Worker.execute_run/1` so runs are fully persisted with steps +
  scores before the Results queries run.
  """

  use Codefresh.DataCase, async: false

  import Codefresh.Fixtures
  alias Codefresh.{Results, Runs, Scripts, Agents, Personas}
  alias Codefresh.Runs.{Run, Worker}
  alias Codefresh.Results.Dashboard

  # ──────────────────────────────────────────────────────────────────────────
  # Fixture helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp openai_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        adapter: "openai",
        model: "gpt-4o",
        auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/OPENAI_API_KEY"}
      },
      overrides
    )
  end

  defp create_agent!(org, user) do
    {:ok, a} =
      Agents.create_agent(%{
        "organization_id" => org.id,
        "created_by_user_id" => user.id,
        "name" => "Agent #{System.unique_integer([:positive])}"
      })

    {:ok, :published, _v} =
      Agents.publish_version(a, Map.put(openai_attrs(), :published_by_user_id, user.id))

    Agents.get_agent!(org.id, a.id)
  end

  defp build_script!(org, user, name \\ "Flow") do
    {:ok, script, v} =
      Scripts.create_script(%{
        "organization_id" => org.id,
        "name" => "#{name} #{System.unique_integer([:positive])}"
      })

    {:ok, sn} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})
    {:ok, en} = Scripts.add_node(v, %{"node_key" => "end", "kind" => "terminal"})

    {:ok, _exp} =
      Scripts.add_expectation(sn, %{
        "organization_id" => org.id,
        "label" => "must contain stub",
        "scoring_method" => "regex",
        "config" => %{"pattern" => "stub"}
      })

    {:ok, _edge} =
      Scripts.add_edge(v, %{
        "from_node_id" => sn.id,
        "to_node_id" => en.id,
        "match_method" => "always"
      })

    {:ok, :published, _pub} = Scripts.publish_version(script, published_by_user_id: user.id)
    {Scripts.get_script!(org.id, script.id), sn, en}
  end

  defp run_and_finish!(script, agent, opts \\ []) do
    {:ok, run} = Runs.trigger_run(script, agent.id, Keyword.merge([enqueue: false], opts))
    {:ok, finished} = Worker.execute_run(run.id)
    finished
  end

  defp setup_org do
    %{user: user, organization: org} = org_with_owner()
    agent = create_agent!(org, user)
    %{user: user, org: org, agent: agent}
  end

  defp backdate_run!(%Run{} = run, days_ago) do
    inserted_at =
      DateTime.utc_now()
      |> DateTime.add(-days_ago * 86_400, :second)
      |> DateTime.truncate(:second)

    Repo.update_all(
      from(r in Run, where: r.id == ^run.id),
      set: [inserted_at: inserted_at]
    )

    Runs.get_run(run.organization_id, run.id)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-025..US-028 — list_runs w/ filters
  # ──────────────────────────────────────────────────────────────────────────

  describe "list_runs/2 filter combinations (US-025..US-028)" do
    test "filters by script_id and agent_id" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script_a, _, _} = build_script!(org, u, "A")
      {script_b, _, _} = build_script!(org, u, "B")

      ra = run_and_finish!(script_a, agent)
      _rb = run_and_finish!(script_b, agent)

      only_a = Results.list_runs(org.id, script_id: script_a.id)
      assert Enum.any?(only_a, &(&1.id == ra.id))
      assert Enum.all?(only_a, &(&1.organization_id == org.id))
      assert length(only_a) == 1

      by_agent = Results.list_runs(org.id, agent_id: agent.id)
      assert length(by_agent) == 2
    end

    test "filters by status list" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      _ = run_and_finish!(script, agent)

      {:ok, pending} = Runs.trigger_run(script, agent.id, enqueue: false)
      ids = Results.list_runs(org.id, status: ["pending"]) |> Enum.map(& &1.id)
      assert pending.id in ids
    end

    test "filters by since/until date range" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)

      fresh = run_and_finish!(script, agent)
      old = run_and_finish!(script, agent)
      old = backdate_run!(old, 10)

      since = DateTime.utc_now() |> DateTime.add(-1 * 86_400, :second)
      recent_ids = Results.list_runs(org.id, since: since) |> Enum.map(& &1.id)
      assert fresh.id in recent_ids
      refute old.id in recent_ids
    end

    test "search filters by script name" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script_a, _, _} = build_script!(org, u, "Checkout")
      {script_b, _, _} = build_script!(org, u, "Refund")
      ra = run_and_finish!(script_a, agent)
      rb = run_and_finish!(script_b, agent)

      matches = Results.list_runs(org.id, search: "checkout")
      assert Enum.any?(matches, &(&1.id == ra.id))
      refute Enum.any?(matches, &(&1.id == rb.id))

      zero = Results.list_runs(org.id, search: "nonexistent-xyz")
      assert zero == []
    end

    test "pagination via limit + offset" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      for _ <- 1..5, do: run_and_finish!(script, agent)

      page1 = Results.list_runs(org.id, limit: 2, offset: 0)
      page2 = Results.list_runs(org.id, limit: 2, offset: 2)
      assert length(page1) == 2
      assert length(page2) == 2
      assert MapSet.disjoint?(MapSet.new(Enum.map(page1, & &1.id)), MapSet.new(Enum.map(page2, & &1.id)))

      assert Results.count_runs(org.id) >= 5
    end

    test "cross-org rejection: other org's runs never leak in" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      r1 = run_and_finish!(script, agent)

      %{user: other_u, organization: other_org} = org_with_owner()
      other_agent = create_agent!(other_org, other_u)
      {other_script, _, _} = build_script!(other_org, other_u)
      r2 = run_and_finish!(other_script, other_agent)

      our_ids = Results.list_runs(org.id) |> Enum.map(& &1.id)
      assert r1.id in our_ids
      refute r2.id in our_ids
    end

    test "verdict filter matches summary_metrics verdict" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      _ = run_and_finish!(script, agent)

      passes = Results.list_runs(org.id, verdict: "pass")
      assert Enum.any?(passes, fn r -> Map.get(r.summary_metrics || %{}, "verdict") == "pass" end)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-029 / US-030 — Run detail + timeline
  # ──────────────────────────────────────────────────────────────────────────

  describe "get_run_detail/2 (US-029/US-030)" do
    test "returns run + steps + scores + script + agent + verdict" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      detail = Results.get_run_detail(org.id, finished.id)
      assert detail.run.id == finished.id
      assert detail.script.id == script.id
      assert detail.agent.id == agent.id
      assert length(detail.steps) >= 1
      assert is_map(detail.step_scores)
      assert detail.verdict.verdict in ~w(pass warn fail)
    end

    test "cross-org returns nil" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      %{organization: other} = org_with_owner()
      assert Results.get_run_detail(other.id, finished.id) == nil
    end

    test "bad uuid returns nil (no crash)" do
      %{org: org} = setup_org()
      assert Results.get_run_detail(org.id, "not-a-uuid") == nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-031 — Step detail
  # ──────────────────────────────────────────────────────────────────────────

  describe "get_step_detail/3 (US-031)" do
    test "returns step + scores" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      step = finished |> Runs.list_steps() |> List.first()
      detail = Results.get_step_detail(org.id, finished.id, step.step_index)
      assert detail.step.id == step.id
      assert is_list(detail.scores)
    end

    test "cross-org returns nil" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)
      step = finished |> Runs.list_steps() |> List.first()

      %{organization: other} = org_with_owner()
      assert Results.get_step_detail(other.id, finished.id, step.step_index) == nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-077 — Cross-run diff
  # ──────────────────────────────────────────────────────────────────────────

  describe "diff_runs/3 (US-077)" do
    test "diffs two runs of the same script, pairs steps by step_index" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      r1 = run_and_finish!(script, agent)
      r2 = run_and_finish!(script, agent)

      assert {:ok, diff} = Results.diff_runs(org.id, r1.id, r2.id)
      assert diff.left.run.id == r1.id
      assert diff.right.run.id == r2.id
      assert length(diff.steps) >= 1
      first = hd(diff.steps)
      assert first.aligned? == true
      assert first.left.step_index == first.right.step_index
      assert is_map(diff.verdict_comparison)
    end

    test "unknown run id → :not_found" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      r1 = run_and_finish!(script, agent)

      fake = Ecto.UUID.generate()
      assert {:error, :not_found} = Results.diff_runs(org.id, r1.id, fake)
    end

    test "diff refuses cross-org" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      r1 = run_and_finish!(script, agent)

      %{user: ou, organization: other} = org_with_owner()
      other_agent = create_agent!(other, ou)
      {other_script, _, _} = build_script!(other, ou)
      r2 = run_and_finish!(other_script, other_agent)

      assert {:error, :not_found} = Results.diff_runs(org.id, r1.id, r2.id)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-078 — Trend chart
  # ──────────────────────────────────────────────────────────────────────────

  describe "verdict_trend/3 (US-078)" do
    test "rolls up runs by day for the last N days" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)

      _today = run_and_finish!(script, agent)
      old = run_and_finish!(script, agent)
      _ = backdate_run!(old, 5)

      rows = Results.verdict_trend(org.id, 7)
      assert length(rows) == 7
      assert Enum.all?(rows, &Map.has_key?(&1, :date))
      assert Enum.all?(rows, &Map.has_key?(&1, :pass))
      assert Enum.all?(rows, &Map.has_key?(&1, :total))
      assert Enum.sum(Enum.map(rows, & &1.total)) >= 2
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-129 — Cohort summary
  # ──────────────────────────────────────────────────────────────────────────

  describe "cohort_summary/2 (US-129)" do
    test "aggregates verdicts and per-script-version rollup" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      _ = run_and_finish!(script, agent)
      _ = run_and_finish!(script, agent)

      summary = Results.cohort_summary(org.id, script_id: script.id)
      assert summary.total >= 2
      assert summary.verdicts.pass + summary.verdicts.warn + summary.verdicts.fail + summary.verdicts.other == summary.total
      assert is_list(summary.by_script_version)
    end

    test "cohort filtering by persona" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)

      {:ok, persona} =
        Personas.create_persona(%{
          "organization_id" => org.id,
          "created_by_user_id" => u.id,
          "name" => "Priya #{System.unique_integer([:positive])}"
        })

      {:ok, :published, pv} =
        Personas.publish_version(persona, %{tone: "curt", published_by_user_id: u.id})

      r_with = run_and_finish!(script, agent, persona_version_ids: [pv.id])
      _r_without = run_and_finish!(script, agent)

      summary = Results.cohort_summary(org.id, persona_version_id: pv.id)
      assert summary.total == 1
      [by_sv | _] = summary.by_script_version
      assert by_sv.script_version_id == r_with.script_version_id
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-032 — Export
  # ──────────────────────────────────────────────────────────────────────────

  describe "export_run/3 (US-032)" do
    test "json export contains run + steps + scores" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      assert {:ok, json} = Results.export_run(org.id, finished.id, format: :json)
      payload = Jason.decode!(json)
      assert payload["run"]["id"] == finished.id
      assert is_list(payload["steps"])
      assert payload["verdict"]["verdict"] in ~w(pass warn fail)
    end

    test "csv export shape: header + one row per step/score" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      assert {:ok, csv} = Results.export_run(org.id, finished.id, format: :csv)
      lines = String.split(csv, "\n", trim: true)
      [header | rows] = lines
      assert header =~ "run_id"
      assert header =~ "step_index"
      assert header =~ "verdict"
      assert rows != []
      assert Enum.all?(rows, fn r -> String.starts_with?(r, finished.id) end)
    end

    test "export rejects cross-org" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      %{organization: other} = org_with_owner()
      assert {:error, :not_found} = Results.export_run(other.id, finished.id, format: :json)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-079 — Expectation breakdown
  # ──────────────────────────────────────────────────────────────────────────

  describe "expectation_breakdown/2 (US-079)" do
    test "rows include label + verdict counts per authored expectation" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      rows = Results.expectation_breakdown(org.id, finished.id)
      assert is_list(rows)
      assert Enum.any?(rows, &(&1.kind == "authored"))
      row = List.first(rows)
      assert Map.has_key?(row, :pass)
      assert Map.has_key?(row, :warn)
      assert Map.has_key?(row, :fail)
      assert Map.has_key?(row, :total)
    end

    test "cross-org returns nil" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      %{organization: other} = org_with_owner()
      assert Results.expectation_breakdown(other.id, finished.id) == nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-080 — Regression detection
  # ──────────────────────────────────────────────────────────────────────────

  describe "regression_report/2 (US-080)" do
    test "first-ever run has no baseline" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      report = Results.regression_report(org.id, finished.id)
      assert report.run_id == finished.id
      assert report.baseline_run_id == nil
      assert report.regressions == []
    end

    test "finds baseline among prior terminal runs on same script" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      r1 = run_and_finish!(script, agent)
      _ = backdate_run!(r1, 1)
      r2 = run_and_finish!(script, agent)

      report = Results.regression_report(org.id, r2.id)
      assert report.run_id == r2.id
      assert report.baseline_run_id == r1.id
      assert is_list(report.regressions)
    end

    test "cross-org returns nil" do
      %{user: u, org: org, agent: agent} = setup_org()
      {script, _, _} = build_script!(org, u)
      finished = run_and_finish!(script, agent)

      %{organization: other} = org_with_owner()
      assert Results.regression_report(other.id, finished.id) == nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-130 — Saved dashboards
  # ──────────────────────────────────────────────────────────────────────────

  describe "save_dashboard/1 + get_dashboard/2 (US-130)" do
    test "creates a dashboard with a published version" do
      %{user: u, organization: org} = org_with_owner()

      layout = %{"widgets" => [%{"type" => "trend", "days" => 14}]}

      assert {:ok, %Dashboard{} = d} =
               Results.save_dashboard(%{
                 name: "Weekly Review",
                 layout: layout,
                 organization_id: org.id,
                 created_by_user_id: u.id,
                 published_by_user_id: u.id
               })

      assert d.slug == "weekly-review"
      assert d.current_version_id
      assert d.layout == layout

      fetched = Results.get_dashboard(org.id, d.id)
      assert fetched.layout == layout
    end

    test "re-saving identical layout does not create a new version" do
      %{user: u, organization: org} = org_with_owner()
      layout = %{"widgets" => []}

      {:ok, d1} =
        Results.save_dashboard(%{
          "name" => "A",
          "layout" => layout,
          "organization_id" => org.id,
          "created_by_user_id" => u.id
        })

      {:ok, d2} =
        Results.save_dashboard(%{
          "id" => d1.id,
          "name" => "A",
          "layout" => layout,
          "organization_id" => org.id
        })

      assert d1.current_version_id == d2.current_version_id
    end

    test "list_dashboards is org-scoped" do
      %{user: u, organization: org} = org_with_owner()
      {:ok, _} = Results.save_dashboard(%{"name" => "X", "layout" => %{}, "organization_id" => org.id, "created_by_user_id" => u.id})

      %{organization: other} = org_with_owner()
      assert Results.list_dashboards(org.id) |> length() == 1
      assert Results.list_dashboards(other.id) == []
    end

    test "archive_dashboard hides from list" do
      %{user: u, organization: org} = org_with_owner()

      {:ok, d} =
        Results.save_dashboard(%{
          "name" => "To Archive",
          "layout" => %{},
          "organization_id" => org.id,
          "created_by_user_id" => u.id
        })

      {:ok, _} = Results.archive_dashboard(d)
      assert Enum.all?(Results.list_dashboards(org.id), &(&1.id != d.id))
    end
  end
end
