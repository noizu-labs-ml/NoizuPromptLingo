defmodule NoizuPromptLingua.Authz.ScopedMembershipsPMSplitTest do
  @moduledoc """
  pm_core cutover split coverage: USER memberships are written via Noizu.PM (pm_core DB)
  while PERSONA memberships (add_persona_member) stay on the app DB. The read paths
  (list_for_resource / get_membership / list_for_user / Organizations.list_user_organizations)
  must source user rows from pm and union the app-DB persona rows — the pre-fix code read
  everything from the app DB, so a post-cutover owner never appeared in members lists.

  Unlike scoped_memberships_persona_test (which seeds the app repo directly and so bypassed
  the bug), these tests seed the pm side through the public write path
  (Organizations.create_with_owner / ScopedMemberships.add_member).
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Organizations

  setup do
    user_id = insert_pm_user()
    org = pm_org(user_id)
    {:ok, org_id: org, user_id: user_id}
  end

  test "a pm-created owner appears in list_for_resource", %{org_id: org, user_id: uid} do
    rows = ScopedMemberships.list_for_resource("organization", org)

    owner = Enum.find(rows, &(&1.member_type == "user"))
    assert owner, "expected a user (pm) row, got: #{inspect(Enum.map(rows, & &1.member_type))}"
    assert owner.role == "owner"
    assert owner.member_id == uid
    assert owner.user_id == uid
    assert String.starts_with?(owner.email, "pm-split-")
    assert String.starts_with?(owner.display_name, "PM Split User")
    assert owner.resource_type == "organization"
    assert owner.resource_id == org
    # persona-only fields present-but-nil on user rows (unified shape)
    assert owner.persona_id == nil
    assert owner.persona_slug == nil
    assert owner.avatar == nil
  end

  test "pm user rows and app-DB persona rows render side by side", %{org_id: org} do
    pid = insert_persona(org)
    {:ok, membership} = ScopedMemberships.add_persona_member("organization", org, pid, "member")

    rows = ScopedMemberships.list_for_resource("organization", org)

    user = Enum.find(rows, &(&1.member_type == "user"))
    p_row = Enum.find(rows, &(&1.member_type == "persona"))
    assert user
    assert user.role == "owner"

    assert p_row.id == membership.id
    assert p_row.persona_id == pid
    assert p_row.role == "member"
    assert p_row.display_name == "Split Test Persona"
    # unified shape holds across both sources
    assert Map.keys(user) |> MapSet.new() == Map.keys(p_row) |> MapSet.new()
  end

  test "get_membership resolves both pm (user) and app-DB (persona) ids", %{
    org_id: org,
    user_id: uid
  } do
    user_row =
      ScopedMemberships.list_for_resource("organization", org)
      |> Enum.find(&(&1.member_type == "user"))

    assert user_row.member_id == uid
    got_user = ScopedMemberships.get_membership(user_row.id)
    assert got_user.member_type == "user"
    assert got_user.role == "owner"
    assert got_user.email == user_row.email

    {:ok, persona} =
      ScopedMemberships.add_persona_member("organization", org, insert_persona(org), "viewer")

    # persona.id is the app-DB membership id on this path
    got_persona = ScopedMemberships.get_membership(persona.id)
    assert got_persona.member_type == "persona"
    assert got_persona.role == "viewer"
    assert got_persona.persona_id == persona.member_id
  end

  test "list_for_user reads pm memberships (/memberships/me path)", %{org_id: org, user_id: uid} do
    mine = ScopedMemberships.list_for_user(uid)
    assert [%{resource_type: "organization", resource_id: rid, role: "owner"}] = mine
    assert to_string(rid) == to_string(org)
  end

  test "add_member (pm path) + list_for_resource shows the added member", %{
    org_id: org,
    user_id: owner
  } do
    member = insert_pm_user()
    {:ok, _} = ScopedMemberships.add_member("organization", org, member, "member", owner)

    rows = ScopedMemberships.list_for_resource("organization", org)
    assert Enum.find(rows, &(&1.member_id == member and &1.role == "member"))
    assert Enum.find(rows, &(&1.member_id == owner and &1.role == "owner"))
    assert length(rows) == 2
  end

  test "Organizations.list_user_organizations reads pm orgs + memberships", %{
    org_id: org,
    user_id: uid
  } do
    orgs = Organizations.list_user_organizations(uid)

    assert [%{id: id, slug: slug, role: "owner", effective_role: "owner", owner: owner_name}] =
             orgs

    assert to_string(id) == to_string(org)
    assert slug =~ "split-org-"
    assert String.starts_with?(owner_name, "PM Split User")
  end

  # ── regression: pm read alone must not empty the org switcher ──────────
  # Reading list_user_organizations / list_for_user from pm ONLY returns [] for
  # memberships that exist solely on the app DB: pre-cutover rows (never
  # re-written to pm) and ETL-collapsed users whose pm member_id is a different
  # uuid than the app user id. An empty list degrades every console route to the
  # org dashboard (nav hrefs fall back to /app/<section>, which the [orgId]
  # route renders). The union must surface app-DB-only rows, deduped.

  test "app-DB-only (pre-cutover) org appears in list_user_organizations", %{
    user_id: uid
  } do
    legacy = insert_app_org_with_owner(uid)

    orgs = Organizations.list_user_organizations(uid)
    slugs = Enum.map(orgs, & &1.slug)
    assert legacy.slug in slugs
    assert Enum.find(orgs, &(&1.slug == legacy.slug)).role == "owner"
    # no dupes across the two sources
    assert length(slugs) == length(Enum.uniq(slugs))
  end

  test "org mirrored in both DBs renders once (pm row wins)", %{org_id: org, user_id: uid} do
    mirror_app_membership(org, uid, "owner")

    orgs = Organizations.list_user_organizations(uid)
    rows = Enum.filter(orgs, &(to_string(&1.id) == to_string(org)))
    assert length(rows) == 1
  end

  test "app-DB-only membership appears in list_for_user, deduped", %{user_id: uid} do
    legacy = insert_app_org_with_owner(uid)

    mine = ScopedMemberships.list_for_user(uid)
    assert Enum.find(mine, &(to_string(&1.resource_id) == legacy.id and &1.role == "owner"))

    keys = Enum.map(mine, &{&1.resource_type, to_string(&1.resource_id)})
    assert length(keys) == length(Enum.uniq(keys))
  end

  test "get_membership resolves an app-DB USER membership id (pre-cutover shape)", %{
    user_id: uid
  } do
    legacy = insert_app_org_with_owner(uid)

    got = ScopedMemberships.get_membership(legacy.membership_id)
    assert got, "app-DB user membership id resolved nil"
    assert got.member_type == "user"
    assert got.role == "owner"
    assert to_string(got.resource_id) == legacy.id
    assert to_string(got.member_id) == to_string(uid)
  end

  # ── seed helpers ────────────────────────────────────────────────────────

  defp insert_pm_user do
    email = "pm-split-#{System.unique_integer([:positive])}@example.com"

    %{rows: [[raw]]} =
      Ecto.Adapters.SQL.query!(
        Noizu.PM.Repo,
        "INSERT INTO users (id, email, user_name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [email, "PM Split User #{System.unique_integer([:positive])}"]
      )

    Ecto.UUID.load!(raw)
  end

  defp pm_org(user_id) do
    slug = "split-org-#{System.unique_integer([:positive])}"

    {:ok, org} =
      Organizations.create_organization_with_owner(%{slug: slug, name: "Split Org"}, user_id)

    to_string(org.id)
  end

  defp insert_persona(org_id) do
    # personas.organization_id FKs the APP-DB organizations table — mirror the pm org row
    # (same UUID) there so app-DB persona rows can reference it.
    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1::uuid, $2, 'Split Org Mirror', now(), now()) ON CONFLICT (id) DO NOTHING",
      [Ecto.UUID.dump!(org_id), "split-mirror-#{System.unique_integer([:positive])}"]
    )

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO personas (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::uuid, $2, $3, now(), now()) RETURNING id",
        [
          Ecto.UUID.dump!(org_id),
          "split-persona-#{System.unique_integer([:positive])}",
          "Split Test Persona"
        ]
      )

    Ecto.UUID.load!(raw)
  end

  # App-DB-only org + owner membership — the pre-cutover shape that was never
  # re-written to pm (and what the ETL member_id remap leaves unmatched).
  # Returns the membership id too (get_membership coverage below).
  defp insert_app_org_with_owner(user_id) do
    slug = "legacy-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw_id, raw_mid]]} =
      Repo.query!(
        "WITH o AS (INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, 'Legacy Org', now(), now()) RETURNING id), " <>
          "m AS (INSERT INTO scoped_memberships (id, group_id, resource_type, resource_id, member_type, member_id, created_at) " <>
          "SELECT gen_random_uuid(), g.id, 'organization', o.id, 'user', $2::uuid, now() " <>
          "FROM o, groups g WHERE g.name = 'owner' RETURNING id, resource_id) " <>
          "SELECT o.id, m.id FROM o, m",
        [slug, Ecto.UUID.dump!(user_id)]
      )

    %{id: Ecto.UUID.load!(raw_id), membership_id: Ecto.UUID.load!(raw_mid), slug: slug}
  end

  # Mirror a pm org into the app DB with a same-role membership, as the ETL /
  # insert_persona mirror path does — the union must not double-render it.
  defp mirror_app_membership(org_id, user_id, role) do
    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1::uuid, $2, 'Mirror Org', now(), now()) ON CONFLICT (id) DO NOTHING",
      [Ecto.UUID.dump!(org_id), "mirror-#{System.unique_integer([:positive])}"]
    )

    Repo.query!(
      "INSERT INTO scoped_memberships (id, group_id, resource_type, resource_id, member_type, member_id, created_at) " <>
        "SELECT gen_random_uuid(), g.id, 'organization', $1::uuid, 'user', $2::uuid, now() " <>
        "FROM groups g WHERE g.name = $3",
      [Ecto.UUID.dump!(org_id), Ecto.UUID.dump!(user_id), role]
    )
  end
end
