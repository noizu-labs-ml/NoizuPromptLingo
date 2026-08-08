defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectGet do
  use Noizu.MCP.Server.Tool,
    name: "Project.Get",
    description: "Get a project by slug or UUID.",
    hidden: true,
    category: "Projects",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :project, :string, required: true, description: "Project slug or UUID"
  end

  @impl true
  def call(args, _ctx) do
    ref = Args.get(args, :project)

    case Resolve.project(ref) do
      nil ->
        {:error, "Project '#{ref}' not found"}

      project ->
        {:ok,
         %{
           id: project.id,
           organization_id: project.organization_id,
           name: project.name,
           slug: project.slug,
           description: project.description,
           status: project.status,
           created_at: project.inserted_at
         }}
    end
  end
end
