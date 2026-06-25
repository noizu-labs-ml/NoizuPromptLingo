defmodule NoizuPromptLinguaWeb.ArtifactControllerTest do
  @moduledoc """
  Artifacts viewer BE-dep (ticket c0f97e6b). LIST/GET/CREATE already existed; this
  covers the gap that unblocks the FE viewer — the revision/lineage history endpoint
  — plus the show contract the detail view renders (current revision content + a
  specific revision via ?revision_id=), and org-scoping (no cross-org IDOR).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Artifacts

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "artifact-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Artifact Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    # Artifact with two revisions (v1 from create, v2 via add_revision).
    {:ok, artifact} =
      Artifacts.create(%{organization_id: org_id, kind: "document", title: "Doc", mime_type: "text/markdown", content: "v1 body"})

    rev1 = List.first(artifact.revisions)
    {:ok, _rev2} = Artifacts.add_revision(artifact.id, "v2 body", "second pass")

    {:ok, conn: auth_conn, org_id: org_id, artifact: artifact, rev1: rev1}
  end

  describe "GET revisions" do
    test "lists revisions newest-first with metadata, no content", %{conn: conn, org_id: org_id, artifact: a} do
      revs = json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}/revisions"), 200)["revisions"]

      assert Enum.map(revs, & &1["revision_number"]) == [2, 1]
      assert Enum.find(revs, &(&1["revision_number"] == 2))["note"] == "second pass"
      assert Enum.all?(revs, &(Map.has_key?(&1, "id") and Map.has_key?(&1, "created_at")))
      # history is metadata-only — content is fetched per-revision via show
      refute Enum.any?(revs, &Map.has_key?(&1, "content"))
    end

    test "404 for an artifact in another org (no cross-org IDOR)", %{conn: conn, org_id: org_id} do
      other_slug = "artifact-org2-#{System.unique_integer([:positive])}"
      other_created = post(conn, "/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other Org"}})
      other_org_id = json_response(other_created, 201)["organization"]["id"]

      {:ok, other} =
        Artifacts.create(%{organization_id: other_org_id, kind: "document", title: "Other", mime_type: "text/markdown", content: "x"})

      # requested under org_id's path, but the artifact belongs to other_org_id -> 404
      assert json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{other.id}/revisions"), 404)
    end

    test "404 when the artifact does not exist", %{conn: conn, org_id: org_id} do
      assert json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{Ecto.UUID.generate()}/revisions"), 404)
    end
  end

  describe "POST revision (edit = append, history-preserving)" do
    test "appends a new revision and returns it as the current", %{conn: conn, org_id: org_id, artifact: a} do
      body = json_response(post(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}/revisions", %{content: "v3 body", note: "third"}), 201)["artifact"]
      assert body["content"] == "v3 body"
      assert body["revision_number"] == 3

      # history preserved — list now has 3, newest-first
      revs = json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}/revisions"), 200)["revisions"]
      assert Enum.map(revs, & &1["revision_number"]) == [3, 2, 1]
    end

    test "blank content -> 422", %{conn: conn, org_id: org_id, artifact: a} do
      assert json_response(post(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}/revisions", %{content: ""}), 422)["errors"]
    end

    test "404 for an artifact in another org", %{conn: conn, org_id: org_id} do
      other_slug = "artifact-org3-#{System.unique_integer([:positive])}"
      other_created = post(conn, "/api/v1/organizations", %{organization: %{slug: other_slug, name: "Other Org"}})
      other_org_id = json_response(other_created, 201)["organization"]["id"]
      {:ok, other} = Artifacts.create(%{organization_id: other_org_id, kind: "document", title: "Other", mime_type: "text/markdown", content: "x"})

      assert json_response(post(conn, "/api/v1/organizations/#{org_id}/artifacts/#{other.id}/revisions", %{content: "y"}), 404)
    end
  end

  describe "GET show (detail view contract)" do
    test "returns the latest revision's content + number by default", %{conn: conn, org_id: org_id, artifact: a} do
      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}"), 200)["artifact"]
      assert body["content"] == "v2 body"
      assert body["revision_number"] == 2
      assert body["kind"] == "document"
    end

    test "?revision_id= returns that specific revision's content", %{conn: conn, org_id: org_id, artifact: a, rev1: rev1} do
      body = json_response(get(conn, "/api/v1/organizations/#{org_id}/artifacts/#{a.id}?revision_id=#{rev1.id}"), 200)["artifact"]
      assert body["content"] == "v1 body"
      assert body["revision_number"] == 1
    end
  end
end
