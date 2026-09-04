defmodule NoizuPromptLinguaWeb.ProjectControllerTest do
  @moduledoc """
  ProjectController — CRUD + archive/leave/members over the TRP shared-key
  plane (in-memory TestStub transport wired in test_helper.exs) with app-DB
  PBAC permission checks.

  Two behaviors are PINNED as documented findings, not endorsements:

    * freshly created projects grant the creator NO project-scope membership
      (TRP v1 has no membership surface; `create_with_owner/2` ignores the
      user id) — show/update by the creator 403 until a membership is added
      via the app-DB `ScopedMemberships` plane;
    * archive/unarchive are unsupported on the shared-key plane and surface
      as 422 (controller gained the `{:error, reason}` clause in cov-w2d —
      previously the tuple crashed the case -> 500).
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.TRP.TestStub

  @base "/api/v1/organizations"

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    suffix = System.unique_integer([:positive])
    slug = "pc-#{suffix}"

    org_id =
      auth
      |> post(@base, %{organization: %{slug: slug, name: "Proj Org #{suffix}"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    # TRP org provisioning warns+skips in tests (:trp_service_not_configured);
    # seed the stub org so project lookups (scan_orgs) resolve.
    TestStub.seed_org(org_id, slug, "Proj Org #{suffix}")
    # The TRP client caches GETs in a global ETS (survives sandbox rollback);
    # clear it so this test's org is visible to list-based scans.
    NoizuPromptLingua.TRP.Cache.clear()

    {:ok, conn: auth, user: user, org_id: org_id}
  end

  defp create_project(conn, org_id, attrs \\ %{}) do
    slug = "proj-#{System.unique_integer([:positive])}"

    payload =
      Map.merge(
        %{"name" => "Proj", "slug" => slug, "description" => "d", "key_prefix" => "PRJ"},
        attrs
      )

    resp = post(conn, "#{@base}/#{org_id}/projects", %{"project" => payload})
    {resp.status, resp}
  end

  defp grant_project_role(user_id, project_id, role) do
    assert {:ok, _} = ScopedMemberships.add_member("project", project_id, user_id, role)
  end

  # ── index / create ────────────────────────────────────────────────────────

  describe "index" do
    test "empty then populated", %{conn: conn, org_id: org_id} do
      assert %{"projects" => []} = json_response(get(conn, "#{@base}/#{org_id}/projects"), 200)

      {201, resp} = create_project(conn, org_id)
      json_response(resp, 201)

      assert [%{"slug" => slug}] =
               json_response(get(conn, "#{@base}/#{org_id}/projects"), 200)["projects"]

      assert String.starts_with?(slug, "proj-")
    end

    test "non-member -> 403; unknown org -> 404", %{conn: conn, org_id: org_id} do
      %{access_token: other_token} = setup_user_and_token()
      other = authenticated_conn(build_conn(), other_token)

      assert %{"error" => "Not a member of this organization"} =
               json_response(get(other, "#{@base}/#{org_id}/projects"), 403)

      assert %{"error" => "Organization not found"} =
               json_response(get(conn, "#{@base}/bogus-org-xyz/projects"), 404)
    end
  end

  describe "create" do
    test "owner creates; fields echoed", %{conn: conn, org_id: org_id} do
      {201, resp} = create_project(conn, org_id, %{"settings" => %{"theme" => "dark"}})
      project = json_response(resp, 201)["project"]

      assert project["organization_id"] == org_id
      assert project["key_prefix"] == "PRJ"
      # TRP v1 shape does not round-trip `settings`.
      assert project["status"] == "active"
    end

    test "org viewer cannot create -> 403", %{conn: conn, org_id: org_id} do
      %{access_token: vtok, user: vuser} = setup_user_and_token()
      assert {:ok, _} = ScopedMemberships.add_member("organization", org_id, vuser.id, "viewer")

      assert %{"error" => "Insufficient permissions"} =
               json_response(
                 post(authenticated_conn(build_conn(), vtok), "#{@base}/#{org_id}/projects", %{
                   "project" => %{"name" => "x"}
                 }),
                 403
               )
    end

    test "unknown org -> 404", %{conn: conn} do
      assert %{"error" => "Organization not found"} =
               json_response(
                 post(conn, "#{@base}/bogus-org-xyz/projects", %{"project" => %{"name" => "x"}}),
                 404
               )
    end

    test "TRP 422 envelope -> 422 error body", %{conn: conn, org_id: org_id} do
      TestStub.queue_response({422, %{"errors" => %{"name" => ["can't be blank"]}}})

      {_, resp} = create_project(conn, org_id)
      assert %{"error" => msg} = json_response(resp, 422)
      assert is_binary(msg) and msg != ""
    end

    @doc "NOTE: the stub accepts duplicate slugs, so the 422-on-duplicate fix (other branch) is not reachable at this base."
    test "duplicate slug accepted by the shared-key plane (spec gap)", %{
      conn: conn,
      org_id: org_id
    } do
      {201, resp} = create_project(conn, org_id, %{"slug" => "dup-slug-x"})
      first = json_response(resp, 201)["project"]["id"]

      {201, resp2} = create_project(conn, org_id, %{"slug" => "dup-slug-x"})
      second = json_response(resp2, 201)["project"]["id"]

      assert first != second
    end
  end

  # ── show / update / delete ────────────────────────────────────────────────

  describe "show" do
    test "creator has NO implicit project membership -> 403 until granted (spec gap)", %{
      conn: conn,
      org_id: org_id,
      user: user
    } do
      {201, resp} = create_project(conn, org_id)
      project = json_response(resp, 201)["project"]

      assert %{"error" => "Insufficient permissions"} =
               json_response(get(conn, "#{@base}/#{org_id}/projects/#{project["id"]}"), 403)

      grant_project_role(user.id, project["id"], "owner")

      assert %{"project" => %{"id" => id}} =
               json_response(get(conn, "#{@base}/#{org_id}/projects/#{project["id"]}"), 200)

      assert id == project["id"]
    end

    test "membership on a nonexistent project -> 404", %{conn: conn, org_id: org_id, user: user} do
      bogus = Ecto.UUID.generate()
      grant_project_role(user.id, bogus, "member")

      assert %{"error" => "Project not found"} =
               json_response(get(conn, "#{@base}/#{org_id}/projects/#{bogus}"), 404)
    end
  end

  describe "update" do
    setup %{conn: conn, org_id: org_id, user: user} do
      {201, resp} = create_project(conn, org_id)
      project = json_response(resp, 201)["project"]
      grant_project_role(user.id, project["id"], "owner")
      {:ok, project: project}
    end

    test "200 update", %{conn: conn, org_id: org_id, project: project} do
      # Warm the orgs-list cache so scan_orgs serves it from cache (no
      # request), then queue a deterministic PATCH envelope. Covers the
      # controller 200-mapping without depending on cross-test stub ETS state.
      NoizuPromptLingua.TRP.list_organizations()
      TestStub.queue_response({200, %{"project" => Map.put(project, "name", "Renamed")}})

      assert %{"project" => %{"name" => "Renamed"}} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/projects/#{project["id"]}", %{
                   "project" => %{"name" => "Renamed"}
                 }),
                 200
               )
    end

    test "unknown project -> TRP 404 -> 404", %{conn: conn, org_id: org_id, user: user} do
      bogus = Ecto.UUID.generate()
      grant_project_role(user.id, bogus, "owner")

      assert %{"error" => "Project not found"} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/projects/#{bogus}", %{
                   "project" => %{"name" => "x"}
                 }),
                 404
               )
    end

    test "TRP 422 envelope -> 422 error body (was: crashed format_errors -> 500)", %{
      conn: conn,
      org_id: org_id,
      project: project
    } do
      TestStub.queue_response({422, %{"errors" => %{"name" => ["too long"]}}})

      assert %{"error" => msg} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/projects/#{project["id"]}", %{
                   "project" => %{"name" => "x"}
                 }),
                 422
               )

      assert is_binary(msg) and msg != ""
    end

    test "no membership -> 403", %{conn: conn, org_id: org_id} do
      %{access_token: other_token} = setup_user_and_token()
      other = authenticated_conn(build_conn(), other_token)

      assert %{"error" => "Insufficient permissions"} =
               json_response(
                 put(other, "#{@base}/#{org_id}/projects/#{Ecto.UUID.generate()}", %{
                   "project" => %{"name" => "x"}
                 }),
                 403
               )
    end
  end

  describe "delete" do
    test "200 delete", %{conn: conn, org_id: org_id, user: user} do
      {201, resp} = create_project(conn, org_id)
      project = json_response(resp, 201)["project"]
      grant_project_role(user.id, project["id"], "owner")

      # Warm the orgs-list cache (scan_orgs then serves it from cache, no
      # request) and queue a deterministic DELETE envelope — covers the
      # controller 200-mapping without depending on cross-test stub ETS state.
      NoizuPromptLingua.TRP.list_organizations()
      TestStub.queue_response({200, %{"project" => project}})

      assert %{"message" => "Project deleted"} =
               json_response(delete(conn, "#{@base}/#{org_id}/projects/#{project["id"]}"), 200)
    end

    test "unknown project -> 404", %{conn: conn, org_id: org_id, user: user} do
      bogus = Ecto.UUID.generate()
      grant_project_role(user.id, bogus, "admin")

      assert %{"error" => "Project not found"} =
               json_response(delete(conn, "#{@base}/#{org_id}/projects/#{bogus}"), 404)
    end
  end

  describe "archive / unarchive" do
    test "no membership -> 403", %{conn: conn, org_id: org_id} do
      bogus = Ecto.UUID.generate()

      assert %{"error" => "Insufficient permissions"} =
               json_response(post(conn, "#{@base}/#{org_id}/projects/#{bogus}/archive"), 403)

      assert %{"error" => "Insufficient permissions"} =
               json_response(post(conn, "#{@base}/#{org_id}/projects/#{bogus}/unarchive"), 403)
    end

    test "supported-permission + unsupported-plane -> 422 (not 500)", %{
      conn: conn,
      org_id: org_id,
      user: user
    } do
      {201, resp} = create_project(conn, org_id)
      project = json_response(resp, 201)["project"]
      grant_project_role(user.id, project["id"], "owner")

      assert %{"error" => "trp_unsupported_shared_key"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/projects/#{project["id"]}/archive"),
                 422
               )

      assert %{"error" => "trp_unsupported_shared_key"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/projects/#{project["id"]}/unarchive"),
                 422
               )
    end
  end

  # ── members ───────────────────────────────────────────────────────────────

  describe "members management" do
    setup %{conn: conn, org_id: org_id, user: user} do
      {201, resp} = create_project(conn, org_id)
      project = json_response(resp, 201)["project"]
      grant_project_role(user.id, project["id"], "owner")

      %{access_token: m2tok, user: m2} = setup_user_and_token()
      assert {:ok, _} = ScopedMemberships.add_member("organization", org_id, m2.id, "member")

      {:ok, project: project, m2: m2, m2tok: m2tok}
    end

    test "list members", %{conn: conn, org_id: org_id, project: project, user: user} do
      assert %{"members" => members} =
               json_response(
                 get(conn, "#{@base}/#{org_id}/projects/#{project["id"]}/members"),
                 200
               )

      assert Enum.any?(members, &(&1["user_id"] == user.id or &1["member_id"] == user.id))
    end

    test "list without membership -> 403", %{conn: conn, org_id: org_id, project: project} do
      %{access_token: other_token} = setup_user_and_token()

      assert %{"error" => "Insufficient permissions"} =
               json_response(
                 get(
                   authenticated_conn(build_conn(), other_token),
                   "#{@base}/#{org_id}/projects/#{project["id"]}/members"
                 ),
                 403
               )
    end

    test "add member 201; duplicate 409; invalid role 400; non-admin 403", %{
      conn: conn,
      org_id: org_id,
      project: project,
      m2: m2,
      m2tok: m2tok
    } do
      url = "#{@base}/#{org_id}/projects/#{project["id"]}/members"

      assert %{"members" => members} =
               json_response(post(conn, url, %{"user_id" => m2.id, "role" => "member"}), 201)

      assert Enum.any?(members, &(&1["user_id"] == m2.id or &1["member_id"] == m2.id))

      assert %{"error" => "User is already a member"} =
               json_response(post(conn, url, %{"user_id" => m2.id, "role" => "member"}), 409)

      assert %{"error" => "Invalid role"} =
               json_response(
                 post(conn, url, %{"user_id" => Ecto.UUID.generate(), "role" => "wizard"}),
                 400
               )

      assert %{"error" => "Insufficient permissions"} =
               json_response(
                 post(authenticated_conn(build_conn(), m2tok), url, %{
                   "user_id" => Ecto.UUID.generate()
                 }),
                 403
               )
    end

    test "update member 200; self-change 400; unknown 404; invalid role 422", %{
      conn: conn,
      org_id: org_id,
      project: project,
      user: user,
      m2: m2
    } do
      grant_project_role(m2.id, project["id"], "member")
      url = "#{@base}/#{org_id}/projects/#{project["id"]}/members/#{m2.id}"

      assert %{"membership" => %{"member_id" => member_id}} =
               json_response(patch(conn, url, %{"role" => "admin"}), 200)

      assert member_id == m2.id

      assert %{"error" => "Cannot change your own role"} =
               json_response(
                 patch(conn, "#{@base}/#{org_id}/projects/#{project["id"]}/members/#{user.id}", %{
                   "role" => "admin"
                 }),
                 400
               )

      assert %{"error" => "invalid_role"} =
               json_response(patch(conn, url, %{"role" => "wizard"}), 422)

      assert %{"error" => "Member not found"} =
               json_response(
                 patch(
                   conn,
                   "#{@base}/#{org_id}/projects/#{project["id"]}/members/#{Ecto.UUID.generate()}",
                   %{"role" => "admin"}
                 ),
                 404
               )
    end

    test "remove member 200; sole owner 400; unknown 404", %{
      conn: conn,
      org_id: org_id,
      project: project,
      m2: m2,
      user: user
    } do
      grant_project_role(m2.id, project["id"], "owner")
      url = "#{@base}/#{org_id}/projects/#{project["id"]}/members"

      assert %{"message" => "Member removed"} =
               json_response(delete(conn, "#{url}/#{m2.id}"), 200)

      assert %{"error" => "Cannot remove the sole owner"} =
               json_response(delete(conn, "#{url}/#{user.id}"), 400)

      assert %{"error" => "Member not found"} =
               json_response(delete(conn, "#{url}/#{Ecto.UUID.generate()}"), 404)
    end

    test "leave 200; sole owner 400; non-member 404", %{
      conn: conn,
      org_id: org_id,
      project: project,
      m2: m2,
      m2tok: m2tok,
      user: user
    } do
      grant_project_role(m2.id, project["id"], "member")

      assert %{"message" => "Left project"} =
               json_response(
                 post(
                   authenticated_conn(build_conn(), m2tok),
                   "#{@base}/#{org_id}/projects/#{project["id"]}/leave"
                 ),
                 200
               )

      assert %{"error" => "Cannot leave as sole owner. Transfer ownership first."} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/projects/#{project["id"]}/leave"),
                 400
               )

      %{access_token: other_token} = setup_user_and_token()

      assert %{"error" => "Not a member"} =
               json_response(
                 post(
                   authenticated_conn(build_conn(), other_token),
                   "#{@base}/#{org_id}/projects/#{project["id"]}/leave"
                 ),
                 404
               )
    end
  end
end
