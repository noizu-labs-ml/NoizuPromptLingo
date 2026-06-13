defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectList do
  use Noizu.MCP.Server.Tool,
    name: "Project.List",
    description: "List projects with optional status filter.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  input do
    field :status, :string, description: "Filter by status (active|archived)"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    opts =
      [:status, :limit, :offset]
      |> Enum.reduce([], fn k, acc ->
        val = args[k] || args[Atom.to_string(k)]
        if val, do: [{k, val} | acc], else: acc
      end)

    projects = Projects.list(opts)

    {:ok, %{
      projects: Enum.map(projects, fn p ->
        %{id: p.id, name: p.name, slug: p.slug, status: p.status, created_at: p.inserted_at}
      end),
      count: length(projects)
    }}
  end
end
