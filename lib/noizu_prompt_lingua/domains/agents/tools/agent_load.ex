defmodule NoizuPromptLingua.Domains.Agents.Tools.AgentLoad do
  use Noizu.MCP.Server.Tool, name: "Agent.Load",
    description: "Load full agent specification by name.", hidden: true, category: "Agents",
    annotations: [read_only_hint: true]

  input do
    field :name, :string, required: true, description: "Agent name (slug)"
  end

  @impl true
  def call(args, _ctx) do
    name = args[:name] || args["name"]
    {:ok, %{name: name, status: "stub", hint: "Agent catalog not yet populated."}}
  end
end
