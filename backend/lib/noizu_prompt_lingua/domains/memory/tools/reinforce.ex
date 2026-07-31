defmodule NoizuPromptLingua.Domains.Memory.Tools.Reinforce do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.Reinforce",
    description: "Strengthen a memory (raise its decay weight, clamped to 1.0). Scope-checked.",
    category: "Memory"

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :scope_type, :string, required: true, description: "persona | weego | team_member"

    field :agent, :string,
      description: "Persona slug/uuid or agent call sign (omit for the org weego)"

    field :memory_id, :string, required: true, description: "The memory UUID"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope

  @impl true
  def call(args, _ctx) do
    with {:ok, context} <- Scope.resolve(args) do
      case Memory.reinforce(Args.get(args, :memory_id), context) do
        {:ok, weight} -> {:ok, %{memory_id: Args.get(args, :memory_id), decay_weight: weight}}
        {:error, :not_found} -> {:error, "memory not found in this scope"}
        {:error, reason} -> {:error, "reinforce failed: #{inspect(reason)}"}
      end
    end
  end
end
