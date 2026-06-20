defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Update",
    description: "Update a ticket type definition.",
    hidden: true,
    category: "Tickets.Types"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID. Omit to target a global type."},
      "project" => %{"type" => "string", "description" => "Project slug or UUID — targets the project-scoped type."},
      "slug" => %{"type" => "string", "description" => "Type slug to update (within the chosen scope)"},
      "name" => %{"type" => "string", "description" => "New display name"},
      "description" => %{"type" => "string", "description" => "New description"},
      "icon" => %{"type" => "string", "description" => "New icon"},
      "status_workflow" => %{"type" => "object", "description" => "New status workflow"},
      "disabled" => %{"type" => "boolean", "description" => "Set true to suppress (tombstone) the inherited type"}
    },
    "required" => ["slug"]
  }

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    slug = Args.get(args, :slug)

    with {:ok, org_id, project_id} <- Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         %{id: id} <- Definitions.get_type_in_scope(org_id, project_id, slug) do
      attrs = extract(args, ~w(name description icon status_workflow disabled))

      case Definitions.update_type(id, attrs) do
        {:ok, type_def} -> {:ok, %{id: type_def.id, slug: type_def.slug, name: type_def.name}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      nil -> {:error, "Type '#{slug}' not found in the given scope"}
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
