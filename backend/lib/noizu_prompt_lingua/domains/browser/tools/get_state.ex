defmodule NoizuPromptLingua.Domains.Browser.Tools.GetState do
  use Noizu.MCP.Server.Tool,
    name: "Browser.GetState",
    description:
      "Get the local browser's current state: url and title, plus the visible page text when requested.",
    annotations: [read_only_hint: true],
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :include_text, :boolean, required: false, description: "Include the page's visible text content (default false)"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    params = %{include_text: Args.get(args, :include_text) || false}
    Browser.run(Args.get(args, :organization), "state", params)
  end
end
