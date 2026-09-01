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

    test "returns a session_url deep link", %{org_id: org_id} do
      assert {:ok, result} = SessionCreate.call(%{organization: org_id, title: "Linked"}, %{})

      assert String.contains?(
               result.session_url,
               "/app/#{org_slug(org_id)}/sessions/#{result.id}"
             )
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

    test "returns a session_url deep link", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "U3"})

      assert {:ok, result} = SessionUpdate.call(%{session: session.id, title: "Relinked"}, %{})

      assert String.contains?(
               result.session_url,
               "/app/#{org_slug(org_id)}/sessions/#{result.id}"
             )
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

  describe "inactivity tracking (Liquibase 079)" do
    alias NoizuPromptLingua.Domains.Chat
    alias NoizuPromptLingua.Domains.Memory.Store
    alias NoizuPromptLingua.Repo

    test "status validation accepts 'inactive'", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "I"})
      assert {:ok, updated} = Sessions.update_session(session.id, %{status: "inactive"})
      assert updated.status == "inactive"
    end

    test "create initializes last_activity_at to the insert time", %{org_id: org_id} do
      before = DateTime.utc_now() |> DateTime.add(-1, :second)
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "LA"})

      assert session.last_activity_at != nil
      assert DateTime.compare(session.last_activity_at, before) == :gt
    end

    test "update_session bumps last_activity_at", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "T"})
      stale = DateTime.utc_now() |> DateTime.add(-48, :hour)
      backdate(session.id, stale)

      assert {:ok, updated} = Sessions.update_session(session.id, %{title: "T2"})
      assert DateTime.compare(updated.last_activity_at, stale) == :gt
    end

    test "get_session bumps last_activity_at (REST show / MCP Session.Get path)", %{
      org_id: org_id
    } do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "G"})
      stale = DateTime.utc_now() |> DateTime.add(-48, :hour)
      backdate(session.id, stale)

      # get_session returns the pre-touch snapshot; read the row fresh
      Sessions.get_session(session.id)
      touched = Repo.get!(NoizuPromptLingua.Schema.Sessions.Session, session.id)
      assert DateTime.compare(touched.last_activity_at, stale) == :gt
    end

    test "a chat message in a session-linked room bumps last_activity_at", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "C"})

      {:ok, room} =
        Chat.create_room(%{organization_id: org_id, name: "R", session_id: session.id})

      stale = DateTime.utc_now() |> DateTime.add(-48, :hour)
      backdate(session.id, stale)

      assert {:ok, _msg} =
               Chat.send_message(%{room_id: room.id, content: "ping", sender: "tester"})

      touched = Repo.get!(NoizuPromptLingua.Schema.Sessions.Session, session.id)
      assert DateTime.compare(touched.last_activity_at, stale) == :gt
    end

    test "a memory write carrying session_id bumps last_activity_at", %{org_id: org_id} do
      {:ok, session} = Sessions.create(%{organization_id: org_id, title: "M"})
      stale = DateTime.utc_now() |> DateTime.add(-48, :hour)
      backdate(session.id, stale)

      context = %{
        organization_id: org_id,
        scope_type: :persona,
        scope_id: Ecto.UUID.generate()
      }

      assert {:ok, _} =
               Store.remember(
                 %{content: "session activity memory", session_id: session.id},
                 context
               )

      touched = Repo.get!(NoizuPromptLingua.Schema.Sessions.Session, session.id)
      assert DateTime.compare(touched.last_activity_at, stale) == :gt
    end
  end

  defp backdate(session_id, dt) do
    import Ecto.Query

    from(s in NoizuPromptLingua.Schema.Sessions.Session, where: s.id == ^session_id)
    |> Repo.update_all(set: [last_activity_at: dt])
  end

  defp org_slug(org_id) do
    NoizuPromptLingua.Repo.get!(NoizuPromptLingua.Schema.Organizations.Organization, org_id).slug
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
