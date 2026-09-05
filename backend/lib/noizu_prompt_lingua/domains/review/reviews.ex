defmodule NoizuPromptLingua.Domains.Reviews do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Review, ReviewOverlay}

  def create(attrs) do
    %Review{} |> Review.changeset(attrs) |> Repo.insert()
  end

  def get(review_id) do
    case Repo.get(Review, review_id) do
      nil ->
        nil

      review ->
        comments = NoizuPromptLingua.Services.Comment.list("review", review_id)
        overlays = list_overlays(review_id)
        {review, comments, overlays}
    end
  end

  def complete(review_id, attrs \\ %{}) do
    case Repo.get(Review, review_id) do
      nil ->
        {:error, :not_found}

      review ->
        # Normalize incoming keys to strings: the HTTP layer passes
        # Map.take(params, ["summary", "verdict"]) (string keys) while the
        # completion status below is merged in as a string too — mixing the two
        # made Ecto.CastError blow up every controller-driven complete call
        # (cov-w5a bugfix).
        attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)

        review
        |> Review.changeset(Map.merge(attrs, %{"status" => "completed"}))
        |> Repo.update()
    end
  end

  # Fields a review owner may edit in place. Identity/lineage
  # (organization_id, project_id, artifact_id, revision_id) are immutable — a
  # review's subject is fixed at create — so they are NOT updatable here.
  @updatable_fields ~w(title reviewer_persona summary verdict status)

  @doc """
  Update a review's mutable metadata. A completed review is FROZEN (immutable);
  finalization (status -> "completed") goes through `complete/2`, not here.

  Returns `{:error, :not_found}` if absent, `{:error, :completed}` if the review
  is already completed, `{:error, :use_complete}` if the caller tries to set
  status to "completed" via update, or the changeset result otherwise.
  """
  def update(review_id, attrs) do
    case Repo.get(Review, review_id) do
      nil ->
        {:error, :not_found}

      %Review{status: "completed"} ->
        {:error, :completed}

      review ->
        attrs = sanitize_update_attrs(attrs)

        if Map.get(attrs, "status") == "completed" do
          {:error, :use_complete}
        else
          review |> Review.changeset(attrs) |> Repo.update()
        end
    end
  end

  defp sanitize_update_attrs(attrs) do
    attrs
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
    |> Map.take(@updatable_fields)
  end

  def add_overlay(attrs) do
    %ReviewOverlay{} |> ReviewOverlay.changeset(attrs) |> Repo.insert()
  end

  def list_overlays(review_id) do
    ReviewOverlay
    |> where([o], o.review_id == ^review_id)
    |> order_by([o], asc: o.inserted_at)
    |> Repo.all()
  end

  def list(opts \\ []) do
    Review
    |> maybe_filter_organization(opts[:organization_id])
    |> maybe_filter_project(opts[:project_id])
    |> maybe_filter_artifact(opts[:artifact_id])
    |> maybe_filter_status(opts[:status])
    |> order_by([r], desc: r.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  def count_by_status do
    Review
    |> group_by([r], r.status)
    |> select([r], {r.status, count(r.id)})
    |> Repo.all()
    |> Map.new()
  end

  defp maybe_filter_organization(query, nil), do: query

  defp maybe_filter_organization(query, org_id),
    do: where(query, [r], r.organization_id == ^org_id)

  defp maybe_filter_project(query, nil), do: query
  defp maybe_filter_project(query, project_id), do: where(query, [r], r.project_id == ^project_id)

  defp maybe_filter_artifact(query, nil), do: query

  defp maybe_filter_artifact(query, artifact_id),
    do: where(query, [r], r.artifact_id == ^artifact_id)

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status), do: where(query, [r], r.status == ^status)
end
