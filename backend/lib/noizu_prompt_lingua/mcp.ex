defmodule NoizuPromptLingua.MCP do
  @moduledoc """
  Root MCP server. Aggregates the organization, project, and session domain
  tools alongside the Discovery tools so a single endpoint can browse and
  invoke everything via ToolSummary / ToolCall.
  """
  use NoizuPromptLingua.MCP.Server,
    name: "noizu_prompt_lingua",
    version: "0.1.0",
    instructions:
      "Noizu Prompt Lingua MCP server. Use the Discovery tools (ToolSummary, ToolSearch, " <>
        "ToolDefinition, ToolHelp, ToolCall) to find and invoke all available tools."

  # Organizations
  tool(NoizuPromptLingua.MCP.Organizations.Tools.Overview, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationCreate, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationUpdate, category: "Organizations")
  tool(NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList, category: "Organizations")

  # Projects
  tool(NoizuPromptLingua.MCP.Projects.Tools.Overview, category: "Projects")
  tool(NoizuPromptLingua.MCP.Projects.Tools.ProjectCreate, category: "Projects")
  tool(NoizuPromptLingua.MCP.Projects.Tools.ProjectGet, category: "Projects")
  tool(NoizuPromptLingua.MCP.Projects.Tools.ProjectUpdate, category: "Projects")
  tool(NoizuPromptLingua.MCP.Projects.Tools.ProjectList, category: "Projects")

  tool(NoizuPromptLingua.MCP.Clients.Tools.Overview, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientCreate, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientGet, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientUpdate, category: "Clients")
  tool(NoizuPromptLingua.MCP.Clients.Tools.ClientList, category: "Clients")

  # Sessions
  tool(NoizuPromptLingua.MCP.Sessions.Tools.Overview, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionCreate, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionGet, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionUpdate, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionList, category: "Sessions")
  tool(NoizuPromptLingua.MCP.Sessions.Tools.SessionArchive, category: "Sessions")

  # Discovery
  tool(NoizuPromptLingua.Tools.ToolSummary)
  tool(NoizuPromptLingua.Tools.ToolSearch)
  tool(NoizuPromptLingua.Tools.ToolDefinition)
  tool(NoizuPromptLingua.Tools.ToolCall)
  tool(NoizuPromptLingua.Tools.ToolHelp)
  # Hidden: task-proximity tailored overview of this endpoint's tools (pgvector).
  tool(NoizuPromptLingua.Tools.McpOverview)

  # NPL — Noizu Prompt Lingua convention loading & spec generation (read-only)
  tool(NoizuPromptLingua.Tools.NPLLoad, category: "NPL")
  tool(NoizuPromptLingua.Tools.NPLSpec, category: "NPL")

  # Keys — per-API-key MCP toolset management (caller-scoped; raw keys shown once)
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyCreate, category: "Keys")
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyList, category: "Keys")
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyGet, category: "Keys")
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyUpdate, category: "Keys")
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyClone, category: "Keys")
  tool(NoizuPromptLingua.MCP.Keys.Tools.KeyRevoke, category: "Keys")
end
