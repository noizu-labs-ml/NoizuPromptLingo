defmodule NoizuPromptLingua.Domains.Agents.Tools.OrchestrationTrigger do
  use Noizu.MCP.Server.Tool, name: "Agent.Orchestration.Trigger",
    description: "Trigger an orchestration pipeline.", hidden: true, category: "Agents.Orchestration"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "pipeline" => %{"type" => "string", "description" => "Pipeline name"},
      "context" => %{"type" => "object", "description" => "Input context"},
      "session_id" => %{"type" => "string", "description" => "Session UUID"}
    },
    "required" => ["pipeline"]
  }

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    attrs = %{pipeline: args["pipeline"], context: args["context"], session_id: args["session_id"]}
    case Agents.trigger_pipeline(attrs) do
      {:ok, orch} -> {:ok, %{id: orch.id, pipeline: orch.pipeline, status: orch.status}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
