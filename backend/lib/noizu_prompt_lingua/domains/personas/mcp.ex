defmodule NoizuPromptLingua.Domains.Personas.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_personas",
    version: "0.1.0",
    instructions:
      "Persona domain — named identities with a bio, work log/journal, and personal knowledge base."

  tool(NoizuPromptLingua.Domains.Personas.Tools.Overview, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.PersonaCreate, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.PersonaGet, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.PersonaUpdate, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.PersonaList, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.PersonaDelete, category: "Personas")
  tool(NoizuPromptLingua.Domains.Personas.Tools.JournalAdd, category: "Personas.Journal")
  tool(NoizuPromptLingua.Domains.Personas.Tools.JournalList, category: "Personas.Journal")
  tool(NoizuPromptLingua.Domains.Personas.Tools.KnowledgeAdd, category: "Personas.Knowledge")
  tool(NoizuPromptLingua.Domains.Personas.Tools.KnowledgeUpdate, category: "Personas.Knowledge")
  tool(NoizuPromptLingua.Domains.Personas.Tools.KnowledgeGet, category: "Personas.Knowledge")
  tool(NoizuPromptLingua.Domains.Personas.Tools.KnowledgeList, category: "Personas.Knowledge")
  tool(NoizuPromptLingua.Domains.Personas.Tools.KnowledgeDelete, category: "Personas.Knowledge")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
