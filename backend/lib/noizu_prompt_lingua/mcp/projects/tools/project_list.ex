defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectList do
  use Noizu.MCP.Server.Tool,
    name: "Project.List",
    description: "List projects, optionally scoped to an organization and/or status.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.TRP

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

    projects = list_projects(org_id, status, limit, offset)

    {:ok,
     %{
       projects:
         Enum.map(
           projects,
           &%{
             id: &1.id,
             name: &1.name,
             slug: &1.slug,
             status: &1.status,
             organization_id: &1.organization_id,
             created_at: &1.inserted_at
           }
         ),
       count: length(projects)
     }}
  end

  # TRP key scope (spec 4.2); status filter client-side (spec filter is items-only).
  defp list_projects(org_id, status, limit, offset) do
    rows =
      case org_id do
        nil ->
          case TRP.list_organizations() do
            orgs when is_list(orgs) ->
              Enum.flat_map(orgs, fn o ->
                case TRP.list_projects(o.id, status: status) do
                  ps when is_list(ps) -> ps
                  {:error, _} -> []
                end
              end)

            {:error, _} ->
              []
          end

        org_id ->
          case TRP.list_projects(org_id, status: status) do
            ps when is_list(ps) -> ps
            {:error, _} -> []
          end
      end

    rows
    |> Enum.reject(&(&1.status && status && &1.status != status))
    |> Enum.sort_by(& &1.inserted_at, :desc)
    |> Enum.drop(offset)
    |> Enum.take(limit)
  end
end
