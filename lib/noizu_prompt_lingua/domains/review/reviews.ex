defmodule NoizuPromptLingua.Domains.Reviews do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Review, ReviewOverlay}

  def create(attrs) do
    %Review{} |> Review.changeset(attrs) |> Repo.insert()
  end

  def get(review_id) do
    case Repo.get(Review, review_id) do
      nil -> nil
      review ->
        comments = NoizuPromptLingua.Services.Comment.list("review", review_id)
        overlays = list_overlays(review_id)
        {review, comments, overlays}
    end
  end

  def complete(review_id, attrs \\ %{}) do
    case Repo.get(Review, review_id) do
      nil -> {:error, :not_found}
      review ->
        review
        |> Review.changeset(Map.merge(attrs, %{status: "completed"}))
        |> Repo.update()
    end
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

  def count_by_status do
    Review
    |> group_by([r], r.status)
    |> select([r], {r.status, count(r.id)})
    |> Repo.all()
    |> Map.new()
  end
end
