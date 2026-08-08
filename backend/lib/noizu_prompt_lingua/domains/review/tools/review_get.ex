defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewGet do
  use Noizu.MCP.Server.Tool,
    name: "Review.Get",
    description: "Fetch review with comments and overlays.",
    hidden: true,
    category: "Review",
    annotations: [read_only_hint: true]

  input do
    field :review_id, :string, required: true, description: "Review UUID"
  end

  alias NoizuPromptLingua.Domains.Reviews

  @impl true
  def call(args, _ctx) do
    review_id = args[:review_id] || args["review_id"]

    case Reviews.get(review_id) do
      nil ->
        {:error, "Review not found"}

      {review, comments, overlays} ->
        {:ok,
         %{
           id: review.id,
           artifact_id: review.artifact_id,
           revision_id: review.revision_id,
           reviewer_persona: review.reviewer_persona,
           title: review.title,
           status: review.status,
           summary: review.summary,
           verdict: review.verdict,
           comments:
             Enum.map(
               comments,
               &%{
                 id: &1.id,
                 content: &1.content,
                 author: &1.author,
                 location: &1.location,
                 created_at: &1.inserted_at
               }
             ),
           overlays:
             Enum.map(
               overlays,
               &%{
                 id: &1.id,
                 x: &1.x,
                 y: &1.y,
                 width: &1.width,
                 height: &1.height,
                 comment: &1.comment,
                 persona: &1.persona
               }
             ),
           created_at: review.inserted_at
         }}
    end
  end
end
