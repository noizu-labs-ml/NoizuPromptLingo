defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewComment do
  use Noizu.MCP.Server.Tool,
    name: "Review.Comment",
    description: "Add a comment to a review.",
    hidden: true,
    category: "Review"

  input do
    field :review_id, :string, required: true, description: "Review UUID"
    field :content, :string, required: true, description: "Comment text (markdown)"
    field :author, :string, required: true, description: "Persona slug"
    field :location, :string, description: "Location in artifact (line number, section, etc.)"
    field :reply_to_id, :string, description: "Parent comment UUID for threading"
  end

  alias NoizuPromptLingua.Services.Comment

  @impl true
  def call(args, _ctx) do
    review_id = args[:review_id] || args["review_id"]

    attrs = %{
      content: args[:content] || args["content"],
      author: args[:author] || args["author"],
      location: args[:location] || args["location"],
      reply_to_id: args[:reply_to_id] || args["reply_to_id"]
    }

    case Comment.add("review", review_id, attrs) do
      {:ok, c} ->
        {:ok, %{id: c.id, review_id: review_id, content: c.content, location: c.location}}

      {:error, cs} ->
        {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
