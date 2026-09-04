defmodule NoizuPromptLingua.Domains.ArtifactsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Artifacts

  setup do
    {:ok, org_id: insert_org()}
  end

  defp artifact_attrs(org_id, extra \\ %{}) do
    Map.merge(
      %{
        organization_id: org_id,
        kind: "document",
        title: "Artifact #{System.unique_integer([:positive])}"
      },
      extra
    )
  end

  test "create wraps artifact + first revision in a transaction", %{org_id: org_id} do
    {:ok, artifact} = Artifacts.create(artifact_attrs(org_id, %{content: "v1 body"}))

    assert [%{revision_number: 1}] = artifact.revisions
    assert {a, rev} = Artifacts.get(artifact.id)
    assert a.id == artifact.id
    assert rev.revision_number == 1
    assert rev.content == "v1 body"

    assert Artifacts.get(Ecto.UUID.generate()) == nil
  end

  test "create without content rolls back the artifact insert", %{org_id: org_id} do
    assert {:error, _cs} = Artifacts.create(artifact_attrs(org_id))
    assert Artifacts.list(organization_id: org_id) == []
  end

  test "add_revision increments revision_number; get can pin a revision", %{org_id: org_id} do
    {:ok, artifact} = Artifacts.create(artifact_attrs(org_id, %{content: "v1"}))

    {:ok, rev2} = Artifacts.add_revision(artifact.id, "v2", "second pass")
    {:ok, rev3} = Artifacts.add_revision(artifact.id, "v3")

    assert rev2.revision_number == 2
    assert rev3.revision_number == 3
    assert rev3.note == nil

    # Latest by default
    assert {_, latest} = Artifacts.get(artifact.id)
    assert latest.revision_number == 3

    # Pinned revision
    assert {_, pinned} = Artifacts.get(artifact.id, rev2.id)
    assert pinned.content == "v2"
  end

  test "list_revisions orders desc and projects fields", %{org_id: org_id} do
    {:ok, artifact} = Artifacts.create(artifact_attrs(org_id, %{content: "v1"}))
    {:ok, _} = Artifacts.add_revision(artifact.id, "v2", "note-2")

    revisions = Artifacts.list_revisions(artifact.id)
    assert Enum.map(revisions, & &1.revision_number) == [2, 1]
    assert hd(revisions).note == "note-2"
    assert %{id: _, created_at: _} = hd(revisions)
    assert length(Artifacts.list_revisions(artifact.id, limit: 1)) == 1
  end

  test "list filters by org / kind / project / title search with pagination", %{org_id: org_id} do
    {:ok, doc} = Artifacts.create(artifact_attrs(org_id, %{content: "c", title: "Design Doc Alpha"}))
    {:ok, _} = Artifacts.create(artifact_attrs(org_id, %{content: "c", kind: "image", title: "Sketch"}))
    other = insert_org()
    {:ok, _} = Artifacts.create(artifact_attrs(other, %{content: "c"}))

    assert length(Artifacts.list(organization_id: org_id)) == 2
    assert [%{id: id}] = Artifacts.list(organization_id: org_id, kind: "document")
    assert id == doc.id

    assert [%{title: "Design Doc Alpha"}] = Artifacts.list(organization_id: org_id, search: "design doc")
    assert Artifacts.list(organization_id: org_id, search: "does-not-match") == []

    assert length(Artifacts.list(organization_id: org_id, limit: 1, offset: 1)) == 1
  end

  test "count_by_kind aggregates per org-unscoped kinds", %{org_id: org_id} do
    {:ok, _} = Artifacts.create(artifact_attrs(org_id, %{content: "c", kind: "document"}))
    {:ok, _} = Artifacts.create(artifact_attrs(org_id, %{content: "c", kind: "document"}))
    {:ok, _} = Artifacts.create(artifact_attrs(org_id, %{content: "c", kind: "image"}))

    counts = Artifacts.count_by_kind()
    assert counts["document"] == 2
    assert counts["image"] == 1
  end

  defp insert_org do
    slug = "art-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Artifacts Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
