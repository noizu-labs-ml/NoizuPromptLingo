defmodule NoizuPromptLingua.Domains.Review.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Review.Overview",
    description: "List review tools and workflow states.",
    annotations: [read_only_hint: true],
    category: "Review"

  input do
  end

  alias NoizuPromptLingua.Domains.Reviews

  @impl true
  def call(_args, _ctx) do
    {:ok,
     %{
       domain: "Review",
       subdomain: "review.tobor.locker",
       status_counts: Reviews.count_by_status(),
       workflow_states: ["open", "in_progress", "completed"],
       verdicts: ["approved", "changes_requested", "rejected"],
       tools: [
         %{name: "Review.Create", description: "Start a review for an artifact revision"},
         %{name: "Review.Get", description: "Fetch review with comments and overlays"},
         %{name: "Review.Comment", description: "Add inline or general comment"},
         %{name: "Review.Overlay", description: "Add coordinate-based image annotation"},
         %{name: "Review.Complete", description: "Mark review as completed"},
         %{name: "Review.Compile", description: "Generate annotated artifact"},
         %{name: "Review.Attach", description: "Attach supplementary artifact"}
       ]
     }}
  end
end
