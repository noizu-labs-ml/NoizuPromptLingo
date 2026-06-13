defmodule NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionDelete do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Field.Definition.Delete",
    description: "Delete a custom field definition.",
    hidden: true,
    category: "Tickets.Fields"

  input do
    field :slug, :string, required: true, description: "Field slug to delete"
  end

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    slug = args[:slug] || args["slug"]

    case Definitions.delete_field(slug) do
      {:ok, _} -> {:ok, %{deleted: slug}}
      {:error, :not_found} -> {:error, "Field '#{slug}' not found"}
    end
  end
end
