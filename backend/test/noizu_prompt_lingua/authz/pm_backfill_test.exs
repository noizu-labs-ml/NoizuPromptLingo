defmodule NoizuPromptLingua.Authz.PMBackfillTest do
  @moduledoc """
  pm_core membership backfill (post-cutover reconciliation):

  - dry-run (plan/0) is read-only and returns exactly the inserts that would
    make pm self-sufficient for app-DB USER rows;
  - execute goes through the public write path and is idempotent — re-planning
    after a run finds nothing;
  - ETL-collapsed users (different uuid, same email) resolve onto the right
    pm user via the email rule;
  - unresolvable members are reported, never guessed;
  - persona rows are never touched (app-DB by design);
  - non-admin callers get 403 from the route.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Authz.PMBackfill
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Organizations

  setup do
    user_id = insert_pm_user()
    org = pm_org(user_id)
    {:ok, org_id: org, user_id: user_id}
  end

  test "dry-run plans app-DB-only USER rows and inserts nothing", %{user_id: uid} do
    legacy = insert_app_org_with_owner(uid)

    plan = PMBackfill.plan()
    assert plan.planned == 1
    [action] = plan.actions
    assert action.resource_type == "organization"
    assert to_string(action.resource_id) == legacy.id
    assert action.role == "owner"
    assert action.pm_user_id == uid
    assert action.via == :id

    # nothing inserted: the app-DB row still does not resolve from pm alone
    assert PMBackfill.plan().planned == 1
  end

  test "execute backfills and is idempotent across repeats", %{user_id: uid} do
    legacy = insert_app_org_with_owner(uid)

    %{inserted: 1, skipped: 0, errors: []} =
      PMBackfill.execute(PMBackfill.plan(), uid)

    # pm now covers the membership: re-plan finds nothing
    plan = PMBackfill.plan()
    assert plan.planned == 0
    assert plan.already_present >= 1

    # and the read path resolves it from pm (union's pm side wins)
    rows = ScopedMemberships.list_for_resource("organization", legacy.id)
    mine = Enum.filter(rows, &(&1.member_type == "user"))
    assert length(mine) == 1
    assert hd(mine).member_id == uid
  end

  test "ETL-collapsed user (same email, different uuid) lands on the right pm user", %{
    org_id: org,
    user_id: owner
  } do
    email = "backfill-#{System.unique_integer([:positive])}@example.com"
    pm_uid = insert_pm_user(email)
    app_uid = insert_app_user(email, "Backfill Collapsed User")
    insert_app_membership("organization", org, app_uid, "member")

    plan = PMBackfill.plan()
    action = Enum.find(plan.actions, &(&1.email == email))
    assert action, "expected an email-resolved action, got: #{inspect(plan.actions)}"
    assert action.pm_user_id == pm_uid
    assert action.via == :email

    %{inserted: inserted, errors: []} = PMBackfill.execute(plan, owner)
    assert inserted >= 1

    rows = ScopedMemberships.list_for_resource("organization", org)
    collapsed = Enum.filter(rows, &(&1.email == email))
    assert length(collapsed) == 1
    assert hd(collapsed).member_id == pm_uid
  end

  test "unresolvable members are reported, not guessed", %{org_id: org, user_id: owner} do
    ghost = Ecto.UUID.generate()
    :ok = insert_app_membership("organization", org, ghost, "viewer")

    plan = PMBackfill.plan()
    assert plan.planned == 0
    ghost_row = Enum.find(plan.unmatched, &(to_string(&1.member_id) == ghost))
    assert ghost_row
    assert ghost_row.reason == :no_pm_user
    # the setup owner's own org row resolves via pm — not in unmatched
    assert not Enum.any?(plan.unmatched, &(to_string(&1.member_id) == owner))
  end

  test "persona rows are never backfilled", %{org_id: org} do
    pid = insert_persona(org)
    {:ok, _} = ScopedMemberships.add_persona_member("organization", org, pid, "member")

    plan = PMBackfill.plan()
    # app user rows in this test: only the persona's org membership is user-typed
    # for the setup owner (already pm) — no persona action may appear
    assert Enum.all?(plan.actions, &(&1.pm_user_id != pid))
    assert not Enum.any?(plan.unmatched, &match?(%{member_id: ^pid}, &1))
  end

  describe "admin endpoint" do
    setup %{conn: conn} do
      %{access_token: token, user: user} = setup_user_and_token()
      auth_conn = authenticated_conn(conn, token)
      {:ok, conn: auth_conn, user: user, plain_conn: build_conn()}
    end

    test "non-admin gets 403 on the route", %{conn: conn} do
      # setup user defaults to role :user — the :admin pipeline must reject
      conn = get(conn, "/api/v1/admin/authz/pm-backfill")
      assert conn.status == 403
    end

    test "GET defaults to dry-run and inserts nothing", %{conn: conn, user: user} do
      promote_admin(user)
      before_plan = PMBackfill.plan()

      res = json_response(get(conn, "/api/v1/admin/authz/pm-backfill"), 200)
      assert res["dry_run"] == true
      assert res["inserted"] == 0
      assert res["planned"] == before_plan.planned
      assert PMBackfill.plan().planned == before_plan.planned
    end
  end

  # ── helpers (mirror scoped_memberships_pm_split_test seeding) ───────────

  defp insert_pm_user(email \\ nil) do
    email = email || "pm-backfill-#{System.unique_integer([:positive])}@example.com"

    %{rows: [[raw]]} =
      Ecto.Adapters.SQL.query!(
        Noizu.PM.Repo,
        "INSERT INTO users (id, email, user_name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [email, "PM Backfill User #{System.unique_integer([:positive])}"]
      )

    Ecto.UUID.load!(raw)
  end

  defp pm_org(user_id) do
    slug = "backfill-org-#{System.unique_integer([:positive])}"

    {:ok, org} =
      Organizations.create_organization_with_owner(%{slug: slug, name: "Backfill Org"}, user_id)

    to_string(org.id)
  end

  defp insert_app_user(email, user_name) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO users (id, email, user_name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::citext, $2, now(), now()) RETURNING id",
        [email, user_name]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_app_membership(resource_type, resource_id, member_id, role) do
    Repo.query!(
      "INSERT INTO scoped_memberships (id, group_id, resource_type, resource_id, member_type, member_id, created_at) " <>
        "SELECT gen_random_uuid(), g.id, $1, $2::uuid, 'user', $3::uuid, now() " <>
        "FROM groups g WHERE g.name = $4",
      [resource_type, Ecto.UUID.dump!(resource_id), Ecto.UUID.dump!(member_id), role]
    )

    :ok
  end

  defp insert_app_org_with_owner(user_id) do
    slug = "backfill-legacy-#{System.unique_integer([:positive])}"

    %{rows: [[raw_id]]} =
      Repo.query!(
        "WITH o AS (INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, 'Backfill Legacy Org', now(), now()) RETURNING id) " <>
          "SELECT id FROM o",
        [slug]
      )

    org_id = Ecto.UUID.load!(raw_id)
    :ok = insert_app_membership("organization", org_id, user_id, "owner")
    %{id: org_id, slug: slug}
  end

  defp insert_persona(org_id) do
    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1::uuid, $2, 'Backfill Mirror', now(), now()) ON CONFLICT (id) DO NOTHING",
      [Ecto.UUID.dump!(org_id), "backfill-mirror-#{System.unique_integer([:positive])}"]
    )

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO personas (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::uuid, $2, 'Backfill Persona', now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), "backfill-persona-#{System.unique_integer([:positive])}"]
      )

    Ecto.UUID.load!(raw)
  end

  defp promote_admin(user) do
    user
    |> Ecto.Changeset.change(role: :admin)
    |> Repo.update!()
  end
end
