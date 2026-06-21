defmodule NoizuPromptLingua.Domains.Personas.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Persona.Overview",
    description: "List persona tools and persona count for an organization.",
    annotations: [read_only_hint: true], category: "Personas"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the count"
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> Personas.count(org_id)
      end

    {:ok, %{domain: "Personas", subdomain: "personas.tobor.locker",
      persona_count: count,
      tools: %{
        crud: ~w(Persona.Create Persona.Get Persona.Update Persona.List Persona.Delete Persona.Archive),
        journal: ~w(Persona.Journal.Add Persona.Journal.List),
        knowledge: ~w(Persona.Knowledge.Add Persona.Knowledge.Update Persona.Knowledge.Get Persona.Knowledge.List Persona.Knowledge.Delete)
      }}}
  end
end
