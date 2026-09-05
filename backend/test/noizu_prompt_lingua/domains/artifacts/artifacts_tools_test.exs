defmodule NoizuPromptLingua.Domains.Artifacts.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Artifacts.Tools.{
    ArtifactAddRevision,
    ArtifactCreate,
    ArtifactGet,
    ArtifactGetBinary,
    ArtifactList,
    ArtifactListRevisions,
    Overview
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp create_artifact(org_slug) do
    {:ok, %{id: id}} =
      ArtifactCreate.call(
        %{
          "organization" => org_slug,
          "title" => uniq("Spec"),
          "kind" => "document",
          "content" => "v1 body"
        },
        %{}
      )

    id
  end

  test "artifact create / get / add_revision / list_revisions / get_binary / list", %{org_slug: org_slug} do
    title = uniq("Spec")

    assert {:ok, %{id: id, revision_id: rev1}} =
             ArtifactCreate.call(
               %{"organization" => org_slug, "title" => title, "kind" => "document", "content" => "v1 body"},
               %{}
             )

    assert {:ok, %{id: ^id, revision: %{id: ^rev1, content: "v1 body"}}} =
             ArtifactGet.call(%{"artifact_id" => id}, %{})

    assert {:ok, %{revision_id: rev2}} =
             ArtifactAddRevision.call(%{"artifact_id" => id, "content" => "v2 body", "note" => "tweak"}, %{})

    assert {:ok, %{artifact_id: ^id, count: 2, revisions: revisions}} =
             ArtifactListRevisions.call(%{"artifact_id" => id}, %{})

    assert length(revisions) == 2

    assert {:ok, %{content_base64: content_b64}} = ArtifactGetBinary.call(%{"artifact_id" => id, "revision_id" => rev2}, %{})
    assert Base.decode64!(content_b64) =~ "v2 body"

    assert {:ok, %{artifacts: arts, count: 1}} = ArtifactList.call(%{"organization" => org_slug}, %{})
    assert hd(arts).id == id

    # Pinned revision fetch + not-found paths
    assert {:ok, %{revision: %{id: ^rev1}}} = ArtifactGet.call(%{"artifact_id" => id, "revision_id" => rev1}, %{})
    assert {:error, "Revision not found"} = ArtifactGet.call(%{"artifact_id" => id, "revision_id" => Ecto.UUID.generate()}, %{})

    missing = Ecto.UUID.generate()
    assert {:error, msg} = ArtifactGet.call(%{"artifact_id" => missing}, %{})
    assert msg == "Artifact '#{missing}' not found"
  end

  test "Overview summarizes counts by kind", %{org_slug: org_slug} do
    create_artifact(org_slug)
    assert {:ok, %{counts_by_kind: counts}} = Overview.call(%{}, %{})
    assert counts["document"] >= 1
  end

  defp insert_org do
    slug = "art-tools-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Artifacts Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
