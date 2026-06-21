defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionSetActiveVersion do
  use Noizu.MCP.Server.Tool, name: "Instruction.SetActiveVersion",
    description: "Point an instruction's active version at an existing version (rollback/forward).",
    hidden: true, category: "Instructions"

  input do
    field :instruction, :string, required: true, description: "Slug handle or UUID"
    field :organization, :string, description: "Organization slug or UUID (needed to resolve a slug)"
    field :version, :integer, required: true, description: "Version number to activate"
  end

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :instruction)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    instruction = (org_id && Instructions.resolve(org_id, key)) || Instructions.get(key)

    case instruction do
      nil -> {:error, "Instruction '#{key}' not found"}
      i ->
        case Instructions.set_active_version(i.id, Args.get(args, :version)) do
          {:ok, u} -> {:ok, %{id: u.id, slug: u.slug, active_version: u.active_version}}
          {:error, :not_found} -> {:error, "Version not found"}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
