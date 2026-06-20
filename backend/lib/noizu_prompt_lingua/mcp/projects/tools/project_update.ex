defmodule NoizuPromptLingua.MCP.Projects.Tools.ProjectUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Project.Update",
    description: "Update a project's name, slug, description, or status.",
    hidden: true,
    category: "Projects"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :project, :string, required: true, description: "Project slug or UUID"
    field :name, :string, description: "New name"
    field :slug, :string, description: "New slug"
    field :description, :string, description: "New description"
    field :status, :string, description: "New status (active|archived|deleted)"
  end

  @impl true
  def call(args, _ctx) do
    ref = Args.get(args, :project)
    attrs = Args.take(args, [:name, :slug, :description, :status])

    case Resolve.project(ref) do
      nil ->
        {:error, "Project '#{ref}' not found"}

      project ->
        case NoizuPromptLingua.Projects.update_project(project.id, attrs) do
          {:ok, updated} -> {:ok, %{id: updated.id, name: updated.name, slug: updated.slug, status: updated.status}}
          {:error, :not_found} -> {:error, "Project '#{ref}' not found"}
          {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
