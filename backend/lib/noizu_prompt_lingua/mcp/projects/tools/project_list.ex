defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectList do
  use Noizu.MCP.Server.Tool,
    name: "Project.List",
    description: "List projects, optionally scoped to an organization and/or status.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  import Ecto.Query
  alias NoizuPromptLingua.Schema.Projects.Project, as: Schema
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, description: "Organization slug or UUID to scope to"
    field :status, :string, description: "Filter by status (active|archived|deleted)"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    org_id = Resolve.organization_id(Args.get(args, :organization))
    status = Args.get(args, :status)
    limit = Args.get(args, :limit) || 50
    offset = Args.get(args, :offset) || 0

    projects =
      Schema
      |> maybe_org(org_id)
      |> maybe_status(status)
      |> order_by([p], desc: p.inserted_at)
      |> limit(^limit)
      |> offset(^offset)
      |> NoizuPromptLingua.Repo.all()

    {:ok, %{
      projects: Enum.map(projects, &%{
        id: &1.id, name: &1.name, slug: &1.slug, status: &1.status,
        organization_id: &1.organization_id, created_at: &1.inserted_at
      }),
      count: length(projects)
    }}
  end

  defp maybe_org(query, nil), do: query
  defp maybe_org(query, org_id), do: where(query, [p], p.organization_id == ^org_id)

  defp maybe_status(query, nil), do: query
  defp maybe_status(query, status), do: where(query, [p], p.status == ^status)
end
