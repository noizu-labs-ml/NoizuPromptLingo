defmodule NoizuPromptLingua.Domains.Memory.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_memory",
    version: "0.1.0",
    instructions:
      "Associative memory domain — agent-scoped memories (persona / weego / team_member) with " <>
        "four embedded text facets + an emotional vector in Weaviate, an association graph, and " <>
        "recall by text, by emotion, and by association."

  tool(NoizuPromptLingua.Domains.Memory.Tools.Overview, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.Remember, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.Recall, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.RecallByEmotion, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.MemoryAssociations, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.Reinforce, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.Denforce, category: "Memory")
  tool(NoizuPromptLingua.Domains.Memory.Tools.AgentRegister, category: "Memory.Agents")
  tool(NoizuPromptLingua.Domains.Memory.Tools.AgentList, category: "Memory.Agents")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
