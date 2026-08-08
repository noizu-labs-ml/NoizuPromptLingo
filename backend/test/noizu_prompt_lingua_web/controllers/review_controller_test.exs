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
end
