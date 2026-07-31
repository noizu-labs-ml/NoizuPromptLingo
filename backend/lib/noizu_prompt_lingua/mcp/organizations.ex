defmodule NoizuPromptLingua.MCP.Organizations do
  use Noizu.MCP.Server,
    name: "tobor_organizations",
    version: "0.1.0",
    instructions: "Organization management domain — list, get, create, and update organizations."

  tool(NoizuPromptLingua.MCP.Organizations.Tools.Overview, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationCreate, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationUpdate, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList, category: "Organizations")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
