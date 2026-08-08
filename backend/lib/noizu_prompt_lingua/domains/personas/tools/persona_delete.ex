defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaDelete do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Delete",
    description: "Delete a persona (and its journal + knowledge base).",
    hidden: true,
    category: "Personas",
    annotations: [destructive_hint: true]

  input do
    field :persona, :string, required: true, description: "Slug or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :persona)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    persona = (org_id && Personas.resolve(org_id, key)) || Personas.get(key)

    case persona do
      nil ->
        {:error, "Persona '#{key}' not found"}

      p ->
        case Personas.delete(p.id) do
          {:ok, _} -> {:ok, %{id: p.id, deleted: true}}
          {:error, _} -> {:error, "Failed to delete"}
        end
    end
  end
end
