defmodule NoizuPromptLingua.Domains.Instructions.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Instruction.Overview",
    description: "List instruction tools and instruction count for an organization.",
    annotations: [read_only_hint: true], category: "Instructions"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the count"
  end

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> Instructions.count(org_id)
      end

    {:ok, %{domain: "Instructions", subdomain: "instructions.tobor.locker",
      instruction_count: count,
      usage: "Save a prompt once, then spawn sub-agents with Instruction.Render passing the slug handle + params.",
      tools: %{
        crud: ~w(Instruction.Create Instruction.Get Instruction.Update Instruction.List Instruction.Delete),
        versions: ~w(Instruction.Versions Instruction.SetActiveVersion),
        dispatch: ~w(Instruction.Render)
      }}}
  end
end
