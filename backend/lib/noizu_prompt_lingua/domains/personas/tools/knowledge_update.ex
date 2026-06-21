defmodule NoizuPromptLingua.Domains.Personas.Tools.KnowledgeUpdate do
  use Noizu.MCP.Server.Tool, name: "Persona.Knowledge.Update",
    description: "Update a persona knowledge-base article by its id.",
    hidden: true, category: "Personas.Knowledge"

  input do
    field :id, :string, required: true, description: "Knowledge entry UUID"
    field :title, :string
    field :body, :string
    field :source, :string
    field :tags, {:array, :string}
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    attrs = Args.take(args, [:title, :body, :source, :tags])

    case Personas.update_knowledge(id, attrs) do
      {:ok, k} -> {:ok, %{id: k.id, slug: k.slug, title: k.title}}
      {:error, :not_found} -> {:error, "Knowledge entry not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
