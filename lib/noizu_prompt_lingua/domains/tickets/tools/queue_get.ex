defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueGet do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.Get",
    description: "Get a queue with status counts.",
    hidden: true,
    category: "Tickets.Queues",
    annotations: [read_only_hint: true]

  input do
    field :slug, :string, required: true, description: "Queue slug"
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues

  @impl true
  def call(args, _ctx) do
    slug = args[:slug] || args["slug"]

    case Queues.get(slug) do
      nil -> {:error, "Queue '#{slug}' not found"}
      queue ->
        counts = Queues.status_counts(queue.id)
        {:ok, %{
          id: queue.id,
          name: queue.name,
          slug: queue.slug,
          description: queue.description,
          status_counts: counts
        }}
    end
  end
end
