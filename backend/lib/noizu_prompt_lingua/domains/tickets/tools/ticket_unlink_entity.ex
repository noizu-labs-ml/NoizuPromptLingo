defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketUnlinkEntity do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.UnlinkEntity",
    description: "Remove a link between a ticket and a non-ticket entity.",
    hidden: true,
    category: "Tickets"

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :entity_type, :string, required: true, description: "Entity type used when linking"
    field :entity_id, :string, required: true, description: "UUID of the linked entity"
    field :link_type, :string, description: "Link type to remove (default relates_to)"
  end

  alias NoizuPromptLingua.Domains.Links
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    ticket_id = Args.get(args, :ticket_id)
    entity_type = Args.get(args, :entity_type)
    entity_id = Args.get(args, :entity_id)
    opts = [link_type: Args.get(args, :link_type) || "relates_to"]

    case Links.unlink_entity(ticket_id, entity_type, entity_id, opts) do
      {:ok, _} -> {:ok, %{unlinked: true}}
      {:error, :not_found} -> {:error, "Link not found"}
    end
  end
end
