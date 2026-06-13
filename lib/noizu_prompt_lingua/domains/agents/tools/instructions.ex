defmodule NoizuPromptLingua.Domains.Agents.Tools.Instructions do
  use Noizu.MCP.Server.Tool, name: "Agent.Instructions",
    description: "Retrieve instruction body by UUID.", hidden: true, category: "Agents.Instructions",
    annotations: [read_only_hint: true]

  input do
    field :instruction_id, :string, required: true, description: "Instruction UUID"
  end

  alias NoizuPromptLingua.Domains.Agents

  @impl true
  def call(args, _ctx) do
    id = args[:instruction_id] || args["instruction_id"]
    case Agents.get_instruction(id) do
      nil -> {:error, "Instruction not found"}
      instr -> {:ok, %{id: instr.id, title: instr.title, content: instr.content, tags: instr.tags, version: instr.version, created_at: instr.inserted_at}}
    end
  end
end
