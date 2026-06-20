defmodule NoizuPromptLingua.Domains.Tickets.Tools.QueueCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Queue.Create",
    description:
      "Create a board for organizing tickets. Pick a methodology (kanban, scrum, " <>
        "waterfall, spiral) — default stages are created automatically. Boards are " <>
        "tri-scoped: omit organization for a global board, or pass organization (+ project).",
    hidden: true,
    category: "Tickets.Queues"

  input do
    field :name, :string, required: true, description: "Board name"
    field :slug, :string, required: true, description: "Slug, unique within the chosen scope"
    field :methodology, :string, description: "kanban | scrum | waterfall | spiral (default kanban)"
    field :description, :string, description: "Board description"
    field :organization, :string, description: "Organization slug or UUID. Omit for a global board."
    field :project, :string, description: "Project slug or UUID. Requires organization."
  end

  alias NoizuPromptLingua.Domains.Tickets.Queues
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok, org_id, project_id} ->
        attrs = %{
          name: Args.get(args, :name),
          slug: Args.get(args, :slug),
          methodology: Args.get(args, :methodology) || "kanban",
          description: Args.get(args, :description),
          organization_id: org_id,
          project_id: project_id
        }

        case Queues.create(attrs) do
          {:ok, board} ->
            {:ok, %{id: board.id, name: board.name, slug: board.slug, methodology: board.methodology,
                    stages: Enum.map(board.stages, &%{slug: &1.slug, name: &1.name, position: &1.position})}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end

      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to this organization"}
    end
  end
end
