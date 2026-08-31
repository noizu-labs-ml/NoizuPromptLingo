defmodule NoizuPromptLingua.MCP.Projects.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Project.Overview",
    description: "List project tools and active project count.",
    annotations: [read_only_hint: true],
    category: "Projects"

  alias NoizuPromptLingua.TRP

  input do
  end

  @impl true
  def call(_args, _ctx) do
    active =
      case TRP.list_organizations() do
        orgs when is_list(orgs) ->
          Enum.sum(
            for o <- orgs do
              case TRP.list_projects(o.id, status: "active") do
                ps when is_list(ps) -> length(ps)
                {:error, _} -> 0
              end
            end
          )

        {:error, _} ->
          0
      end

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
