defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectUpdateRole do
  use Noizu.MCP.Server.Tool,
    name: "Project.UpdateRole",
    description: "Change a project member's role.",
    hidden: true,
    category: "Projects.Members"

  input do
    field :project_id, :string, required: true, description: "Project UUID"
    field :user_id, :string, required: true, description: "Member user UUID"
    field :role, :string, required: true, description: "New role (owner|admin|member|viewer)"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    project_id = args[:project_id] || args["project_id"]
    user_id = args[:user_id] || args["user_id"]
    role = args[:role] || args["role"]

    case Projects.update_role(project_id, user_id, role) do
      {:ok, member} ->
        {:ok, %{project_id: project_id, user_id: user_id, role: member.role}}
      {:error, :not_found} ->
        {:error, "Member not found"}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
