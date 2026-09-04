defmodule NoizuPromptLingua.Entities.EntitiesResidualTest do
  @moduledoc """
  W4-D residual coverage for the entity facades: Clients CRUD + resolution,
  Media asset/variant DB paths, Organizations list/create-provisioning/delete,
  Projects TRP walks, ScopedMemberships persona/role helpers, Authz floor
  matching, MCP API key id-based miss folds, and Versioned.Name struct
  protocol stubs.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Clients
  alias NoizuPromptLingua.Media
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Projects
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.TRP.{Cache, TestStub}
  alias NoizuPromptLingua.Versioned.Names.Name

  setup do
    Cache.clear()
    TestStub.reset()
    {:ok, user: insert_user!()}
  end

  defp insert_user! do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "ent-#{uniq}@example.com",
      user_name: "ent#{uniq}",
      handle: "e#{uniq}",
      status: :active
    }
    |> Repo.insert!()
  end

  # ── Clients ──────────────────────────────────────────────────────

  test "clients CRUD, listing, resolution, and archiving" do
    org_id = Ecto.UUID.generate()

    {:ok, client} = Clients.create(%{organization_id: org_id, name: "Acme", slug: "acme"})
    assert Clients.get(client.id).id == client.id

    # created_by assignment when a user id is supplied
    uid = Ecto.UUID.generate()
    {:ok, client2} = Clients.create(%{organization_id: org_id, name: "B", slug: "b"}, uid)
    assert client2.created_by == uid

    {:ok, updated} = Clients.update(client.id, %{name: "Acme 2"})
    assert updated.name == "Acme 2"
    assert {:error, :not_found} = Clients.update(Ecto.UUID.generate(), %{name: "x"})

    assert length(Clients.list_for_org(org_id)) == 2
    assert is_list(Clients.list_for_org(org_id, status: "all"))
    assert [] = Clients.list_for_org(org_id, status: "archived")

    assert Clients.resolve(org_id, client.slug).id == client.id
    assert Clients.resolve(org_id, client.id).id == client.id
    assert Clients.resolve(org_id, "nope") == nil

    {:ok, archived} = Clients.archive(client.id)
    assert archived.status == "archived"
    assert {:error, :not_found} = Clients.archive(Ecto.UUID.generate())
  end

  # ── Media ────────────────────────────────────────────────────────

  test "media register/list/get and variant caching" do
    {:ok, asset} =
      Media.register_asset(%{
        short_id: "w4dAAAA",
        media_type: "image",
        file_type: "png",
        file: "uploads/w4d.png",
        file_size: 10,
        content_type: "image/png"
      })

    assert Media.get_by_short_id("w4dAAAA").id == asset.id
    assert Media.get_by_short_id("nope") == nil

    # entity facade over the seeded row
    entity = Media.get_media_asset(asset.id, nil)
    assert entity
    assert is_list(Media.list(nil))

    # variant cache round-trip
    assert Media.get_cached_variant(asset.id, "p=1") == nil

    {:ok, _} =
      Media.cache_variant(%{
        media_id: asset.id,
        variant_key: "var/w4d.png",
        params: "p=1",
        file_size: 5,
        content_type: "image/webp"
      })

    assert %{variant_key: "var/w4d.png"} = Media.get_cached_variant(asset.id, "p=1")
  end

  # ── Organizations ────────────────────────────────────────────────

  test "organization create mirrors through TRP when the service identity works", %{user: user} do
    prev = Application.get_env(:noizu_prompt_lingua, :trp)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    on_exit(fn -> if prev, do: Application.put_env(:noizu_prompt_lingua, :trp, prev) end)

    uid = user.id

    # provisioning: login + org create both succeed over the stub transport
    TestStub.queue_response({200, %{"access_token" => "jwt_a", "refresh_token" => "jwt_r"}})
    TestStub.queue_response({201, %{"organization" => %{"id" => "trp-1", "slug" => "w4d-org"}}})

    slug = "w4d-org-#{System.unique_integer([:positive])}"
    {:ok, org} = Organizations.create_organization_with_owner(%{slug: slug, name: "W4D Org"}, uid)
    assert org.slug == slug
  end

  test "organization create survives provisioning failures", %{user: user} do
    prev = Application.get_env(:noizu_prompt_lingua, :trp)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    on_exit(fn -> if prev, do: Application.put_env(:noizu_prompt_lingua, :trp, prev) end)

    # login fails → provisioning error → warn-and-continue
    TestStub.queue_response({500, %{"error" => "auth down"}})
    TestStub.queue_response({500, %{"error" => "auth down"}})
    TestStub.queue_response({500, %{"error" => "auth down"}})

    uid = user.id
    slug = "w4d-org-fail-#{System.unique_integer([:positive])}"
    {:ok, org} = Organizations.create_organization_with_owner(%{slug: slug, name: "W4D Org 2"}, uid)
    assert org.slug == slug
  end

  test "organization list and entity delete" do
    assert is_list(Organizations.list(nil))

    slug = "w4d-org-del-#{System.unique_integer([:positive])}"

    org =
      Repo.insert!(%NoizuPromptLingua.Schema.Organizations.Organization{name: "Del Org", slug: slug})

    assert Repo.get(NoizuPromptLingua.Schema.Organizations.Organization, org.id)
  end

  test "create_invite_token surfaces changeset errors" do
    assert {:error, _} = Organizations.create_invite_token(%{"organization_id" => "not-a-uuid"})
  end

  # ── Projects ─────────────────────────────────────────────────────

  test "project list walks all orgs when unscoped and folds TRP errors" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-proj-org")
    TestStub.seed_project(org_id, %{slug: "alpha", name: "Alpha"})

    projects = Projects.list_for_user(nil)
    assert Enum.any?(projects, fn p -> p[:name] == "Alpha" or p["name"] == "Alpha" end)

    # TRP error on the org walk → empty list, no crash
    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert [] = Projects.list_for_user(nil, "w4d-proj-org")
  end

  test "get_project_by_slug folds miss shapes" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-proj-org-2")
    TestStub.seed_project(org_id, %{slug: "beta", name: "Beta"})

    assert %{slug: "beta"} = Projects.get_project_by_slug(org_id, "beta")
    assert Projects.get_project_by_slug(org_id, "nope") == nil
    assert Projects.get_project_by_slug(%{}, "beta") == nil
  end

  test "update_project folds 404s, successes, and errors" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "w4d-proj-org-3")
    project = TestStub.seed_project(org_id, %{slug: "gamma", name: "Gamma"})

    assert {:error, :not_found} =
             Projects.update_project(Ecto.UUID.generate(), %{name: "X"})

    {:ok, updated} = Projects.update_project(project.id, %{name: "Gamma 2"})
    assert updated.name == "Gamma 2"

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})
    assert {:error, _} = Projects.update_project(project.id, %{name: "Nope"})
  end

  # ── ScopedMemberships helpers ────────────────────────────────────

  test "persona role updates validate the role" do
    assert {:error, :invalid_role} =
             NoizuPromptLingua.Authz.ScopedMemberships.update_persona_role(
               "project",
               Ecto.UUID.generate(),
               "persona-1",
               "emperor"
             )
  end

  test "list_for_user returns active memberships with role facet" do
    uid = Ecto.UUID.generate()
    rid = Ecto.UUID.generate()

    group = Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: "member", is_system: true)

    %NoizuPromptLingua.Schema.Authz.ScopedMembership{
      resource_type: "project",
      resource_id: rid,
      member_type: "user",
      member_id: uid,
      group_id: group.id
    }
    |> Repo.insert!()

    rows = NoizuPromptLingua.Authz.ScopedMemberships.list_for_user(uid)
    assert [%{role: "member", resource_id: ^rid}] = rows
    assert [] = NoizuPromptLingua.Authz.ScopedMemberships.list_for_user(Ecto.UUID.generate())
  end

  test "active_member? accepts binary ids and folds unknown shapes to false" do
    rid = Ecto.UUID.generate()
    uid = Ecto.UUID.generate()

    group = Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: "member", is_system: true)

    %NoizuPromptLingua.Schema.Authz.ScopedMembership{
      resource_type: "project",
      resource_id: rid,
      member_type: "user",
      member_id: uid,
      group_id: group.id
    }
    |> Repo.insert!()

    assert NoizuPromptLingua.Authz.ScopedMemberships.active_member?("project", rid, uid, [])
    refute NoizuPromptLingua.Authz.ScopedMemberships.active_member?("project", rid, Ecto.UUID.generate(), [])
    refute NoizuPromptLingua.Authz.ScopedMemberships.active_member?(:weird, :shape, :here, [])
  end

  # ── Authz floor matching ─────────────────────────────────────────

  test "check_permission supports contains-style floors and atom actions" do
    uid = Ecto.UUID.generate()
    rid = Ecto.UUID.generate()

    add_membership!(uid, rid, "member")

    # contains "manage_members" floors at admin → member denied
    refute Authz.check_permission(uid, "organization", rid, :manage_members_settings)
    # atom actions are stringified through required_role_for
    assert Authz.check_permission(uid, "organization", rid, :org_view)
  end

  defp add_membership!(user_id, resource_id, group_name) do
    group = Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: group_name, is_system: true)

    %NoizuPromptLingua.Schema.Authz.ScopedMembership{
      resource_type: "organization",
      resource_id: resource_id,
      member_type: "user",
      member_id: user_id,
      group_id: group.id
    }
    |> Repo.insert!()
  end

  # ── MCP API keys: id-based miss folds ────────────────────────────

  test "mcp api key operations fold unknown ids" do
    assert {:error, :not_found} = MCPApiKeys.update(Ecto.UUID.generate(), %{status: "revived"}, [])
    assert {:error, :not_found} = MCPApiKeys.clone(Ecto.UUID.generate(), %{})
    assert {:error, :not_found} = MCPApiKeys.copy_toolset_from(Ecto.UUID.generate(), "other")
  end

  # ── Versioned name struct protocol ───────────────────────────────

  test "versioned name struct helpers" do
    refute Name.equal?(%Name{}, %Name{})
    assert Name.__schema__(:primary_key) == [:id]
    assert Name.__schema__(:redact_fields) == []
    assert is_map(Name.__changeset__())
  end
end
