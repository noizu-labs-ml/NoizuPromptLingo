defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectAcceptInvite do
  use Noizu.MCP.Server.Tool,
    name: "Project.AcceptInvite",
    description: "Accept a pending project invitation.",
    hidden: true,
    category: "Projects.Members"

  input do
    field :project_id, :string, required: true, description: "Project UUID"
    field :user_id, :string, required: true, description: "User UUID accepting the invite"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    project_id = args[:project_id] || args["project_id"]
    user_id = args[:user_id] || args["user_id"]

    case Projects.accept_invite(project_id, user_id) do
      {:ok, member} ->
        {:ok, %{project_id: project_id, user_id: user_id, role: member.role, status: "active"}}
      {:error, :not_found} ->
        {:error, "No pending invite found"}
      {:error, :already_active} ->
        {:error, "Membership already active"}
      {:error, reason} ->
        {:error, "Failed: #{inspect(reason)}"}
    end
  end
end
