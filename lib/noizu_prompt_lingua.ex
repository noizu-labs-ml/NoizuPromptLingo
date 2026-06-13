defmodule NoizuPromptLingua.Tools.Greet do
  use Noizu.MCP.Server.Tool,
    description: "Say hello to someone by name.",
    annotations: [read_only_hint: true]

  input do
    field :name, :string, required: true, description: "Who to greet"
  end

  @impl true
  def call(%{name: name}, _ctx) do
    {:ok, "Hello, #{name}! Welcome to the Noizu MCP world."}
  end
end

defmodule NoizuPromptLingua.MCP do
  use Noizu.MCP.Server,
    name: "noizu_prompt_lingua",
    version: "0.1.0",
    instructions:
      "Noizu Prompt Lingua MCP server. Use the Discovery tools (ToolSummary, ToolSearch, " <>
        "ToolDefinition, ToolHelp, ToolCall) to find and invoke all available tools."

  tool NoizuPromptLingua.Tools.Greet, category: "Utility"
  tool NoizuPromptLingua.Tools.NPLLoad, category: "NPL"
  tool NoizuPromptLingua.Tools.NPLSpec, category: "NPL"

  # Agent domain (unrouted — served from root)
  tool NoizuPromptLingua.Domains.Agents.Tools.Overview, category: "Agents"
  tool NoizuPromptLingua.Domains.Agents.Tools.AgentList, category: "Agents"
  tool NoizuPromptLingua.Domains.Agents.Tools.AgentLoad, category: "Agents"
  tool NoizuPromptLingua.Domains.Agents.Tools.PipeIn, category: "Agents.Pipes"
  tool NoizuPromptLingua.Domains.Agents.Tools.PipeOut, category: "Agents.Pipes"
  tool NoizuPromptLingua.Domains.Agents.Tools.OrchestrationTrigger, category: "Agents.Orchestration"
  tool NoizuPromptLingua.Domains.Agents.Tools.OrchestrationExecute, category: "Agents.Orchestration"
  tool NoizuPromptLingua.Domains.Agents.Tools.OrchestrationPatterns, category: "Agents.Orchestration"
  tool NoizuPromptLingua.Domains.Agents.Tools.OrchestrationStatus, category: "Agents.Orchestration"
  tool NoizuPromptLingua.Domains.Agents.Tools.Instructions, category: "Agents.Instructions"
  tool NoizuPromptLingua.Domains.Agents.Tools.InstructionsCreate, category: "Agents.Instructions"
  tool NoizuPromptLingua.Domains.Agents.Tools.InstructionsList, category: "Agents.Instructions"

  tool NoizuPromptLingua.Tools.ToolSummary
  tool NoizuPromptLingua.Tools.ToolSearch
  tool NoizuPromptLingua.Tools.ToolDefinition
  tool NoizuPromptLingua.Tools.ToolCall
  tool NoizuPromptLingua.Tools.ToolHelp
end
