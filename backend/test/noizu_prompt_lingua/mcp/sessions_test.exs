defmodule NoizuPromptLingua.MCP.SessionsTest do
  @moduledoc """
  Sessions carry an optional `model` + `runner` (spec §3) that tailor tool
  descriptions and may change mid-session. Covers the Sessions context and the
  Session.Create / Session.Update / Session.Get MCP tools.
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Sessions
  alias NoizuPromptLingua.MCP.Sessions.Tools.{SessionCreate, SessionUpdate, SessionGet}

  setup do
    {:ok, org_id: insert_org()}
  end

  describe "Sessions context" do
    test "create/1 persists model and runner", %{org_id: org_id} do
      {:ok, session} =
        Sessions.create(%{
          organization_id: org_id,
          title: "Ctx session",
          model: "5.4",
          runner: "codex"
        })

      assert session.model == "5.4"
      assert session.runner == "codex"
      # they round-trip out of the DB
      reloaded = Sessions.get_session(session.id)
      assert reloaded.model == "5.4"
      assert reloaded.runner == "codex"
    end

    test "create/1 leaves model and runner nil when omitted", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "Bare session"})
      assert session.model == nil
      assert session.runner == nil
    end

    test "update_session/2 changes model and runner mid-session", %{org_id: org_id} do
      {:ok, session} =
        Sessions.create(%{organization_id: org_id, title: "S", model: "5.4", runner: "codex"})

      {:ok, updated} = Sessions.update_session(session.id, %{model: "spark", runner: "grok"})
      assert updated.model == "spark"
      assert updated.runner == "grok"
    end
  end

  describe "Session.Create MCP tool" do
    test "accepts model + runner and persists + echoes them", %{org_id: org_id} do
      assert {:ok, result} =
               SessionCreate.call(
                 %{organization: org_id, title: "Created", model: "5.4", runner: "codex"},
                 %{}
               )

      assert result.model == "5.4"
      assert result.runner == "codex"

      stored = Sessions.get_session(result.id)
      assert stored.model == "5.4"
      assert stored.runner == "codex"
    end

    test "omitting model + runner yields nils", %{org_id: org_id} do
      assert {:ok, result} = SessionCreate.call(%{organization: org_id, title: "Plain"}, %{})
      assert result.model == nil
      assert result.runner == nil
    end
  end

  describe "Session.Update MCP tool" do
    test "updates model + runner and echoes them", %{org_id: org_id} do
      {:ok, session} =
        Sessions.create(%{organization_id: org_id, title: "U", model: "5.4", runner: "codex"})

      assert {:ok, result} =
               SessionUpdate.call(%{session: session.id, model: "spark", runner: "grok"}, %{})

      assert result.model == "spark"
      assert result.runner == "grok"

      assert Sessions.get_session(session.id).model == "spark"
      assert Sessions.get_session(session.id).runner == "grok"
    end

    test "an update that omits model + runner leaves them unchanged", %{org_id: org_id} do
      {:ok, session} =
        Sessions.create(%{organization_id: org_id, title: "U2", model: "5.4", runner: "codex"})

      assert {:ok, _} = SessionUpdate.call(%{session: session.id, title: "Renamed"}, %{})

      stored = Sessions.get_session(session.id)
      assert stored.title == "Renamed"
      assert stored.model == "5.4"
      assert stored.runner == "codex"
    end
  end

  describe "Session.Get MCP tool" do
    test "surfaces model + runner", %{org_id: org_id} do
      {:ok, session} =
        Sessions.create(%{organization_id: org_id, title: "G", model: "5.4", runner: "codex"})

      assert {:ok, result} = SessionGet.call(%{session: session.id}, %{})
      assert result.model == "5.4"
      assert result.runner == "codex"
    end
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["sesstest-#{System.unique_integer([:positive])}", "Session Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
