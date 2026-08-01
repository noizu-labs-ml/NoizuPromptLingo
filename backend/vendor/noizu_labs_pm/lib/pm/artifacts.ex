defmodule Noizu.PM.Artifacts do
  @moduledoc """
  Artifact domain: versioned code/document/image/wiki/config/binary blobs.

  Lifted from npl's `Domains.Artifacts`; an artifact is created with an initial
  revision, and further revisions append with a monotonic per-artifact number.
  """
  import Ecto.Query, except: [update: 2]

  alias Noizu.PM.Repo
  alias Noizu.PM.Schema.Artifacts.{Artifact, ArtifactRevision}

  def create(attrs) do
    content = attrs[:content] || attrs["content"]
    metadata = Map.drop(attrs, [:content, "content"])

    Repo.transaction(fn ->
      with {:ok, artifact} <- %Artifact{} |> Artifact.changeset(metadata) |> Repo.insert(),
           {:ok, revision} <- create_revision(artifact.id, content, nil, 1) do
        %{artifact | revisions: [revision]}
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  def get(artifact_id, revision_id \\ nil) do
    case Repo.get(Artifact, artifact_id) do
      nil ->
        nil

      artifact ->
        revision =
          if revision_id do
            Repo.get(ArtifactRevision, revision_id)
          else
            latest_revision(artifact_id)
          end

        {artifact, revision}
    end
  end

  def list(opts \\ []) do
    Artifact
    |> maybe_filter_organization(opts[:organization_id])
    |> maybe_filter_kind(opts[:kind])
    |> maybe_filter_project(opts[:project_id])
    |> maybe_search(opts[:search])
    |> order_by([a], desc: a.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def add_revision(artifact_id, content, note \\ nil) do
    next_num =
      ArtifactRevision
      |> where([r], r.artifact_id == ^artifact_id)
      |> select([r], max(r.revision_number))
      |> Repo.one()
      |> Kernel.||(0)
      |> Kernel.+(1)

    create_revision(artifact_id, content, note, next_num)
  end

  def list_revisions(artifact_id, opts \\ []) do
    ArtifactRevision
    |> where([r], r.artifact_id == ^artifact_id)
    |> order_by([r], desc: r.revision_number)
    |> limit(^(opts[:limit] || 50))
    |> select([r], %{
      id: r.id,
      revision_number: r.revision_number,
      note: r.note,
      created_at: r.inserted_at
    })
    |> Repo.all()
  end

  def count_by_kind do
    Artifact
    |> group_by([a], a.kind)
    |> select([a], {a.kind, count(a.id)})
    |> Repo.all()
    |> Map.new()
  end

  defp latest_revision(artifact_id) do
    ArtifactRevision
    |> where([r], r.artifact_id == ^artifact_id)
    |> order_by([r], desc: r.revision_number)
    |> limit(1)
    |> Repo.one()
  end

  defp create_revision(artifact_id, content, note, number) do
    %ArtifactRevision{}
    |> ArtifactRevision.changeset(%{
      artifact_id: artifact_id,
      content: content,
      note: note,
      revision_number: number
    })
    |> Repo.insert()
  end

  defp maybe_filter_organization(query, nil), do: query

  defp maybe_filter_organization(query, org_id),
    do: where(query, [a], a.organization_id == ^org_id)

  defp maybe_filter_kind(query, nil), do: query
  defp maybe_filter_kind(query, kind), do: where(query, [a], a.kind == ^kind)

  defp maybe_filter_project(query, nil), do: query
  defp maybe_filter_project(query, project_id), do: where(query, [a], a.project_id == ^project_id)

  defp maybe_search(query, nil), do: query

  defp maybe_search(query, search) do
    pattern = "%#{search}%"
    where(query, [a], ilike(a.title, ^pattern))
  end
end
