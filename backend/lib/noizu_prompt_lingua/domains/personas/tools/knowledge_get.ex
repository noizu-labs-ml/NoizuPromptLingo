defmodule NoizuPromptLingua.Domains.Personas.Tools.KnowledgeGet do
  use Noizu.MCP.Server.Tool, name: "Persona.Knowledge.Get",
    description: "Get a persona knowledge-base article by slug or UUID.",
    hidden: true, category: "Personas.Knowledge", annotations: [read_only_hint: true]

  input do
    field :persona, :string, required: true, description: "Persona slug or UUID"
    field :organization, :string, description: "Organization slug or UUID (needed to resolve a slug)"
    field :entry, :string, required: true, description: "Article slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :persona)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    persona = (org_id && Personas.resolve(org_id, key)) || Personas.get(key)

    case persona do
      nil -> {:error, "Persona '#{key}' not found"}
      p ->
        case Personas.get_knowledge(p.id, Args.get(args, :entry)) do
          nil -> {:error, "Knowledge entry not found"}
          k -> {:ok, %{id: k.id, slug: k.slug, title: k.title, body: k.body,
                       source: k.source, tags: k.tags, updated_at: k.updated_at}}
        end
    end
  end
end
