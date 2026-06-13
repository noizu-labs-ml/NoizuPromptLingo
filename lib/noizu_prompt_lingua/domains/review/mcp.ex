defmodule NoizuPromptLingua.Domains.Review.MCP do
  use Noizu.MCP.Server,
    name: "tobor_review",
    version: "0.1.0",
    instructions: "Code review domain — create reviews, add comments and overlays, compile feedback."

  tool NoizuPromptLingua.Domains.Review.Tools.Overview, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewCreate, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewGet, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewComment, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewOverlay, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewComplete, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewCompile, category: "Review"
  tool NoizuPromptLingua.Domains.Review.Tools.ReviewAttach, category: "Review"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
