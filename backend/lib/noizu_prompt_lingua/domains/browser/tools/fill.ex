defmodule NoizuPromptLingua.Domains.Browser.Tools.Fill do
  use Noizu.MCP.Server.Tool,
    name: "Browser.Fill",
    description: "Fill an input or textarea in the local browser, located by CSS selector.",
    category: "Browser"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :selector, :string, required: true, description: "CSS selector of the input to fill"
    field :value, :string, required: true, description: "Value to type into the input"
  end

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    Browser.run(Args.get(args, :organization), "fill", %{
      selector: Args.get(args, :selector),
      value: Args.get(args, :value)
    })
  end
end
