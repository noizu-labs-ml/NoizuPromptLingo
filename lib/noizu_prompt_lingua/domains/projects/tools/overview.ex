defmodule NoizuPromptLingua.Domains.Projects.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Project.Overview",
    description: "List project tools and active project count.",
    annotations: [read_only_hint: true],
    category: "Projects"

  input do
  end

  alias NoizuPromptLingua.Domains.Projects

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Projects",
      subdomain: "projects.tobor.locker",
      active_projects: Projects.count_active(),
      tools: %{
        crud: ["Project.Create", "Project.Get", "Project.Update", "Project.List", "Project.Archive"],
        members: ["Project.Members", "Project.Invite", "Project.AcceptInvite",
                   "Project.UpdateRole", "Project.RemoveMember"]
      }
    }}
  end
end
