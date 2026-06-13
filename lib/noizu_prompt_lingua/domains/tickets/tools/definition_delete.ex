defmodule NoizuPromptLingua.Domains.Tickets.Tools.DefinitionDelete do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Definition.Delete",
    description: "Soft-delete a ticket type definition.",
    hidden: true,
    category: "Tickets.Types"

  input do
    field :slug, :string, required: true, description: "Type slug to delete"
  end

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    slug = args[:slug] || args["slug"]

    case Definitions.delete_type(slug) do
      {:ok, _} -> {:ok, %{deleted: slug}}
      {:error, :not_found} -> {:error, "Type '#{slug}' not found"}
    end
  end
end
