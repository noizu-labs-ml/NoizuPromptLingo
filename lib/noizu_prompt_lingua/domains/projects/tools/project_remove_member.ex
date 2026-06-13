defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectRemoveMember do
  use Noizu.MCP.Server.Tool,
    name: "Project.RemoveMember",
    description: "Remove a member from a project.",
    hidden: true,
    category: "Projects.Members"

  input do
    field :project_id, :string, required: true, description: "Project UUID"
    field :user_id, :string, required: true, description: "Member user UUID to remove"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    project_id = args[:project_id] || args["project_id"]
    user_id = args[:user_id] || args["user_id"]

    case Projects.remove_member(project_id, user_id) do
      {:ok, _} ->
        {:ok, %{project_id: project_id, user_id: user_id, removed: true}}
      {:error, :not_found} ->
        {:error, "Member not found"}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
