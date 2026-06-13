defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectInvite do
  use Noizu.MCP.Server.Tool,
    name: "Project.Invite",
    description: "Invite a user to a project by email.",
    hidden: true,
    category: "Projects.Members"

  input do
    field :project_id, :string, required: true, description: "Project UUID"
    field :email, :string, required: true, description: "User email to invite"
    field :role, :string, description: "Role to assign (owner|admin|member|viewer, default: member)"
    field :invited_by, :string, description: "Inviting user UUID"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    project_id = args[:project_id] || args["project_id"]
    email = args[:email] || args["email"]
    role = args[:role] || args["role"] || "member"
    invited_by = args[:invited_by] || args["invited_by"]

    case Projects.invite(project_id, email, role: role, invited_by: invited_by) do
      {:ok, member} ->
        {:ok, %{id: member.id, project_id: project_id, user_id: member.user_id,
                role: member.role, status: "pending"}}
      {:error, :user_not_found} ->
        {:error, "No user found with email '#{email}'"}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
