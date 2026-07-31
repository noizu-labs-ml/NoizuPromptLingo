defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueGet do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.Get",
    description: "Get a queue with status counts.",
    hidden: true,
    category: "Tickets.Queues",
    annotations: [read_only_hint: true]

  input do
    field :slug, :string, required: true, description: "Board slug"
    field :organization, :string, description: "Organization slug or UUID (scope to resolve in)"
    field :project, :string, description: "Project slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    slug = Args.get(args, :slug)

    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         board when not is_nil(board) <- Queues.get(slug, org_id, project_id) do
      {:ok,
       %{
         id: board.id,
         name: board.name,
         slug: board.slug,
         methodology: board.methodology,
         description: board.description,
         status_counts: Queues.status_counts(board.id),
         stages:
           Enum.map(
             board.stages,
             &%{
               id: &1.id,
               slug: &1.slug,
               name: &1.name,
               kind: &1.kind,
               position: &1.position,
               wip_limit: &1.wip_limit
             }
           ),
         iterations:
           Enum.map(
             board.iterations,
             &%{
               id: &1.id,
               name: &1.name,
               sequence: &1.sequence,
               status: &1.status,
               goal: &1.goal,
               starts_on: &1.starts_on,
               ends_on: &1.ends_on
             }
           )
       }}
    else
      nil -> {:error, "Board '#{slug}' not found"}
      {:error, _} -> {:error, "Scope could not be resolved"}
    end
  end
end
