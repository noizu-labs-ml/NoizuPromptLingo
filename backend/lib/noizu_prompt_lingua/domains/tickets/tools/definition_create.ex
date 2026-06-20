defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Create",
    description: "Define a ticket type with custom field schema and status workflow.",
    hidden: true,
    category: "Tickets.Types"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID. Omit for a global type."},
      "project" => %{"type" => "string", "description" => "Project slug or UUID. Requires organization; scopes the type to a project."},
      "slug" => %{"type" => "string", "description" => "Slug, unique within the chosen scope (e.g. \"bug\", \"epic\")"},
      "name" => %{"type" => "string", "description" => "Display name"},
      "description" => %{"type" => "string", "description" => "Type description"},
      "icon" => %{"type" => "string", "description" => "Emoji or icon key"},
      "status_workflow" => %{"type" => "object", "description" => "{statuses: [...], transitions: {status: [targets]}}"},
      "fields" => %{"type" => "array", "description" => "Array of {slug, required} field assignments (slugs resolved within scope)",
        "items" => %{"type" => "object", "properties" => %{
          "slug" => %{"type" => "string"},
          "required" => %{"type" => "boolean"}
        }}}
    },
    "required" => ["slug", "name"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs =
          extract(args, ~w(slug name description icon status_workflow))
          |> Map.merge(%{organization_id: org_id, project_id: project_id})

        case Definitions.create_type(attrs) do
          {:ok, type_def} ->
            (args["fields"] || [])
            |> Enum.with_index()
            |> Enum.each(fn {spec, idx} ->
              case Definitions.resolve_field(org_id, project_id, spec["slug"]) do
                nil -> :ok
                field -> Definitions.add_field_to_type(type_def.id, field.id, required: spec["required"] || false, position: idx)
              end
            end)

            {:ok, %{id: type_def.id, slug: type_def.slug, name: type_def.name, scope: Atom.to_string(Definitions.scope_of(type_def))}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end

      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to this organization"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
