defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectList do
  use Noizu.MCP.Server.Tool,
    name: "Project.List",
    description:
      "List projects, optionally scoped to an organization and/or status, with sorting. " <>
        "Spans every org in the key scope when `organization` is omitted.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}
  alias NoizuPromptLingua.TRP

  @sort_fields ~w(name status created_at updated_at)

  input do
    field :organization, :string, description: "Organization slug or UUID to scope to"

    field :status, :string,
      description: "Filter by status (active|archived|deleted); comma-separated = match any"

    field :sort, :string,
      description: "Sort field: name|status|created_at|updated_at (default created_at desc)"

    field :sort_dir, :string, description: "Sort direction: asc|desc (default desc)"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset (default 0)"
  end

  @impl true
  def call(args, _ctx) do
    org_id = Resolve.organization_id(Args.get(args, :organization))
    status = Args.get(args, :status)
    sort = Args.get(args, :sort)
    sort_dir = Args.get(args, :sort_dir)
    limit = Args.get(args, :limit) || 50
    offset = Args.get(args, :offset) || 0

    projects = list_projects(org_id, status, sort, sort_dir, limit, offset)

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
             created_at: &1.inserted_at,
             updated_at: &1.updated_at
           }
         ),
       count: length(projects)
     }}
  end

  # TRP key scope (spec 4.2); status filter client-side (the v1 projects filter
  # contract carries only project_id — spec §4.2 — so the scalar is still sent
  # opportunistically for forward-compat but never relied on).
  defp list_projects(org_id, status, sort, sort_dir, limit, offset) do
    statuses = split_statuses(status)

    rows =
      case org_id do
        nil ->
          case TRP.list_organizations() do
            orgs when is_list(orgs) ->
              Enum.flat_map(orgs, fn o ->
                case TRP.list_projects(o.id) do
                  ps when is_list(ps) -> ps
                  {:error, _} -> []
                end
              end)

            {:error, _} ->
              []
          end

        org_id ->
          case TRP.list_projects(org_id) do
            ps when is_list(ps) -> ps
            {:error, _} -> []
          end
      end

    rows
    |> apply_status_filter(statuses)
    |> apply_sort(sort, sort_dir)
    |> Enum.drop(offset)
    |> Enum.take(limit)
  end

  defp split_statuses(nil), do: []

  defp split_statuses(status) when is_binary(status),
    do: status |> String.split(",", trim: true) |> Enum.map(&String.trim/1)

  defp apply_status_filter(rows, []), do: rows

  defp apply_status_filter(rows, statuses),
    do: Enum.filter(rows, &(&1.status in statuses))

  defp apply_sort(rows, nil, _dir), do: Enum.sort_by(rows, & &1.inserted_at, :desc)
  defp apply_sort(rows, "", _dir), do: Enum.sort_by(rows, & &1.inserted_at, :desc)

  defp apply_sort(rows, field, dir) when field in @sort_fields do
    # Default direction is desc (matches the legacy created_at desc default).
    descending = dir not in ["asc", :asc]

    keyfn = fn row ->
      case Map.get(row, String.to_existing_atom(field)) do
        nil -> ""
        v -> v
      end
    end

    Enum.sort_by(rows, keyfn, if(descending, do: :desc, else: :asc))
  end

  defp apply_sort(rows, _unknown, dir), do: apply_sort(rows, nil, dir)
end
