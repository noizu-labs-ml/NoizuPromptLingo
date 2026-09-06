defmodule NoizuPromptLinguaWeb.SessionControllerTest do
  @moduledoc """
  Org-scoped work sessions: index filters, create/show/update/delete lifecycle,
  archive/unarchive, project-binding validation (TRP-backed), and the auth
  matrix (pipeline 401, non-member 403, viewer-vs-member 403, unknown org 404,
  cross-org 404 IDOR guards).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Sessions
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "sess-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Session Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    %{access_token: viewer_token, user: viewer} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

    %{access_token: outsider_token} = setup_user_and_token()

    {:ok,
     auth: auth,
     user: user,
     org_id: org_id,
     viewer_token: viewer_token,
     outsider_token: outsider_token}
  end

  defp path(org_id, suffix \\ "/sessions"), do: "/api/v1/organizations/#{org_id}#{suffix}"

  defp create_session(auth, org_id, attrs \\ %{}) do
    attrs = Map.merge(%{title: "Work Sprint"}, attrs)

    auth
    |> post(path(org_id), %{session: attrs})
    |> json_response(201)
    |> get_in(["session", "id"])
  end

  # ── Auth matrix ───────────────────────────────────────────────────────────

  describe "auth matrix" do
    test "unauthenticated request is rejected by the pipeline", %{conn: conn, org_id: org_id} do
      assert %{"error" => "unauthenticated"} = conn |> get(path(org_id)) |> json_response(401)
    end

    test "non-member gets 403 not_a_member on index", %{
      conn: conn,
      org_id: org_id,
      outsider_token: t
    } do
      assert %{"error" => "Not a member of this organization"} =
               conn |> authenticated_conn(t) |> get(path(org_id)) |> json_response(403)
    end

    test "viewer is denied member-only create", %{conn: conn, org_id: org_id, viewer_token: t} do
      assert %{"error" => "Insufficient permissions"} =
               conn
               |> authenticated_conn(t)
               |> post(path(org_id), %{session: %{title: "Nope"}})
               |> json_response(403)
    end

    test "viewer is denied member-only archive", %{
      conn: conn,
      auth: auth,
      org_id: org_id,
      viewer_token: t
    } do
      id = create_session(auth, org_id)

      assert %{"error" => "Insufficient permissions"} =
               conn
               |> authenticated_conn(t)
               |> post(path(org_id, "/sessions/#{id}/archive"), %{})
               |> json_response(403)
    end

    test "unknown org slug returns 404", %{auth: auth} do
      assert %{"error" => "Organization not found"} =
               auth |> get(path("no-such-sess-org")) |> json_response(404)
    end
  end

  # ── Index ─────────────────────────────────────────────────────────────────

  describe "GET /sessions" do
    test "lists org sessions", %{auth: auth, org_id: org_id} do
      create_session(auth, org_id, %{title: "A"})
      create_session(auth, org_id, %{title: "B"})

      %{"sessions" => sessions} = auth |> get(path(org_id)) |> json_response(200)
      assert length(sessions) == 2
    end

    test "status filter", %{auth: auth, org_id: org_id} do
      create_session(auth, org_id, %{title: "Live", status: "active"})
      create_session(auth, org_id, %{title: "Done", status: "completed"})

      %{"sessions" => live} =
        auth |> get(path(org_id), status: "active") |> json_response(200)

      assert [%{"title" => "Live", "status" => "active"}] = live
    end

    test "project_id filter and empty-string filters are ignored", %{
      auth: auth,
      org_id: org_id
    } do
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-org")
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      proj = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{slug: "flt-proj"})
      create_session(auth, org_id, %{title: "WithProj", project_id: proj.id})
      create_session(auth, org_id, %{title: "Bare"})

      %{"sessions" => by_proj} =
        auth |> get(path(org_id), project_id: proj.id) |> json_response(200)

      assert [%{"title" => "WithProj"}] = by_proj

      %{"sessions" => all} =
        auth |> get(path(org_id), status: "", project_id: "") |> json_response(200)

      assert length(all) == 2
    end
  end

  # ── Create ────────────────────────────────────────────────────────────────

  describe "POST /sessions" do
    test "creates with defaults and stamps created_by", %{auth: auth, org_id: org_id, user: user} do
      body =
        auth
        |> post(path(org_id), %{session: %{title: "New Sprint", description: "d"}})
        |> json_response(201)
        |> Map.fetch!("session")

      assert body["title"] == "New Sprint"
      assert body["status"] == "active"
      assert body["organization_id"] == org_id
      assert body["project_id"] == nil
      assert body["archived_at"] == nil
    end

    test "creates with an org project (TRP-backed validation)", %{auth: auth, org_id: org_id} do
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-org")
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      proj = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{slug: "sess-proj"})

      body =
        auth
        |> post(path(org_id), %{session: %{title: "T", project_id: proj.id}})
        |> json_response(201)
        |> Map.fetch!("session")

      assert body["project_id"] == proj.id
    end

    test "without title is 422", %{auth: auth, org_id: org_id} do
      assert %{"errors" => errors} =
               auth
               |> post(path(org_id), %{session: %{description: "no title"}})
               |> json_response(422)

      assert errors["title"]
    end

    test "invalid status is 422", %{auth: auth, org_id: org_id} do
      assert %{"errors" => errors} =
               auth
               |> post(path(org_id), %{session: %{title: "T", status: "bogus"}})
               |> json_response(422)

      assert errors["status"]
    end

    test "project from another org is 422", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Project does not belong to this organization"} =
               auth
               |> post(path(org_id), %{session: %{title: "T", project_id: Ecto.UUID.generate()}})
               |> json_response(422)
    end
  end

  # ── Show / Update / Delete ────────────────────────────────────────────────

  describe "GET /sessions/:id" do
    test "shows a session", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id, %{title: "Shown"})

      assert %{"session" => %{"id" => ^id, "title" => "Shown"}} =
               auth |> get(path(org_id, "/sessions/#{id}")) |> json_response(200)
    end

    test "unknown id is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Session not found"} =
               auth
               |> get(path(org_id, "/sessions/#{Ecto.UUID.generate()}"))
               |> json_response(404)
    end

    test "cross-org session is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      other_org = Ecto.UUID.generate()

      {:ok, foreign} =
        Sessions.create(%{organization_id: other_org, title: "Foreign"}, nil)

      assert %{"error" => "Session not found"} =
               auth |> get(path(org_id, "/sessions/#{foreign.id}")) |> json_response(404)
    end
  end

  describe "PUT /sessions/:id" do
    test "updates mutable fields", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)

      body =
        auth
        |> put(path(org_id, "/sessions/#{id}"), %{
          session: %{title: "Renamed", description: "d2", status: "completed"}
        })
        |> json_response(200)
        |> Map.fetch!("session")

      assert body["title"] == "Renamed"
      assert body["description"] == "d2"
      assert body["status"] == "completed"
    end

    test "rebinds to an org project", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-org")
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      proj = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{slug: "rebind-proj"})

      body =
        auth
        |> put(path(org_id, "/sessions/#{id}"), %{session: %{project_id: proj.id}})
        |> json_response(200)
        |> Map.fetch!("session")

      assert body["project_id"] == proj.id
    end

    test "invalid status is 422 (changeset arm)", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)

      assert %{"errors" => errors} =
               auth
               |> put(path(org_id, "/sessions/#{id}"), %{session: %{status: "wat"}})
               |> json_response(422)

      assert errors["status"]
    end

    test "foreign project is 422", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)

      assert %{"error" => "Project does not belong to this organization"} =
               auth
               |> put(path(org_id, "/sessions/#{id}"), %{
                 session: %{project_id: Ecto.UUID.generate()}
               })
               |> json_response(422)
    end

    test "unknown id is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Session not found"} =
               auth
               |> put(path(org_id, "/sessions/#{Ecto.UUID.generate()}"), %{session: %{title: "X"}})
               |> json_response(404)
    end

    test "cross-org session is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      other_org = Ecto.UUID.generate()
      {:ok, foreign} = Sessions.create(%{organization_id: other_org, title: "F"}, nil)

      assert %{"error" => "Session not found"} =
               auth
               |> put(path(org_id, "/sessions/#{foreign.id}"), %{session: %{title: "Hijack"}})
               |> json_response(404)
    end
  end

  describe "archive/unarchive/delete" do
    test "archive sets status + archived_at; unarchive clears it", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)

      archived =
        auth
        |> post(path(org_id, "/sessions/#{id}/archive"), %{})
        |> json_response(200)
        |> Map.fetch!("session")

      assert archived["status"] == "archived"
      refute archived["archived_at"] == nil

      restored =
        auth
        |> post(path(org_id, "/sessions/#{id}/unarchive"), %{})
        |> json_response(200)
        |> Map.fetch!("session")

      assert restored["status"] == "active"
      assert restored["archived_at"] == nil
    end

    test "archive of unknown session is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Session not found"} =
               auth
               |> post(path(org_id, "/sessions/#{Ecto.UUID.generate()}/archive"), %{})
               |> json_response(404)
    end

    test "delete removes the session and it then 404s", %{auth: auth, org_id: org_id} do
      id = create_session(auth, org_id)

      assert %{"message" => "Session deleted"} =
               auth |> delete(path(org_id, "/sessions/#{id}")) |> json_response(200)

      assert %{"error" => "Session not found"} =
               auth |> get(path(org_id, "/sessions/#{id}")) |> json_response(404)
    end

    test "delete of unknown session is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Session not found"} =
               auth
               |> delete(path(org_id, "/sessions/#{Ecto.UUID.generate()}"))
               |> json_response(404)
    end
  end
end
