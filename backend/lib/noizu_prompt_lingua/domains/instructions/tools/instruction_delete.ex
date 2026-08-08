defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionDelete do
  use Noizu.MCP.Server.Tool,
    name: "Instruction.Delete",
    description: "Delete an instruction and all its versions.",
    hidden: true,
    category: "Instructions",
    annotations: [destructive_hint: true]

  input do
    field :instruction, :string, required: true, description: "Slug handle or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"
  end

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :instruction)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    instruction = (org_id && Instructions.resolve(org_id, key)) || Instructions.get(key)

    case instruction do
      nil ->
        {:error, "Instruction '#{key}' not found"}

      i ->
        case Instructions.delete(i.id) do
          {:ok, _} -> {:ok, %{id: i.id, deleted: true}}
          {:error, _} -> {:error, "Failed to delete"}
        end
    end
  end
end
