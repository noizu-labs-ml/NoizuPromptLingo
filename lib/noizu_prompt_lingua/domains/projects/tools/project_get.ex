defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectGet do
  use Noizu.MCP.Server.Tool,
    name: "Project.Get",
    description: "Get a project by slug or UUID.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  input do
    field :project, :string, required: true, description: "Project slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    key = args[:project] || args["project"]

    case Projects.get(key) do
      nil -> {:error, "Project '#{key}' not found"}
      project ->
        members = Projects.list_members(project.id)
        {:ok, %{
          id: project.id, name: project.name, slug: project.slug,
          description: project.description, status: project.status,
          owner_id: project.owner_id,
          member_count: length(members),
          created_at: project.inserted_at
        }}
    end
  end
end
