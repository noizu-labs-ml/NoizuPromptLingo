defmodule NoizuPromptLingua.ProjectsTrpTest do
  use NoizuPromptLingua.DataCase, async: false

  @moduledoc """
  Projects context (entities/projects.ex) over the TRP shared-key plane via
  the in-memory TestStub transport: org-scan resolution, shaped reads,
  create/update/delete, and the explicit unsupported/required guards.
  """

  alias NoizuPromptLingua.Projects
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TestStub.reset()
    NoizuPromptLingua.TRP.Cache.clear()

    org_id = TestStub.seed_org(Ecto.UUID.generate(), "proj-org", "Proj Org")
    TestStub.seed_project(org_id, %{name: "Alpha", slug: "alpha"})
    TestStub.seed_project(org_id, %{name: "Beta", slug: "beta"})

    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "prj-#{n}@example.com",
        user_name: "prj_user#{n}",
        handle: "prj_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    %{org_id: org_id, user: user}
  end

  test "list_for_user returns shaped rows for the key-scope orgs" do
    rows = Projects.list_for_user(Ecto.UUID.generate())
    # legacy STRING-keyed shape (TRP.Shapes.project_for_user)
    slugs = Enum.map(rows, & &1["slug"])
    assert Enum.sort(slugs) == ["alpha", "beta"]

    # org-scoped list narrows to that org's projects
    org_id = NoizuPromptLingua.TRP.TestStub.org_id_by_slug("proj-org")

    assert [%{"slug" => "alpha"}, %{"slug" => "beta"}] =
             Enum.sort_by(Projects.list_for_user("u", org_id), & &1["slug"])
  end

  test "get_project scans orgs; unknown id resolves to nil" do
    org_id = TestStub.org_id_by_slug("proj-org")

    {:ok, project} =
      Projects.create_with_owner(%{name: "Gamma", slug: "gamma", organization_id: org_id}, "u")

    assert %{slug: "gamma"} = Projects.get_project(project.id)
    assert nil == Projects.get_project(Ecto.UUID.generate())
  end

  test "get_project_by_slug: found, missing, and guard clauses" do
    org_id = TestStub.org_id_by_slug("proj-org")

    assert %{slug: "alpha"} = Projects.get_project_by_slug(org_id, "alpha")
    assert nil == Projects.get_project_by_slug(org_id, "no-such-slug")
    # non-binary inputs hit the catch-all clause
    assert nil == Projects.get_project_by_slug(nil, "alpha")
    assert nil == Projects.get_project_by_slug(org_id, 42)
  end

  test "create_with_owner: success, missing org, and error pass-through" do
    org_id = TestStub.org_id_by_slug("proj-org")

    assert {:ok, %{slug: "delta"}} =
             Projects.create_with_owner(
               %{name: "Delta", slug: "delta", organization_id: org_id},
               "u"
             )

    assert {:error, :trp_org_required} = Projects.create_with_owner(%{name: "No Org"}, "u")

    # error pass-through: inject a synthetic TRP failure before routing
    TestStub.queue_response({422, %{"error" => "slug taken"}})

    assert {:error, _} =
             Projects.create_with_owner(%{name: "Bad", slug: "bad", organization_id: org_id}, "u")
  end

  test "update_project applies changes; 404 maps to :not_found" do
    org_id = TestStub.org_id_by_slug("proj-org")

    {:ok, project} =
      Projects.create_with_owner(
        %{name: "Epsilon", slug: "epsilon", organization_id: org_id},
        "u"
      )

    assert {:ok, updated} = Projects.update_project(project.id, %{name: "Epsilon 2"})
    assert updated.name == "Epsilon 2"

    assert {:error, :not_found} = Projects.update_project(Ecto.UUID.generate(), %{name: "x"})
  end

  test "delete_project removes; unknown is :not_found" do
    org_id = TestStub.org_id_by_slug("proj-org")

    {:ok, project} =
      Projects.create_with_owner(%{name: "Zeta", slug: "zeta", organization_id: org_id}, "u")

    assert {:ok, nil} = Projects.delete_project(project.id)
    assert {:error, :not_found} = Projects.delete_project(project.id)
  end

  test "archive/unarchive are explicit no-ops on the shared-key plane" do
    assert {:error, :trp_unsupported_shared_key} = Projects.archive(Ecto.UUID.generate())
    assert {:error, :trp_unsupported_shared_key} = Projects.unarchive(Ecto.UUID.generate())
  end

  test "list_members reads app-DB scoped memberships", %{user: user} do
    project_id = Ecto.UUID.generate()
    group = Repo.get_by!(Group, name: "member", is_system: true)

    %NoizuPromptLingua.Schema.Authz.ScopedMembership{
      resource_type: "project",
      resource_id: project_id,
      member_type: "user",
      member_id: user.id,
      group_id: group.id
    }
    |> Repo.insert!()

    members = Projects.list_members(project_id)
    assert Enum.any?(members, &(&1.member_id == user.id))
  end
end
