defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Create",
    description: "Define a custom field type for use in ticket type definitions.",
    hidden: true,
    category: "Tickets.Fields"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID. Omit for a global definition."},
      "project" => %{"type" => "string", "description" => "Project slug or UUID. Requires organization; scopes the field to a project."},
      "slug" => %{"type" => "string", "description" => "Slug, unique within the chosen scope (e.g. \"story_points\")"},
      "label" => %{"type" => "string", "description" => "Display label"},
      "field_type" => %{"type" => "string", "description" => "One of: text, rich_text, markdown, radio, select, multi_select, number, date, persona, url"},
      "options" => %{"type" => "object", "description" => "For select/radio/multi_select: {values: [{value, label}]}"},
      "default_value" => %{"type" => "string", "description" => "Default value"},
      "description" => %{"type" => "string", "description" => "Help text"}
    },
    "required" => ["slug", "label", "field_type"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs =
          extract(args, ~w(slug label field_type options default_value description))
          |> Map.merge(%{organization_id: org_id, project_id: project_id})

        case Definitions.create_field(attrs) do
          {:ok, field} ->
            {:ok, %{id: field.id, slug: field.slug, label: field.label, field_type: field.field_type, scope: Atom.to_string(Definitions.scope_of(field))}}
          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end

      {:error, reason} ->
        {:error, scope_error(reason)}
    end
  end

  defp scope_error(:org_not_found), do: "Organization not found"
  defp scope_error(:project_not_found), do: "Project not found"
  defp scope_error(:project_not_in_org), do: "Project does not belong to this organization"

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k] || args[String.to_atom(k)]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
