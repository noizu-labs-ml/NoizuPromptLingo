defmodule NoizuPromptLingua.Domains.Markdown.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Markdown.Overview",
    description: "List the markdown tools and their purpose.",
    annotations: [read_only_hint: true],
    category: "Markdown"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Markdown",
      subdomain: "markdown.tobor.locker",
      tools: [
        %{name: "Markdown.Convert", description: "Convert a URL, HTML, or raw content to Markdown"},
        %{name: "Markdown.View", description: "Filter/collapse a Markdown document by heading selector"}
      ]
    }}
  end
end
