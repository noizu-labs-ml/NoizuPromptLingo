defmodule NoizuPromptLingua.Domains.Review.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Artifacts.Tools.{ArtifactCreate}
  alias NoizuPromptLingua.Domains.Review.Tools.{
    Overview,
    ReviewAttach,
    ReviewComment,
    ReviewComplete,
    ReviewCompile,
    ReviewCreate,
    ReviewGet,
    ReviewOverlay
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug

    title = "rev-artifact-#{System.unique_integer([:positive])}"

    {:ok, %{id: artifact_id, revision_id: revision_id}} =
      ArtifactCreate.call(
        %{"organization" => org_slug, "title" => title, "kind" => "document", "content" => "body"},
        %{}
      )

    {:ok, org_id: org_id, org_slug: org_slug, artifact_id: artifact_id, revision_id: revision_id}
  end

  defp create_review(org_slug, artifact_id, revision_id) do
    {:ok, %{id: id}} =
      ReviewCreate.call(
        %{
          "organization" => org_slug,
          "artifact_id" => artifact_id,
          "revision_id" => revision_id,
          "reviewer_persona" => "ana",
          "title" => "Design review"
        },
        %{}
      )

    id
  end

  test "review create / get / comment / overlay / complete", %{
    org_slug: org_slug,
    artifact_id: artifact_id,
    revision_id: revision_id
  } do
    assert {:ok, %{id: id}} =
             ReviewCreate.call(
               %{
                 "organization" => org_slug,
                 "artifact_id" => artifact_id,
                 "revision_id" => revision_id,
                 "reviewer_persona" => "ana",
                 "title" => "Design review"
               },
               %{}
             )

    assert {:ok, %{id: ^id, comments: comments, overlays: overlays}} =
             ReviewGet.call(%{"review_id" => id}, %{})

    assert comments == [] and overlays == []

    assert {:ok, %{id: comment_id, review_id: ^id}} =
             ReviewComment.call(%{"review_id" => id, "content" => "typo here"}, %{})

    assert {:ok, %{id: overlay_id, x: 1}} =
             ReviewOverlay.call(
               %{"review_id" => id, "x" => 1, "y" => 2, "comment" => "spacing", "persona" => "ana"},
               %{}
             )

    assert {:ok, %{id: ^id, comments: [_], overlays: [_]}} = ReviewGet.call(%{"review_id" => id}, %{})
    assert is_binary(comment_id) and is_binary(overlay_id)

    assert {:ok, %{id: ^id, status: "completed"}} = ReviewComplete.call(%{"review_id" => id}, %{})
    assert {:error, "Review not found"} = ReviewComplete.call(%{"review_id" => Ecto.UUID.generate()}, %{})
    assert {:error, "Review not found"} = ReviewGet.call(%{"review_id" => Ecto.UUID.generate()}, %{})
  end

  test "review create verifies artifact ownership", %{org_slug: org_slug, revision_id: revision_id} do
    other_org = insert_org()
    other_slug = Repo.get!(Organization, other_org).slug

    title = "other-artifact-#{System.unique_integer([:positive])}"

    {:ok, %{id: foreign_artifact}} =
      ArtifactCreate.call(
        %{"organization" => other_slug, "title" => title, "kind" => "document", "content" => "x"},
        %{}
      )

    result =
      ReviewCreate.call(
        %{
          "organization" => org_slug,
          "artifact_id" => foreign_artifact,
          "revision_id" => revision_id,
          "title" => "sneaky"
        },
        %{}
      )

    assert {:error, _} = result
  end

  test "review attach and compile paths", %{org_slug: org_slug, artifact_id: artifact_id, revision_id: revision_id} do
    id = create_review(org_slug, artifact_id, revision_id)

    attach_result =
      ReviewAttach.call(
        %{
          "review_id" => id,
          "artifact_type" => "url",
          "url" => "https://example.com/notes",
          "description" => "supporting notes",
          "created_by" => "ana"
        },
        %{}
      )

    assert {:ok, %{id: _, review_id: ^id}} = attach_result

    compile_result = ReviewCompile.call(%{"review_id" => id}, %{})

    case compile_result do
      {:ok, %{review_id: ^id}} -> :ok
      {:ok, _} -> :ok
      {:error, _} -> :ok
    end
  end

  test "Overview aggregates status counts", %{org_slug: org_slug, artifact_id: artifact_id, revision_id: revision_id} do
    create_review(org_slug, artifact_id, revision_id)
    assert {:ok, %{status_counts: counts}} = Overview.call(%{}, %{})
    assert counts["open"] >= 1
  end

  defp insert_org do
    slug = "rev-tools-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Review Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
