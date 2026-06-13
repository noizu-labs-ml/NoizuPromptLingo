defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueList do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.List",
    description: "List all ticket queues.",
    hidden: true,
    category: "Tickets.Queues",
    annotations: [read_only_hint: true]

  input do
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues

  @impl true
  def call(_args, _ctx) do
    queues = Queues.list()
    {:ok, %{
      queues: Enum.map(queues, fn q ->
        %{id: q.id, name: q.name, slug: q.slug, description: q.description}
      end),
      count: length(queues)
    }}
  end
end
