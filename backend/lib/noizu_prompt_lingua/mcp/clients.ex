defmodule NoizuPromptLingua.MCP.Clients do
  use Noizu.MCP.Server,
    name: "tobor_clients",
    version: "0.1.0",
    instructions:
      "Clients domain — external customers under an organization (distinct from orgs). " <>
        "Projects may nest under clients. Shared via pm_core with therobotplans."

  tool(NoizuPromptLingua.MCP.Clients.Tools.Overview, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientCreate, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientGet, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientUpdate, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientList, category: "Clients")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
