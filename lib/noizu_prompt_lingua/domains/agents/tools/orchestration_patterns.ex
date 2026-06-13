defmodule NoizuPromptLingua.Domains.Agents.Tools.OrchestrationPatterns do
  use Noizu.MCP.Server.Tool, name: "Agent.Orchestration.Patterns",
    description: "List registered orchestration patterns.", hidden: true, category: "Agents.Orchestration",
    annotations: [read_only_hint: true]

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{patterns: [], hint: "No orchestration patterns registered yet."}}
  end
end
