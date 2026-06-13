defmodule NoizuPromptLingua.Domains.Agents.Tools.OrchestrationStatus do
  use Noizu.MCP.Server.Tool, name: "Agent.Orchestration.Status",
    description: "Get orchestration instance status.", hidden: true, category: "Agents.Orchestration",
    annotations: [read_only_hint: true]

  input do
    field :instance_id, :string, required: true, description: "Pipeline instance UUID"
  end

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    id = args[:instance_id] || args["instance_id"]
    case Agents.get_orchestration(id) do
      nil -> {:error, "Instance not found"}
      orch -> {:ok, %{id: orch.id, pipeline: orch.pipeline, status: orch.status, result: orch.result}}
    end
  end
end
