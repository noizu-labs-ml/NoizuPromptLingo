defmodule Codefresh.AutoFlagTest do
  @moduledoc """
  Stage 10+ auto-flag rule engine (US-106 auto mode, US-147).

  Oban runs `testing: :manual` in the test config so the worker is invoked
  directly via `Codefresh.AutoFlag.Worker.perform/1` / `eval_rules_against_run/1`.
  """

  use Codefresh.DataCase, async: false

  import Codefresh.Fixtures

  alias Codefresh.{AutoFlag, Agents, Repo, Runs, Scripts}
  alias Codefresh.AutoFlag.{Rule, Worker}
  alias Codefresh.Datasets.FlaggedCapture
  alias Codefresh.Otel.Span
  alias Codefresh.Runs.{Run, RunStep, Score}

  # ──────────────────────────────────────────────────────────────────────────
  # Fixture helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp create_agent!(org, user) do
    {:ok, a} =
      Agents.create_agent(%{
        "organization_id" => org.id,
        "created_by_user_id" => user.id,
        "name" => "Agent #{System.unique_integer([:positive])}"
      })

    {:ok, :published, _v} =
      Agents.publish_version(a, %{
        adapter: "openai",
        model: "gpt-4o",
        auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/OPENAI_API_KEY"},
        published_by_user_id: user.id
      })

    Agents.get_agent!(org.id, a.id)
  end

  defp build_script!(org, user) do
    {:ok, script, v} =
      Scripts.create_script(%{
        "organization_id" => org.id,
        "name" => "Flow #{System.unique_integer([:positive])}"
      })

    {:ok, start_node} = Scripts.add_node(v, %{"node_key" => "start", "kind" => "user_turn"})
    {:ok, end_node} = Scripts.add_node(v, %{"node_key" => "end", "kind" => "terminal"})

    {:ok, exp} =
      Scripts.add_expectation(start_node, %{
        "organization_id" => org.id,
        "label" => "must contain stub",
        "scoring_method" => "regex",
        "config" => %{"pattern" => "stub"}
      })

    {:ok, _edge} =
      Scripts.add_edge(v, %{
        "from_node_id" => start_node.id,
        "to_node_id" => end_node.id,
        "match_method" => "always"
      })

    {:ok, :published, _pub} = Scripts.publish_version(script, published_by_user_id: user.id)
    {Scripts.get_script!(org.id, script.id), start_node, exp}
  end

  defp seed_completed_run!(org, user) do
    agent = create_agent!(org, user)
    {script, start_node, exp} = build_script!(org, user)

    {:ok, run} =
      Runs.trigger_run(script, agent.id, triggered_by_user_id: user.id, enqueue: false)

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    run =
      run
      |> Run.summary_changeset(%{status: "passed", finished_at: now, summary_metrics: %{}})
      |> Repo.update!()

    {:ok, step} =
      %RunStep{}
      |> RunStep.create_changeset(%{
        "run_id" => run.id,
        "organization_id" => org.id,
        "step_index" => 0,
        "from_node_id" => start_node.id,
        "user_message" => "hello there friend",
        "agent_message" => "I am unable to help with that topic.",
        "tokens_in" => 10,
        "tokens_out" => 20,
        "latency_ms" => 120,
        "status" => "ok",
        "trace_id" => "trace-#{System.unique_integer([:positive])}"
      })
      |> Repo.insert()

    %{run: run, step: step, expectation: exp, start_node: start_node}
  end

  defp insert_score!(step, expectation, organization_id, score_value) do
    %Score{}
    |> Score.create_changeset(%{
      "run_step_id" => step.id,
      "organization_id" => organization_id,
      "expectation_id" => expectation.id,
      "scoring_method" => "regex",
      "score" => Decimal.from_float(score_value * 1.0),
      "verdict" => if(score_value < 0.5, do: "fail", else: "pass"),
      "rationale" => "test",
      "scored_at" => DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> Repo.insert!()
  end

  defp insert_span!(run, step, organization_id, overrides) do
    now = DateTime.utc_now()

    attrs =
      Map.merge(
        %{
          "organization_id" => organization_id,
          "run_id" => run.id,
          "run_step_id" => step.id,
          "trace_id" => "trace-#{System.unique_integer([:positive])}",
          "span_id" => "span-#{System.unique_integer([:positive])}",
          "name" => "llm.invoke",
          "kind" => "client",
          "start_time" => now,
          "end_time" => DateTime.add(now, 250, :millisecond),
          "duration_ns" => 250 * 1_000_000,
          "status_code" => "ok",
          "attributes" => %{}
        },
        overrides
      )

    %Span{}
    |> Span.create_changeset(attrs)
    |> Repo.insert!()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Rule CRUD
  # ──────────────────────────────────────────────────────────────────────────

  describe "create_rule/2 (US-147)" do
    test "creates a valid score_threshold rule with defaults" do
      %{organization: org} = org_with_owner()

      assert {:ok, %Rule{} = rule} =
               AutoFlag.create_rule(org.id, %{
                 name: "Low-score production bugs",
                 rule_type: "score_threshold",
                 config: %{"score_below" => 0.3},
                 default_reason: "bug",
                 default_tags: ["production", "low-score"]
               })

      assert rule.organization_id == org.id
      assert rule.enabled == true
      assert rule.match_count == 0
      assert rule.soft_deleted_at == nil
      assert "production" in rule.default_tags
    end

    test "rejects a regex rule with an invalid pattern" do
      %{organization: org} = org_with_owner()

      assert {:error, cs} =
               AutoFlag.create_rule(org.id, %{
                 name: "broken",
                 rule_type: "regex",
                 config: %{"pattern" => "[unclosed"},
                 default_reason: "deviation"
               })

      refute cs.valid?
      assert %{config: [msg]} = Ecto.Changeset.traverse_errors(cs, fn {m, _} -> m end)
      assert msg =~ "invalid regex"
    end

    test "rejects unknown rule_type" do
      %{organization: org} = org_with_owner()

      assert {:error, cs} =
               AutoFlag.create_rule(org.id, %{
                 name: "bogus",
                 rule_type: "telepathy",
                 config: %{},
                 default_reason: "deviation"
               })

      refute cs.valid?
    end

    test "list_rules hides soft-deleted by default" do
      %{organization: org} = org_with_owner()

      {:ok, a} =
        AutoFlag.create_rule(org.id, %{
          name: "alpha",
          rule_type: "token_count_exceeds",
          config: %{"threshold" => 100},
          default_reason: "edge_case"
        })

      {:ok, b} =
        AutoFlag.create_rule(org.id, %{
          name: "beta",
          rule_type: "token_count_exceeds",
          config: %{"threshold" => 100},
          default_reason: "edge_case"
        })

      {:ok, _} = AutoFlag.soft_delete_rule(b)

      ids = AutoFlag.list_rules(org.id) |> Enum.map(& &1.id)
      assert a.id in ids
      refute b.id in ids

      all = AutoFlag.list_rules(org.id, include_deleted: true) |> Enum.map(& &1.id)
      assert b.id in all
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Evaluation — rule matching
  # ──────────────────────────────────────────────────────────────────────────

  describe "eval_rules_against_run/1 (US-147)" do
    test "score_threshold rule flags step whose score is below threshold" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step, expectation: exp} = seed_completed_run!(org, u)

      insert_score!(step, exp, org.id, 0.1)

      {:ok, rule} =
        AutoFlag.create_rule(org.id, %{
          name: "score < 0.3",
          rule_type: "score_threshold",
          config: %{"score_below" => 0.3},
          default_reason: "bug",
          default_tags: ["low-score"]
        })

      assert {:ok, %{rules_applied: 1, captures_created: 1}} =
               AutoFlag.eval_rules_against_run(run.id)

      [cap] =
        Repo.all(
          from fc in FlaggedCapture,
            where: fc.organization_id == ^org.id
        )

      assert cap.auto_rule_id == rule.id
      assert cap.flagged_by_user_id == nil
      assert cap.reason == "bug"
      assert "low-score" in cap.tags
      assert "auto-flag" in cap.tags
      assert cap.source_run_step_id == step.id

      reloaded = Repo.get!(Rule, rule.id)
      assert reloaded.match_count == 1
    end

    test "attribute_contains rule fires on correlated span attribute" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step} = seed_completed_run!(org, u)

      insert_span!(run, step, org.id, %{
        "name" => "http.call",
        "attributes" => %{"http.url" => "https://api.foo.example/search?q=x"}
      })

      {:ok, _rule} =
        AutoFlag.create_rule(org.id, %{
          name: "risky endpoint",
          rule_type: "attribute_contains",
          config: %{"attribute" => "http.url", "substring" => "api.foo"},
          default_reason: "edge_case"
        })

      assert {:ok, %{captures_created: 1}} = AutoFlag.eval_rules_against_run(run.id)
    end

    test "regex rule against agent response fires only on match" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run} = seed_completed_run!(org, u)

      {:ok, _matcher} =
        AutoFlag.create_rule(org.id, %{
          name: "refusal",
          rule_type: "regex",
          config: %{"target" => "response", "pattern" => "unable to help"},
          default_reason: "bug"
        })

      {:ok, _non_matcher} =
        AutoFlag.create_rule(org.id, %{
          name: "never matches",
          rule_type: "regex",
          config: %{"target" => "response", "pattern" => "IMPOSSIBLE_TOKEN_XYZ"},
          default_reason: "deviation"
        })

      assert {:ok, %{rules_applied: 2, captures_created: 1}} =
               AutoFlag.eval_rules_against_run(run.id)
    end

    test "no active rules → no captures, no error" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run} = seed_completed_run!(org, u)

      assert {:ok, %{rules_applied: 0, captures_created: 0}} =
               AutoFlag.eval_rules_against_run(run.id)

      assert [] = Repo.all(from fc in FlaggedCapture, where: fc.organization_id == ^org.id)
    end

    test "disabled rules are skipped" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step, expectation: exp} = seed_completed_run!(org, u)
      insert_score!(step, exp, org.id, 0.05)

      {:ok, rule} =
        AutoFlag.create_rule(org.id, %{
          name: "paused",
          rule_type: "score_threshold",
          config: %{"score_below" => 0.9},
          default_reason: "bug"
        })

      {:ok, _} = AutoFlag.update_rule(rule, %{"enabled" => false})

      assert {:ok, %{rules_applied: 0, captures_created: 0}} =
               AutoFlag.eval_rules_against_run(run.id)
    end

    test "cross-org rules never evaluate against another org's run" do
      %{user: ua, organization: org_a} = org_with_owner()
      %{user: ub, organization: org_b} = org_with_owner()

      %{run: run_b} = seed_completed_run!(org_b, ub)

      # Rule in org A — should not match org B's run even with a matching payload.
      {:ok, _rule_a} =
        AutoFlag.create_rule(org_a.id, %{
          name: "org A only",
          rule_type: "regex",
          config: %{"target" => "response", "pattern" => ".+"},
          default_reason: "deviation"
        })

      _ = ua

      assert {:ok, %{rules_applied: 0, captures_created: 0}} =
               AutoFlag.eval_rules_against_run(run_b.id)

      assert [] = Repo.all(from fc in FlaggedCapture, where: fc.organization_id == ^org_a.id)
      assert [] = Repo.all(from fc in FlaggedCapture, where: fc.organization_id == ^org_b.id)
    end

    test "latency_exceeds_ms fires on step latency" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step} = seed_completed_run!(org, u)

      # Bump the step's latency to exceed the threshold.
      step
      |> Ecto.Changeset.change(latency_ms: 9_000)
      |> Repo.update!()

      {:ok, _} =
        AutoFlag.create_rule(org.id, %{
          name: "slow",
          rule_type: "latency_exceeds_ms",
          config: %{"threshold_ms" => 5_000},
          default_reason: "edge_case"
        })

      assert {:ok, %{captures_created: 1}} = AutoFlag.eval_rules_against_run(run.id)
    end

    test "rule bumps match_count once per matching step per pass" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step, expectation: exp} = seed_completed_run!(org, u)

      # Two scores on the same step — both below threshold. Should still produce
      # exactly ONE capture for the step (dedup on {rule_id, step_id}).
      insert_score!(step, exp, org.id, 0.01)
      insert_score!(step, exp, org.id, 0.02)

      {:ok, rule} =
        AutoFlag.create_rule(org.id, %{
          name: "dedup",
          rule_type: "score_threshold",
          config: %{"score_below" => 0.5},
          default_reason: "regression"
        })

      assert {:ok, %{captures_created: 1}} = AutoFlag.eval_rules_against_run(run.id)
      assert Repo.get!(Rule, rule.id).match_count == 1
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Worker — Oban job wrapper
  # ──────────────────────────────────────────────────────────────────────────

  describe "Worker.perform/1" do
    test "discards when run_id is unknown" do
      job = %Oban.Job{args: %{"run_id" => Ecto.UUID.generate()}}
      assert {:discard, :run_not_found} = Worker.perform(job)
    end

    test "invoked with a live run_id evaluates rules and emits captures" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run, step: step, expectation: exp} = seed_completed_run!(org, u)
      insert_score!(step, exp, org.id, 0.0)

      {:ok, _} =
        AutoFlag.create_rule(org.id, %{
          name: "fail-floor",
          rule_type: "score_threshold",
          config: %{"score_below" => 0.1},
          default_reason: "bug"
        })

      job = %Oban.Job{args: %{"run_id" => run.id}}
      assert :ok = Worker.perform(job)

      assert Repo.aggregate(
               from(fc in FlaggedCapture, where: fc.organization_id == ^org.id),
               :count,
               :id
             ) == 1
    end

    test "schedule_eval enqueues an Oban job" do
      %{user: u, organization: org} = org_with_owner()
      %{run: run} = seed_completed_run!(org, u)

      assert {:ok, %Oban.Job{} = job} = AutoFlag.schedule_eval(run.id)
      assert job.args["run_id"] == run.id
      assert job.queue == "default"
      assert job.worker == "Codefresh.AutoFlag.Worker"
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Misc
  # ──────────────────────────────────────────────────────────────────────────

  describe "get_rule/2" do
    test "returns nil on cross-org lookup" do
      %{organization: a} = org_with_owner()
      %{organization: b} = org_with_owner()

      {:ok, rule} =
        AutoFlag.create_rule(a.id, %{
          name: "org-a",
          rule_type: "token_count_exceeds",
          config: %{"threshold" => 5},
          default_reason: "deviation"
        })

      assert AutoFlag.get_rule(a.id, rule.id) != nil
      assert AutoFlag.get_rule(b.id, rule.id) == nil
    end
  end

end
