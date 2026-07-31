defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationList do
  use Noizu.MCP.Server.Tool,
    name: "Organization.List",
    description: "List organizations.",
    hidden: true,
    category: "Organizations",
    annotations: [read_only_hint: true]

  import Ecto.Query
  alias NoizuPromptLingua.Schema.Organizations.Organization, as: Schema
  alias NoizuPromptLingua.MCP.Args

  input do
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    limit = Args.get(args, :limit) || 50
    offset = Args.get(args, :offset) || 0

    orgs =
      Schema
      |> order_by([o], asc: o.name)
      |> limit(^limit)
      |> offset(^offset)
      |> NoizuPromptLingua.Repo.all()

    {:ok,
     %{
       organizations: Enum.map(orgs, &%{id: &1.id, name: &1.name, slug: &1.slug}),
       count: length(orgs)
     }}
  end
end
