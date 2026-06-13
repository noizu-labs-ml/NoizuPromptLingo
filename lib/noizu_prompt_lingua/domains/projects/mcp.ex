defmodule NoizuPromptLingua.Domains.Projects.MCP do
  use Noizu.MCP.Server,
    name: "tobor_projects",
    version: "0.1.0",
    instructions: "Project management domain — create projects, manage members and invitations."

  tool NoizuPromptLingua.Domains.Projects.Tools.Overview, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectCreate, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectGet, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectUpdate, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectList, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectArchive, category: "Projects"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectMembers, category: "Projects.Members"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectInvite, category: "Projects.Members"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectAcceptInvite, category: "Projects.Members"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectUpdateRole, category: "Projects.Members"
  tool NoizuPromptLingua.Domains.Projects.Tools.ProjectRemoveMember, category: "Projects.Members"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
