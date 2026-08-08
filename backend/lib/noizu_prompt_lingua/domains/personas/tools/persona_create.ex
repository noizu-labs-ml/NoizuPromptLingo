defmodule NoizuPromptLingua.Domains.Personas.Tools.PersonaCreate do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Create",
    description: "Create a persona (name, role, bio).",
    hidden: true,
    category: "Personas"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "slug" => %{"type" => "string", "description" => "Slug, unique within the organization"},
      "name" => %{"type" => "string", "description" => "Persona display name"},
      "role" => %{"type" => "string", "description" => "Role/title"},
      "bio" => %{"type" => "string", "description" => "Biography / description"},
      "avatar" => %{"type" => "string", "description" => "Avatar URL or media ref"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}},
      "metadata" => %{
        "type" => "object",
        "description" =>
          "Structured persona definition (e.g. voice signature, OCEAN personality, expertise graph, relationships)"
      }
    },
    "required" => ["organization", "slug", "name"]
  })

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs =
          %{
            organization_id: org_id,
            project_id: project_id,
            slug: args["slug"],
            name: args["name"],
            role: args["role"],
            bio: args["bio"],
            avatar: args["avatar"],
            tags: args["tags"]
          }
          |> maybe_put(:metadata, args["metadata"])

        case Personas.create(attrs) do
          {:ok, p} ->
            {:ok, %{id: p.id, slug: p.slug, name: p.name, role: p.role, status: p.status}}

          {:error, cs} ->
            {:error, "Failed: #{inspect(cs.errors)}"}
        end

      {:error, :org_not_found} ->
        {:error, "Organization not found"}

      {:error, :project_not_found} ->
        {:error, "Project not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project does not belong to this organization"}
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
