defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueList do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.List",
    description: "List all ticket queues.",
    hidden: true,
    category: "Tickets.Queues",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, description: "Organization slug or UUID — lists global ∪ org (∪ project) boards"
    field :project, :string, description: "Project slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        boards = Queues.list(org_id, project_id)
        {:ok, %{
          queues: Enum.map(boards, fn q ->
            %{id: q.id, name: q.name, slug: q.slug, methodology: q.methodology, description: q.description}
          end),
          count: length(boards)
        }}

      {:error, _} ->
        {:error, "Scope could not be resolved"}
    end
  end
end
