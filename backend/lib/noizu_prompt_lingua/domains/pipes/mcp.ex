defmodule NoizuPromptLingua.Domains.Pipes.MCP do
  use Noizu.MCP.Server,
    name: "tobor_pipes",
    version: "0.1.0",
    instructions:
      "Agent pipes — a lightweight agent-to-agent message bus. Publish a YAML/JSON payload under a message name to a target agent, a group, or a broadcast (Pipe.Output); pull everything addressed to you (Pipe.Input). Entries are scoped to an organization."

  tool NoizuPromptLingua.Domains.Pipes.Tools.Overview, category: "Pipes"
  tool NoizuPromptLingua.Domains.Pipes.Tools.Output, category: "Pipes"
  tool NoizuPromptLingua.Domains.Pipes.Tools.Input, category: "Pipes"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
