defmodule NoizuPromptLingua.SessionsContextTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Work-session lifecycle (entities/sessions.ex): create with activity stamp,
  read-touch, org listing with filters, update/archive/unarchive, delete, and
  the best-effort touch_activity guards.
  """

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Sessions

  setup do
    n = System.unique_integer([:positive])

    org = %Organization{name: "Sess Org #{n}", slug: "sess-org-#{n}"} |> Repo.insert!()

    user =
      %NoizuPromptLingua.Schema.Users.User{
        email: "sess-#{n}@example.com",
        user_name: "sess_user#{n}",
        handle: "sess_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    project =
      %Project{organization_id: org.id, name: "Sess Proj", slug: "sess-proj-#{n}"}
      |> Repo.insert!()

    %{org: org, project: project, user: user}
  end

  test "create stamps last_activity_at and optional created_by", %{org: org, user: user} do
    assert {:ok, session} =
             Sessions.create(%{organization_id: org.id, title: "t1", status: "active"}, user.id)

    assert session.created_by == user.id
    assert session.last_activity_at
    assert session.status == "active"
  end

  test "get_session touches activity; missing id returns nil", %{org: org} do
    {:ok, session} = Sessions.create(%{organization_id: org.id, title: "t2"}, nil)
    stale = DateTime.add(session.last_activity_at, -3600)

    session
    |> Ecto.Changeset.change(last_activity_at: stale)
    |> Repo.update!()

    assert fetched = Sessions.get_session(session.id)
    assert fetched.id == session.id
    # the read bumped the clock past `stale`
    assert DateTime.compare(Repo.reload!(session).last_activity_at, stale) == :gt

    assert Sessions.get_session(Ecto.UUID.generate()) == nil
  end

  test "list_for_org filters by status/project and windows limit/offset", %{
    org: org,
    project: project
  } do
    {:ok, s1} = Sessions.create(%{organization_id: org.id, title: "a"}, nil)

    {:ok, s2} =
      Sessions.create(%{organization_id: org.id, title: "b", project_id: project.id}, nil)

    {:ok, s3} = Sessions.create(%{organization_id: org.id, title: "c"}, nil)
    Sessions.archive(s3.id)

    all = Sessions.list_for_org(org.id)
    assert length(all) == 3

    assert Enum.map(Sessions.list_for_org(org.id, limit: 2), & &1.id) == [s3.id, s2.id]
    assert [%{id: id}] = Sessions.list_for_org(org.id, offset: 2)
    assert id == s1.id

    assert [%{id: s2_id}] = Sessions.list_for_org(org.id, project_id: project.id)
    assert s2_id == s2.id

    assert [%{status: "archived"}] = Sessions.list_for_org(org.id, status: "archived")
    assert Sessions.list_for_org(org.id, status: "nonexistent-status") == []
  end

  test "update_session bumps activity and applies attrs; missing id is not_found", %{org: org} do
    {:ok, session} = Sessions.create(%{organization_id: org.id, title: "before"}, nil)

    assert {:ok, updated} = Sessions.update_session(session.id, %{title: "after"})
    assert updated.title == "after"

    assert {:error, :not_found} = Sessions.update_session(Ecto.UUID.generate(), %{title: "x"})
  end

  test "archive/unarchive round-trip flips status and timestamps", %{org: org} do
    {:ok, session} = Sessions.create(%{organization_id: org.id, title: "arch"}, nil)

    assert {:ok, archived} = Sessions.archive(session.id)
    assert archived.status == "archived"
    assert archived.archived_at

    assert {:ok, unarchived} = Sessions.unarchive(session.id)
    assert unarchived.status == "active"
    assert unarchived.archived_at == nil

    assert {:error, :not_found} = Sessions.archive(Ecto.UUID.generate())
    assert {:error, :not_found} = Sessions.unarchive(Ecto.UUID.generate())
  end

  test "delete_session removes the row and reports not_found after", %{org: org} do
    {:ok, session} = Sessions.create(%{organization_id: org.id, title: "gone"}, nil)

    assert {:ok, _} = Sessions.delete_session(session.id)
    assert {:error, :not_found} = Sessions.delete_session(session.id)
  end

  test "touch_activity is infallible and ignores non-binary input" do
    assert :ok = Sessions.touch_activity(Ecto.UUID.generate())
    assert :ok = Sessions.touch_activity(12345)
    assert :ok = Sessions.touch_activity(nil)
  end
end
