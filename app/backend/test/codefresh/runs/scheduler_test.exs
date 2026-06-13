defmodule Codefresh.Runs.SchedulerTest do
  @moduledoc """
  Cron-backed recurring run schedules (US-069).
  """

  use Codefresh.DataCase, async: false

  import Codefresh.Fixtures
  alias Codefresh.{Runs, Scripts, Agents}
  alias Codefresh.Runs.{Scheduler, ScheduledRun}
  alias Codefresh.Scripts.Script
  alias Codefresh.Agents.Agent

  defp openai_attrs do
    %{
      adapter: "openai",
      model: "gpt-4o",
      auth_ref: %{"type" => "secret_ref", "ref" => "infisical://proj/OPENAI_API_KEY"}
    }
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

  defp build_script!(org, user) do
    {:ok, script, v} =
      Scripts.create_script(%{
        "organization_id" => org.id,
        "name" => "Sched Flow #{System.unique_integer([:positive])}"
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

    {:ok, :published, _} = Scripts.publish_version(script, published_by_user_id: user.id)
    Scripts.get_script!(org.id, script.id)
  end

  defp setup_env do
    %{user: user, organization: org} = org_with_owner()
    agent = create_agent!(org, user)
    script = build_script!(org, user)

    script_head = Repo.get!(Script, script.id)
    script_version_id = script_head.current_version_id

    agent_head = Repo.get!(Agent, agent.id)
    agent_version_id = agent_head.current_version_id

    %{
      user: user,
      org: org,
      agent: agent,
      script: script,
      script_version_id: script_version_id,
      agent_version_id: agent_version_id
    }
  end

  describe "parse_cron/1" do
    test "accepts standard 5-field expressions" do
      assert {:ok, _} = Scheduler.parse_cron("0 2 * * *")
      assert {:ok, _} = Scheduler.parse_cron("*/15 * * * *")
      assert {:ok, _} = Scheduler.parse_cron("0 9-17 * * 1-5")
      assert {:ok, _} = Scheduler.parse_cron("0,15,30,45 * * * *")
    end

    test "rejects malformed expressions" do
      assert {:error, _} = Scheduler.parse_cron("not a cron")
      assert {:error, _} = Scheduler.parse_cron("0 99 * * *")
      assert {:error, _} = Scheduler.parse_cron("0 2 * *")
    end
  end

  describe "compute_next/2" do
    test "rolls forward to the next minute matching the spec" do
      from = ~U[2026-04-21 01:30:00Z]
      # every day at 02:00 UTC
      {:ok, next} = Scheduler.compute_next("0 2 * * *", from)
      assert next == ~U[2026-04-21 02:00:00Z]
    end

    test "crosses day boundary when the time has passed today" do
      from = ~U[2026-04-21 03:00:00Z]
      {:ok, next} = Scheduler.compute_next("0 2 * * *", from)
      assert next == ~U[2026-04-22 02:00:00Z]
    end

    test "every-15-minutes hits the next quarter" do
      from = ~U[2026-04-21 10:07:00Z]
      {:ok, next} = Scheduler.compute_next("*/15 * * * *", from)
      assert next == ~U[2026-04-21 10:15:00Z]
    end
  end

  describe "schedule_run/3" do
    test "creates a ScheduledRun and computes next_run_at" do
      env = setup_env()

      assert {:ok, %ScheduledRun{} = sr} =
               Scheduler.schedule_run(
                 env.script_version_id,
                 env.agent_version_id,
                 "*/5 * * * *",
                 created_by_user_id: env.user.id
               )

      assert sr.organization_id == env.org.id
      assert sr.enabled
      assert sr.next_run_at
    end

    test "rejects invalid cron expression" do
      env = setup_env()

      assert {:error, reason} =
               Scheduler.schedule_run(
                 env.script_version_id,
                 env.agent_version_id,
                 "not a cron"
               )

      # Either a parse-stage string reason or a changeset with cron_expression error.
      case reason do
        %Ecto.Changeset{} = cs ->
          refute cs.valid?
          assert cs.errors[:cron_expression]

        str when is_binary(str) ->
          assert str =~ "fields"
      end
    end

    test "rejects cross-org script + agent pairing" do
      a = setup_env()
      b = setup_env()

      assert {:error, :cross_org} =
               Scheduler.schedule_run(
                 a.script_version_id,
                 b.agent_version_id,
                 "0 2 * * *"
               )
    end
  end

  describe "tick/1" do
    test "due schedules enqueue runs with trigger_source=scheduled" do
      env = setup_env()

      {:ok, sr} =
        Scheduler.schedule_run(
          env.script_version_id,
          env.agent_version_id,
          "*/5 * * * *"
        )

      # Move next_run_at into the past so it's due.
      past = DateTime.add(DateTime.utc_now(), -60, :second) |> DateTime.truncate(:second)
      {:ok, _} = Scheduler.update_schedule(sr, %{next_run_at: past})

      results = Scheduler.tick(DateTime.utc_now())
      assert Enum.any?(results, fn r -> match?({:ok, _}, r) end)

      {:ok, %Codefresh.Runs.Run{} = run} = Enum.find(results, fn r -> match?({:ok, _}, r) end)
      assert run.trigger_source == "scheduled"

      reloaded = Repo.get!(ScheduledRun, sr.id)
      assert reloaded.last_triggered_at
      assert reloaded.last_run_id == run.id
      assert DateTime.compare(reloaded.next_run_at, past) == :gt
    end

    test "disabled schedules are not fired" do
      env = setup_env()

      {:ok, sr} =
        Scheduler.schedule_run(
          env.script_version_id,
          env.agent_version_id,
          "*/5 * * * *",
          enabled: false
        )

      past = DateTime.add(DateTime.utc_now(), -60, :second) |> DateTime.truncate(:second)
      {:ok, _} = Scheduler.update_schedule(sr, %{next_run_at: past})

      # No runs should be triggered for this org.
      pre_count = length(Runs.list_runs(env.org.id))
      _ = Scheduler.tick(DateTime.utc_now())
      post_count = length(Runs.list_runs(env.org.id))
      assert pre_count == post_count
    end

    test "schedules not yet due are skipped (no backfill)" do
      env = setup_env()
      future = DateTime.add(DateTime.utc_now(), 3600, :second) |> DateTime.truncate(:second)

      {:ok, _sr} =
        Scheduler.schedule_run(
          env.script_version_id,
          env.agent_version_id,
          "0 * * * *"
        )
        |> case do
          {:ok, sr} -> Scheduler.update_schedule(sr, %{next_run_at: future})
        end

      pre_count = length(Runs.list_runs(env.org.id))
      _ = Scheduler.tick(DateTime.utc_now())
      post_count = length(Runs.list_runs(env.org.id))
      assert pre_count == post_count
    end
  end

  describe "list_schedules/2" do
    test "scoped by organization" do
      a = setup_env()
      b = setup_env()

      {:ok, _} = Scheduler.schedule_run(a.script_version_id, a.agent_version_id, "0 2 * * *")
      {:ok, _} = Scheduler.schedule_run(b.script_version_id, b.agent_version_id, "0 3 * * *")

      assert length(Scheduler.list_schedules(a.org.id)) == 1
      assert length(Scheduler.list_schedules(b.org.id)) == 1
    end
  end
end
