defmodule NoizuPromptLingua.Domains.Review.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Review.Overview",
    description: "List review tools and active review counts.",
    annotations: [read_only_hint: true],
    category: "Review"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Review",
      subdomain: "review.tobor.locker",
      status: "stub",
      tools: [
        "Review.Create", "Review.Get", "Review.Complete",
        "Review.Comment", "Review.Overlay", "Review.Compile", "Review.Attach"
      ]
    }}
  end
end
