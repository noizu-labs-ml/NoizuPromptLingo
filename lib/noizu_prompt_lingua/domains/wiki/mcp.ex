defmodule NoizuPromptLingua.Domains.Wiki.MCP do
  use Noizu.MCP.Server,
    name: "tobor_wiki",
    version: "0.1.0",
    instructions: "Wiki domain — manage spaces, pages, permissions, comments, and attachments."

  tool NoizuPromptLingua.Domains.Wiki.Tools.Overview, category: "Wiki"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
