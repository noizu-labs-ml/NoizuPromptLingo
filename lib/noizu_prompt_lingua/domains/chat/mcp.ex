defmodule NoizuPromptLingua.Domains.Chat.MCP do
  use Noizu.MCP.Server,
    name: "tobor_chat",
    version: "0.1.0",
    instructions: "Chat domain — manage rooms, messages, events, members, and notifications."

  tool NoizuPromptLingua.Domains.Chat.Tools.Overview, category: "Chat"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
