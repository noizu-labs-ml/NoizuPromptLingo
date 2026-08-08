defmodule NoizuPromptLingua.Domains.Personas.Tools.KnowledgeAdd do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Knowledge.Add",
    description: "Add a knowledge-base article to a persona.",
    hidden: true,
    category: "Personas.Knowledge"

  input do
    field :persona, :string, required: true, description: "Slug or UUID"

    field :organization, :string,
      description: "Organization slug or UUID (needed to resolve a slug)"

    field :slug, :string,
      required: true,
      description: "Article slug, unique within the persona's KB"

    field :title, :string, required: true
    field :body, :string, required: true, description: "Article body (markdown)"
    field :source, :string, description: "Origin/citation"
    field :tags, {:array, :string}
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
        attrs = Args.take(args, [:slug, :title, :body, :source, :tags])

        case Personas.add_knowledge(p.id, attrs) do
          {:ok, k} -> {:ok, %{id: k.id, slug: k.slug, title: k.title}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
