defmodule NoizuPromptLingua.Domains.Artifacts.MCP do
  use Noizu.MCP.Server,
    name: "tobor_artifacts",
    version: "0.1.0",
    instructions:
      "Artifact management domain — create, version, and retrieve typed content objects."

  tool(NoizuPromptLingua.Domains.Artifacts.Tools.Overview, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactCreate, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactGet, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactList, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactAddRevision, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactListRevisions, category: "Artifacts")
  tool(NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactGetBinary, category: "Artifacts")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
