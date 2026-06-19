defmodule NPLWeb.API.ReviewsAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Reviews

  def index(conn, params) do
    opts = if params["status"], do: [status: params["status"]], else: []
    reviews = Reviews.list(opts)
    json(conn, %{
      reviews: Enum.map(reviews, fn r ->
        %{id: r.id, artifact_id: r.artifact_id, reviewer: r.reviewer_persona,
          status: r.status, verdict: r.verdict, title: r.title, at: r.updated_at}
      end)
    })
  end

  def show(conn, %{"id" => id}) do
    case Reviews.get(id) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      {review, comments, overlays} ->
        json(conn, %{
          review: %{id: review.id, artifact_id: review.artifact_id, status: review.status,
                    verdict: review.verdict, summary: review.summary, reviewer: review.reviewer_persona},
          comments: Enum.map(comments, fn c ->
            %{id: c.id, content: c.content, author: c.author, at: c.inserted_at}
          end),
          overlays: Enum.map(overlays, fn o ->
            %{id: o.id, x: o.x, y: o.y, width: o.width, height: o.height,
              comment: o.comment, persona: o.persona}
          end)
        })
    end
  end

  def create(conn, params) do
    attrs = Map.take(params, ~w(artifact_id reviewer_persona title summary verdict status))
    case Reviews.create(attrs) do
      {:ok, review} ->
        conn |> put_status(201) |> json(%{review: review_json(review)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def complete(conn, %{"id" => id} = params) do
    attrs = Map.take(params, ~w(verdict summary))
    case Reviews.complete(id, attrs) do
      {:ok, review} ->
        json(conn, %{review: review_json(review)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  defp review_json(r) do
    %{id: r.id, artifact_id: r.artifact_id, reviewer: r.reviewer_persona,
      status: r.status, verdict: r.verdict, title: r.title, summary: r.summary,
      updated_at: r.updated_at}
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  defp format_errors(other), do: inspect(other)
end
