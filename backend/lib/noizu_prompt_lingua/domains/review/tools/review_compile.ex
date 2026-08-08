defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewCompile do
  use Noizu.MCP.Server.Tool,
    name: "Review.Compile",
    description: "Generate annotated artifact with inline comments.",
    hidden: true,
    category: "Review"

  input do
    field :review_id, :string, required: true, description: "Review UUID"
    field :format, :string, description: "Output format: markdown (default), html, pdf"
  end

  @impl true
  def call(args, _ctx) do
    review_id = args[:review_id] || args["review_id"]
    format = args[:format] || args["format"] || "markdown"

    {:ok,
     %{
       review_id: review_id,
       format: format,
       status: "stub",
       hint: "Compilation not yet implemented."
     }}
  end
end
