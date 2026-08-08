defmodule NoizuPromptLingua.Domains.Browser.Tools.Navigate do
  use Noizu.MCP.Server.Tool,
    name: "Browser.Navigate",
    description: "Navigate the local browser to a URL and return the resulting url and title.",
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :url, :string, required: true, description: "Absolute URL to navigate to"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    Browser.run(Args.get(args, :organization), "navigate", %{url: Args.get(args, :url)})
  end
end
