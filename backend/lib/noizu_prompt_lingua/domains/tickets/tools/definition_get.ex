defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionGet do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Get",
    description:
      "Get a ticket type definition by slug, including its fields and status workflow.",
    hidden: true,
    category: "Tickets.Types",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string,
      description: "Organization slug or UUID. Omit to resolve against global only."

    field :project, :string,
      description: "Project slug or UUID — resolves with project precedence."

    field :slug, :string, required: true, description: "Ticket type slug (e.g. \"bug\", \"epic\")"
  end

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    slug = Args.get(args, :slug)

    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         type_def when not is_nil(type_def) <- Definitions.resolve_type(org_id, project_id, slug) do
      {:ok,
       %{
         slug: type_def.slug,
         name: type_def.name,
         scope: Atom.to_string(Definitions.scope_of(type_def)),
         description: type_def.description,
         icon: type_def.icon,
         status_workflow: type_def.status_workflow,
         fields: Definitions.type_field_list(type_def)
       }}
    else
      nil -> {:error, "Ticket type '#{slug}' not found"}
      {:error, _} -> {:error, "Scope could not be resolved"}
    end
  end
end
