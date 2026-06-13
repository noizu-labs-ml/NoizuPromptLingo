defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketLink do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Link",
    description: "Create a directional link between two tickets.",
    hidden: true,
    category: "Tickets"

  input do
    field :source_ticket_id, :string, required: true, description: "Source ticket UUID"
    field :target_ticket_id, :string, required: true, description: "Target ticket UUID"
    field :link_type, :string, required: true, description: "blocks, blocked_by, relates_to, duplicates, parent_of, child_of"
  end

  alias NoizuPromptLingua.Domains.Tickets

  @impl true
  def call(args, _ctx) do
    source = args[:source_ticket_id] || args["source_ticket_id"]
    target = args[:target_ticket_id] || args["target_ticket_id"]
    link_type = args[:link_type] || args["link_type"]

    case Tickets.link(source, target, link_type) do
      {:ok, link} ->
        {:ok, %{id: link.id, source: source, target: target, link_type: link_type}}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
