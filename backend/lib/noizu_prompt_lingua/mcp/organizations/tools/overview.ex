defmodule NoizuPromptLingua.MCP.Organizations.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Overview",
    description: "List organization tools and active organization count.",
    annotations: [read_only_hint: true],
    category: "Organizations"

  import Ecto.Query

  input do
  end

  @impl true
  def call(_args, _ctx) do
    count = NoizuPromptLingua.Repo.aggregate(from(o in NoizuPromptLingua.Schema.Organizations.Organization), :count)

    {:ok, %{
      domain: "Organizations",
      organizations: count,
      tools: %{
        crud: ["Organization.List", "Organization.Get", "Organization.Create", "Organization.Update"]
      }
    }}
  end
end
