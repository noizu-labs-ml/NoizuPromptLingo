defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectArchive do
  use Noizu.MCP.Server.Tool,
    name: "Project.Archive",
    description: "Archive a project.",
    hidden: true,
    category: "Projects"

  input do
    field :project, :string, required: true, description: "Project slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    key = args[:project] || args["project"]

    case Projects.archive(key) do
      {:ok, project} -> {:ok, %{id: project.id, slug: project.slug, status: "archived"}}
      {:error, :not_found} -> {:error, "Project '#{key}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
