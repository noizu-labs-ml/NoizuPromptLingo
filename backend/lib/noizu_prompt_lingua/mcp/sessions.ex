defmodule NoizuPromptLingua.MCP.Sessions do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_sessions",
    version: "0.1.0",
    instructions:
      "Session management domain — create and manage work sessions that group rooms, artifacts, and tickets. Sessions belong to an organization; associating one with a project is optional."

  tool(NoizuPromptLingua.MCP.Sessions.Tools.Overview, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionCreate, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionGet, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionUpdate, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionList, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionArchive, category: "Sessions")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
