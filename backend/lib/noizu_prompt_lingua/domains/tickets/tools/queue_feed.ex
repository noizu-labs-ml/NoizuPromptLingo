defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueFeed do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.Feed",
    description: "Activity feed for a ticket queue.",
    hidden: true,
    category: "Tickets.Queues",
    annotations: [read_only_hint: true]

  input do
    field :slug, :string, required: true, description: "Queue slug"
    field :limit, :integer, description: "Max events (default 50)"
  end

  @impl true
  def call(args, _ctx) do
    slug = args[:slug] || args["slug"]
    {:ok, %{
      queue: slug,
      events: [],
      hint: "Activity feed not yet implemented."
    }}
  end
end
