defmodule NoizuPromptLingua.Domains.Sessions.MCP do
  use Noizu.MCP.Server,
    name: "tobor_sessions",
    version: "0.1.0",
    instructions: "Session management domain — create and manage work sessions that group rooms, artifacts, and tickets."

  tool NoizuPromptLingua.Domains.Sessions.Tools.Overview, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionCreate, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionUpdate, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionGet, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionList, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionContents, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionArchive, category: "Sessions"
  tool NoizuPromptLingua.Domains.Sessions.Tools.SessionActivity, category: "Sessions"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
