defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionGet do
  use Noizu.MCP.Server.Tool,
    name: "Instruction.Get",
    description: "Get an instruction with its active (or specified) body version.",
    hidden: true,
    category: "Instructions",
    annotations: [read_only_hint: true]

  input do
    field :instruction, :string, required: true, description: "Slug handle or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"

    field :version, :integer, description: "Specific version (defaults to active)"
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
        ver = Instructions.get_version(i.id, Args.get(args, :version))

        {:ok,
         %{
           id: i.id,
           slug: i.slug,
           title: i.title,
           description: i.description,
           tags: i.tags,
           parameters: i.parameters,
           status: i.status,
           active_version: i.active_version,
           version: ver && ver.version,
           body: ver && ver.body
         }}
    end
  end
end
