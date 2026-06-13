defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionGet do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Get",
    description: "Get a ticket type definition by slug, including its fields and status workflow.",
    hidden: true,
    category: "Tickets.Types",
    annotations: [read_only_hint: true]

  input do
    field :slug, :string, required: true, description: "Ticket type slug (e.g. \"bug\", \"epic\")"
  end

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    slug = args[:slug] || args["slug"]

    case Definitions.get_type(slug) do
      nil ->
        {:error, "Ticket type '#{slug}' not found"}

      type_def ->
        fields = Definitions.get_type_fields(slug)
        {:ok, %{
          slug: type_def.slug,
          name: type_def.name,
          description: type_def.description,
          icon: type_def.icon,
          status_workflow: type_def.status_workflow,
          fields: fields
        }}
    end
  end
end
