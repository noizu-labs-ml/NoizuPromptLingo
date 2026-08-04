defmodule NoizuPromptLingua.MCP.Projects.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Project.Overview",
    description: "List project tools and active project count.",
    annotations: [read_only_hint: true],
    category: "Projects"

  import Ecto.Query

  input do
  end

  @impl true
  def call(_args, _ctx) do
    active =
      NoizuPromptLingua.PMCore.with_pm(fn ->
        Noizu.PM.Repo.aggregate(
          from(p in Noizu.PM.Schema.Projects.Project, where: p.status == "active"),
          :count
        )
      end)

    {:ok,
     %{
       domain: "Projects",
       active_projects: active,
       tools: %{
         crud: ["Project.List", "Project.Get", "Project.Create", "Project.Update"]
       }
     }}
  end
end
