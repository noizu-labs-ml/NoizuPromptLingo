defmodule NoizuPromptLingua.Domains.Instructions.MCP do
  use Noizu.MCP.Server,
    name: "tobor_instructions",
    version: "0.1.0",
    instructions:
      "Instruction domain — reusable versioned prompts referenced by slug handle and rendered with per-task params to spawn sub-agents."

  tool(NoizuPromptLingua.Domains.Instructions.Tools.Overview, category: "Instructions")
  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionCreate, category: "Instructions")
  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionGet, category: "Instructions")
  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionUpdate, category: "Instructions")
  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionList, category: "Instructions")
  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionVersions, category: "Instructions")

  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionSetActiveVersion,
    category: "Instructions"
  )

  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionRender,
    category: "Instructions.Dispatch"
  )

  tool(NoizuPromptLingua.Domains.Instructions.Tools.InstructionDelete, category: "Instructions")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
