defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewComplete do
  use Noizu.MCP.Server.Tool,
    name: "Review.Complete",
    description: "Mark review as completed.",
    hidden: true,
    category: "Review"

  input do
    field :review_id, :string, required: true, description: "Review UUID"
    field :summary, :string, description: "Final summary comment"
    field :verdict, :string, description: "approved, changes_requested, rejected"
  end

  alias NoizuPromptLingua.Domains.Reviews

  @impl true
  def call(args, _ctx) do
    review_id = args[:review_id] || args["review_id"]
    attrs = %{}
    attrs = if v = args[:summary] || args["summary"], do: Map.put(attrs, :summary, v), else: attrs
    attrs = if v = args[:verdict] || args["verdict"], do: Map.put(attrs, :verdict, v), else: attrs

    case Reviews.complete(review_id, attrs) do
      {:ok, review} -> {:ok, %{id: review.id, status: review.status, verdict: review.verdict}}
      {:error, :not_found} -> {:error, "Review not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
