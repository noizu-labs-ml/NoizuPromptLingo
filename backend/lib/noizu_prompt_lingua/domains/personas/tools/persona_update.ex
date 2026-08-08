defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Update",
    description: "Update a persona's name, role, bio, avatar, tags, or status.",
    hidden: true,
    category: "Personas"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "persona" => %{"type" => "string", "description" => "Slug or UUID"},
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (needed to resolve a slug)"
      },
      "name" => %{"type" => "string"},
      "role" => %{"type" => "string"},
      "bio" => %{"type" => "string"},
      "avatar" => %{"type" => "string"},
      "status" => %{"type" => "string", "description" => "active or archived"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "metadata" => %{
        "type" => "object",
        "description" =>
          "Structured persona definition (voice signature, OCEAN personality, expertise graph, relationships); replaces the stored metadata object"
      }
    },
    "required" => ["persona"]
  })

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
        attrs = Args.take(args, [:name, :role, :bio, :avatar, :status, :tags, :metadata])

        case Personas.update(p.id, attrs) do
          {:ok, u} -> {:ok, %{id: u.id, slug: u.slug, name: u.name, status: u.status}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
