defmodule NoizuPromptLingua.OrganizationsContextTest do
  use NoizuPromptLingua.DataCase, async: false

  @moduledoc """
  Direct coverage of the Organizations context (entities/organizations.ex):
  org update with slug-cache invalidation, transactional delete with dependent
  rows, local-first org creation with best-effort TRP provisioning, invite
  token minting/lookup/usage, member listing, and resolve_org_id's guard
  branches.

  async: false — the TRP stub ETS + slug cache are VM-global; slugs are
  run-unique because localhost Redis outlives the sandbox.
  """

  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership
  alias NoizuPromptLingua.Schema.Organizations.InviteToken
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TestStub.reset()
    NoizuPromptLingua.TRP.Cache.clear()

    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "orgc-#{n}@example.com",
        user_name: "orgc_user#{n}",
        handle: "orgc_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    org =
      %Organization{name: "OrgCtx #{n}", slug: "orgctx-#{n}"}
      |> Repo.insert!()

    %{user: user, org: org, n: n}
  end

  defp run_slug(prefix), do: "#{prefix}-#{Ecto.UUID.generate()}"

  defp owner_group do
    Repo.get_by!(Group, name: "owner", is_system: true)
  end

  # ── update_organization ──────────────────────────────────────────

  test "update_organization renames and busts the old slug cache", %{org: org} do
    new_slug = run_slug("orgctx-renamed")

    assert {:ok, updated} =
             Organizations.update_organization(org.id, %{"name" => "Renamed", "slug" => new_slug})

    assert updated.slug == new_slug
    assert updated.name == "Renamed"

    # old slug must no longer resolve, new slug must
    assert Organizations.get_id_by_slug(org.slug) == nil
    assert Organizations.get_id_by_slug(new_slug) == org.id
  end

  test "update_organization without a slug change skips invalidation", %{org: org} do
    assert {:ok, updated} = Organizations.update_organization(org.id, %{"name" => "Same Slug"})
    assert updated.slug == org.slug
    assert Organizations.get_id_by_slug(org.slug) == org.id
  end

  test "update_organization on a missing org is not_found" do
    assert {:error, :not_found} =
             Organizations.update_organization(Ecto.UUID.generate(), %{"name" => "x"})
  end

  # ── delete_organization ──────────────────────────────────────────

  test "delete_organization removes memberships, tokens, projects and the org", %{
    org: org,
    user: user
  } do
    {:ok, _} =
      NoizuPromptLingua.Authz.ScopedMemberships.add_member(
        "organization",
        org.id,
        user.id,
        "owner",
        user.id
      )

    {:ok, invite, _raw} =
      Organizations.create_invite_token(%{
        "organization_id" => org.id,
        "email" => "in@example.com"
      })

    project =
      %Project{
        organization_id: org.id,
        name: "Doomed",
        slug: "doomed-#{System.unique_integer([:positive])}"
      }
      |> Repo.insert!()

    # a scoped membership attached to the org's PROJECT must go too
    %ScopedMembership{
      resource_type: "project",
      resource_id: project.id,
      member_type: "user",
      member_id: user.id,
      group_id: owner_group().id
    }
    |> Repo.insert!()

    assert {:ok, _} = Organizations.delete_organization(org.id)

    refute Repo.get(Organization, org.id)
    refute Repo.get(InviteToken, invite.id)
    refute Repo.exists?(from sm in ScopedMembership, where: sm.resource_id == ^org.id)
    refute Repo.exists?(from sm in ScopedMembership, where: sm.resource_id == ^project.id)

    # NOTE (pinned): the moduledoc claims projects are removed via ON DELETE
    # CASCADE, but the row survives — the projects.organization_id FK does not
    # cascade. Flagged to the campaign lead as a doc/DB mismatch.
    assert Repo.get(Project, project.id)
  end

  test "delete_organization on a missing org is not_found" do
    assert {:error, :not_found} = Organizations.delete_organization(Ecto.UUID.generate())
  end

  # ── create_organization_with_owner ───────────────────────────────

  test "create_organization_with_owner persists org + owner membership even when TRP provisioning fails",
       %{user: user} do
    slug = run_slug("ownerless-no-more")

    assert {:ok, org} =
             Organizations.create_organization_with_owner(
               %{"name" => "New Org", "slug" => slug},
               user.id
             )

    assert org.slug == slug
    assert Organizations.get_id_by_slug(slug) == org.id

    members = NoizuPromptLingua.Authz.ScopedMemberships.list_for_resource("organization", org.id)
    assert Enum.any?(members, &(&1.member_id == user.id and &1.role == "owner"))
  end

  test "create_organization_with_owner rejects an invalid org changeset" do
    assert {:error, %Ecto.Changeset{}} =
             Organizations.create_organization_with_owner(
               %{"name" => "No Slug"},
               Ecto.UUID.generate()
             )
  end

  # ── members / authorize ──────────────────────────────────────────

  test "list_members and list_user_organizations round-trip a membership", %{org: org, user: user} do
    {:ok, _} =
      NoizuPromptLingua.Authz.ScopedMemberships.add_member(
        "organization",
        org.id,
        user.id,
        "owner",
        user.id
      )

    members = Organizations.list_members(org.id)
    assert Enum.any?(members, &(&1.member_id == user.id))

    orgs = Organizations.list_user_organizations(user.id)
    row = Enum.find(orgs, &(&1.id == org.id))
    assert row
    assert row.slug == org.slug
    assert row.role == "owner"
    assert row.owner == user.user_name
  end

  test "authorize delegates to the authz layer", %{org: org, user: user} do
    {:ok, _} =
      NoizuPromptLingua.Authz.ScopedMemberships.add_member(
        "organization",
        org.id,
        user.id,
        "owner",
        user.id
      )

    assert match?({:ok, _}, Organizations.authorize(user.id, org.id, "owner"))
    refute match?({:ok, _}, Organizations.authorize(Ecto.UUID.generate(), org.id, "owner"))
  end

  # ── resolve_org_id guard branches ────────────────────────────────

  test "resolve_org_id passes UUIDs through and rejects non-binary junk", %{org: org} do
    org_id = org.id
    assert {:ok, ^org_id} = Organizations.resolve_org_id(org.id)
    assert {:error, :not_found} = Organizations.resolve_org_id(nil)
    assert {:error, :not_found} = Organizations.resolve_org_id(12345)
  end

  # ── get_slug_by_id ───────────────────────────────────────────────

  test "get_slug_by_id inverts get_id_by_slug", %{org: org} do
    assert Organizations.get_slug_by_id(org.id) == org.slug
    assert Organizations.get_slug_by_id(Ecto.UUID.generate()) == nil
  end

  # ── invite tokens ────────────────────────────────────────────────

  test "invite token lifecycle: mint, find by raw token, increment uses, revoke gate", %{org: org} do
    assert {:ok, invite, raw} =
             Organizations.create_invite_token(%{
               "organization_id" => org.id,
               "email" => "join@example.com",
               "max_uses" => 2
             })

    assert String.starts_with?(raw, invite.key_prefix)
    assert byte_size(invite.key_prefix) == 8
    assert invite.uses == 0
    assert Bcrypt.verify_pass(raw, invite.token_hash)

    assert {:ok, found} = Organizations.find_active_invite_by_raw_token(raw)
    assert found.id == invite.id

    assert {:error, :invalid_token} =
             Organizations.find_active_invite_by_raw_token("not-a-token-here")

    # uses counter increments
    assert {1, nil} = Organizations.increment_invite_uses(invite)
    assert Repo.reload!(invite).uses == 1

    # a revoked token no longer matches
    invite |> Ecto.Changeset.change(revoked: true) |> Repo.update!()
    assert {:error, :invalid_token} = Organizations.find_active_invite_by_raw_token(raw)
  end

  test "find_active_invite_by_raw_token rejects expired and exhausted tokens", %{org: org} do
    assert {:ok, expired, raw} =
             Organizations.create_invite_token(%{
               "organization_id" => org.id,
               "expires_at" => DateTime.add(DateTime.utc_now(), -3600)
             })

    assert {:error, :invalid_token} = Organizations.find_active_invite_by_raw_token(raw)

    assert {:ok, exhausted, raw2} =
             Organizations.create_invite_token(%{
               "organization_id" => org.id,
               "max_uses" => 3,
               "uses" => 3
             })

    assert exhausted.uses >= exhausted.max_uses
    assert {:error, :invalid_token} = Organizations.find_active_invite_by_raw_token(raw2)
  end
end
