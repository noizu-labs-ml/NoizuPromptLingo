defmodule NoizuPromptLingua.MCP.Organizations.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Overview",
    description: "List organization tools and active organization count.",
    annotations: [read_only_hint: true],
    category: "Organizations"

  alias NoizuPromptLingua.TRP

  input do
  end

  @impl true
  def call(_args, _ctx) do
    count =
      case TRP.list_organizations() do
        list when is_list(list) -> length(list)
        {:error, _} -> 0
      end

    {:ok,
     %{
       domain: "Organizations",
       organizations: count,
       tools: %{
         crud: [
           "Organization.List",
           "Organization.Get",
           "Organization.Create",
           "Organization.Update"
         ]
       }
     }}
  end
end
