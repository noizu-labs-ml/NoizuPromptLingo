defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.Create",
    description: "Create a ticket queue for organizing tickets.",
    hidden: true,
    category: "Tickets.Queues"

  input do
    field :name, :string, required: true, description: "Queue name"
    field :slug, :string, required: true, description: "Unique slug"
    field :description, :string, description: "Queue description"
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues

  @impl true
  def call(args, _ctx) do
    attrs = %{
      name: args[:name] || args["name"],
      slug: args[:slug] || args["slug"],
      description: args[:description] || args["description"]
    }

    case Queues.create(attrs) do
      {:ok, queue} -> {:ok, %{id: queue.id, name: queue.name, slug: queue.slug}}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
