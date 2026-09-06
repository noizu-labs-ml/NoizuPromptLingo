defmodule NoizuPromptLinguaWeb.WikiControllerTest do
  @moduledoc """
  Org-scoped wiki spaces/pages/comments/attachments/reactions. Covers happy
  CRUD, validation errors, project-binding validation, and the auth matrix
  (pipeline 401, non-member 403, viewer-vs-member 403, unknown org 404,
  cross-org 404 IDOR guards).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "wiki-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Wiki Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    %{access_token: viewer_token, user: viewer} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

    %{access_token: outsider_token} = setup_user_and_token()

    {:ok,
     auth: auth,
     org_id: org_id,
     user: user,
     viewer_token: viewer_token,
     outsider_token: outsider_token}
  end

  defp space_path(org_id, suffix \\ ""),
    do: "/api/v1/organizations/#{org_id}/wiki/spaces#{suffix}"

  defp page_path(org_id, suffix), do: "/api/v1/organizations/#{org_id}/wiki/pages#{suffix}"

  # A real second org row: FK-backed seeds (spaces etc.) need an existing org.
  defp foreign_org do
    {:ok, org} =
      NoizuPromptLingua.Repo.insert(%NoizuPromptLingua.Schema.Organizations.Organization{
        slug: "foreign-#{System.unique_integer([:positive])}",
        name: "Foreign Org"
      })

    org.id
  end

  defp create_space(auth, org_id, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{name: "Handbook", description: "org docs"},
        attrs
      )

    auth
    |> post(space_path(org_id), %{space: attrs})
    |> json_response(201)
    |> get_in(["space", "id"])
  end

  defp create_page(auth, org_id, space_id, attrs \\ %{}) do
    attrs = Map.merge(%{title: "Intro", content: "hello"}, attrs)

    auth
    |> post(space_path(org_id, "/#{space_id}/pages"), %{page: attrs})
    |> json_response(201)
    |> get_in(["page", "id"])
  end

  # ── Auth matrix ───────────────────────────────────────────────────────────

  describe "auth matrix" do
    test "unauthenticated request is rejected by the pipeline", %{conn: conn, org_id: org_id} do
      assert %{"error" => "unauthenticated"} =
               conn |> get(space_path(org_id)) |> json_response(401)
    end

    test "non-member gets 403 not_a_member", %{conn: conn, org_id: org_id, outsider_token: t} do
      conn = authenticated_conn(conn, t)

      assert %{"error" => "Not a member of this organization"} =
               conn |> get(space_path(org_id)) |> json_response(403)
    end

    test "viewer is denied member-only create_space", %{
      conn: conn,
      org_id: org_id,
      viewer_token: t
    } do
      assert %{"error" => "Insufficient permissions"} =
               conn
               |> authenticated_conn(t)
               |> post(space_path(org_id), %{space: %{name: "Nope"}})
               |> json_response(403)
    end

    test "unknown org slug returns 404", %{auth: auth} do
      assert %{"error" => "Organization not found"} =
               auth |> get(space_path("no-such-wiki-org")) |> json_response(404)
    end

    test "nonexistent org uuid passes resolution but fails membership", %{auth: auth} do
      uuid = Ecto.UUID.generate()

      assert %{"error" => "Not a member of this organization"} =
               auth |> get(space_path(uuid)) |> json_response(403)
    end
  end

  # ── Spaces ────────────────────────────────────────────────────────────────

  describe "spaces" do
    test "index lists org spaces and honors search filter", %{auth: auth, org_id: org_id} do
      create_space(auth, org_id, %{name: "Alpha Docs"})
      create_space(auth, org_id, %{name: "Beta Lab"})

      %{"spaces" => all} = auth |> get(space_path(org_id)) |> json_response(200)
      assert length(all) == 2

      %{"spaces" => filtered} =
        auth |> get(space_path(org_id), search: "alpha") |> json_response(200)

      assert [%{"name" => "Alpha Docs"}] = filtered
    end

    test "empty-string search param is ignored", %{auth: auth, org_id: org_id} do
      create_space(auth, org_id)

      %{"spaces" => spaces} = auth |> get(space_path(org_id), search: "") |> json_response(200)
      assert length(spaces) == 1
    end

    test "create defaults slug from name and returns 201", %{auth: auth, org_id: org_id} do
      body =
        auth
        |> post(space_path(org_id), %{space: %{name: "Design Docs"}})
        |> json_response(201)
        |> Map.fetch!("space")

      assert body["slug"] == "design-docs"
      assert body["name"] == "Design Docs"
      assert body["organization_id"] == org_id
    end

    test "create without name is 422", %{auth: auth, org_id: org_id} do
      assert %{"errors" => errors} =
               auth
               |> post(space_path(org_id), %{space: %{description: "no name"}})
               |> json_response(422)

      assert errors["name"]
    end

    test "create with a project from another org is 422", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Project does not belong to this organization"} =
               auth
               |> post(space_path(org_id), %{
                 space: %{name: "X", project_id: Ecto.UUID.generate()}
               })
               |> json_response(422)
    end

    test "create with an org project succeeds (TRP-backed validation)", %{
      auth: auth,
      org_id: org_id
    } do
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-org")
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      proj = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{slug: "wiki-proj"})

      body =
        auth
        |> post(space_path(org_id), %{space: %{name: "Proj Space", project_id: proj.id}})
        |> json_response(201)
        |> Map.fetch!("space")

      assert body["project_id"] == proj.id
    end

    test "show returns space with its pages", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      create_page(auth, org_id, space_id, %{title: "Only Page"})

      body = auth |> get(space_path(org_id, "/#{space_id}")) |> json_response(200)
      assert body["space"]["id"] == space_id
      assert [%{"title" => "Only Page"}] = body["pages"]
    end

    test "show of a space from another org is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      {:ok, foreign} = Wiki.create_space(%{organization_id: foreign_org(), name: "Foreign"})

      assert %{"error" => "Space not found"} =
               auth |> get(space_path(org_id, "/#{foreign.id}")) |> json_response(404)
    end

    test "show of unknown space is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Space not found"} =
               auth |> get(space_path(org_id, "/#{Ecto.UUID.generate()}")) |> json_response(404)
    end

    test "update renames a space", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)

      body =
        auth
        |> put(space_path(org_id, "/#{space_id}"), %{space: %{name: "Renamed", description: "d2"}})
        |> json_response(200)
        |> Map.fetch!("space")

      assert body["name"] == "Renamed"
      assert body["description"] == "d2"
    end

    test "update with blank project_id clears it (maybe_put true arm)", %{
      auth: auth,
      org_id: org_id
    } do
      _ = NoizuPromptLingua.TRP.TestStub.seed_org(org_id, "stub-org")
      NoizuPromptLingua.TRP.Cache.bust_prefix([:orgs])
      proj = NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{slug: "clr-proj"})
      space_id = create_space(auth, org_id, %{project_id: proj.id})

      body =
        auth
        |> put(space_path(org_id, "/#{space_id}"), %{space: %{"project_id" => ""}})
        |> json_response(200)
        |> Map.fetch!("space")

      assert body["project_id"] == nil
    end

    test "update with invalid slug is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)

      assert %{"errors" => errors} =
               auth
               |> put(space_path(org_id, "/#{space_id}"), %{space: %{slug: "Not Valid!"}})
               |> json_response(422)

      assert errors["slug"]
    end

    test "delete removes the space and it then 404s", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)

      assert %{"message" => "Space deleted"} =
               auth |> delete(space_path(org_id, "/#{space_id}")) |> json_response(200)

      assert %{"error" => "Space not found"} =
               auth |> get(space_path(org_id, "/#{space_id}")) |> json_response(404)
    end
  end

  # ── Pages ─────────────────────────────────────────────────────────────────

  describe "pages" do
    test "index lists pages in a space and honors search", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      create_page(auth, org_id, space_id, %{title: "Setup Guide"})
      create_page(auth, org_id, space_id, %{title: "Runbook"})

      %{"pages" => all} =
        auth |> get(space_path(org_id, "/#{space_id}/pages")) |> json_response(200)

      assert length(all) == 2

      %{"pages" => filtered} =
        auth
        |> get(space_path(org_id, "/#{space_id}/pages"), search: "runbook")
        |> json_response(200)

      assert [%{"title" => "Runbook"}] = filtered
    end

    test "create defaults slug and position, blank parent_id becomes nil", %{
      auth: auth,
      org_id: org_id
    } do
      space_id = create_space(auth, org_id)

      body =
        auth
        |> post(space_path(org_id, "/#{space_id}/pages"), %{
          page: %{title: "Getting Started", content: "c", parent_id: ""}
        })
        |> json_response(201)
        |> Map.fetch!("page")

      assert body["slug"] == "getting-started"
      assert body["title"] == "Getting Started"
      assert body["parent_id"] == nil
      assert body["space_id"] == space_id
      # Position defaults to max+1 (1 for the first page in the space).
      assert body["position"] == 1
    end

    test "create without title is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)

      assert %{"errors" => errors} =
               auth
               |> post(space_path(org_id, "/#{space_id}/pages"), %{page: %{content: "x"}})
               |> json_response(422)

      assert errors["title"]
    end

    test "show returns page with comments/attachments/reactions arrays", %{
      auth: auth,
      org_id: org_id
    } do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      body = auth |> get(page_path(org_id, "/#{page_id}")) |> json_response(200)
      assert body["page"]["id"] == page_id
      assert body["page"]["content"] == "hello"
      assert body["page"]["comments"] == []
      assert body["page"]["attachments"] == []
      assert body["page"]["reactions"] == []
    end

    test "show of a page in another org is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      other_org = foreign_org()

      {:ok, foreign_space} = Wiki.create_space(%{organization_id: other_org, name: "F"})
      {:ok, foreign} = Wiki.create_page(%{space_id: foreign_space.id, title: "FP"})

      assert %{"error" => "Page not found"} =
               auth |> get(page_path(org_id, "/#{foreign.id}")) |> json_response(404)
    end

    test "update edits title and honors parent_id (true/false arms)", %{
      auth: auth,
      org_id: org_id
    } do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id, %{title: "Child"})
      parent_id = create_page(auth, org_id, space_id, %{title: "Parent"})

      body =
        auth
        |> put(page_path(org_id, "/#{page_id}"), %{
          page: %{title: "Child v2", parent_id: parent_id}
        })
        |> json_response(200)
        |> Map.fetch!("page")

      assert body["title"] == "Child v2"
      assert body["parent_id"] == parent_id

      cleared =
        auth
        |> put(page_path(org_id, "/#{page_id}"), %{page: %{"parent_id" => ""}})
        |> json_response(200)
        |> Map.fetch!("page")

      assert cleared["parent_id"] == nil
    end

    test "update with invalid slug is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      assert %{"errors" => errors} =
               auth
               |> put(page_path(org_id, "/#{page_id}"), %{page: %{slug: "BAD Slug"}})
               |> json_response(422)

      assert errors["slug"]
    end

    test "delete removes the page and it then 404s", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      assert %{"message" => "Page deleted"} =
               auth |> delete(page_path(org_id, "/#{page_id}")) |> json_response(200)

      assert %{"error" => "Page not found"} =
               auth |> get(page_path(org_id, "/#{page_id}")) |> json_response(404)
    end

    test "delete of unknown page is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Page not found"} =
               auth |> delete(page_path(org_id, "/#{Ecto.UUID.generate()}")) |> json_response(404)
    end
  end

  # ── Comments ──────────────────────────────────────────────────────────────

  describe "comments" do
    defp comment_path(org_id, suffix),
      do: "/api/v1/organizations/#{org_id}/wiki/comments#{suffix}"

    test "index lists comments for a page", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      auth
      |> post(page_path(org_id, "/#{page_id}/comments"), %{comment: %{body: "first"}})
      |> json_response(201)

      %{"comments" => comments} =
        auth |> get(page_path(org_id, "/#{page_id}/comments")) |> json_response(200)

      assert [%{"body" => "first"}] = comments
    end

    test "create defaults author to the caller and returns 201", %{
      auth: auth,
      org_id: org_id,
      user: user
    } do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      body =
        auth
        |> post(page_path(org_id, "/#{page_id}/comments"), %{comment: %{body: "hi"}})
        |> json_response(201)
        |> Map.fetch!("comment")

      assert body["author"] == user.id
      assert body["page_id"] == page_id
    end

    test "create without body is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      assert %{"errors" => errors} =
               auth
               |> post(page_path(org_id, "/#{page_id}/comments"), %{comment: %{"author" => "x"}})
               |> json_response(422)

      assert errors["body"]
    end

    test "delete removes a comment; unknown and cross-org ids are 404", %{
      auth: auth,
      org_id: org_id
    } do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      comment_id =
        auth
        |> post(page_path(org_id, "/#{page_id}/comments"), %{comment: %{body: "bye"}})
        |> json_response(201)
        |> get_in(["comment", "id"])

      assert %{"message" => "Comment deleted"} =
               auth |> delete(comment_path(org_id, "/#{comment_id}")) |> json_response(200)

      assert %{"error" => "Comment not found"} =
               auth |> delete(comment_path(org_id, "/#{comment_id}")) |> json_response(404)

      assert %{"error" => "Comment not found"} =
               auth
               |> delete(comment_path(org_id, "/#{Ecto.UUID.generate()}"))
               |> json_response(404)
    end

    test "delete of another org's comment is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      other_org = foreign_org()
      {:ok, fs} = Wiki.create_space(%{organization_id: other_org, name: "F"})
      {:ok, fp} = Wiki.create_page(%{space_id: fs.id, title: "FP"})
      {:ok, fc} = Wiki.create_comment(%{page_id: fp.id, body: "foreign"})

      # The comment resolves, but its space belongs to another org.
      assert %{"error" => _} =
               auth |> delete(comment_path(org_id, "/#{fc.id}")) |> json_response(404)
    end
  end

  # ── Attachments ───────────────────────────────────────────────────────────

  describe "attachments" do
    test "index lists attachments for a page", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      auth
      |> post(page_path(org_id, "/#{page_id}/attachments"), %{
        attachment: %{filename: "a.png", url: "https://x/a.png", byte_size: 12}
      })
      |> json_response(201)

      %{"attachments" => atts} =
        auth |> get(page_path(org_id, "/#{page_id}/attachments")) |> json_response(200)

      assert [%{"filename" => "a.png", "byte_size" => 12}] = atts
    end

    test "create returns 201 with serialized fields", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      body =
        auth
        |> post(page_path(org_id, "/#{page_id}/attachments"), %{
          attachment: %{
            filename: "spec.pdf",
            mime_type: "application/pdf",
            url: "https://x/s.pdf"
          }
        })
        |> json_response(201)
        |> Map.fetch!("attachment")

      assert body["filename"] == "spec.pdf"
      assert body["mime_type"] == "application/pdf"
      assert body["page_id"] == page_id
    end

    test "create without filename is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      assert %{"errors" => errors} =
               auth
               |> post(page_path(org_id, "/#{page_id}/attachments"), %{attachment: %{url: "u"}})
               |> json_response(422)

      assert errors["filename"]
    end

    test "delete removes an attachment; unknown id is 404", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      att_id =
        auth
        |> post(page_path(org_id, "/#{page_id}/attachments"), %{
          attachment: %{filename: "tmp.txt", url: "https://x/t.txt"}
        })
        |> json_response(201)
        |> get_in(["attachment", "id"])

      att_path = "/api/v1/organizations/#{org_id}/wiki/attachments/#{att_id}"

      assert %{"message" => "Attachment deleted"} =
               auth |> delete(att_path) |> json_response(200)

      assert %{"error" => "Attachment not found"} =
               auth |> delete(att_path) |> json_response(404)
    end

    test "delete of another org's attachment is 404 (IDOR guard)", %{
      auth: auth,
      org_id: org_id
    } do
      other_org = foreign_org()
      {:ok, fs} = Wiki.create_space(%{organization_id: other_org, name: "F"})
      {:ok, fp} = Wiki.create_page(%{space_id: fs.id, title: "FP"})
      {:ok, fa} = Wiki.create_attachment(%{page_id: fp.id, filename: "f.png", url: "u"})

      att_path = "/api/v1/organizations/#{org_id}/wiki/attachments/#{fa.id}"

      # The attachment resolves, but its space belongs to another org.
      assert %{"error" => _} =
               auth |> delete(att_path) |> json_response(404)
    end
  end

  # ── Reactions ─────────────────────────────────────────────────────────────

  describe "reactions" do
    test "page reaction lifecycle: add, index, remove, remove-again 404", %{
      auth: auth,
      org_id: org_id,
      user: user
    } do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)
      rxn = page_path(org_id, "/#{page_id}/reactions")

      body =
        auth
        |> post(rxn, %{emoji: "🎉"})
        |> json_response(201)
        |> Map.fetch!("reaction")

      assert body["emoji"] == "🎉"
      assert body["target_type"] == "page"
      assert body["actor"] == user.id

      assert [%{"emoji" => "🎉"}] =
               auth |> get(rxn) |> json_response(200) |> Map.fetch!("reactions")

      assert %{"message" => "Reaction removed"} =
               auth |> delete(rxn, %{emoji: "🎉"}) |> json_response(200)

      assert %{"error" => "Reaction not found"} =
               auth |> delete(rxn, %{emoji: "🎉"}) |> json_response(404)
    end

    test "page reaction add without emoji is 422", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      assert %{"errors" => errors} =
               auth
               |> post(page_path(org_id, "/#{page_id}/reactions"), %{emoji: nil})
               |> json_response(422)

      assert errors["emoji"]
    end

    test "comment reaction lifecycle: add, index, remove", %{auth: auth, org_id: org_id} do
      space_id = create_space(auth, org_id)
      page_id = create_page(auth, org_id, space_id)

      comment_id =
        auth
        |> post(page_path(org_id, "/#{page_id}/comments"), %{comment: %{body: "c"}})
        |> json_response(201)
        |> get_in(["comment", "id"])

      crxn = "/api/v1/organizations/#{org_id}/wiki/comments/#{comment_id}/reactions"

      assert %{"reaction" => %{"target_type" => "comment"}} =
               auth |> post(crxn, %{emoji: "👍"}) |> json_response(201)

      assert [%{"emoji" => "👍"}] =
               auth |> get(crxn) |> json_response(200) |> Map.fetch!("reactions")

      assert %{"message" => "Reaction removed"} =
               auth |> delete(crxn, %{emoji: "👍"}) |> json_response(200)
    end

    test "comment reaction index on another org's comment is 404", %{
      auth: auth,
      org_id: org_id
    } do
      other_org = foreign_org()
      {:ok, fs} = Wiki.create_space(%{organization_id: other_org, name: "F"})
      {:ok, fp} = Wiki.create_page(%{space_id: fs.id, title: "FP"})
      {:ok, fc} = Wiki.create_comment(%{page_id: fp.id, body: "f"})

      assert %{"error" => "Comment not found"} =
               auth
               |> get("/api/v1/organizations/#{org_id}/wiki/comments/#{fc.id}/reactions")
               |> json_response(404)
    end
  end
end
