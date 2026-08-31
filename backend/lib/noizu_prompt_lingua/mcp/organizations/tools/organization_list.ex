defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList do
  use Noizu.MCP.Server.Tool,
    name: "Organization.List",
    description: "List organizations.",
    hidden: true,
    category: "Organizations",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.TRP

  input do
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    limit = Args.get(args, :limit) || 50
    offset = Args.get(args, :offset) || 0

    orgs = list_organizations(limit, offset)

    {:ok,
     %{
       organizations: Enum.map(orgs, &%{id: &1.id, name: &1.name, slug: &1.slug}),
       count: length(orgs)
     }}
  end

  # TRP key scope IS the org inventory for this key (spec 4.1); cached 30s.
  defp list_organizations(limit, offset) do
    case TRP.list_organizations() do
      list when is_list(list) -> list |> Enum.sort_by(& &1.name) |> Enum.drop(offset) |> Enum.take(limit)
      {:error, _} -> []
    end
  end
end
