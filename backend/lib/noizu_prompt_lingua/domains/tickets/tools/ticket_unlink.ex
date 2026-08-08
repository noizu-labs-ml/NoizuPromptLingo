defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketUnlink do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Unlink",
    description: "Remove a link between two tickets.",
    hidden: true,
    category: "Tickets"

  input do
    field :source_ticket_id, :string, required: true, description: "Source ticket UUID"
    field :target_ticket_id, :string, required: true, description: "Target ticket UUID"
    field :link_type, :string, required: true, description: "Link type to remove"
  end

  alias NoizuPromptLingua.Domains.Tickets

  @impl true
  def call(args, _ctx) do
    source = args[:source_ticket_id] || args["source_ticket_id"]
    target = args[:target_ticket_id] || args["target_ticket_id"]
    link_type = args[:link_type] || args["link_type"]

    case Tickets.unlink(source, target, link_type) do
      {:ok, _} -> {:ok, %{unlinked: true}}
      {:error, :not_found} -> {:error, "Link not found"}
    end
  end
end
