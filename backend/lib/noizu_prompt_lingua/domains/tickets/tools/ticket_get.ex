defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketGet do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Get",
    description: "Fetch a ticket by UUID with fields, links, and attachments.",
    hidden: true,
    category: "Tickets",
    annotations: [read_only_hint: true]

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID"
  end

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(args, _ctx) do
    ticket_id = args[:ticket_id] || args["ticket_id"]

    case Tickets.get(ticket_id) do
      nil ->
        {:error, "Ticket '#{ticket_id}' not found"}

      ticket ->
        links = Tickets.get_links(ticket_id)

        type_fields =
          case Definitions.resolve_type(
                 ticket.organization_id,
                 ticket.project_id,
                 ticket.ticket_type
               ) do
            nil -> []
            type_def -> Definitions.type_field_list(type_def)
          end

        {:ok,
         %{
           id: ticket.id,
           title: ticket.title,
           description: ticket.description,
           ticket_type: ticket.ticket_type,
           status: ticket.status,
           priority: ticket.priority,
           assignee: ticket.assignee,
           reporter: ticket.reporter,
           project_id: ticket.project_id,
           queue_id: ticket.queue_id,
           parent_id: ticket.parent_id,
           custom_fields: ticket.custom_fields,
           type_fields: type_fields,
           links: %{
             outgoing:
               Enum.map(links.outgoing, fn l ->
                 %{ticket_id: l.target_ticket_id, link_type: l.link_type}
               end),
             incoming:
               Enum.map(links.incoming, fn l ->
                 %{ticket_id: l.source_ticket_id, link_type: l.link_type}
               end)
           },
           created_at: ticket.inserted_at,
           updated_at: ticket.updated_at
         }}
    end
  end
end
