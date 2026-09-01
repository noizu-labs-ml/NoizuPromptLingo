defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList do
  use Noizu.MCP.Server.Tool,
    name: "Organization.List",
    description:
      "List organizations. Optionally include a project-count summary per organization.",
    hidden: true,
    category: "Organizations",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.TRP

  input do
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"

    field :include_project_counts, :boolean,
      description: "Include a project_count per organization (default false)"
  end

  @impl true
  def call(args, _ctx) do
    limit = Args.get(args, :limit) || 50
    offset = Args.get(args, :offset) || 0
    counts? = truthy?(Args.get(args, :include_project_counts))

    orgs = list_organizations(limit, offset)

    counts =
      if counts? do
        project_counts(orgs)
      else
        %{}
      end

    {:ok,
     %{
       organizations:
         Enum.map(orgs, fn org ->
           base = %{id: org.id, name: org.name, slug: org.slug}

           if counts? do
             Map.put(base, :project_count, Map.get(counts, org.id, 0))
           else
             base
           end
         end),
       count: length(orgs)
     }}
  end

  # Accept the JSON boolean and its common string spellings (some clients
  # coerce flags to strings — same workaround family as the no-:map rule).
  defp truthy?(true), do: true
  defp truthy?("true"), do: true
  defp truthy?(_), do: false

  # TRP key scope IS the org inventory for this key (spec 4.1); cached 30s.
  defp list_organizations(limit, offset) do
    case TRP.list_organizations() do
      list when is_list(list) ->
        list |> Enum.sort_by(& &1.name) |> Enum.drop(offset) |> Enum.take(limit)

      {:error, _} ->
        []
    end
  end

  # W6 project-count summary: one cached list_projects read per org on the
  # page (key-scope org lists are small); a failed read counts as 0 rather
  # than failing the whole listing.
  defp project_counts(orgs) do
    Map.new(orgs, fn org ->
      count =
        case TRP.list_projects(org.id) do
          rows when is_list(rows) -> length(rows)
          _ -> 0
        end

      {org.id, count}
    end)
  end
end
