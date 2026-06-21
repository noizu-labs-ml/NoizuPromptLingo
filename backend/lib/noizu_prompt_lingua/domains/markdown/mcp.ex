defmodule NoizuPromptLingua.Domains.Markdown.MCP do
  use Noizu.MCP.Server,
    name: "tobor_markdown",
    version: "0.1.0",
    instructions:
      "Markdown utilities — convert a URL, HTML, or raw content to Markdown, and filter/collapse a Markdown document by heading. Pure transforms; no organization context required."

  tool NoizuPromptLingua.Domains.Markdown.Tools.Overview, category: "Markdown"
  tool NoizuPromptLingua.Domains.Markdown.Tools.Convert, category: "Markdown"
  tool NoizuPromptLingua.Domains.Markdown.Tools.View, category: "Markdown"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
