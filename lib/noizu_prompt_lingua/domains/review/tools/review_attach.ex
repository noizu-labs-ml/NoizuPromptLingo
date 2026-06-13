defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewAttach do
  use Noizu.MCP.Server.Tool,
    name: "Review.Attach", description: "Attach supplementary artifact to a review.", hidden: true, category: "Review"

  input do
    field :review_id, :string, required: true, description: "Review UUID"
    field :artifact_id, :string, description: "Artifact UUID"
    field :artifact_type, :string, description: "artifact (default), url, file"
    field :url, :string, description: "URL if artifact_type is url"
    field :description, :string, description: "Description"
  end

  alias NoizuPromptLingua.Services.Attach

  @impl true
  def call(args, _ctx) do
    review_id = args[:review_id] || args["review_id"]
    attrs = %{
      artifact_type: args[:artifact_type] || args["artifact_type"] || "artifact",
      url: args[:url] || args["url"],
      description: args[:description] || args["description"]
    }
    case Attach.add("review", review_id, attrs) do
      {:ok, att} -> {:ok, %{id: att.id, review_id: review_id, artifact_type: att.artifact_type}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
