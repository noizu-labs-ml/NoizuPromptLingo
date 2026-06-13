defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketList do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.List",
    description: "List tickets with optional filters.",
    hidden: true,
    category: "Tickets",
    annotations: [read_only_hint: true]

  input do
    field :status, :string, description: "Filter by status"
    field :ticket_type, :string, description: "Filter by type slug"
    field :priority, :string, description: "Filter by priority"
    field :assignee, :string, description: "Filter by assignee"
    field :project_id, :string, description: "Filter by project UUID"
    field :queue_id, :string, description: "Filter by queue UUID"
    field :parent_id, :string, description: "Filter by parent ticket UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Tickets

  @impl true
  def call(args, _ctx) do
    opts =
      [:status, :ticket_type, :priority, :assignee, :project_id, :queue_id, :parent_id, :limit, :offset]
      |> Enum.reduce([], fn key, acc ->
        val = args[key] || args[Atom.to_string(key)]
        if val, do: [{key, val} | acc], else: acc
      end)

    tickets = Tickets.list(opts)

    {:ok, %{
      tickets: Enum.map(tickets, fn t ->
        %{id: t.id, title: t.title, ticket_type: t.ticket_type,
          status: t.status, priority: t.priority, assignee: t.assignee,
          created_at: t.inserted_at}
      end),
      count: length(tickets)
    }}
  end
end
