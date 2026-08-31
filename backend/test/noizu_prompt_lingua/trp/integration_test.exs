defmodule NoizuPromptLingua.TRP.IntegrationTest do
  @moduledoc """
  Rewired-module integration over the in-memory TRP stub: shapes preserved,
  write-bust visibility, org-by-slug, resolve, definitions resolution, and
  spec-gap error surfaces. Exercises the full Client+Cache stack.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Clients
  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Projects
  alias NoizuPromptLingua.TRP
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TRP.Cache.clear()
    TestStub.reset()
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "acme")
    {:ok, org_id: org_id}
  end

  # ── items / tickets ───────────────────────────────────────────

  test "ticket create → get round-trips the ticket shape (alias + fields)", %{org_id: org} do
    {:ok, t} = Tickets.create(%{organization_id: org, title: "A", ticket_type: "bug"})

    assert t.ticket_type == "bug"
    assert t.item_type == "bug"
    assert t.key

    got = Tickets.get(t.id)
    assert got.title == "A"
    assert got.custom_fields == %{}
  end

  test "ticket update write-busts: fresh read reflects the change immediately", %{org_id: org} do
    {:ok, t} = Tickets.create(%{organization_id: org, title: "before"})
    assert Tickets.get(t.id).title == "before" # populate cache

    {:ok, _} = Tickets.update(t.id, %{title: "after"})
    assert Tickets.get(t.id).title == "after"
  end

  test "list reflects a create immediately (write-bust of list keys)", %{org_id: org} do
    assert Tickets.list(organization_id: org) == []
    {:ok, _} = Tickets.create(%{organization_id: org, title: "A"})
    assert length(Tickets.list(organization_id: org)) == 1
  end

  # ── organizations / projects ──────────────────────────────────

  test "get_id_by_slug resolves via the TRP org list", %{org_id: org} do
    assert Organizations.get_id_by_slug("acme") == org
    assert Organizations.get_id_by_slug("nope") == nil
  end

  test "org creation is local (TRP provisioning deferred to W8) with owner membership" do
    # added_by FK needs a real users row.
    uid =
      %NoizuPromptLingua.Schema.Users.User{}
      |> Ecto.Changeset.change(%{
        email: "org-owner-#{System.unique_integer([:positive])}@test.local",
        status: :active
      })
      |> NoizuPromptLingua.Repo.insert!()
      |> Map.fetch!(:id)

    assert {:ok, org} =
             Organizations.create_organization_with_owner(%{slug: "local-org", name: "Local"}, uid)

    assert org.slug == "local-org"
    assert NoizuPromptLingua.Repo.get_by(NoizuPromptLingua.Schema.Authz.ScopedMembership,
             resource_type: "organization",
             resource_id: org.id,
             member_id: uid
           )
  end

  test "list_for_user returns the legacy STRING-keyed shape", %{org_id: org} do
    TestStub.seed_project(org, %{slug: "p1", name: "P1"})
    [row] = Projects.list_for_user("user-id", org)

    assert %{"id" => _, "name" => "P1", "role_name" => nil} = row
    assert is_map_key(row, "inherited_from_org")
  end

  test "project create/get round-trip through TRP", %{org_id: org} do
    {:ok, p} = Projects.create_with_owner(%{organization_id: org, name: "N", slug: "n"}, "u")

    got = Projects.get_project(p.id)
    assert got && got.slug == "n"
  end

  test "archive/unarchive surface the spec gap explicitly" do
    assert {:error, :trp_unsupported_shared_key} = Projects.archive(Ecto.UUID.generate())
    assert {:error, :trp_unsupported_shared_key} = Projects.unarchive(Ecto.UUID.generate())
  end

  # ── resolve ───────────────────────────────────────────────────

  test "Resolve.project resolves by slug across the key scope", %{org_id: org} do
    TestStub.seed_project(org, %{slug: "alpha", name: "Alpha"})
    project = Resolve.project("alpha")
    assert project && project.id
    pid = project.id
    assert {:ok, ^pid} = Resolve.project_in_org("alpha", org)
  end

  # ── definitions ───────────────────────────────────────────────

  test "definitions CRUD + resolution precedence project > org > global", %{org_id: org} do
    org_field =
      %{organization_id: org, slug: "severity", label: "Severity", field_type: "select"}

    {:ok, of} = Definitions.create_field(org_field)
    assert of.slug == "severity"

    {:ok, pf} =
      Definitions.create_field(%{
        organization_id: org,
        project_id: "22222222-2222-2222-2222-222222222222",
        slug: "severity",
        label: "Project Severity"
      })

    assert pf.project_id

    # project-level wins
    winner = Definitions.resolve_field(org, "22222222-2222-2222-2222-222222222222", "severity")
    assert winner.label == "Project Severity"
    # org-level resolves when no project context
    assert Definitions.resolve_field(org, nil, "severity").label == "Severity"

    # effective set dedupes by slug
    eff = Definitions.effective_fields(org, "22222222-2222-2222-2222-222222222222")
    assert Enum.map(eff, & &1.slug) == ["severity"]
  end

  test "type definitions keep the type_fields join shape for type_field_list/1", %{org_id: org} do
    {:ok, f} =
      Definitions.create_field(%{organization_id: org, slug: "points", label: "Points"})

    {:ok, t} = Definitions.create_type(%{organization_id: org, slug: "story", name: "Story"})

    assert {:ok, _} = Definitions.add_field_to_type(t.id, f.id, required: true, position: 3)

    type = Definitions.get_type(t.id)
    assert [%{required: true, position: 3}] = Definitions.type_field_list(type) |> for_fields()
  end

  defp for_fields(list), do: list |> Enum.filter(&(&1.slug == "points"))

  test "remove_field_from_type counts", %{org_id: org} do
    {:ok, f} = Definitions.create_field(%{organization_id: org, slug: "x1", label: "X"})
    {:ok, t} = Definitions.create_type(%{organization_id: org, slug: "t1", name: "T"})
    {:ok, _} = Definitions.add_field_to_type(t.id, f.id)

    assert {:ok, 1} = Definitions.remove_field_from_type(t.id, f.id)
    assert {:ok, 0} = Definitions.remove_field_from_type(t.id, f.id)
  end

  # ── clients (local shim) ──────────────────────────────────────

  test "clients round-trip on the local app-DB mirror", %{org_id: org} do
    {:ok, c} = Clients.create(%{organization_id: org, name: "Acme Inc", slug: "acme-inc"})
    assert Clients.get(c.id).slug == "acme-inc"
    cid = c.id
    assert [%{id: ^cid}] = Clients.list_for_org(org)
    assert Clients.resolve(org, "acme-inc").id == cid

    {:ok, archived} = Clients.archive(c.id)
    assert archived.status == "archived"
    assert Clients.list_for_org(org) == []
    assert Clients.list_for_org(org, status: "all") |> length() == 1
  end

  # ── authz (local shim) ────────────────────────────────────────

  test "authz facade ranks roles from the app-DB memberships", %{org_id: org} do
    uid = Ecto.UUID.generate()
    add_member(org, uid, "member")

    assert Authz.get_user_role(uid, "organization", org) == "member"
    assert Authz.check_permission(uid, "organization", org, "project:view")
    refute Authz.check_permission(uid, "organization", org, "project:delete")
    assert {:ok, %{role: "member"}} = Authz.authorize(uid, "organization", org, "viewer")
    assert {:error, :insufficient_role} = Authz.authorize(uid, "organization", org, "admin")
    assert {:error, :not_a_member} = Authz.authorize(Ecto.UUID.generate(), "organization", org, "viewer")
  end

  test "sole-owner guard: last owner cannot be demoted or removed", %{org_id: org} do
    uid = Ecto.UUID.generate()
    add_member(org, uid, "owner")

    assert {:error, :last_owner} =
             Authz.ScopedMemberships.update_role("organization", org, uid, "viewer")

    assert {:error, :last_owner} = Authz.ScopedMemberships.remove_member("organization", org, uid)
  end

  defp add_member(org, uid, role) do
    group = NoizuPromptLingua.Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: role)

    %NoizuPromptLingua.Schema.Authz.ScopedMembership{}
    |> Ecto.Changeset.change(%{
      group_id: group.id,
      resource_type: "organization",
      resource_id: org,
      member_type: "user",
      member_id: uid
    })
    |> NoizuPromptLingua.Repo.insert!()
  end
end
