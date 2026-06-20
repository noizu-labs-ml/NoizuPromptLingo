defmodule NoizuPromptLingua.MCP.Projects do
  use Noizu.MCP.Server,
    name: "tobor_projects",
    version: "0.1.0",
    instructions: "Project management domain — list, get, create, and update projects within an organization."

  tool NoizuPromptLingua.MCP.Projects.Tools.Overview, category: "Projects"
  tool NoizuPromptLingua.MCP.Projects.Tools.ProjectCreate, category: "Projects"
  tool NoizuPromptLingua.MCP.Projects.Tools.ProjectGet, category: "Projects"
  tool NoizuPromptLingua.MCP.Projects.Tools.ProjectUpdate, category: "Projects"
  tool NoizuPromptLingua.MCP.Projects.Tools.ProjectList, category: "Projects"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
