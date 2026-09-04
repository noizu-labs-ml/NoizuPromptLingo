defmodule NoizuPromptLinguaWeb.ReviewControllerTest do
  @moduledoc """
  Reviews UPDATE (ticket f73f4cd2). Covers the mutability contract: a review's
  metadata is editable in place while open/in_progress; identity/lineage
  (artifact/revision/org/project) is immutable; finalization goes through
  /complete (status="completed" via update is rejected); a completed review is
  frozen (409). Plus org-scoping (no cross-org IDOR).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.{Artifacts, Reviews}

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "rev-org-#{System.unique_integer([:positive])}"

    created =
      post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "Review Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, artifact} =
      Artifacts.create(%{
        organization_id: org_id,
        kind: "document",
        title: "Doc",
        mime_type: "text/markdown",
        content: "body"
      })

    rev = List.first(artifact.revisions)

    {:ok, review} =
      Reviews.create(%{
        organization_id: org_id,
        artifact_id: artifact.id,
        revision_id: rev.id,
        reviewer_persona: "soren-backend",
        title: "Initial"
      })

    {:ok, conn: auth, org_id: org_id, artifact: artifact, review: review}
  end

  defp path(org_id, id), do: "/api/v1/organizations/#{org_id}/reviews/#{id}"

  describe "PUT /reviews/:id" do
    test "updates mutable metadata and transitions open -> in_progress", %{
      conn: conn,
      org_id: org_id,
      review: r
    } do
      body =
        conn
        |> put(path(org_id, r.id), %{
          review: %{
            title: "Renamed",
            summary: "looks good",
            verdict: "approved",
            status: "in_progress"
          }
        })
        |> json_response(200)
        |> Map.fetch!("review")

      assert body["title"] == "Renamed"
      assert body["summary"] == "looks good"
      assert body["verdict"] == "approved"
      assert body["status"] == "in_progress"
    end

    test "identity/lineage is immutable — artifact_id/revision_id/org are ignored", %{
      conn: conn,
      org_id: org_id,
      review: r
    } do
      body =
        conn
        |> put(path(org_id, r.id), %{
          review: %{
            title: "X",
            artifact_id: Ecto.UUID.generate(),
            revision_id: Ecto.UUID.generate(),
            organization_id: Ecto.UUID.generate()
          }
        })
        |> json_response(200)
        |> Map.fetch!("review")

      assert body["title"] == "X"
      assert body["artifact_id"] == r.artifact_id
      assert body["revision_id"] == r.revision_id
      assert body["organization_id"] == r.organization_id
    end

    test "completing via update is rejected (422) — must use the /complete endpoint", %{
      conn: conn,
      org_id: org_id,
      review: r
    } do
      assert conn
             |> put(path(org_id, r.id), %{review: %{status: "completed"}})
             |> json_response(422)

      {reloaded, _, _} = Reviews.get(r.id)
      assert reloaded.status != "completed"
    end

    test "a completed review is frozen (409)", %{conn: conn, org_id: org_id, review: r} do
      {:ok, _} = Reviews.complete(r.id, %{verdict: "approved"})
      assert conn |> put(path(org_id, r.id), %{review: %{title: "nope"}}) |> json_response(409)
    end

    test "invalid verdict -> 422", %{conn: conn, org_id: org_id, review: r} do
      assert conn |> put(path(org_id, r.id), %{review: %{verdict: "lgtm"}}) |> json_response(422)
    end

    test "404 for a review in another org (no cross-org IDOR)", %{conn: conn, org_id: org_id} do
      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "rev-org2-#{System.unique_integer([:positive])}", name: "Other"}
        })

      other_org_id = json_response(other, 201)["organization"]["id"]

      {:ok, a2} =
        Artifacts.create(%{
          organization_id: other_org_id,
          kind: "document",
          title: "D2",
          mime_type: "text/markdown",
          content: "b"
        })

      rev2 = List.first(a2.revisions)

      {:ok, r2} =
        Reviews.create(%{
          organization_id: other_org_id,
          artifact_id: a2.id,
          revision_id: rev2.id,
          reviewer_persona: "x",
          title: "T"
        })

      # requested under org_id's path but the review belongs to other_org_id -> 404
      assert conn |> put(path(org_id, r2.id), %{review: %{title: "z"}}) |> json_response(404)
    end

    test "404 when the review does not exist", %{conn: conn, org_id: org_id} do
      assert conn
             |> put(path(org_id, Ecto.UUID.generate()), %{review: %{title: "z"}})
             |> json_response(404)
    end
  end

  # ── W5A coverage extension: index/create/show/complete + authz arms ───────

  describe "GET /reviews (index)" do
    test "lists org reviews with json shape", %{conn: conn, org_id: org_id} do
      %{"reviews" => reviews} =
        conn |> get("/api/v1/organizations/#{org_id}/reviews") |> json_response(200)

      assert [%{"title" => "Initial", "status" => status}] = reviews
      assert status in ["open", "in_progress"]
      assert Map.has_key?(reviews |> hd(), "reviewer_persona")

      # status filter that matches nothing still 200 w/ empty list
      %{"reviews" => []} =
        conn
        |> get("/api/v1/organizations/#{org_id}/reviews", %{status: "completed"})
        |> json_response(200)
    end

    test "unknown org -> 404; non-member -> 403", %{conn: conn, org_id: org_id} do
      assert conn
             |> get("/api/v1/organizations/no-such-rev-org/reviews")
             |> json_response(404)
             |> Map.fetch!("error") =~ "Organization not found"

      %{access_token: outsider} = setup_user_and_token()

      assert conn
             |> authenticated_conn(outsider)
             |> get("/api/v1/organizations/#{org_id}/reviews")
             |> json_response(403)
             |> Map.fetch!("error") =~ "Not a member"
    end

    test "viewer-role member can index but is denied member-only create",
         %{conn: conn, org_id: org_id} do
      # A second user whose membership is viewer-only: index (viewer) passes,
      # create (member) hits the insufficient-role catch-all.
      %{access_token: viewer_token, user: viewer_user} = setup_user_and_token()

      {:ok, _} =
        NoizuPromptLingua.Authz.ScopedMemberships.add_member(
          "organization",
          org_id,
          viewer_user.id,
          "viewer"
        )

      viewer_conn = authenticated_conn(conn, viewer_token)

      assert %{"reviews" => _} =
               viewer_conn
               |> get("/api/v1/organizations/#{org_id}/reviews")
               |> json_response(200)

      assert %{"error" => "Insufficient permissions"} =
               viewer_conn
               |> post("/api/v1/organizations/#{org_id}/reviews", %{
                 review: %{artifact_id: Ecto.UUID.generate(), reviewer_persona: "x", title: "T"}
               })
               |> json_response(403)
    end
  end

  describe "POST /reviews (create)" do
    test "happy path creates a review scoped to the org", %{
      conn: conn,
      org_id: org_id,
      artifact: a
    } do
      rev = List.first(a.revisions)

      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/reviews", %{
          review: %{
            artifact_id: a.id,
            revision_id: rev.id,
            reviewer_persona: "soren-backend",
            title: "HTTP Created"
          }
        })
        |> json_response(201)
        |> Map.fetch!("review")

      assert body["title"] == "HTTP Created"
      assert body["organization_id"] == org_id
      assert body["artifact_id"] == a.id
      assert body["status"] == "open"
    end

    test "artifact from another org -> 422", %{conn: conn, org_id: org_id} do
      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "rev-org5-#{System.unique_integer([:positive])}", name: "O5"}
        })

      other_org = json_response(other, 201)["organization"]["id"]

      {:ok, foreign} =
        Artifacts.create(%{
          organization_id: other_org,
          kind: "document",
          title: "F",
          mime_type: "text/markdown",
          content: "b"
        })

      assert %{"error" => "Artifact does not belong to this organization"} =
               conn
               |> post("/api/v1/organizations/#{org_id}/reviews", %{
                 review: %{
                   artifact_id: foreign.id,
                   revision_id: List.first(foreign.revisions).id,
                   reviewer_persona: "x",
                   title: "T"
                 }
               })
               |> json_response(422)
    end

    test "missing required fields -> 422 errors", %{conn: conn, org_id: org_id} do
      {:ok, a} =
        Artifacts.create(%{
          organization_id: org_id,
          kind: "document",
          title: "D",
          mime_type: "text/markdown",
          content: "b"
        })

      assert json_response(
               post(conn, "/api/v1/organizations/#{org_id}/reviews", %{
                 review: %{artifact_id: a.id}
               }),
               422
             )
             |> Map.has_key?("errors")
    end
  end

  describe "GET /reviews/:id (show)" do
    test "returns review with comments and overlays collections", %{
      conn: conn,
      org_id: org_id,
      review: r
    } do
      body = conn |> get(path(org_id, r.id)) |> json_response(200)

      assert body["review"]["id"] == r.id
      assert body["comments"] == []
      assert body["overlays"] == []
    end

    test "404 for missing review and cross-org review", %{conn: conn, org_id: org_id, review: r} do
      assert %{"error" => "Review not found"} =
               conn |> get(path(org_id, Ecto.UUID.generate())) |> json_response(404)

      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "rev-org6-#{System.unique_integer([:positive])}", name: "O6"}
        })

      other_org = json_response(other, 201)["organization"]["id"]

      assert %{"error" => "Review not found"} =
               conn |> get(path(other_org, r.id)) |> json_response(404)
    end
  end

  describe "POST /reviews/:id/complete" do
    test "finalizes with verdict + summary", %{conn: conn, org_id: org_id, review: r} do
      body =
        conn
        |> post("/api/v1/organizations/#{org_id}/reviews/#{r.id}/complete", %{
          "verdict" => "approved",
          "summary" => "all good"
        })
        |> json_response(200)
        |> Map.fetch!("review")

      assert body["status"] == "completed"
      assert body["verdict"] == "approved"
      assert body["summary"] == "all good"
    end

    test "invalid verdict -> 422", %{conn: conn, org_id: org_id, review: r} do
      assert json_response(
               post(conn, "/api/v1/organizations/#{org_id}/reviews/#{r.id}/complete", %{
                 "verdict" => "lgtm"
               }),
               422
             )
             |> Map.has_key?("errors")
    end

    test "cross-org complete -> 404", %{conn: conn, org_id: org_id, review: r} do
      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "rev-org7-#{System.unique_integer([:positive])}", name: "O7"}
        })

      other_org = json_response(other, 201)["organization"]["id"]

      assert %{"error" => "Review not found"} =
               conn
               |> post("/api/v1/organizations/#{other_org}/reviews/#{r.id}/complete", %{
                 "verdict" => "approved"
               })
               |> json_response(404)
    end
  end
end
