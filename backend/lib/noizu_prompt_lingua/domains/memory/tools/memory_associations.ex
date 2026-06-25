defmodule NoizuPromptLingua.Domains.Memory.Tools.MemoryAssociations do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.Associations",
    description: "List the association edges (type, weight, reason) of a memory, scope-checked.",
    annotations: [read_only_hint: true],
    category: "Memory"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :scope_type, :string, required: true, description: "persona | weego | team_member"
    field :agent, :string, description: "Persona slug/uuid or agent call sign (omit for the org weego)"
    field :memory_id, :string, required: true, description: "The memory UUID"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope

  @impl true
  def call(args, _ctx) do
    with {:ok, context} <- Scope.resolve(args) do
      memory_id = Args.get(args, :memory_id)
      edges = Memory.associations(memory_id, context)

      {:ok,
       %{
         memory_id: memory_id,
         count: length(edges),
         edges:
           Enum.map(edges, fn e ->
             %{
               id: e.id,
               source_memory_id: e.source_memory_id,
               target_memory_id: e.target_memory_id,
               edge_type: to_string(e.edge_type),
               weight: e.weight,
               reason: e.reason
             }
           end)
       }}
    end
  end
end
