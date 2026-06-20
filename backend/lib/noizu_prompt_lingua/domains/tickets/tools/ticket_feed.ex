defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketFeed do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Feed",
    description: "Activity feed for a ticket.",
    hidden: true,
    category: "Tickets",
    annotations: [read_only_hint: true]

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :limit, :integer, description: "Max events (default 50)"
  end

  @impl true
  def call(args, _ctx) do
    ticket_id = args[:ticket_id] || args["ticket_id"]
    {:ok, %{
      ticket_id: ticket_id,
      events: [],
      hint: "Activity feed not yet implemented."
    }}
  end
end
