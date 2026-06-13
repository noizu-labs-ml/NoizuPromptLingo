defmodule NoizuPromptLingua.Domains.Agents.Tools.AgentList do
  use Noizu.MCP.Server.Tool, name: "Agent.List",
    description: "List available agent definitions.", hidden: true, category: "Agents",
    annotations: [read_only_hint: true]

  input do
    field :category, :string, description: "Filter by category"
    field :search, :string, description: "Search in names/descriptions"
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{agents: [], hint: "Agent catalog not yet populated. Define agents via frontmatter YAML files."}}
  end
end
