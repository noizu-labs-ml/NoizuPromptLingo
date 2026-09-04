defmodule NoizuPromptLinguaWeb.Plugs.AuthzGuardsPlugsTest do
  @moduledoc """
  Branch coverage for the RequirePermission / RequireAdmin / RequireRole guard
  plugs (W4-D residual): auth-missing, param-missing, forbidden, and the
  happy-path assign/normalization branches on each guard.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: true

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLinguaWeb.Plugs.RequireAdmin
  alias NoizuPromptLinguaWeb.Plugs.RequirePermission
  alias NoizuPromptLinguaWeb.Plugs.RequireRole

  # ── helpers ──────────────────────────────────────────────────────

  defp insert_user!(role \\ :user) do
    uniq = System.unique_integer([:positive])

    %UserSchema{
      id: Ecto.UUID.generate(),
      email: "guard-#{uniq}@example.com",
      user_name: "guard#{uniq}",
      handle: "g#{uniq}",
      status: :active,
      role: role
    }
    |> Repo.insert!()
  end

  # Entity-layer session with a ref-shaped user (first guard clause).
  defp session_entity(user) do
    %NoizuPromptLingua.Users.Sessions.UserSession{
      id: Ecto.UUID.generate(),
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      status: :active,
      details: %{}
    }
  end

  # Attaches the principal the way Guardian does. `:ref` hits the first
  # get_user/1 clause (ref-shaped user), `:map` the second (plain map).
  defp sign_in(conn, user, shape \\ :ref) do
    entity =
      case shape do
        :map -> session_entity(user) |> Map.put(:user, %{id: user.id})
        _ -> session_entity(user)
      end

    NoizuPromptLingua.Guardian.Plug.put_current_resource(conn, entity)
  end

  defp add_membership!(user_id, resource_type, resource_id, group_name) do
    group = Repo.get_by!(Group, name: group_name, is_system: true)

    %ScopedMembership{
      resource_type: resource_type,
      resource_id: resource_id,
      member_type: "user",
      member_id: user_id,
      group_id: group.id
    }
    |> Repo.insert!()
  end

  # ── RequirePermission ────────────────────────────────────────────

  test "RequirePermission 401s without a signed-in principal" do
    conn =
      RequirePermission.call(
        build_conn() |> fetch_query_params(),
        RequirePermission.init(permission: "ticket_view")
      )

    assert conn.halted
    assert conn.status == 401
  end

  test "RequirePermission 400s when the resource id param is absent" do
    user = insert_user!()

    conn =
      build_conn()
      |> fetch_query_params()
      |> sign_in(user)
      |> RequirePermission.call(RequirePermission.init(permission: "ticket_view"))

    assert conn.halted
    assert conn.status == 400
  end

  test "RequirePermission 403s a non-member" do
    user = insert_user!()
    rid = Ecto.UUID.generate()

    conn =
      build_conn()
      |> sign_in(user)
      |> Map.put(:params, %{"org_id" => rid})
      |> RequirePermission.call(RequirePermission.init(permission: "ticket_view"))

    assert conn.halted
    assert conn.status == 403
  end

  test "RequirePermission passes a member with sufficient floor and assigns the check" do
    user = insert_user!()
    rid = Ecto.UUID.generate()
    add_membership!(user.id, "organization", rid, "member")

    conn =
      build_conn()
      |> sign_in(user)
      |> Map.put(:params, %{"org_id" => rid})
      |> RequirePermission.call(RequirePermission.init(permission: "ticket_create"))

    refute conn.halted
    assert conn.assigns.permission_checked == "ticket_create"
  end

  test "RequirePermission floors admin-only actions above plain members" do
    user = insert_user!()
    rid = Ecto.UUID.generate()
    add_membership!(user.id, "organization", rid, "member")

    conn =
      build_conn()
      |> sign_in(user)
      |> Map.put(:params, %{"org_id" => rid})
      |> RequirePermission.call(RequirePermission.init(permission: "ticket_delete"))

    assert conn.halted
    assert conn.status == 403
  end

  test "RequirePermission reads the resource id from path_params when params lack it" do
    user = insert_user!()
    rid = Ecto.UUID.generate()
    add_membership!(user.id, "organization", rid, "viewer")

    conn =
      build_conn()
      |> Map.put(:params, %{})
      |> Map.put(:path_params, %{"org_id" => rid})
      |> sign_in(user)
      |> RequirePermission.call(
        RequirePermission.init(permission: "ticket_view", resource_id_param: "org_id")
      )

    refute conn.halted
  end

  # ── RequireAdmin ─────────────────────────────────────────────────

  test "RequireAdmin 401s with no principal" do
    conn = RequireAdmin.call(build_conn(), [])

    assert conn.halted
    assert conn.status == 401
  end

  test "RequireAdmin 401s when the session user row is gone" do
    ghost = %NoizuPromptLingua.Users.Sessions.UserSession{
      id: Ecto.UUID.generate(),
      user: {:ref, NoizuPromptLingua.Users.User, Ecto.UUID.generate()},
      status: :active,
      details: %{}
    }

    conn =
      build_conn()
      |> NoizuPromptLingua.Guardian.Plug.put_current_resource(ghost)
      |> RequireAdmin.call([])

    assert conn.halted
    assert conn.status == 401
  end

  test "RequireAdmin 403s non-admin roles" do
    user = insert_user!(:user)

    conn =
      build_conn()
      |> sign_in(user, :map)
      |> RequireAdmin.call([])

    assert conn.halted
    assert conn.status == 403
  end

  test "RequireAdmin passes admins and owners via assign" do
    for role <- [:admin, :owner] do
      user = insert_user!(role)

      conn =
        build_conn()
        |> sign_in(user, :map)
        |> RequireAdmin.call([])

      refute conn.halted
      assert conn.assigns.admin_user.id == user.id
    end
  end

  # ── RequireRole ──────────────────────────────────────────────────

  test "RequireRole 401s without a principal" do
    conn = RequireRole.call(build_conn() |> fetch_query_params(), RequireRole.init(role: :member))

    assert conn.halted
    assert conn.status == 401
  end

  test "RequireRole 400s without an org id" do
    user = insert_user!()

    conn =
      build_conn()
      |> fetch_query_params()
      |> sign_in(user)
      |> RequireRole.call(RequireRole.init(role: :member))

    assert conn.halted
    assert conn.status == 400
  end

  test "RequireRole 404s an unknown org slug" do
    user = insert_user!()

    conn =
      build_conn()
      |> sign_in(user)
      |> Map.put(:params, %{"org_id" => "no-such-org-slug"})
      |> RequireRole.call(RequireRole.init(role: :member))

    assert conn.halted
    assert conn.status == 404
  end

  test "RequireRole 403s non-members and under-ranked members distinctly" do
    org =
      Repo.insert!(%Organization{
        name: "guard-org",
        slug: "guard-org-#{System.unique_integer([:positive])}"
      })

    member = insert_user!()
    viewer = insert_user!()

    add_membership!(member.id, "organization", org.id, "member")
    add_membership!(viewer.id, "organization", org.id, "viewer")

    for {u, expect_error} <- [
          {viewer, "Insufficient permissions"},
          {insert_user!(), "Not a member of this organization"}
        ] do
      conn =
        build_conn()
        |> sign_in(u)
        |> Map.put(:params, %{"org_id" => org.id})
        |> RequireRole.call(RequireRole.init(role: :member))

      assert conn.halted
      assert conn.status == 403
      assert conn.resp_body =~ expect_error
    end

    # member passes the :member gate
    ok =
      build_conn()
      |> sign_in(member)
      |> Map.put(:params, %{"org_id" => org.id})
      |> RequireRole.call(RequireRole.init(role: :member))

    refute ok.halted
    assert ok.assigns.current_membership.role == "member"
  end

  test "RequireRole normalizes slug org ids to the UUID in params and path_params" do
    slug = "guard-slug-#{System.unique_integer([:positive])}"
    org = Repo.insert!(%Organization{name: "guard-org", slug: slug})
    admin = insert_user!()
    add_membership!(admin.id, "organization", org.id, "admin")

    conn =
      build_conn()
      |> sign_in(admin)
      |> Map.put(:params, %{"org_id" => slug, "organization_id" => slug})
      |> Map.put(:path_params, %{"org_id" => slug})
      |> RequireRole.call(RequireRole.init(role: :admin))

    refute conn.halted
    assert conn.params["org_id"] == org.id
    assert conn.params["organization_id"] == org.id
    assert conn.path_params["org_id"] == org.id
  end
end
