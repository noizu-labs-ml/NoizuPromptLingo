defmodule NoizuPromptLingua.Domains.ReviewsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.{Artifacts, Reviews}

  setup do
    org_id = insert_org()
    {:ok, artifact} = Artifacts.create(%{organization_id: org_id, kind: "document", title: "Doc", content: "v1"})
    {artifact, rev} = {artifact, artifact.revisions |> hd()}
    {:ok, org_id: org_id, artifact_id: artifact.id, revision_id: rev.id}
  end

  defp review_attrs(org_id, artifact_id, revision_id, extra \\ %{}) do
    Map.merge(
      %{
        organization_id: org_id,
        artifact_id: artifact_id,
        revision_id: revision_id,
        reviewer_persona: "reviewer-#{System.unique_integer([:positive])}",
        title: "Review"
      },
      extra
    )
  end

  test "create / get returns review with comments and overlays", %{
    org_id: org_id,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    {:ok, review} = Reviews.create(review_attrs(org_id, artifact_id, revision_id))

    assert {r, comments, overlays} = Reviews.get(review.id)
    assert r.id == review.id
    assert comments == []
    assert overlays == []

    assert Reviews.get(Ecto.UUID.generate()) == nil
  end

  test "update mutates metadata, sanitizes identity fields, and freezes when completed", %{
    org_id: org_id,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    {:ok, review} = Reviews.create(review_attrs(org_id, artifact_id, revision_id))

    {:ok, updated} = Reviews.update(review.id, %{title: "Renamed", verdict: "approved", artifact_id: "tampered"})
    assert updated.title == "Renamed"
    assert updated.verdict == "approved"
    assert updated.artifact_id == artifact_id

    # status -> completed via update is refused
    assert {:error, :use_complete} = Reviews.update(review.id, %{status: "completed"})

    {:ok, _} = Reviews.complete(review.id, %{summary: "done"})
    assert {:error, :completed} = Reviews.update(review.id, %{title: "too late"})
    assert {:error, :not_found} = Reviews.update(Ecto.UUID.generate(), %{})
  end

  test "complete sets status and returns not_found for missing id", %{
    org_id: org_id,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    {:ok, review} = Reviews.create(review_attrs(org_id, artifact_id, revision_id))
    assert {:error, :not_found} = Reviews.complete(Ecto.UUID.generate())

    {:ok, completed} = Reviews.complete(review.id)
    assert completed.status == "completed"
  end

  test "overlays add + list in insertion order", %{
    org_id: org_id,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    {:ok, review} = Reviews.create(review_attrs(org_id, artifact_id, revision_id))

    {:ok, o1} = Reviews.add_overlay(%{review_id: review.id, x: 1, y: 2, comment: "first", persona: "p1"})
    {:ok, _} = Reviews.add_overlay(%{review_id: review.id, x: 3, y: 4, comment: "second", persona: "p2"})

    assert [%{comment: "first"}, %{comment: "second"}] = Reviews.list_overlays(review.id)
    assert o1.review_id == review.id

    {_, _, overlays} = Reviews.get(review.id)
    assert length(overlays) == 2

    assert {:error, _} = Reviews.add_overlay(%{review_id: review.id, x: 1})
  end

  test "list filters and count_by_status", %{
    org_id: org_id,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    {:ok, open} = Reviews.create(review_attrs(org_id, artifact_id, revision_id))
    {:ok, other_artifact} = Artifacts.create(%{organization_id: org_id, kind: "document", title: "Doc2", content: "v"})
    other_rev = hd(other_artifact.revisions)

    {:ok, done} = Reviews.create(review_attrs(org_id, artifact_id, other_rev.id))
    {:ok, _} = Reviews.complete(done.id)

    other_org = insert_org()
    {:ok, other_artifact2} = Artifacts.create(%{organization_id: other_org, kind: "document", title: "Other Org Doc", content: "v"})
    other_rev2 = hd(other_artifact2.revisions)
    {:ok, _} = Reviews.create(review_attrs(other_org, other_artifact2.id, other_rev2.id))

    assert length(Reviews.list(organization_id: org_id)) == 2
    assert [%{id: id}] = Reviews.list(organization_id: org_id, status: "open")
    assert id == open.id

    # Both org reviews share the artifact; filtering by artifact yields both
    artifact_reviews = Reviews.list(organization_id: org_id, artifact_id: artifact_id)
    assert length(artifact_reviews) == 2
    assert open.id in Enum.map(artifact_reviews, & &1.id)
    assert length(Reviews.list(organization_id: org_id, project_id: Ecto.UUID.generate())) == 0

    counts = Reviews.count_by_status()
    assert counts["completed"] >= 1
    assert counts["open"] >= 1
  end

  test "create requires organization, artifact, revision and reviewer_persona", %{org_id: _org_id} do
    assert {:error, cs} = Reviews.create(%{title: "incomplete"})
    for field <- [:organization_id, :artifact_id, :revision_id, :reviewer_persona] do
      assert Keyword.has_key?(cs.errors, field)
    end
  end

  defp insert_org do
    slug = "rev-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Reviews Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
