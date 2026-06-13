defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewCreate do
  use Noizu.MCP.Server.Tool,
    name: "Review.Create", description: "Start a review for an artifact revision.", hidden: true, category: "Review"

  input do
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :revision_id, :string, required: true, description: "Revision UUID"
    field :reviewer_persona, :string, required: true, description: "Reviewer persona slug"
    field :title, :string, description: "Review title"
  end

  alias NoizuPromptLingua.Domains.Reviews

  @impl true
  def call(args, _ctx) do
    attrs = %{
      artifact_id: args[:artifact_id] || args["artifact_id"],
      revision_id: args[:revision_id] || args["revision_id"],
      reviewer_persona: args[:reviewer_persona] || args["reviewer_persona"],
      title: args[:title] || args["title"]
    }
    case Reviews.create(attrs) do
      {:ok, review} -> {:ok, %{id: review.id, artifact_id: review.artifact_id, revision_id: review.revision_id, status: review.status, created_at: review.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
