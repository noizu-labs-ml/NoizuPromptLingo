defmodule NoizuPromptLingua.Domains.Projects.Tools.ProjectMembers do
  use Noizu.MCP.Server.Tool,
    name: "Project.Members",
    description: "List members of a project.",
    hidden: true,
    category: "Projects.Members",
    annotations: [read_only_hint: true]

  input do
    field :project_id, :string, required: true, description: "Project UUID"
    field :status, :string, description: "Filter by status (pending|active|removed)"
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(args, _ctx) do
    project_id = args[:project_id] || args["project_id"]
    status = args[:status] || args["status"]
    opts = if status, do: [status: status], else: []

    members = Projects.list_members(project_id, opts)

    {:ok, %{
      project_id: project_id,
      members: Enum.map(members, fn m ->
        %{
          id: m.id,
          user_id: m.user_id,
          email: m.user && m.user.email,
          name: m.user && m.user.name,
          role: m.role,
          status: m.status,
          invited_at: m.invited_at,
          accepted_at: m.accepted_at
        }
      end),
      count: length(members)
    }}
  end
end
