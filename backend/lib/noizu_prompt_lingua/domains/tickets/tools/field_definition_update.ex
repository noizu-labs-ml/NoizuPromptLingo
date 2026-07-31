defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Update",
    description: "Update an existing custom field definition.",
    hidden: true,
    category: "Tickets.Fields"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID. Omit to target a global definition."
      },
      "project" => %{
        "type" => "string",
        "description" => "Project slug or UUID — targets the project-scoped definition."
      },
      "slug" => %{
        "type" => "string",
        "description" => "Field slug to update (within the chosen scope)"
      },
      "label" => %{"type" => "string", "description" => "New label"},
      "options" => %{"type" => "object", "description" => "New options"},
      "default_value" => %{"type" => "string", "description" => "New default"},
      "description" => %{"type" => "string", "description" => "New help text"},
      "disabled" => %{
        "type" => "boolean",
        "description" => "Set true to suppress (tombstone) the inherited definition"
      }
    },
    "required" => ["slug"]
  })

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    slug = Args.get(args, :slug)

    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         %{id: id} <- Definitions.get_field_in_scope(org_id, project_id, slug) do
      attrs = extract(args, ~w(label options default_value description disabled))

      case Definitions.update_field(id, attrs) do
        {:ok, field} ->
          {:ok,
           %{id: field.id, slug: field.slug, label: field.label, field_type: field.field_type}}

        {:error, changeset} ->
          {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      nil -> {:error, "Field '#{slug}' not found in the given scope"}
      {:error, _} -> {:error, "Scope could not be resolved"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
