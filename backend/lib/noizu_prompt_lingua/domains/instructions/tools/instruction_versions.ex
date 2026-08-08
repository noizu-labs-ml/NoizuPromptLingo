defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionVersions do
  use Noizu.MCP.Server.Tool,
    name: "Instruction.Versions",
    description: "List an instruction's version history.",
    hidden: true,
    category: "Instructions",
    annotations: [read_only_hint: true]

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
        versions = Instructions.list_versions(i.id)

        {:ok,
         %{
           active_version: i.active_version,
           count: length(versions),
           versions:
             Enum.map(versions, fn v ->
               %{
                 version: v.version,
                 change_note: v.change_note,
                 at: v.inserted_at,
                 active: v.version == i.active_version
               }
             end)
         }}
    end
  end
end
