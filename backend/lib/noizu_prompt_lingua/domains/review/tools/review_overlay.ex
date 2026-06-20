defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewOverlay do
  use Noizu.MCP.Server.Tool,
    name: "Review.Overlay", description: "Add coordinate-based image annotation.", hidden: true, category: "Review"

  input do
    field :review_id, :string, required: true, description: "Review UUID"
    field :x, :integer, required: true, description: "X coordinate"
    field :y, :integer, required: true, description: "Y coordinate"
    field :comment, :string, required: true, description: "Annotation text"
    field :persona, :string, required: true, description: "Persona slug"
    field :width, :integer, description: "Annotation region width"
    field :height, :integer, description: "Annotation region height"
  end

  alias NoizuPromptLingua.Domains.Reviews

  @impl true
  def call(args, _ctx) do
    attrs = %{
      review_id: args[:review_id] || args["review_id"],
      x: args[:x] || args["x"], y: args[:y] || args["y"],
      comment: args[:comment] || args["comment"],
      persona: args[:persona] || args["persona"],
      width: args[:width] || args["width"],
      height: args[:height] || args["height"]
    }
    case Reviews.add_overlay(attrs) do
      {:ok, o} -> {:ok, %{id: o.id, x: o.x, y: o.y, comment: o.comment}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
