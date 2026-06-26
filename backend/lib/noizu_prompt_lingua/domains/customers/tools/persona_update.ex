defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaUpdate do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.Update",
    description: "Update fields on a customer persona.",
    hidden: true,
    category: "Customers"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Persona UUID"},
      "name" => %{"type" => "string", "description" => "Name"},
      "archetype" => %{"type" => "string", "description" => "Archetype"},
      "segment_id" => %{"type" => "string", "description" => "Customer segment UUID"},
      "demographics" => %{"type" => "object", "description" => "Demographics"},
      "goals" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Goals"},
      "pains" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Pain points"},
      "channels" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Channels"},
      "motivations" => %{"type" => "string", "description" => "Motivations"},
      "objections" => %{"type" => "string", "description" => "Objections"},
      "summary" => %{"type" => "string", "description" => "Summary"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"},
      "status" => %{"type" => "string", "description" => "active or archived"}
    },
    "required" => ["id"]
  }

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name archetype segment_id demographics goals pains channels motivations objections summary tags status)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    attrs = Args.take(args, @fields)

    case Customers.update_persona(id, attrs) do
      {:ok, p} -> {:ok, %{id: p.id, slug: p.slug, name: p.name, status: p.status}}
      {:error, :not_found} -> {:error, "Customer persona '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
