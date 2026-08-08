defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionDelete do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Delete",
    description: "Delete a custom field definition.",
    hidden: true,
    category: "Tickets.Fields"

  input do
    field :organization, :string,
      description: "Organization slug or UUID. Omit to target a global definition."

    field :project, :string,
      description: "Project slug or UUID — targets the project-scoped definition."

    field :slug, :string,
      required: true,
      description: "Field slug to delete (within the chosen scope)"
  end

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    slug = Args.get(args, :slug)

    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         %{id: id} <- Definitions.get_field_in_scope(org_id, project_id, slug) do
      Definitions.delete_field(id)
      {:ok, %{deleted: slug}}
    else
      nil -> {:error, "Field '#{slug}' not found in the given scope"}
      {:error, _} -> {:error, "Scope could not be resolved"}
    end
  end
end
