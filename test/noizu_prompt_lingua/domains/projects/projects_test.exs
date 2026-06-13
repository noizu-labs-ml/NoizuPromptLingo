defmodule NoizuPromptLingua.Domains.ProjectsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Projects
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.User

  defp create_user(email \\ "test-#{System.unique_integer([:positive])}@example.com") do
    %User{}
    |> User.changeset(%{sub: "sub-#{System.unique_integer([:positive])}", email: email, name: "Test"})
    |> Repo.insert!()
  end

  defp create_project(attrs \\ %{}) do
    defaults = %{name: "Test Project", slug: "proj-#{System.unique_integer([:positive])}"}
    Projects.create(Map.merge(defaults, attrs))
  end

  describe "project CRUD" do
    test "create/1 creates a project" do
      assert {:ok, project} = create_project(%{name: "My Project", slug: "my-project"})
      assert project.name == "My Project"
      assert project.slug == "my-project"
      assert project.status == "active"
    end

    test "create/1 enforces unique slug" do
      {:ok, _} = create_project(%{slug: "dupe"})
      assert {:error, _} = create_project(%{slug: "dupe"})
    end

    test "create/1 with owner" do
      user = create_user()
      assert {:ok, project} = create_project(%{owner_id: user.id})
      assert project.owner_id == user.id
    end

    test "get/1 by slug" do
      {:ok, project} = create_project(%{slug: "find-me"})
      found = Projects.get("find-me")
      assert found.id == project.id
    end

    test "get/1 by uuid" do
      {:ok, project} = create_project()
      found = Projects.get(project.id)
      assert found.id == project.id
    end

    test "get/1 returns nil for missing" do
      assert is_nil(Projects.get("nonexistent"))
    end

    test "update/2 updates attributes" do
      {:ok, project} = create_project()
      assert {:ok, updated} = Projects.update(project.slug, %{name: "New Name"})
      assert updated.name == "New Name"
    end

    test "archive/1 sets status to archived" do
      {:ok, project} = create_project()
      assert {:ok, archived} = Projects.archive(project.slug)
      assert archived.status == "archived"
    end

    test "list/1 returns projects" do
      {:ok, _} = create_project()
      {:ok, _} = create_project()
      assert length(Projects.list()) >= 2
    end

    test "list/1 filters by status" do
      {:ok, _} = create_project()
      {:ok, p2} = create_project()
      Projects.archive(p2.slug)

      active = Projects.list(status: "active")
      assert Enum.all?(active, &(&1.status == "active"))
    end

    test "count_active/0 counts active projects" do
      {:ok, _} = create_project()
      assert Projects.count_active() >= 1
    end
  end

  describe "membership" do
    test "invite/3 creates a pending membership" do
      user = create_user("invite@test.com")
      {:ok, project} = create_project()

      assert {:ok, member} = Projects.invite(project.id, "invite@test.com")
      assert member.status == "pending"
      assert member.role == "member"
      assert member.user_id == user.id
    end

    test "invite/3 with role and invited_by" do
      user = create_user("admin@test.com")
      inviter = create_user("inviter@test.com")
      {:ok, project} = create_project()

      assert {:ok, member} = Projects.invite(project.id, "admin@test.com",
        role: "admin", invited_by: inviter.id)
      assert member.role == "admin"
      assert member.invited_by == inviter.id
    end

    test "invite/3 returns error for unknown email" do
      {:ok, project} = create_project()
      assert {:error, :user_not_found} = Projects.invite(project.id, "nobody@test.com")
    end

    test "invite/3 enforces unique membership" do
      user = create_user("uniq@test.com")
      {:ok, project} = create_project()

      assert {:ok, _} = Projects.invite(project.id, "uniq@test.com")
      assert {:error, _} = Projects.invite(project.id, "uniq@test.com")
    end

    test "accept_invite/2 activates a pending membership" do
      user = create_user("accept@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "accept@test.com")

      assert {:ok, member} = Projects.accept_invite(project.id, user.id)
      assert member.status == "active"
      assert member.accepted_at
    end

    test "accept_invite/2 errors for already active" do
      user = create_user("active@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "active@test.com")
      Projects.accept_invite(project.id, user.id)

      assert {:error, :already_active} = Projects.accept_invite(project.id, user.id)
    end

    test "accept_invite/2 errors when no invite exists" do
      {:ok, project} = create_project()
      assert {:error, :not_found} = Projects.accept_invite(project.id, Ecto.UUID.generate())
    end

    test "update_role/3 changes role" do
      user = create_user("role@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "role@test.com")

      assert {:ok, member} = Projects.update_role(project.id, user.id, "admin")
      assert member.role == "admin"
    end

    test "remove_member/2 sets status to removed" do
      user = create_user("remove@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "remove@test.com")

      assert {:ok, member} = Projects.remove_member(project.id, user.id)
      assert member.status == "removed"
    end

    test "list_members/2 excludes removed by default" do
      user1 = create_user("m1@test.com")
      user2 = create_user("m2@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "m1@test.com")
      {:ok, _} = Projects.invite(project.id, "m2@test.com")
      Projects.remove_member(project.id, user2.id)

      members = Projects.list_members(project.id)
      user_ids = Enum.map(members, & &1.user_id)
      assert user1.id in user_ids
      refute user2.id in user_ids
    end

    test "list_members/2 with status filter" do
      user = create_user("filter@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "filter@test.com")
      Projects.accept_invite(project.id, user.id)

      pending = Projects.list_members(project.id, status: "pending")
      active = Projects.list_members(project.id, status: "active")

      assert length(pending) == 0
      assert length(active) == 1
    end

    test "get_membership/2 returns the membership" do
      user = create_user("gm@test.com")
      {:ok, project} = create_project()
      {:ok, _} = Projects.invite(project.id, "gm@test.com")

      member = Projects.get_membership(project.id, user.id)
      assert member.user_id == user.id
    end
  end
end
