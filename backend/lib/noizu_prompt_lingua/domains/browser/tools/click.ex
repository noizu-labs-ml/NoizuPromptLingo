defmodule NoizuPromptLingua.Domains.Browser.Tools.Click do
  use Noizu.MCP.Server.Tool,
    name: "Browser.Click",
    description: "Click an element in the local browser, located by CSS selector.",
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :selector, :string, required: true, description: "CSS selector of the element to click"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    Browser.run(Args.get(args, :organization), "click", %{selector: Args.get(args, :selector)})
  end
end
