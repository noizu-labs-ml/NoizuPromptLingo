defmodule NoizuPromptLingua.Workers.SessionInactivityWorkerTest do
  @moduledoc """
  SessionInactivityWorker flips `active` → `inactive` when no activity has been
  recorded for the configured window (Liquibase 079). Cutoff semantics:
  `coalesce(last_activity_at, updated_at)`; only `active` rows are swept.
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Sessions.Session, as: Schema
  alias NoizuPromptLingua.Sessions
  alias NoizuPromptLingua.Workers.SessionInactivityWorker

  import Ecto.Query

  setup do
    {:ok, org_id: insert_org()}
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["sweep-#{System.unique_integer([:positive])}", "Sweep Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_session(org_id, attrs \\ %{}) do
    {:ok, session} = Sessions.create(Map.merge(%{organization_id: org_id, title: "S"}, attrs))
    session
  end

  # update_all with an explicit set bypasses autotimestamps, so we can backdate
  # both activity columns deterministically for cutoff-boundary tests.
  defp backdate(session_id, dt) do
    from(s in Schema, where: s.id == ^session_id)
    |> Repo.update_all(set: [last_activity_at: dt, updated_at: dt])
  end

  defp reload(session_id), do: Repo.get!(Schema, session_id)

  describe "perform/1 sweep" do
    test "marks a stale active session inactive, leaves a recent one active", %{org_id: org_id} do
      old = insert_session(org_id)
      recent = insert_session(org_id)

      backdate(old.id, DateTime.add(DateTime.utc_now(), -48, :hour))
      backdate(recent.id, DateTime.add(DateTime.utc_now(), -1, :hour))

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})

      assert reload(old.id).status == "inactive"
      assert reload(recent.id).status == "active"
    end

    test "inactive sessions stay inactive across repeat sweeps", %{org_id: org_id} do
      session = insert_session(org_id)
      backdate(session.id, DateTime.add(DateTime.utc_now(), -48, :hour))

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "inactive"

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "inactive"
    end

    test "archived and completed sessions are never swept", %{org_id: org_id} do
      archived = insert_session(org_id)
      completed = insert_session(org_id)

      {:ok, _} = Sessions.archive(archived.id)
      {:ok, _} = Sessions.update_session(completed.id, %{status: "completed"})

      # re-backdate after the archive/update writes reset the clock
      stale = DateTime.add(DateTime.utc_now(), -72, :hour)
      backdate(archived.id, stale)
      backdate(completed.id, stale)

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})

      assert reload(archived.id).status == "archived"
      assert reload(completed.id).status == "completed"
    end

    test "falls back to updated_at when last_activity_at is NULL", %{org_id: org_id} do
      session = insert_session(org_id)

      stale = DateTime.add(DateTime.utc_now(), -48, :hour)

      from(s in Schema, where: s.id == ^session.id)
      |> Repo.update_all(set: [last_activity_at: nil, updated_at: stale])

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "inactive"
    end

    test "cutoff boundary: activity exactly at the window stays active", %{org_id: org_id} do
      session = insert_session(org_id)
      # 23h old against a 24h window — inside
      backdate(session.id, DateTime.add(DateTime.utc_now(), -23, :hour))

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "active"
    end

    test "nil or 0 hours disables the sweep", %{org_id: org_id} do
      session = insert_session(org_id)
      backdate(session.id, DateTime.add(DateTime.utc_now(), -48, :hour))

      for hours <- [nil, 0] do
        Application.put_env(:noizu_prompt_lingua, :session_inactivity_hours, hours)
        on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :session_inactivity_hours) end)

        assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
        assert reload(session.id).status == "active"
      end

      Application.delete_env(:noizu_prompt_lingua, :session_inactivity_hours)
    end

    test "respects a smaller configured window", %{org_id: org_id} do
      session = insert_session(org_id)
      backdate(session.id, DateTime.add(DateTime.utc_now(), -2, :hour))

      Application.put_env(:noizu_prompt_lingua, :session_inactivity_hours, 1)
      on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :session_inactivity_hours) end)

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "inactive"
    end
  end

  describe "manual reactivation resets the clock" do
    test "inactive → active via update_session survives the next sweep", %{org_id: org_id} do
      session = insert_session(org_id)
      backdate(session.id, DateTime.add(DateTime.utc_now(), -48, :hour))

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "inactive"

      {:ok, reactivated} = Sessions.update_session(session.id, %{status: "active"})
      assert reactivated.status == "active"
      assert reactivated.last_activity_at != nil

      assert :ok = SessionInactivityWorker.perform(%Oban.Job{})
      assert reload(session.id).status == "active"
    end
  end
end
