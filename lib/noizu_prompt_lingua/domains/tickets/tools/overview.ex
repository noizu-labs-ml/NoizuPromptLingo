defmodule NoizuPromptLingua.Domains.Tickets.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Overview",
    description: "List ticket tools, available ticket types, and status counts.",
    annotations: [read_only_hint: true],
    category: "Tickets"

  input do
  end

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.Domains.Tickets.Definitions

  @impl true
  def call(_args, _ctx) do
    types = Definitions.list_types()
    status_counts = Tickets.count_by_status()

    {:ok, %{
      domain: "Tickets",
      subdomain: "tickets.tobor.locker",
      status_counts: status_counts,
      ticket_types: Enum.map(types, fn t ->
        %{slug: t.slug, name: t.name, description: t.description}
      end),
      tools: %{
        crud: ["Ticket.Create", "Ticket.Get", "Ticket.Update", "Ticket.List"],
        cross_cutting: ["Ticket.Comment", "Ticket.Watch", "Ticket.Attach", "Ticket.Feed"],
        links: ["Ticket.Link", "Ticket.Unlink"],
        queues: ["Ticket.Queue.Create", "Ticket.Queue.Get", "Ticket.Queue.List", "Ticket.Queue.Feed"],
        definitions: ["Ticket.Definition.Create", "Ticket.Definition.Get",
                       "Ticket.Definition.Update", "Ticket.Definition.Delete"],
        fields: ["Ticket.Field.Definition.Create", "Ticket.Field.Definition.Update",
                  "Ticket.Field.Definition.Delete"]
      }
    }}
  end
end
