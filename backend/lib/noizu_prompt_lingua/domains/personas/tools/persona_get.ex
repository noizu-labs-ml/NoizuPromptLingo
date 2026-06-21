defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaGet do
  use Noizu.MCP.Server.Tool, name: "Persona.Get",
    description: "Get a persona with recent journal entries and knowledge-base index.",
    hidden: true, category: "Personas", annotations: [read_only_hint: true]

  input do
    field :persona, :string, required: true, description: "Slug or UUID"
    field :organization, :string, description: "Organization slug or UUID (needed to resolve a slug)"
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
        journal = Personas.list_journal(p.id, limit: 10)
        kb = Personas.list_knowledge(p.id)
        {:ok, %{
          id: p.id, slug: p.slug, name: p.name, role: p.role, bio: p.bio,
          avatar: p.avatar, tags: p.tags, status: p.status,
          organization_id: p.organization_id, project_id: p.project_id,
          journal: Enum.map(journal, fn j ->
            %{id: j.id, category: j.category, title: j.title, body: j.body, at: j.inserted_at}
          end),
          knowledge_base: Enum.map(kb, fn k ->
            %{id: k.id, slug: k.slug, title: k.title, tags: k.tags}
          end)}}
    end
  end
end
