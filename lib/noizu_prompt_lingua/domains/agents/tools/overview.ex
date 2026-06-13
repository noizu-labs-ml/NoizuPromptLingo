defmodule NoizuPromptLingua.Domains.Agents.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Agent.Overview",
    description: "List agent, orchestration, and instruction tools.",
    annotations: [read_only_hint: true], category: "Agents"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{domain: "Agents", tools: %{
      catalog: ["Agent.List", "Agent.Load"],
      pipes: ["Agent.Pipe.In", "Agent.Pipe.Out"],
      orchestration: ["Agent.Orchestration.Trigger", "Agent.Orchestration.Execute",
                       "Agent.Orchestration.Patterns", "Agent.Orchestration.Status"],
      instructions: ["Agent.Instructions", "Agent.Instructions.Create", "Agent.Instructions.List"]
    }}}
  end
end
