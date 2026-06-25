defmodule NoizuPromptLingua.Domains.Memory.Tools.Overview do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.Overview",
    description: "Describe the memory domain: its tools, scopes, and (optionally) per-org agent count.",
    annotations: [read_only_hint: true],
    category: "Memory"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the agent count"
  end

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.Domains.Memory.Agents

  @impl true
  def call(args, _ctx) do
    agent_count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> length(Agents.list(org_id, status: "active"))
      end

    {:ok,
     %{
       domain: "Memory",
       subdomain: "memory.tobor.locker",
       scopes: ~w(persona weego team_member),
       visibility: "persona/team_member see only their own memories; weego sees all memories in its org",
       vector_store: "Weaviate (5 named vectors: content/context/reflection/tangent/emotional)",
       registered_agents: agent_count,
       tools: %{
         memory: ~w(Memory.Remember Memory.Recall Memory.RecallByEmotion Memory.Associations Memory.Reinforce Memory.Denforce),
         agents: ~w(Memory.AgentRegister Memory.AgentList)
       }
     }}
  end
end
