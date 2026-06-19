defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Session.Create",
    description: "Create a new work session. Sessions group chat rooms, artifacts, and tickets under a shared context. Use the `project` field to associate the session with a project by slug or UUID.",
    hidden: true,
    category: "Sessions"

  input do
    field :title, :string, required: true, description: "Human-readable session title"
    field :description, :string, description: "Optional longer description of the session's purpose"
    field :status, :string, description: "Initial status (default \"active\")"
    field :project, :string, description: "Project slug or UUID to associate this session with"
  end

  @impl true
  def call(args, _ctx) do
    project_ref = args[:project] || args["project"]

    with {:ok, project_id} <- NoizuPromptLingua.Domains.Sessions.resolve_project_id(project_ref) do
      attrs = %{
        title: args[:title] || args["title"],
        description: args[:description] || args["description"],
        status: args[:status] || args["status"] || "active",
        project_id: project_id
      }

      case NoizuPromptLingua.Domains.Sessions.create(attrs) do
        {:ok, session} ->
          {:ok, %{
            id: session.id,
            title: session.title,
            status: session.status,
            project_id: session.project_id,
            created_at: session.inserted_at
          }}

        {:error, changeset} ->
          {:error, "Failed to create session: #{inspect(changeset.errors)}"}
      end
    else
      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}
    end
  end
end
