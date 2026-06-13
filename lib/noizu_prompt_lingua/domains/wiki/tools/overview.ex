defmodule NoizuPromptLingua.Domains.Wiki.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.Overview",
    description: "List wiki tools and page/space counts.",
    annotations: [read_only_hint: true],
    category: "Wiki"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Wiki",
      subdomain: "wiki.tobor.locker",
      status: "stub",
      tools: [
        "Wiki.CreateSpace", "Wiki.CreatePage", "Wiki.EditPage",
        "Wiki.GetPage", "Wiki.ListPages",
        "Wiki.Attach", "Wiki.Comment", "Wiki.Permissions"
      ]
    }}
  end
end
