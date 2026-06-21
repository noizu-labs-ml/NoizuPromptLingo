defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaUpdate do
  use Noizu.MCP.Server.Tool, name: "Persona.Update",
    description: "Update a persona's name, role, bio, avatar, tags, or status.",
    hidden: true, category: "Personas"

  input do
    field :persona, :string, required: true, description: "Slug or UUID"
    field :organization, :string, description: "Organization slug or UUID (needed to resolve a slug)"
    field :name, :string
    field :role, :string
    field :bio, :string
    field :avatar, :string
    field :status, :string, description: "active or archived"
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
      nil -> {:error, "Persona '#{key}' not found"}
      p ->
        attrs = Args.take(args, [:name, :role, :bio, :avatar, :status, :tags])
        case Personas.update(p.id, attrs) do
          {:ok, u} -> {:ok, %{id: u.id, slug: u.slug, name: u.name, status: u.status}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
