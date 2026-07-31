defmodule NoizuPromptLingua.Domains.Personas.Tools.KnowledgeList do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Knowledge.List",
    description: "List a persona's knowledge-base articles (index, no bodies).",
    hidden: true,
    category: "Personas.Knowledge",
    annotations: [read_only_hint: true]

  input do
    field :persona, :string, required: true, description: "Persona slug or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"

    field :tag, :string
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
        opts = if t = Args.get(args, :tag), do: [tag: t], else: []
        entries = Personas.list_knowledge(p.id, opts)

        {:ok,
         %{
           count: length(entries),
           knowledge_base:
             Enum.map(entries, fn k ->
               %{id: k.id, slug: k.slug, title: k.title, tags: k.tags, source: k.source}
             end)
         }}
    end
  end
end
